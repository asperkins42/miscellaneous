# LLVM Kernel-Detect Pass: Build & Usage Guide

How to build the LLVM pass plugins and detect GEMM loop nests in compiled
RISC-V bitcode.  Two plugins are provided:

| Plugin | Pass name | What it does |
|---|---|---|
| `MatMulDetect.so` | `kernel-detect` | Structural loop-nest detection only |
| `MatMulDetectJIT.so` | `jit-kernel-detect` | Structural detection **+ JIT behavioral verification** (T1/T2 tests) |

`gemm_offload.cpp` (the original submitted artifact for GRACE ICS 2026 §396)
is unchanged; the JIT plugin lives in `jit_verify.cpp` + `jit_kernel_detect.cpp`.

---

## Directory Layout (assumed)

```
~/
├── mm_detect/
│   ├── CMakeLists.txt
│   ├── gemm_offload.cpp          # pass source
│   └── build/                   # cmake build dir (create it yourself)
│
└── cfu-playground-cfuaxi/
    └── proj/2_6_26/
        └── build/
            ├── src/
            │   └── proj_menu.cc  # (or whatever translation unit you want to analyse)
            └── proj_menu.bc      # generated bitcode (you create this)
```

---

## 1. Environment Setup

These steps are specific to `milan3` with the shared software tree.  Run them
**every new shell session** before touching either the pass or the bitcode.

```fish
# fish shell
bass module load llvm/16.0.6
bass module load cmake/4.1.1

# (optional, if you use the cfu-playground source environment)
source ~/likelyImportant/source-me.fish

# Handy variables used throughout this doc
set LLVM     /auto/software/swtree/ubuntu22.04/x86_64/llvm/16.0.6/bin
set GCC_TOOLCHAIN /home/asperkins42/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14
set SYSROOT  ($GCC_TOOLCHAIN/bin/riscv64-unknown-elf-gcc -print-sysroot)
set CXXINC   $GCC_TOOLCHAIN/riscv64-unknown-elf/include/c++/10.1.0
```

---

## 2. Build the Passes

Do this once (or after any source change).

```fish
cd ~/mm_detect
mkdir -p build && cd build

# Wipe any stale cache before the first configure (clang++ vs GCC detection)
rm -rf CMakeCache.txt CMakeFiles

cmake .. && make -j(nproc)
```

Success looks like:

```
-- Found LLVM 16.0.6 in ...
[ 16%] Building libLLVMSupportNeeded.a from libLLVMSupport.a
[100%] Built target MatMulDetect
[100%] Built target MatMulDetectJIT
```

Both plugins are now at `~/mm_detect/build/`:
- `MatMulDetect.so` — original structural pass
- `MatMulDetectJIT.so` — JIT behavioral verification pass

> **Note:** CMake must use GCC 13 (system default on milan3), not clang, as the
> host compiler.  clang++-16 is not on PATH as `clang++-16`; it is available
> only as `clang++` after `bass module load llvm/16.0.6`.  If you see
> `CMAKE_CXX_COMPILER … not found`, wipe `CMakeCache.txt` and re-run `cmake ..`.

---

## 3. Compile Source to LLVM Bitcode

> **Critical:** compile at **`-O0`** (or at most `-O1`).  
> At `-O3` the optimiser inlines and vectorises the loop nest aggressively
> enough that the three canonical induction-variable loops the pass looks for
> are no longer recognisable as GEMM.

```fish
cd ~/cfu-playground-cfuaxi/proj/2_6_26/build

$LLVM/clang++ -emit-llvm -c src/proj_menu.cc -o proj_menu.bc \
    -std=gnu++14 -Wno-register \
    --target=riscv32-unknown-elf -march=rv32im -mabi=ilp32 \
    --gcc-toolchain=$GCC_TOOLCHAIN \
    --sysroot=$SYSROOT \
    -isystem $CXXINC \
    -isystem $CXXINC/riscv64-unknown-elf \
    -isystem $CXXINC/backward \
    -isystem $SYSROOT/include \
    -D__vexriscv__ -DPLACEHOLDER -DINCLUDE_MODEL_PDTI8 \
    -DPLATFORM_common_soc -DPLATFORM=common_soc \
    -Isrc \
    -Isrc/third_party/gemmlowp \
    -Isrc/third_party/flatbuffers/include \
    -Isrc/third_party/ruy \
    -Isrc/third_party/kissfft \
    -I/home/asperkins42/cfu-playground-cfuaxi/soc/build/xilinx_alveo_u280.1_10_26/software/include \
    -I/home/asperkins42/cfu-playground-cfuaxi/soc/build/xilinx_alveo_u280.1_10_26/software/libc \
    -I/home/asperkins42/cfu-playground-cfuaxi/third_party/python/pythondata-software-picolibc/pythondata_software_picolibc/data/newlib/libc/include \
    -I/home/asperkins42/cfu-playground-cfuaxi/third_party/python/litex/litex/soc/software/include \
    -I/home/asperkins42/cfu-playground-cfuaxi/third_party/python/litex/litex/soc/software/libbase \
    -I/home/asperkins42/cfu-playground-cfuaxi/third_party/python/litex/litex/soc/cores/cpu/vexriscv \
    -I/home/asperkins42/cfu-playground-cfuaxi/third_party/python/litex/litex/soc/cores/cpu/serv \
    -ffreestanding -fno-builtin -nostdlib \
    -Wno-uninitialized -Wno-unused-parameter -Wno-missing-field-initializers \
    -O0        # <-- keep this low so loop structure survives
```

