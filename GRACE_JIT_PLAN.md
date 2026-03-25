# GRACE Compiler: JIT Behavioral Verification Pass
## Claude Code Implementation Plan

### Context

This plan extends the existing `mm_detect` LLVM pass plugin with JIT-based behavioral
GEMM verification. The goal is to move beyond structural loop-nest detection (which only
works at `-O0` and only on canonical triple-nested loops) toward the input/output testing
approach described in Iskandar et al., ACM TACO 2025 ("An End-to-End Framework for
Compiling Dense and Sparse Matrix-Vector Multiplications for FPGA-HBM Acceleration").

This directly addresses reviewer feedback on the GRACE paper (ICS 2026 #396):
- Review C: "very simple static code analysis which can only detect the canonical triple
  nested loop"
- Review D: "offloading decided only on structural patterns"
- Review B: requests quantifiable miss/hit detection statistics

**Critical constraint:** `gemm_offload.cpp` must not be modified. It represents the
original submitted work. All new code goes in new files.

---

### Repository Layout (what Claude Code can see)

```
mm_detect/
├── gemm_offload.cpp       ← READ ONLY. Do not modify.
├── CMakeLists.txt         ← needs updating
├── build/                 ← cmake build dir; run make here to verify
│   └── MatMulDetect.so
└── [new files go here]

cfu-playground-cfuaxi/proj/2_6_26/
└── build/
    ├── proj_menu.bc       ← test target (compile at -O0 if not present, see HOWTO)
    └── src/
```

Refer to `KERNEL_DETECT_HOWTO.md` for the exact clang++ invocation to regenerate
`proj_menu.bc` at `-O0` if it is not present or stale.

---

### Existing Code to Understand Before Writing Anything

Read `gemm_offload.cpp` and note the following before writing a single line of new code:

1. **`GEMMInfo` struct** — fields `L1`, `L2`, `L3`, `ABase`, `BBase`, `CBase`, `M`, `N`, `K`.
   The new pass will receive a populated `GEMMInfo` and must not redefine this struct.

2. **`detectGEMM(Loop &Top, ScalarEvolution &SE, const DataLayout &DL, GEMMInfo &Info)`**
   — this is the structural detection function. The new pass calls this as a pre-filter,
   then runs JIT confirmation on the candidates it returns.

3. **`KernelDetectPass::run(Function &F, FunctionAnalysisManager &FAM)`** — this is the
   existing detection pass entry point. The new pass (`JITKernelDetectPass`) follows the
   same `PassInfoMixin` pattern and registers under a different name (`jit-kernel-detect`).

4. **Plugin registration** at the bottom of `gemm_offload.cpp` — the new file adds its
   own pass registration in a separate `llvmGetPassPluginInfo` symbol. Since two `.so`
   files cannot both export `llvmGetPassPluginInfo`, both passes must be registered in
   the **same plugin**. See Phase 6 for how to handle this.

---

## Phase 1: New File — `jit_verify.h`

Create `mm_detect/jit_verify.h`.

This header is included by `jit_kernel_detect.cpp` only. It declares:

```cpp
#pragma once

#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include <memory>
#include <string>

struct GEMMInfo;

namespace jitverify {

struct JITVerifyResult {
  bool confirmed;      // passed T1 + T2 behavioral tests
  bool jitFailed;      // IR retargeting or LLJIT compilation error
  bool signatureBad;   // could not resolve or cast function symbol
  std::string reason;  // human-readable diagnosis for diagnostics output
};

struct TestMatrices {
  int        N;
  int       *A;   // N×N upper-triangular, row-major, i32
  int       *B;   // N×N modified identity: B[0][N-1]=1, rest standard identity, i32
  long long *C;   // N×N zero-initialized output, i64 (matches pim_gemm ABI)
};

/// Allocate and fill test matrices per MATIO Section 4.3.1.
/// Caller is responsible for calling freeTestMatrices().
TestMatrices buildTestInputs(int N);

/// Free heap memory allocated by buildTestInputs.
void freeTestMatrices(TestMatrices &tm);

/// T2 condition: |C[0][N-1] - A[0][0] - A[0][N-1]| < epsilon
/// T1 condition: trace(C) significantly differs from trace(A)+trace(B)
/// Both must pass for a confirmed GEMM.
bool checkT1T2(const TestMatrices &tm);

/// Main entry point. Clones and retargets F's parent module for the host,
/// JIT-compiles F, runs it with test matrices, and checks T1+T2.
JITVerifyResult verifyGEMMWithJIT(llvm::Function &F, GEMMInfo &Info);

} // namespace jitverify
```

---

## Phase 2: Shared Header for GEMMInfo — `gemm_types.h`

`GEMMInfo` is currently defined inside `gemm_offload.cpp` in an anonymous namespace.
To share it with `jit_kernel_detect.cpp` without modifying `gemm_offload.cpp`:

Create `mm_detect/gemm_types.h` with exactly the `GEMMInfo` struct definition copied
from `gemm_offload.cpp`. This is a deliberate, isolated duplication to preserve the
original file.

```cpp
#pragma once

#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/IR/Value.h"

struct GEMMInfo {
  llvm::Loop       *L1    = nullptr;
  llvm::Loop       *L2    = nullptr;
  llvm::Loop       *L3    = nullptr;
  llvm::Value      *ABase = nullptr;
  llvm::Value      *BBase = nullptr;
  llvm::Value      *CBase = nullptr;
  const llvm::SCEV *M     = nullptr;
  const llvm::SCEV *N     = nullptr;
  const llvm::SCEV *K     = nullptr;
};
```

**Note:** If the struct in `gemm_offload.cpp` ever diverges from this header, the
build will catch it at link time. This is acceptable — the header is a known snapshot
of the original work.

---

## Phase 3: New File — `jit_verify.cpp`

Create `mm_detect/jit_verify.cpp`.

### 3.1 Includes

```cpp
#include "jit_verify.h"
#include "gemm_types.h"

#include "llvm/ExecutionEngine/Orc/LLJIT.h"
#include "llvm/ExecutionEngine/Orc/ThreadSafeModule.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include <cmath>
#include <cstdlib>
#include <cstring>
```

### 3.2 `buildTestInputs`

Allocate and fill matrices per MATIO Section 4.3.1:
- `A`: upper-triangular N×N with small positive integers, fixed-seed xorshift32
  (seed `0xdeadbeef`) for reproducibility
- `B`: identity matrix with `B[0][N-1] = 1` (MATIO Equation 7)
- `C`: zero-initialized

Use `int` (i32) for A and B, `long long` (i64) for C to match the existing
`pim_gemm_entry_rowmajor_out` ABI.

### 3.3 `freeTestMatrices`

`delete[]` each of `tm.A`, `tm.B`, `tm.C` and null them.

### 3.4 `checkT1T2`

```
T1: |trace(C) - trace(A) - trace(B)| >= 1.0  → not addition → T1 passes
T2: |C[0][N-1] - A[0][0] - A[0][N-1]| < 2.0  → matches GEMM prediction → T2 passes
Return true only if both T1 and T2 pass.
```

Epsilon of 2.0 for T2 accounts for integer rounding. If C values are i64 and A/B
values are i32, all arithmetic should be done in `long long` to avoid overflow.

### 3.5 `retargetForHost` (file-static, not declared in header)

1. `CloneModule(Src)` into a fresh context
2. `setTargetTriple(sys::getDefaultTargetTriple())`
3. `setDataLayout(DataLayout(""))` — let LLJIT assign a host layout
4. Erase `llvm.ident` named metadata if present
5. Run `verifyModule`; return nullptr on failure

### 3.6 `verifyGEMMWithJIT`

1. Call `retargetForHost`; on failure set `jitFailed` and return
2. `LLJITBuilder().create()`; on failure set `jitFailed` and return
3. `jit->addIRModule(ThreadSafeModule(...))`; on failure set `jitFailed` and return
4. `jit->lookup(F.getName())`; on failure set `signatureBad` and return
5. Cast symbol to `void(*)(const int*, const int*, long long*, int, int, int)`
6. `buildTestInputs(8)`, invoke fn with `M=N=K=8`, `checkT1T2`, `freeTestMatrices`
7. Return result

Wrap all LLVM `Expected<>` returns with explicit error handling (not `cantFail`) so
a JIT failure never aborts the compilation process.

---

## Phase 4: New File — `jit_kernel_detect.cpp`

Create `mm_detect/jit_kernel_detect.cpp`.

This file implements `JITKernelDetectPass` and a helper `printGEMMInfo`. It does not
touch anything in `gemm_offload.cpp`.

### 4.1 `printGEMMInfo` helper

Extracts the header/matrix/size printing logic that currently lives inline in
`KernelDetectPass::run()` in `gemm_offload.cpp`. Prints using the same format as
the original pass so output is comparable.

### 4.2 `DetectionStats` struct

```cpp
struct DetectionStats {
    unsigned structuralCandidates = 0;
    unsigned jitConfirmed        = 0;
    unsigned jitRejected         = 0;
    unsigned jitFailed           = 0;
    unsigned signatureBad        = 0;

    void print(llvm::StringRef FuncName) const {
        llvm::errs() << "[jit-kernel-detect] Stats for '" << FuncName << "':\n"
                     << "  structural=" << structuralCandidates
                     << " confirmed=" << jitConfirmed
                     << " rejected="  << jitRejected
                     << " jit_err="   << jitFailed
                     << " sig_err="   << signatureBad << "\n";
    }
};
```

### 4.3 Pass option

```cpp
static llvm::cl::opt<bool> EnableJIT(
    "jit-verify",
    llvm::cl::desc("Enable JIT behavioral verification of structural GEMM candidates"),
    llvm::cl::init(true));
```

### 4.4 `JITKernelDetectPass::run()` logic

```
For each top-level loop in LI:
  Run detectGEMM() [from gemm_offload.cpp, declared extern]
  If no structural match: continue
  stats.structuralCandidates++

  If !EnableJIT:
    print STRUCTURAL result, continue

  result = verifyGEMMWithJIT(F, Info)

  If confirmed:
    stats.jitConfirmed++
    print "CONFIRMED GEMM" + GEMMInfo
  Else if jitFailed:
    stats.jitFailed++
    print "JIT ERROR: <reason>"
    print structural match as fallback (with warning label)
  Else if signatureBad:
    stats.signatureBad++
    print "SIGNATURE MISMATCH: <reason>"
  Else:
    stats.jitRejected++
    print "FALSE POSITIVE rejected: <reason>"

stats.print(F.getName())
```

### 4.5 Forward declaration for `detectGEMM`

Since `detectGEMM` is in the anonymous namespace of `gemm_offload.cpp` it is not
externally linkable. Claude Code should either:

**Option A (preferred):** Extract `detectGEMM` and its dependencies into a new
`gemm_detect.h` / `gemm_detect.cpp` pair that both `gemm_offload.cpp` and
`jit_kernel_detect.cpp` include. `gemm_offload.cpp` gets a one-line `#include
"gemm_detect.h"` added — this is the minimal possible change to the original file
and does not alter any logic.

**Option B (if Option A is rejected):** Copy `detectGEMM` and all functions it
transitively calls into `jit_kernel_detect.cpp` under its own namespace. This avoids
any touch of `gemm_offload.cpp` at the cost of duplication. Document the duplication
explicitly.

Claude Code should choose Option A if feasible and document the decision.

---

## Phase 5: New File — `plugin_registration.cpp`

Because a `.so` can only export one `llvmGetPassPluginInfo` symbol, and
`gemm_offload.cpp` already exports one, a unified registration file is needed.

Create `mm_detect/plugin_registration.cpp`:

```cpp
// Unified plugin entry point for MatMulDetect.so.
// Registers: kernel-detect, gemm-offload (from gemm_offload.cpp)
//            jit-kernel-detect           (from jit_kernel_detect.cpp)
//
// gemm_offload.cpp's llvmGetPassPluginInfo is suppressed via
// -DSUPPRESS_PLUGIN_REGISTRATION at compile time.

#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/TargetSelect.h"
#include <mutex>

// Forward declarations — defined in their respective .cpp files
void registerOriginalPasses(llvm::PassBuilder &PB);   // from gemm_offload.cpp
void registerJITPasses(llvm::PassBuilder &PB);         // from jit_kernel_detect.cpp

extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo
llvmGetPassPluginInfo() {
    static std::once_flag initFlag;
    std::call_once(initFlag, []() {
        llvm::InitializeNativeTarget();
        llvm::InitializeNativeTargetAsmPrinter();
    });

    return {LLVM_PLUGIN_API_VERSION, "MatMulDetect", "0.7",
            [](llvm::PassBuilder &PB) {
                registerOriginalPasses(PB);
                registerJITPasses(PB);
            }};
}
```

In `gemm_offload.cpp`, wrap the existing `llvmGetPassPluginInfo` with:
```cpp
#ifndef SUPPRESS_PLUGIN_REGISTRATION
extern "C" LLVM_ATTRIBUTE_WEAK ...
#endif
```
and extract the lambda body into a free function `registerOriginalPasses(PassBuilder&)`.

In `jit_kernel_detect.cpp`, implement `registerJITPasses(PassBuilder&)` that registers
`jit-kernel-detect`.

**If `gemm_offload.cpp` cannot be touched at all:** use the linker flag
`-Wl,--version-script=version.map` with a map that hides the symbol from
`gemm_offload.cpp`. Claude Code should create `mm_detect/version.map`:
```
{
  global: llvmGetPassPluginInfo;
  local: *;
};
```
and add `-Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/version.map` to
`target_link_options`. This avoids touching `gemm_offload.cpp` entirely.

---

## Phase 6: CMakeLists.txt Updates

```cmake
# Add new source files
add_llvm_library(MatMulDetect MODULE
    gemm_offload.cpp
    jit_verify.cpp
    jit_kernel_detect.cpp
    plugin_registration.cpp
)

# JIT-required LLVM components (verify availability first with llvm-config --components)
target_link_libraries(MatMulDetect
    PRIVATE
    LLVMORCJIT
    LLVMOrcTargetProcess
    LLVMExecutionEngine
    LLVMRuntimeDyld
    LLVMX86CodeGen
    LLVMX86AsmParser
    LLVMX86Desc
    LLVMX86Info
    LLVMPasses
    LLVMipo
    LLVMTransformUtils
)

# Suppress duplicate plugin entry point in gemm_offload.cpp
target_compile_definitions(MatMulDetect PRIVATE SUPPRESS_PLUGIN_REGISTRATION)
```

Before editing, run:
```bash
/auto/software/swtree/ubuntu22.04/x86_64/llvm/16.0.6/bin/llvm-config --components
```
and confirm `orcjit x86codegen x86asmparser` are present. If ORC is absent, add a
`#ifdef LLVM_ENABLE_THREADS` guard in `jit_verify.cpp` and degrade to returning
`jitFailed=true` with reason `"LLJIT not available in this LLVM build"`.

---

## Phase 7: Testing Protocol

Run from `~/cfu-playground-cfuaxi/proj/2_6_26/build/`.

### Test 1: Original pass unbroken
```fish
$LLVM/opt \
    -load-pass-plugin /home/asperkins42/mm_detect/build/MatMulDetect.so \
    -passes='function(kernel-detect)' \
    -disable-output proj_menu.bc
```
Expected: identical output to pre-change behavior.

### Test 2: JIT pass confirms known GEMMs
```fish
$LLVM/opt \
    -load-pass-plugin /home/asperkins42/mm_detect/build/MatMulDetect.so \
    -passes='function(jit-kernel-detect)' \
    -disable-output proj_menu.bc 2>&1
```
Expected: `CONFIRMED GEMM` for `gemm_kernel_i32_rm` and `gemm_loop_i32_to_i64_rm`.
Detection summary should show `jit_err=0`.

### Test 3: JIT disabled flag
```fish
$LLVM/opt \
    -load-pass-plugin /home/asperkins42/mm_detect/build/MatMulDetect.so \
    -passes='function(jit-kernel-detect)' \
    -jit-verify=false \
    -disable-output proj_menu.bc
```
Expected: `STRUCTURAL` labels, no JIT confirmation lines.

### Test 4: Behavior at -O2
Recompile `proj_menu.bc` at `-O2` (change `-O0` to `-O2` in the HOWTO clang++ command).
Run the JIT pass. Document structural vs. confirmed counts at each opt level in a comment
block at the top of `jit_kernel_detect.cpp`.

---

## File Change Summary

| File | Action | Notes |
|---|---|---|
| `gemm_offload.cpp` | Minimal touch only | Add `#ifndef SUPPRESS_PLUGIN_REGISTRATION` guard + extract `registerOriginalPasses`. If truly untouchable, use linker version script instead. |
| `gemm_types.h` | **Create** | Shared `GEMMInfo` struct |
| `gemm_detect.h` / `gemm_detect.cpp` | **Create** (Option A) | Extracted `detectGEMM` and dependencies |
| `jit_verify.h` | **Create** | JIT verifier declarations |
| `jit_verify.cpp` | **Create** | JIT verifier: retargeting, test matrices, T1/T2 |
| `jit_kernel_detect.cpp` | **Create** | `JITKernelDetectPass` + `DetectionStats` |
| `plugin_registration.cpp` | **Create** | Unified `llvmGetPassPluginInfo` |
| `version.map` | **Create** (if needed) | Linker symbol visibility script |
| `CMakeLists.txt` | **Modify** | New sources, JIT libs, compile definitions |
| `KERNEL_DETECT_HOWTO.md` | **Modify** | New pass name, output format, JIT troubleshooting |
