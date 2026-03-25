# LLVM Kernel-Detect Pass: Build & Usage Guide

How to build `MatMulDetect.so` and run the `kernel-detect` LLVM pass to find
GEMM loop nests in compiled RISC-V bitcode.

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

## 2. Build the Pass

Do this once (or after any source change to `gemm_offload.cpp`).

```fish
cd ~/mm_detect/build

CC=clang CXX=clang++ cmake .. \
    -DLLVM_DIR=/auto/software/swtree/ubuntu22.04/x86_64/llvm/16.0.6/lib/cmake/llvm

make -j(nproc)
```

Success looks like:

```
-- Found LLVM 16.0.6 in ...
[100%] Built target MatMulDetect
```

The plugin is now at `~/mm_detect/build/MatMulDetect.so`.

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

## 4. Run the Pass

Always use an **absolute path** to `MatMulDetect.so`.  A relative path like
`../mm_detect/build/MatMulDetect.so` resolves from the shell's CWD, but
`opt` `dlopen`s it from its own working directory, which can differ — causing
the cryptic `"Failed to load passes"` error even when the file clearly exists.

```fish
$LLVM/opt \
    -load-pass-plugin /home/asperkins42/mm_detect/build/MatMulDetect.so \
    -passes='function(kernel-detect)' \
    -disable-output proj_menu.bc
```

`-disable-output` suppresses writing transformed bitcode (we only want the
diagnostic output, not a new `.bc`).

---

## 5. Reading the Output

For each function the pass prints one of two things:

```
[kernel-detect] No GEMM in 'foo'
```

or

```
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_118gemm_kernel_i32_rmEPVKiS1_PVxiii'
  headers: L1=%17 L2=%22 L3=%27
  matrices: A=%13 B=%12 C=%14
  sizes: M=%19 N=%24 K=%29
```

| Field | Meaning |
|---|---|
| `L1 / L2 / L3` | The three loop-header basic blocks (outermost → innermost) |
| `A / B / C` | LLVM SSA values for the matrix pointer arguments |
| `M / N / K` | Loop trip-count SSA values; `<unknown>` if SCEV couldn't resolve them |

Use `$LLVM/llvm-dis proj_menu.bc` and grep for the `%N` values to inspect the
surrounding IR if you need to trace a detection back to source.

---

## 6. Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `Failed to load passes … Request ignored` | Relative `.so` path, or `.so` built against a different LLVM | Use absolute path; confirm `llvm/16.0.6` loaded before `cmake`/`make` |
| `unknown function pass 'kernel-detect'` | Plugin didn't load (see above), or pass registration string mismatch | Check `registerPipelineParsingCallback` in source registers exactly `"kernel-detect"` |
| All functions report `No GEMM` | Bitcode compiled with `-O2`/`-O3` | Recompile with `-O0` |
| Trip counts all `<unknown>` at `-O0` | SCEV can't resolve through non-affine indexing | Expected for complex loop bounds; the loop *is* detected, sizes just aren't static |
| `ldd MatMulDetect.so` shows missing libs | LLVM shared libs not on `LD_LIBRARY_PATH` | `bass module load llvm/16.0.6` before running `opt` |

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

# --- (re)build pass if source changed ---
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

# --- run pass ---
$LLVM/opt \
    -load-pass-plugin /home/asperkins42/mm_detect/build/MatMulDetect.so \
    -passes='function(kernel-detect)' \
    -disable-output proj_menu.bc
```