Sanity-check:

```fish
file proj_menu.bc      # → LLVM IR bitcode
ls -lh proj_menu.bc    # should be non-zero
```

---

## 4. Run the Passes

Always use an **absolute or `./`-relative path** to the `.so`.  A bare
relative path resolves from `opt`'s CWD, not the shell's, causing the cryptic
`"Failed to load passes"` error.

### 4a. Structural detection only (original pass)

```fish
cd ~/mm_detect/build
$LLVM/opt \
    -load-pass-plugin ./MatMulDetect.so \
    -passes=kernel-detect \
    -disable-output ~/cfu-playground-cfuaxi/proj/2_6_26/build/proj_menu.bc
```

### 4b. JIT behavioral verification (new pass)

```fish
cd ~/mm_detect/build
$LLVM/opt \
    -load-pass-plugin ./MatMulDetectJIT.so \
    -passes=jit-kernel-detect \
    -disable-output ~/cfu-playground-cfuaxi/proj/2_6_26/build/proj_menu.bc
```

Disable JIT (structural only, same candidates as `kernel-detect`):

```fish
$LLVM/opt \
    -load-pass-plugin ./MatMulDetectJIT.so \
    -passes=jit-kernel-detect -jit-verify=false \
    -disable-output ~/cfu-playground-cfuaxi/proj/2_6_26/build/proj_menu.bc
```

`-disable-output` suppresses writing transformed bitcode.

---

## 5. Reading the Output

### kernel-detect (structural)

```
[kernel-detect] No GEMM in 'foo'
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_118gemm_kernel_i32_rmEPVKiS1_PVxiii'
  headers: L1=%17 L2=%22 L3=%27
  matrices: A=%13 B=%12 C=%14
  sizes: M=%19 N=%24 K=%29
```

### jit-kernel-detect (behavioral)

```
[jit-kernel-detect] CONFIRMED GEMM in 'gemm_loop_i32_to_i64_rm'
  [jit-kernel-detect] reason: T1+T2 behavioral checks passed
[jit-kernel-detect] Stats for 'gemm_loop_i32_to_i64_rm':
  structural=1 confirmed=1 rejected=0 jit_err=0 sig_err=0

[jit-kernel-detect] FALSE POSITIVE rejected in 'gemm_reference': T1/T2 check failed
[jit-kernel-detect] SIGNATURE MISMATCH in 'do_demo_mlp2': IR signature mismatch: …got 0 params
```

| Output tag | Meaning |
|---|---|
| `CONFIRMED GEMM` | Passed both structural and T1+T2 behavioral tests |
| `FALSE POSITIVE rejected` | Structural match but T1/T2 behavioral check failed |
| `SIGNATURE MISMATCH` | IR signature ≠ `void(ptr,ptr,ptr,int,int,int)` or symbol lookup failed |
| `JIT ERROR` | Retargeting or LLJIT compilation failed; falls back to structural match |
| `STRUCTURAL GEMM (fallback)` | JIT error but structural evidence printed anyway |

**`sig_err` in stats** counts functions rejected by the IR signature check
(wrong param count or types) — these are structural false positives where the
inner loop body looks like a GEMM but the enclosing function has a different ABI.

Use `$LLVM/llvm-dis proj_menu.bc` and grep for the `%N` values to trace a
detection back to source IR.

---

## 6. Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `Failed to load passes … Request ignored` | Relative `.so` path, or `.so` built against a different LLVM | Use `./MatMulDetect.so` from `build/`; confirm `llvm/16.0.6` loaded before `cmake`/`make` |
| `unknown pass name 'jit-kernel-detect'` | Plugin didn't load (see above) | Check `LD_DEBUG=libs opt …` for the exact undefined symbol |
| All functions report `No GEMM` | Bitcode compiled with `-O2`/`-O3` | Recompile with `-O0` |
| Trip counts all `<unknown>` at `-O0` | SCEV can't resolve non-affine bounds | Expected; loop is still detected, sizes just aren't static |
| `JIT session error: Symbols not found` | Structural GEMM in a wrapper that calls helpers (bodies deleted during retargeting) | Expected; shown as SIGNATURE MISMATCH in stats |
| `cmake … CMAKE_CXX_COMPILER not found` | Stale cache from previous `-DCMAKE_CXX_COMPILER=clang++-16` run | `rm CMakeCache.txt CMakeFiles -rf && cmake ..` |

---

## 7. Quick Reference (copy-paste session starter)

```fish
# --- environment ---
bass module load llvm/16.0.6
bass module load cmake/4.1.1
set LLVM /auto/software/swtree/ubuntu22.04/x86_64/llvm/16.0.6/bin
set GCC_TOOLCHAIN /home/asperkins42/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14
set SYSROOT ($GCC_TOOLCHAIN/bin/riscv64-unknown-elf-gcc -print-sysroot)
set CXXINC $GCC_TOOLCHAIN/riscv64-unknown-elf/include/c++/10.1.0

# --- (re)build passes if source changed ---
cd ~/mm_detect/build && make -j(nproc) && cd -

# --- compile bitcode (run from proj build dir) ---
cd ~/cfu-playground-cfuaxi/proj/2_6_26/build
$LLVM/clang++ -emit-llvm -c src/proj_menu.cc -o proj_menu.bc \
    -std=gnu++14 -Wno-register \
    --target=riscv32-unknown-elf -march=rv32im -mabi=ilp32 \
    --gcc-toolchain=$GCC_TOOLCHAIN --sysroot=$SYSROOT \
    -isystem $CXXINC -isystem $CXXINC/riscv64-unknown-elf \
    -isystem $CXXINC/backward -isystem $SYSROOT/include \
    -D__vexriscv__ -DPLACEHOLDER -DINCLUDE_MODEL_PDTI8 \
    -DPLATFORM_common_soc -DPLATFORM=common_soc \
    -Isrc -Isrc/third_party/gemmlowp \
    -Isrc/third_party/flatbuffers/include \
    -Isrc/third_party/ruy -Isrc/third_party/kissfft \
    -I/home/asperkins42/cfu-playground-cfuaxi/soc/build/xilinx_alveo_u280.1_10_26/software/include \
    -I/home/asperkins42/cfu-playground-cfuaxi/soc/build/xilinx_alveo_u280.1_10_26/software/libc \
    -I/home/asperkins42/cfu-playground-cfuaxi/third_party/python/pythondata-software-picolibc/pythondata_software_picolibc/data/newlib/libc/include \
    -I/home/asperkins42/cfu-playground-cfuaxi/third_party/python/litex/litex/soc/software/include \
    -I/home/asperkins42/cfu-playground-cfuaxi/third_party/python/litex/litex/soc/software/libbase \
    -I/home/asperkins42/cfu-playground-cfuaxi/third_party/python/litex/litex/soc/cores/cpu/vexriscv \
    -I/home/asperkins42/cfu-playground-cfuaxi/third_party/python/litex/litex/soc/cores/cpu/serv \
    -ffreestanding -fno-builtin -nostdlib \
    -Wno-uninitialized -Wno-unused-parameter -Wno-missing-field-initializers \
    -O0

# --- run structural pass (original) ---
cd ~/mm_detect/build
$LLVM/opt -load-pass-plugin ./MatMulDetect.so \
    -passes=kernel-detect -disable-output \
    ~/cfu-playground-cfuaxi/proj/2_6_26/build/proj_menu.bc

# --- run JIT behavioral pass (new) ---
$LLVM/opt -load-pass-plugin ./MatMulDetectJIT.so \
    -passes=jit-kernel-detect -disable-output \
    ~/cfu-playground-cfuaxi/proj/2_6_26/build/proj_menu.bc

# --- JIT pass, structural-only mode ---
$LLVM/opt -load-pass-plugin ./MatMulDetectJIT.so \
    -passes=jit-kernel-detect -jit-verify=false -disable-output \
    ~/cfu-playground-cfuaxi/proj/2_6_26/build/proj_menu.bc
```
