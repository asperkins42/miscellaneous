NOTE: Most of these notes are a direct result of reading Miguel Young’s blog post [“A Gentle Introduction to LLVM IR.”](https://mcyoung.xyz/2023/08/01/llvm-ir/)

# LLVM to offload/detect kernel presence

LLVM is a set of software components that are used in building compilers. The flagship product of LLVM is Clang, the C/C++ compiler. The general flow when using clang looks like this. 

.c → AST → IR → Assembly

C code is parsed into an [Abstract Syntax Tree](https://www.lenovo.com/us/en/glossary/ast/?orgRef=https%253A%252F%252Fwww.google.com%252F) (AST), which is a hierarchical representation of the code’s structure. It abstracts away details like punctuation and formatting, leaving only the essential elements of the code’s structure. 

The AST is then lowered. This consists of rewriting more complex semantic constructs in terms of simpler ones (for example, ‘while’ and ‘foreach’ loops can be rewritten in terms of ‘for’ loops). This means that the rest of the code only has to deal with the smaller, simpler building blocks, as opposed to more complex ones.

At this point, we have our Intermediate Representation, IR. (AST is also one of these, I think). This IR is then run through an optimizer (which is what LLVM often refers to), and finally, after it is fully optimized, it is compiled into machine code.

# Setting Up LLVM

```
1. Install LLVM 16 + Clang 16 + tools
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 16
sudo apt update
sudo apt install -y clang-16 llvm-16 llvm-16-dev lld-16 cmake build-essential

# sanity check
clang-16 --version
opt-16 --version
llvm-config-16 --version

2. Create a simple project layout
mkdir -p ~/mm_detect/{build,sample}
cd ~/mm_detect

# File structure should be like this -- see below for CMakeLists.txt, mm.c, kernel_detect.cpp
# mm_detect/
#  ├── CMakeLists.txt          ← build config
#  ├── kernel_detect.cpp       ← your LLVM pass
#  ├── sample/
#  │    ├── mm.c               ← matrix multiply test
#  │    ├── conv2d_valid.c     ← optional 2-D convolution test
#  │    └── ...
#  └── build/                  ← build output

3. Build LLVM pass plugin
cd ~/mm_detect/build
cmake -DLLVM_DIR=/usr/lib/llvm-16/lib/cmake/llvm ..
make -j$(nproc)
# Result: MatMulDetect.so

4. Generate LLVM IR (.bc) and run the pass.
# compile to LLVM bitcode
clang-16 -O1 -c -emit-llvm ../sample/mm.c -o mm.bc

# run the detector
opt-16 -load-pass-plugin ./MatMulDetect.so -passes="kernel-detect" -disable-output mm.bc

# should see something like
[kernel-detect] GEMM in 'mm'
  headers: L1=%17 L2=%23 L3=%34

# optional: add 'detect-kernels' as a makefile target for integration (still need to work on this)
detect-kernels:
	clang-16 -O1 -c -emit-llvm proj_menu.cc -o proj_menu.bc
	opt-16 -load-pass-plugin ./MatMulDetect.so -passes="kernel-detect" -disable-output proj_menu.bc
```

# LLVM in our project

So, my code operates on the Intermediate Representations. The C++ (kernel_detect.cpp) program I have compiled the .c code into .bc (an IR format) and parsed through it, looking to see if the patterns we are checking for are detected. I misunderstood how it worked the other day. The C++ file can determine if kernels are present based on the structure of the LLVM IR code and send that information back to the make process. 

This is the basic kernel_detect.cpp file. I’ll break it down bit by bit to help us both understand it. 
```
#include "llvm/ADT/SmallVector.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/PassManager.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;
using namespace llvm::PatternMatch;
```
This first section just pulls in a bunch of helpful includes from the installed LLVM module. 

### LLVM ON MILAN3

Very similar to the one above. Modified CMakeLists.txt, and the commands are slightly different. Also, we need to load multiple modules, not just the vitis one (doubt we even really NEED that one, it just is ingrained in my mind that we do.)

```

asperkins42@milan3:~$ fish
Welcome to fish, the friendly interactive shell

asperkins42@milan3:~$ bass module load llvm/16.0.6                                                                                                                      
Note Well: This is a binary distribution originally built for Ubuntu 22.04.
Caveat Executor.

asperkins42@milan3:~$ bass module load vitis/2020.2                                                                                                                     
Note: This is a binary distribution originally built for Ubuntu 22.04.
Caveat Executor.

asperkins42@milan3:~$ bass module load cmake/4.1.1                                                                                                                      

asperkins42@milan3:~$ source ~/likelyImportant/source-me.fish                                                                                                           

✅ Environment loaded:
  Vivado:       /auto/software/swtree/ubuntu22.04/x86_64/Xilinx/Vivado/2020.2/bin/vivado
  Vitis:        /auto/software/swtree/ubuntu22.04/x86_64/Xilinx/Vitis/2020.2/bin/vitis
  XRT:          /opt/xilinx/xrt/bin/xbutil
  RISC-V GCC:   /home/asperkins42/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-gcc

  Amaranth:     found at /home/asperkins42/CFU-Playground/amaranth/lib/python3.12/site-packages/amaranth/__init__.py
  Yosys:        /usr/bin/yosys

.
.
.

(amaranth) asperkins42@milan3:~/m/build$ cd ..                                                                                                                          
(amaranth) asperkins42@milan3:~/mm_detect$ rm -rf build                                                                                                                 
(amaranth) asperkins42@milan3:~/mm_detect$ mkdir build && cd build                                                                                                      
(amaranth) asperkins42@milan3:~/m/build$ CC=clang CXX=clang++ cmake .. \                                                                                                
                                               -DLLVM_DIR=/auto/software/swtree/ubuntu22.04/x86_64/llvm/16.0.6/lib/cmake/llvm

(amaranth) asperkins42@milan3:~/m/build$ make -j$(nproc)                                                                                                                
(amaranth) asperkins42@milan3:~/m/build$ /auto/software/swtree/ubuntu22.04/x86_64/llvm/16.0.6/bin/clang \                                                               
                                               -O1 -c -emit-llvm ../sample/main.c -o main.bc

(amaranth) asperkins42@milan3:~/m/build$ /auto/software/swtree/ubuntu22.04/x86_64/llvm/16.0.6/bin/opt \                                                                 
                                               -load-pass-plugin ./MatMulDetect.so \
                                               -passes='kernel-detect' \
                                               -disable-output main.bc

[kernel-detect] GEMM in 'main'
  headers: L1=%19 L2=%21 L3=%31
  matrices: A=%2 B=%1 C=%3
  sizes: M=100 N=100 K=100

.
.
.

# IN THE CFU PLAYGROUND DIRECTORY NOW, TO USE WITH proj_menu.cc

(amaranth) asperkins42@milan3:~/cfu-playground-cfuaxi (main +*%)$ $LLVM/clang++ -O1 -c -emit-llvm \                                                                                   1 ↵ <- 0s105 |  8:01PM
                                                                        -std=gnu++14 -Wno-register -Wno-error=register \
                                                                        --target=riscv32-unknown-elf -march=rv32im -mabi=ilp32 -D__vexriscv__ \
                                                                        --gcc-toolchain=$GCC_TOOLCHAIN --sysroot=$GCC_TOOLCHAIN/riscv64-unknown-elf \
                                                                        -I$REPO/third_party/python/litex/litex/soc/software/include \
                                                                        -I$REPO/third_party/python/litex/litex/soc/software/libbase \
                                                                        -I$REPO/third_party/python/litex/litex/soc/cores/cpu/vexriscv \
                                                                        -I$SOC_BUILD/include -I$SOC_BUILD/include/libc \
                                                                        -I$REPO/proj/common \
                                                                        -I$REPO/proj/11_30/src \
                                                                        -I$REPO/proj/11_30/build/src \
                                                                        -include $SOC_BUILD/libc/picolibc.h \
                                                                        -nostdlib -fno-builtin -ffunction-sections -fdata-sections \
                                                                        $REPO/proj/11_30/src/proj_menu.cc -o proj_menu.bc

(amaranth) asperkins42@milan3:~/cfu-playground-cfuaxi (main +*%)$ /auto/software/swtree/ubuntu22.04/x86_64/llvm/16.0.6/bin/opt \                                                          <- 0s243 |  8:01PM
                                                                        -load-pass-plugin ./MatMulDetect.so \
                                                                        -passes='kernel-detect' \
                                                                        -disable-output proj_menu.bc

(amaranth) asperkins42@milan3:~/cfu-playground-cfuaxi (main +*%)$ /auto/software/swtree/ubuntu22.04/x86_64/llvm/16.0.6/bin/opt \                                                      1 ↵ <- 0s057 |  8:03PM
                                                                        -load-pass-plugin ../mm_detect/build/MatMulDetect.so \
                                                                        -passes='kernel-detect' \
                                                                        -disable-output proj_menu.bc

[kernel-detect] No GEMM/Conv2D in 'do_proj_menu'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_111prompt_uintEPKcjPj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_114check_sp1_tileEjjPKc'
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_119run_host_gemm_benchEi'
  headers: L1=%121 L2=%124 L3=%134
  matrices: A=_ZN12_GLOBAL__N_16g_B_rmE B=_ZN12_GLOBAL__N_16g_A_rmE C=_ZN12_GLOBAL__N_17g_C_refE
  sizes: M=%0 N=%0 K=%0
```

# Source Files

CMakeLists.txt
```
cmake_minimum_required(VERSION 3.13)
project(KernelDetect LANGUAGES C CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(LLVM 16 REQUIRED CONFIG PATHS /usr/lib/llvm-16/lib/cmake/llvm)
list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
include(HandleLLVMOptions)
include(AddLLVM)

add_library(MatMulDetect SHARED ../kernel_detect.cpp)
set_target_properties(MatMulDetect PROPERTIES PREFIX "")

target_include_directories(MatMulDetect PRIVATE ${LLVM_INCLUDE_DIRS})
target_compile_definitions(MatMulDetect PRIVATE ${LLVM_DEFINITIONS})

llvm_map_components_to_libnames(LLVM_LIBS
  Core Support Analysis TransformUtils ScalarOpts Passes IRReader
)
target_link_libraries(MatMulDetect PRIVATE ${LLVM_LIBS})
```

mm.c 
```
#include <stddef.h>
void mm(float *A, float *B, float *C, int M, int N, int K) {
  for(int i=0;i<M;i++)
    for(int j=0;j<N;j++){
      float acc=0.0f;
      for(int k=0;k<K;k++)
        acc += A[(size_t)i*K + k] * B[(size_t)k*N + j];
      C[(size_t)i*N + j] = acc;
    }
}
```

### CURRENT LLVM INFORMATION

```
asperkins42@milan3:~$ bass module load vitis/2020.2                                                                                            
asperkins42@milan3:~$ bass module load llvm/16.0.6                                  
asperkins42@milan3:~$ cd cfu-playground-cfuaxi/proj/1_10_26/                                                                                   
asperkins42@milan3:~/c/p/1_10_26 (main +*%)$ source ~/likelyImportant/source-me.fish                                                           

✅ Environment loaded:
  Vivado:       /auto/software/swtree/ubuntu22.04/x86_64/Xilinx/Vivado/2020.2/bin/vivado
  Vitis:        /auto/software/swtree/ubuntu22.04/x86_64/Xilinx/Vitis/2020.2/bin/vitis
  XRT:          /opt/xilinx/xrt/bin/xbutil
  RISC-V GCC:   /home/asperkins42/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-gcc

  Amaranth:     found at /home/asperkins42/CFU-Playground/amaranth/lib/python3.12/site-packages/amaranth/__init__.py
  Yosys:        /usr/bin/yosys

asperkins42@milan3:~$ bass module load cmake/4.1.1    

(amaranth) asperkins42@milan3:~/c/p/1_10_26 (main +*%)$ set LLVM /auto/software/swtree/ubuntu22.04/x86_64/llvm/16.0.6/bin                      
                                                        set REPO $HOME/cfu-playground-cfuaxi
                                                        set SOC_BUILD $REPO/soc/build/xilinx_alveo_u280.1_10_26/software
```

At this point, I was getting an error using the old compilation command, so I ran `make load ... V=1` to get the exact command the Makefile uses to compile proj_menu.cc into proj_menu.o. I adjust this command slightly to produce proj_menu.bc instead, and can then run the LLVM pass on this new .bc file. 

```
(amaranth) asperkins42@milan3:~/c/p/1_10_26 (main +*%)$ rm -f proj_menu.bc                                                                                                                <- 0s014 |  3:23AM

                                                        /auto/software/swtree/ubuntu22.04/x86_64/llvm/16.0.6/bin/clang++ \
                                                              -c -emit-llvm src/proj_menu.cc -o proj_menu.bc \
                                                              --target=riscv32-unknown-elf -march=rv32im -mabi=ilp32 \
                                                              -DREPLACE_NAME_=proj_menu -D__vexriscv__ -DPLACEHOLDER -DINCLUDE_MODEL_PDTI8 \
                                                              -DPLATFORM_common_soc -DPLATFORM=common_soc \
                                                              -Isrc -I$REPO/proj/common \
                                                              -Isrc/third_party/gemmlowp -Isrc/third_party/flatbuffers/include \
                                                              -Isrc/third_party/ruy -Isrc/third_party/kissfft \
                                                              -I/home/asperkins42/cfu-playground-cfuaxi/soc/build/xilinx_alveo_u280.1_10_26/software/include \
                                                              -I/home/asperkins42/cfu-playground-cfuaxi/soc/build/xilinx_alveo_u280.1_10_26/software/libc \
                                                              -I/home/asperkins42/cfu-playground-cfuaxi/third_party/python/pythondata-software-picolibc/pythondata_software_picolibc/data/newlib/libc/include \
                                                              -I/home/asperkins42/cfu-playground-cfuaxi/third_party/python/litex/litex/soc/software/include \
                                                              -I/home/asperkins42/cfu-playground-cfuaxi/third_party/python/litex/litex/soc/cores/cpu/vexriscv \
                                                              -I/home/asperkins42/cfu-playground-cfuaxi/third_party/python/litex/litex/soc/cores/cpu/serv \
                                                              -ffunction-sections -fdata-sections -fno-common -fomit-frame-pointer -ffreestanding \
                                                              -Wsign-compare -Wdouble-promotion -Wshadow -Wunused-variable \
                                                              -Wno-missing-field-initializers -Wunused-function -Wno-maybe-uninitialized \
                                                              -Wswitch -Wvla \
                                                              -DTF_LITE_STATIC_MEMORY -DTF_LITE_USE_GLOBAL_CMATH_FUNCTIONS \
                                                              -DTF_LITE_USE_GLOBAL_MIN -DTF_LITE_USE_GLOBAL_MAX -DTF_LITE_DISABLE_X86_NEON \
                                                              -g -O3 -fno-builtin -std=c++11 -fstrict-aliasing -fno-rtti -fno-exceptions \
                                                              -fno-threadsafe-statics -fmessage-length=0 -Wall -Wextra -Wstrict-aliasing \
                                                              -Wno-unused-parameter

warning: unknown warning option '-Wno-maybe-uninitialized'; did you mean '-Wno-uninitialized'? [-Wunknown-warning-option]
src/proj_menu.cc:1:10: fatal error: 'cstdint' file not found
#include <cstdint>
         ^~~~~~~~~
1 warning and 1 error generated.


```
### LLVM setup on milan3
This produces `proj_menu.bc` in the root project directory `1_10_26`.  

This documents the minimal, working command sequence to go from a fresh `fish` shell to verified LLVM bitcode for `proj_menu.cc`. The goal is to produce `proj_menu.bc` so LLVM passes can be run over the CFU project menu code.

Start an interactive fish shell, load LLVM, and source the project environment so the RISC-V GCC toolchain is available. LLVM is used for bitcode generation, while the GCC toolchain supplies the sysroot and C++ headers.

    fish
    bass module load llvm/16.0.6
    source ~/likelyImportant/source-me.fish

Point explicitly to the LLVM binaries and the RISC-V GCC toolchain, then query the sysroot from GCC. The sysroot and C++ include paths are required so Clang can find standard headers such as <cstdint> while targeting bare-metal RISC-V.

    set LLVM /auto/software/swtree/ubuntu22.04/x86_64/llvm/16.0.6/bin
    set GCC_TOOLCHAIN /home/asperkins42/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14
    set SYSROOT ($GCC_TOOLCHAIN/bin/riscv64-unknown-elf-gcc -print-sysroot)
    set CXXINC $GCC_TOOLCHAIN/riscv64-unknown-elf/include/c++/10.1.0

Change into the project build directory (where `src/proj_menu.cc` and the copied headers such as `cfu.h` live). The compilation must be run from this directory so `-Isrc` resolves correctly.

    cd ~/c/p/1/build

Invoke Clang to emit LLVM bitcode. The key details are:
- `-emit-llvm` produces `.bc` instead of an object file
- `--target=riscv32-unknown-elf`, `-march`, and `-mabi` match the firmware build
- `--gcc-toolchain` and `--sysroot` let Clang reuse the RISC-V GCC headers
- `-std=gnu++14` and `-Wno-register` are required because LiteX RISC-V macros still use `register`
- `-ffreestanding -nostdlib` match the embedded build environment
```
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
      -O3
```
Verify that the output exists and is valid LLVM IR bitcode. The file is written to the current working directory (`build/`), not `build/src/`.

    ls -lh proj_menu.bc
    file proj_menu.bc

Expected output will identify the file as “LLVM IR bitcode”. Optionally, disassemble it to human-readable LLVM IR to confirm correctness.

    $LLVM/llvm-dis proj_menu.bc -o - | head

If the above command prints LLVM IR, the bitcode is valid and ready to be used with `opt` or custom LLVM passes.

To run the LLVM pass over the proj_menu.bc file, navigate into the 1_XX_26/build directory and run this command
```
/auto/software/swtree/ubuntu22.04/x86_64/llvm/16.0.6/bin/opt \
  -load-pass-plugin ../mm_detect/build/MatMulDetect.so \
  -passes='function(kernel-detect)' \
  -disable-output proj_menu.bc
```

### Running on U280

```
(amaranth) asperkins42@milan3:~/c/p/1/build (main +*%)$ $LLVM/clang++ -emit-llvm -c src/proj_menu.cc -o proj_menu.bc \                                                                    <- 0s036 |  8:47PM
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
                                                              -O0

(amaranth) asperkins42@milan3:~/c/p/1/build (main +*%)$ /auto/software/swtree/ubuntu22.04/x86_64/llvm/16.0.6/bin/opt \                                                                    <- 0s114 |  8:47PM
                                                              -load-pass-plugin ../../../../mm_detect/build/MatMulDetect.so \
                                                              -passes='function(kernel-detect)' \
                                                              -disable-output proj_menu.bc

[kernel-detect] GEMM in '_ZN12_GLOBAL__N_123gemm_loop_i32_to_i64_rmEPKiS1_Pxiii'
  headers: L1=%17 L2=%22 L3=%27
  matrices: A=%13 B=%12 C=%14
  sizes: M=<unknown> N=<unknown> K=<unknown>
[kernel-detect] No GEMM/Conv2D in 'pim_gemm_entry_rowmajor_out'
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_118gemm_kernel_i32_rmEPVKiS1_PVxiii'
  headers: L1=%17 L2=%22 L3=%27
  matrices: A=%13 B=%12 C=%14
  sizes: M=<unknown> N=<unknown> K=<unknown>
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_114is_32b_alignedEPKv'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_114is_64b_alignedEPKv'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_124ptr_in_cfu_reachable_hbmEPKv'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_148convert_AB_rowmajor_to_tilemajor_inplace_using_CEPVjS1_S1_j'
[kernel-detect] No GEMM/Conv2D in '_ZL16flush_cpu_dcachev'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_118gemm_tilemajor_cfuEjjjjjjb'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_124tilemajor_to_rowmajor_16EPVKyPVyj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_111copy_dwordsEPVyPVKyj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_18fence_ioEv'
[kernel-detect] No GEMM/Conv2D in 'pim_gemm_entry'
[kernel-detect] No GEMM/Conv2D in 'do_proj_menu'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_116read_menu_choiceEv'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_118do_seed_hbm_regionEv'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_123do_seed_identity_matrixEv'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_122do_seed_32x32_matricesEv'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_118do_load_scratchpadEv'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_110do_run_macEv'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_112do_clear_sp2Ev'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_118do_run_tiled_32x32Ev'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_119do_write_sp2_to_hbmEv'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_118do_dump_scratchpadEv'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_114do_cpu_hexdumpEv'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_121do_run_stripped_32x32Ev'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_115do_host_gemm_32Ev'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_115do_host_gemm_64Ev'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_116do_host_gemm_128Ev'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_116do_host_gemm_256Ev'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_116do_host_gemm_512Ev'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_117do_host_gemm_1024Ev'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_117do_host_gemm_2048Ev'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_117do_probe_hbm_spanEv'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_129do_seed_rowmajor_power32_menuEv'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_127do_convert_row_to_tile_menuEv'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_135do_print_tilemajor_schedule_after_TEv'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_128do_run_cfu_gemm_after_T_menuEv'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_124do_bench_end_to_end_menuEv'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_122do_full_rank_gemm_testEv'
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_124do_demo_linear_bias_reluEv'
  headers: L1=%66 L2=%71 L3=%76
  matrices: A=%15 B=%1 C=%16
  sizes: M=<unknown> N=<unknown> K=<unknown>
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_112do_demo_mlp2Ev'
  headers: L1=%247 L2=%252 L3=%257
  matrices: A=%32 B=%1 C=%33
  sizes: M=<unknown> N=<unknown> K=<unknown>
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_112do_demo_mlp2Ev'
  headers: L1=%139 L2=%144 L3=%149
  matrices: A=%22 B=%1 C=%23
  sizes: M=<unknown> N=<unknown> K=<unknown>
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_117do_demo_attentionEv'
  headers: L1=%162 L2=%167 L3=%172
  matrices: A=%23 B=%1 C=%24
  sizes: M=<unknown> N=<unknown> K=<unknown>
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_117do_demo_attentionEv'
  headers: L1=%98 L2=%103 L3=%108
  matrices: A=%16 B=%1 C=%17
  sizes: M=<unknown> N=<unknown> K=<unknown>
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_118do_demo_covarianceEv'
  headers: L1=%112 L2=%117 L3=%122
  matrices: A=%18 B=%1 C=%19
  sizes: M=<unknown> N=<unknown> K=<unknown>
[kernel-detect] Conv2D in '_ZN12_GLOBAL__N_124do_demo_pack_gemm_unpackEv'
  headers: L1=%324 L2=%329 L3=%343 L4=%347
[kernel-detect] Conv2D in '_ZN12_GLOBAL__N_124do_demo_pack_gemm_unpackEv'
  headers: L1=%258 L2=%263 L3=%277 L4=%281
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_124do_demo_pack_gemm_unpackEv'
  headers: L1=%202 L2=%207 L3=%212
  matrices: A=%30 B=%1 C=%31
  sizes: M=<unknown> N=<unknown> K=<unknown>
[kernel-detect] Conv2D in '_ZN12_GLOBAL__N_124do_demo_pack_gemm_unpackEv'
  headers: L1=%116 L2=%121 L3=%135 L4=%139
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_112ceil_div_u32Ejj'
[kernel-detect] No GEMM/Conv2D in '_ZL17perf_get_mcycle64v'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_113report_statusEPKcj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_110tile_indexEjjj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_113cfu_load_tileEjjj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_117tile_base_addr_abEjj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_116tile_base_addr_cEjj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_111to_cfu_addrEj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_116status_to_stringEj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_119cfu_load_scratchpadEjj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_121tile_base_addr_strideEjjj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_124rowmajor_to_tilemajor_16EPVKjPVjj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_110copy_wordsEPVjPVKjj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_110zero_wordsEPVjj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_114load_u64_wordsEPVKjj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_115store_u64_wordsEPVjjy'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_112discard_lineEv'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_112prompt_hex32EPKcPj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_113hexdump_wordsEjj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_117prompt_scratchpadEPj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_111prompt_uintEPKcjPj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_124check_sp0_against_a_tileEjPKc'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_114check_sp1_tileEjjPKc'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_124check_sp2_against_a_tileEjPKc'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_119cfu_peek_scratchpadEjj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_121dump_scratchpad_rangeEjjj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_119run_host_gemm_benchEi'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_123to_tile_major_16x16_i32EPKiPiii'
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_120gemm_tiled_tilemajorEPKiS1_Piiii'
  headers: L1=%50 L2=%67 L3=%94
  matrices: A=%17 B=%14 C=%18
  sizes: M=<unknown> N=<unknown> K=<unknown>
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_125from_tile_major_16x16_i32EPKiPiii'
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_114gemm_referenceEPKiS1_Piiii'
  headers: L1=%17 L2=%22 L3=%27
  matrices: A=%13 B=%11 C=%14
  sizes: M=<unknown> N=<unknown> K=<unknown>
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_19gemm_tileEPKiS1_Piiiiiii'
  headers: L1=%23 L2=%28 L3=%41
  matrices: A=%20 B=%17 C=%19
  sizes: M=<unknown> N=<unknown> K=<unknown>
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_122prompt_dim_power_of_32EPj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_127seed_rowmajor_count_id_zeroEjj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_119is_power_of_two_u32Ej'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_135schedule_tiled_gemm_tilemajor_printEjjjjjj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_120check_output_genericEjjjPKc'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_134gemm_reference_check_tilemajor_i64EPVKiS1_PVKxjjjPKc'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_115print_cycles_usEPKcy'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_116cycles_to_us_u64Ey'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_126fill_i32_diag_dominant_hbmEPVijji'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_128rowmajor_to_tilemajor_16_i64EPVKxPVxj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_120compare_i64_matricesEPVKxS1_jPKc'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_110xorshift32ERj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_117alloc_demo_regionEjPjS0_S0_S0_j'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_112fill_i32_hbmEPVijj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_125add_bias_relu_i64_inplaceEPVxPVKijj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_116checksum_i64_hbmEPVKxj'
[kernel-detect] No GEMM/Conv2D in '_ZN12_GLOBAL__N_123row_normalize_proxy_i32EPVKiPVijj'
```
Adjusted the pass a little and ran the gemm_offload function pass as well for replacement. Adjustments made to the way sizes are calculated so that they are no longer unknown. Added a fallback calculation method for if SCEV does not work. 
```
(amaranth) asperkins42@milan3:~/c/p/1/build (main +*%)$ $LLVM/clang++ -emit-llvm -c src/proj_menu.cc -o proj_menu_O0_nolsr.bc \                                                           <- 0s015 |  9:39PM
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
                                                              -O0 -Xclang -disable-O0-optnone \
                                                              -fno-vectorize -fno-slp-vectorize \
                                                              -fno-unroll-loops


(amaranth) asperkins42@milan3:~/c/p/1/build (main +*%)$ /auto/software/swtree/ubuntu22.04/x86_64/llvm/16.0.6/bin/opt \                                       <- 0s066 |  9:31PM
                                                              -load-pass-plugin ../../../../mm_detect/build/MatMulDetect.so \
                                                              -passes='function(mem2reg,loop-simplify,loop-rotate,indvars,lcssa),function(kernel-detect,gemm-offload)' \
                                                              -S -o /tmp/proj_menu_offload.ll proj_menu_O0_nolsr.bc

[kernel-detect] GEMM in '_ZN12_GLOBAL__N_123gemm_loop_i32_to_i64_rmEPKiS1_Pxiii'
  headers: L1=%8 L2=%10 L3=%12
  matrices: A=%0 B=%1 C=%2
  sizes: M=%3 N=%4 K=%5
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_123gemm_loop_i32_to_i64_rmEPKiS1_Pxiii
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_123gemm_loop_i32_to_i64_rmEPKiS1_Pxiii'
  [gemm-offload] >>> Inserted pim_gemm_entry() and bypassed GEMM loop.
[kernel-detect] No GEMM in 'pim_gemm_entry_rowmajor_out'
[gemm-offload] Visiting function: pim_gemm_entry_rowmajor_out
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_118gemm_kernel_i32_rmEPVKiS1_PVxiii'
  headers: L1=%8 L2=%10 L3=%12
  matrices: A=%0 B=%1 C=%2
  sizes: M=%3 N=%4 K=%5
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_118gemm_kernel_i32_rmEPVKiS1_PVxiii
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_118gemm_kernel_i32_rmEPVKiS1_PVxiii'
  [gemm-offload] >>> Inserted pim_gemm_entry() and bypassed GEMM loop.
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_114is_32b_alignedEPKv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_114is_32b_alignedEPKv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_114is_64b_alignedEPKv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_114is_64b_alignedEPKv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_124ptr_in_cfu_reachable_hbmEPKv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_124ptr_in_cfu_reachable_hbmEPKv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_148convert_AB_rowmajor_to_tilemajor_inplace_using_CEPVjS1_S1_j'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_148convert_AB_rowmajor_to_tilemajor_inplace_using_CEPVjS1_S1_j
[kernel-detect] No GEMM in '_ZL16flush_cpu_dcachev'
[gemm-offload] Visiting function: _ZL16flush_cpu_dcachev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_118gemm_tilemajor_cfuEjjjjjjb'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_118gemm_tilemajor_cfuEjjjjjjb
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_124tilemajor_to_rowmajor_16EPVKyPVyj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_124tilemajor_to_rowmajor_16EPVKyPVyj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_111copy_dwordsEPVyPVKyj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_111copy_dwordsEPVyPVKyj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_18fence_ioEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_18fence_ioEv
[kernel-detect] No GEMM in 'pim_gemm_entry'
[gemm-offload] Visiting function: pim_gemm_entry
[kernel-detect] No GEMM in 'do_proj_menu'
[gemm-offload] Visiting function: do_proj_menu
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_116read_menu_choiceEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_116read_menu_choiceEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_118do_seed_hbm_regionEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_118do_seed_hbm_regionEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_123do_seed_identity_matrixEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_123do_seed_identity_matrixEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_122do_seed_32x32_matricesEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_122do_seed_32x32_matricesEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_118do_load_scratchpadEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_118do_load_scratchpadEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_110do_run_macEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_110do_run_macEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_112do_clear_sp2Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_112do_clear_sp2Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_118do_run_tiled_32x32Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_118do_run_tiled_32x32Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_119do_write_sp2_to_hbmEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_119do_write_sp2_to_hbmEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_118do_dump_scratchpadEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_118do_dump_scratchpadEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_114do_cpu_hexdumpEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_114do_cpu_hexdumpEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_121do_run_stripped_32x32Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_121do_run_stripped_32x32Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_115do_host_gemm_32Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_115do_host_gemm_32Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_115do_host_gemm_64Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_115do_host_gemm_64Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_116do_host_gemm_128Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_116do_host_gemm_128Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_116do_host_gemm_256Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_116do_host_gemm_256Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_116do_host_gemm_512Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_116do_host_gemm_512Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_117do_host_gemm_1024Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_117do_host_gemm_1024Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_117do_host_gemm_2048Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_117do_host_gemm_2048Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_117do_probe_hbm_spanEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_117do_probe_hbm_spanEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_129do_seed_rowmajor_power32_menuEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_129do_seed_rowmajor_power32_menuEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_127do_convert_row_to_tile_menuEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_127do_convert_row_to_tile_menuEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_135do_print_tilemajor_schedule_after_TEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_135do_print_tilemajor_schedule_after_TEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_128do_run_cfu_gemm_after_T_menuEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_128do_run_cfu_gemm_after_T_menuEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_124do_bench_end_to_end_menuEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_124do_bench_end_to_end_menuEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_122do_full_rank_gemm_testEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_122do_full_rank_gemm_testEv
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_124do_demo_linear_bias_reluEv'
  headers: L1=%46 L2=%49 L3=%52
  matrices: A=%16 B=%18 C=%20
  sizes: M=%83 N=%78 K=%69
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_124do_demo_linear_bias_reluEv
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_124do_demo_linear_bias_reluEv'
  [gemm-offload] No (A,B,C,M,N,K) arg signature; using detected bases + SCEV.
  [gemm-offload] >>> Inserted pim_gemm_entry() and bypassed GEMM loop.
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_112do_demo_mlp2Ev'
  headers: L1=%167 L2=%170 L3=%173
  matrices: A=%34 B=%37 C=%32
  sizes: M=%204 N=%199 K=%190
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_112do_demo_mlp2Ev'
  headers: L1=%89 L2=%92 L3=%95
  matrices: A=%28 B=%30 C=%32
  sizes: M=%126 N=%121 K=%112
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_112do_demo_mlp2Ev
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_112do_demo_mlp2Ev'
  [gemm-offload] No (A,B,C,M,N,K) arg signature; using detected bases + SCEV.
  [gemm-offload] >>> Inserted pim_gemm_entry() and bypassed GEMM loop.
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_112do_demo_mlp2Ev'
  [gemm-offload] No (A,B,C,M,N,K) arg signature; using detected bases + SCEV.
  [gemm-offload] >>> Inserted pim_gemm_entry() and bypassed GEMM loop.
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_117do_demo_attentionEv'
  headers: L1=%110 L2=%113 L3=%116
  matrices: A=%37 B=%30 C=%28
  sizes: M=%147 N=%142 K=%133
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_117do_demo_attentionEv'
  headers: L1=%65 L2=%68 L3=%71
  matrices: A=%24 B=%26 C=%33
  sizes: M=%103 N=%98 K=%88
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_117do_demo_attentionEv
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_117do_demo_attentionEv'
  [gemm-offload] No (A,B,C,M,N,K) arg signature; using detected bases + SCEV.
  [gemm-offload] >>> Inserted pim_gemm_entry() and bypassed GEMM loop.
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_117do_demo_attentionEv'
  [gemm-offload] C store is not i64; skipping.
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_118do_demo_covarianceEv'
  headers: L1=%73 L2=%76 L3=%79
  matrices: A=%25 B=%23 C=%27
  sizes: M=%110 N=%105 K=%96
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_118do_demo_covarianceEv
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_118do_demo_covarianceEv'
  [gemm-offload] No (A,B,C,M,N,K) arg signature; using detected bases + SCEV.
  [gemm-offload] >>> Inserted pim_gemm_entry() and bypassed GEMM loop.
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_124do_demo_pack_gemm_unpackEv'
  headers: L1=%106 L2=%109 L3=%112
  matrices: A=%24 B=%26 C=%28
  sizes: M=%143 N=%138 K=%129
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_124do_demo_pack_gemm_unpackEv
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_124do_demo_pack_gemm_unpackEv'
  [gemm-offload] No (A,B,C,M,N,K) arg signature; using detected bases + SCEV.
  [gemm-offload] >>> Inserted pim_gemm_entry() and bypassed GEMM loop.
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_112ceil_div_u32Ejj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_112ceil_div_u32Ejj
[kernel-detect] No GEMM in '_ZL17perf_get_mcycle64v'
[gemm-offload] Visiting function: _ZL17perf_get_mcycle64v
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_113report_statusEPKcj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_113report_statusEPKcj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_110tile_indexEjjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_110tile_indexEjjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_113cfu_load_tileEjjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_113cfu_load_tileEjjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_117tile_base_addr_abEjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_117tile_base_addr_abEjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_116tile_base_addr_cEjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_116tile_base_addr_cEjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_111to_cfu_addrEj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_111to_cfu_addrEj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_116status_to_stringEj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_116status_to_stringEj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_119cfu_load_scratchpadEjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_119cfu_load_scratchpadEjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_121tile_base_addr_strideEjjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_121tile_base_addr_strideEjjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_124rowmajor_to_tilemajor_16EPVKjPVjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_124rowmajor_to_tilemajor_16EPVKjPVjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_110copy_wordsEPVjPVKjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_110copy_wordsEPVjPVKjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_110zero_wordsEPVjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_110zero_wordsEPVjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_114load_u64_wordsEPVKjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_114load_u64_wordsEPVKjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_115store_u64_wordsEPVjjy'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_115store_u64_wordsEPVjjy
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_112discard_lineEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_112discard_lineEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_112prompt_hex32EPKcPj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_112prompt_hex32EPKcPj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_113hexdump_wordsEjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_113hexdump_wordsEjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_117prompt_scratchpadEPj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_117prompt_scratchpadEPj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_111prompt_uintEPKcjPj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_111prompt_uintEPKcjPj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_124check_sp0_against_a_tileEjPKc'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_124check_sp0_against_a_tileEjPKc
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_114check_sp1_tileEjjPKc'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_114check_sp1_tileEjjPKc
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_124check_sp2_against_a_tileEjPKc'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_124check_sp2_against_a_tileEjPKc
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_119cfu_peek_scratchpadEjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_119cfu_peek_scratchpadEjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_121dump_scratchpad_rangeEjjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_121dump_scratchpad_rangeEjjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_119run_host_gemm_benchEi'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_119run_host_gemm_benchEi
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_123to_tile_major_16x16_i32EPKiPiii'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_123to_tile_major_16x16_i32EPKiPiii
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_120gemm_tiled_tilemajorEPKiS1_Piiii'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_120gemm_tiled_tilemajorEPKiS1_Piiii
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_125from_tile_major_16x16_i32EPKiPiii'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_125from_tile_major_16x16_i32EPKiPiii
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_114gemm_referenceEPKiS1_Piiii'
  headers: L1=%8 L2=%10 L3=%12
  matrices: A=%0 B=%1 C=%2
  sizes: M=%3 N=%5 K=%4
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_114gemm_referenceEPKiS1_Piiii
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_114gemm_referenceEPKiS1_Piiii'
  [gemm-offload] C store is not i64; skipping.
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_19gemm_tileEPKiS1_Piiiiiii'
  headers: L1=%11 L2=%13 L3=%19
  matrices: A=%0 B=%1 C=%2
  sizes: M=%3 N=%5 K=%4
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_19gemm_tileEPKiS1_Piiiiiii
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_19gemm_tileEPKiS1_Piiiiiii'
  [gemm-offload] C store is not i64; skipping.
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_122prompt_dim_power_of_32EPj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_122prompt_dim_power_of_32EPj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_127seed_rowmajor_count_id_zeroEjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_127seed_rowmajor_count_id_zeroEjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_119is_power_of_two_u32Ej'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_119is_power_of_two_u32Ej
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_135schedule_tiled_gemm_tilemajor_printEjjjjjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_135schedule_tiled_gemm_tilemajor_printEjjjjjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_120check_output_genericEjjjPKc'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_120check_output_genericEjjjPKc
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_134check_tilemajor_c_equals_a_via_cfuEjjjPKc'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_134check_tilemajor_c_equals_a_via_cfuEjjjPKc
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_115print_cycles_usEPKcy'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_115print_cycles_usEPKcy
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_116cycles_to_us_u64Ey'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_116cycles_to_us_u64Ey
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_126fill_i32_diag_dominant_hbmEPVijji'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_126fill_i32_diag_dominant_hbmEPVijji
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_128rowmajor_to_tilemajor_16_i64EPVKxPVxj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_128rowmajor_to_tilemajor_16_i64EPVKxPVxj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_120compare_i64_matricesEPVKxS1_jPKc'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_120compare_i64_matricesEPVKxS1_jPKc
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_110xorshift32ERj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_110xorshift32ERj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_117alloc_demo_regionEjPjS0_S0_S0_j'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_117alloc_demo_regionEjPjS0_S0_S0_j
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_112fill_i32_hbmEPVijj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_112fill_i32_hbmEPVijj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_125add_bias_relu_i64_inplaceEPVxPVKijj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_125add_bias_relu_i64_inplaceEPVxPVKijj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_116checksum_i64_hbmEPVKxj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_116checksum_i64_hbmEPVKxj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_123row_normalize_proxy_i32EPVKiPVijj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_123row_normalize_proxy_i32EPVKiPVijj
(amaranth) asperkins42@milan3:~/c/p/1/build (main +*%)$ grep -n "pim_gemm_entry" /tmp/proj_menu_offload.ll                                                   <- 0s101 |  9:32PM
80:@.str = private unnamed_addr constant [32 x i8] c"[pim_gemm]   In pim_gemm_entry!\00", align 1
309:  call void @pim_gemm_entry(ptr %0, ptr %1, ptr %2, i32 %3, i32 %4, i32 %5)
386:define dso_local void @pim_gemm_entry_rowmajor_out(ptr noundef %0, ptr noundef %1, ptr noundef %2, i32 noundef %3, i32 noundef %4, i32 noundef %5) #1 {
516:  call void @pim_gemm_entry(ptr %0, ptr %1, ptr %2, i32 %3, i32 %4, i32 %5)
947:define dso_local void @pim_gemm_entry(ptr noundef %0, ptr noundef %1, ptr noundef %2, i32 noundef %3, i32 noundef %4, i32 noundef %5) #1 {
2613:  call void @pim_gemm_entry(ptr %16, ptr %18, ptr %20, i32 %bound.ld, i32 %bound.ld19, i32 %bound.ld20)
2856:  call void @pim_gemm_entry(ptr %28, ptr %30, ptr %32, i32 %bound.ld67, i32 %bound.ld68, i32 %bound.ld69)
3018:  call void @pim_gemm_entry(ptr %34, ptr %37, ptr %32, i32 %bound.ld, i32 %bound.ld65, i32 %bound.ld66)
3357:  call void @pim_gemm_entry(ptr %37, ptr %30, ptr %28, i32 %bound.ld, i32 %bound.ld37, i32 %bound.ld38)
3591:  call void @pim_gemm_entry(ptr %25, ptr %23, ptr %27, i32 %bound.ld, i32 %bound.ld48, i32 %bound.ld49)
3961:  call void @pim_gemm_entry(ptr %24, ptr %26, ptr %28, i32 %bound.ld, i32 %bound.ld72, i32 %bound.ld73)
(amaranth) asperkins42@milan3:~/c/p/1/build (main +*%)$ sed -n 'define .*do_demo_linear_bias_relu/,/}/p' /tmp/proj_menu_offload.ll  | grep -n "pim_gemm_entry"
sed: -e expression #1, char 2: extra characters after command
(amaranth) asperkins42@milan3:~/c/p/1/build (main +*%)$ sed -n '/define .*do_demo_linear_bias_relu/,/}/p' /tmp/proj_menu_offload.ll  | grep -n "pim_gemm_entry"
79:  call void @pim_gemm_entry(ptr %16, ptr %18, ptr %20, i32 %bound.ld, i32 %bound.ld19, i32 %bound.ld20)
(amaranth) asperkins42@milan3:~/c/p/1/build (main +*%)$ sed -n '/define .*do_demo_mlp2/,/}/p' /tmp/proj_menu_offload.ll  | grep -n "pim_gemm_entry"          <- 0s018 |  9:36PM
143:  call void @pim_gemm_entry(ptr %28, ptr %30, ptr %32, i32 %bound.ld67, i32 %bound.ld68, i32 %bound.ld69)
305:  call void @pim_gemm_entry(ptr %34, ptr %37, ptr %32, i32 %bound.ld, i32 %bound.ld65, i32 %bound.ld66)
(amaranth) asperkins42@milan3:~/c/p/1/build (main +*%)$ sed -n '/define .*do_demo_attention/,/}/p' /tmp/proj_menu_offload.ll  | grep -n "pim_gemm_entry"     <- 0s019 |  9:36PM
194:  call void @pim_gemm_entry(ptr %37, ptr %30, ptr %28, i32 %bound.ld, i32 %bound.ld37, i32 %bound.ld38)
(amaranth) asperkins42@milan3:~/c/p/1/build (main +*%)$ sed -n '/define .*do_demo_covariance/,/}/p' /tmp/proj_menu_offload.ll  | grep -n "pim_gemm_entry"    <- 0s016 |  9:36PM
137:  call void @pim_gemm_entry(ptr %25, ptr %23, ptr %27, i32 %bound.ld, i32 %bound.ld48, i32 %bound.ld49)
(amaranth) asperkins42@milan3:~/c/p/1/build (main +*%)$ sed -n '/define .*do_demo_pack_gemm_unpack/,/}/p' /tmp/proj_menu_offload.ll  | grep -n "pim_gemm_entry"
184:  call void @pim_gemm_entry(ptr %24, ptr %26, ptr %28, i32 %bound.ld, i32 %bound.ld72, i32 %bound.ld73)
(amaranth) asperkins42@milan3:~/c/p/1/build (main +*%)$ grep -n -B6 -A6 "call void @pim_gemm_entry" /tmp/proj_menu_offload.ll                                <- 0s021 |  9:37PM
303-; Function Attrs: mustprogress noinline nounwind
304-define internal void @_ZN12_GLOBAL__N_123gemm_loop_i32_to_i64_rmEPKiS1_Pxiii(ptr noundef %0, ptr noundef %1, ptr noundef %2, i32 noundef %3, i32 noundef %4, i32 noundef %5) #0 {
305-  %7 = icmp slt i32 0, %3
306-  br i1 %7, label %.lr.ph12, label %36
307-
308-.lr.ph12:                                         ; preds = %6
309:  call void @pim_gemm_entry(ptr %0, ptr %1, ptr %2, i32 %3, i32 %4, i32 %5)
310-  br label %._crit_edge13
311-
312-8:                                                ; preds = %34
313-  %.0310 = phi i32 [ %35, %34 ]
314-  %9 = icmp slt i32 0, %4
315-  br i1 %9, label %.lr.ph8, label %33
--
510-; Function Attrs: mustprogress noinline nounwind
511-define internal void @_ZN12_GLOBAL__N_118gemm_kernel_i32_rmEPVKiS1_PVxiii(ptr noundef %0, ptr noundef %1, ptr noundef %2, i32 noundef %3, i32 noundef %4, i32 noundef %5) #0 {
512-  %7 = icmp slt i32 0, %3
513-  br i1 %7, label %.lr.ph12, label %36
514-
515-.lr.ph12:                                         ; preds = %6
516:  call void @pim_gemm_entry(ptr %0, ptr %1, ptr %2, i32 %3, i32 %4, i32 %5)
517-  br label %._crit_edge13
518-
519-8:                                                ; preds = %34
520-  %.0310 = phi i32 [ %35, %34 ]
521-  %9 = icmp slt i32 0, %4
522-  br i1 %9, label %.lr.ph8, label %33
--
2607-  br i1 %45, label %.lr.ph17, label %85
2608-
2609-.lr.ph17:                                         ; preds = %42
2610-  %bound.ld = load i32, ptr %1, align 4
2611-  %bound.ld19 = load i32, ptr %1, align 4
2612-  %bound.ld20 = load i32, ptr %1, align 4
2613:  call void @pim_gemm_entry(ptr %16, ptr %18, ptr %20, i32 %bound.ld, i32 %bound.ld19, i32 %bound.ld20)
2614-  br label %._crit_edge18
2615-
2616-46:                                               ; preds = %81
2617-  %.0315 = phi i32 [ %82, %81 ]
2618-  %47 = load i32, ptr %1, align 4
2619-  %48 = icmp ult i32 0, %47
--
2850-  br i1 %88, label %.lr.ph34, label %128
2851-
2852-.lr.ph34:                                         ; preds = %85
2853-  %bound.ld67 = load i32, ptr %1, align 4
2854-  %bound.ld68 = load i32, ptr %1, align 4
2855-  %bound.ld69 = load i32, ptr %1, align 4
2856:  call void @pim_gemm_entry(ptr %28, ptr %30, ptr %32, i32 %bound.ld67, i32 %bound.ld68, i32 %bound.ld69)
2857-  br label %._crit_edge35
2858-
2859-89:                                               ; preds = %124
2860-  %.01732 = phi i32 [ %125, %124 ]
2861-  %90 = load i32, ptr %1, align 4
2862-  %91 = icmp ult i32 0, %90
--
3012-  br i1 %166, label %.lr.ph56, label %206
3013-
3014-.lr.ph56:                                         ; preds = %164
3015-  %bound.ld = load i32, ptr %1, align 4
3016-  %bound.ld65 = load i32, ptr %1, align 4
3017-  %bound.ld66 = load i32, ptr %1, align 4
3018:  call void @pim_gemm_entry(ptr %34, ptr %37, ptr %32, i32 %bound.ld, i32 %bound.ld65, i32 %bound.ld66)
3019-  br label %._crit_edge57
3020-
3021-167:                                              ; preds = %202
3022-  %.0754 = phi i32 [ %203, %202 ]
3023-  %168 = load i32, ptr %1, align 4
3024-  %169 = icmp ult i32 0, %168
--
3351-  br i1 %109, label %.lr.ph35, label %149
3352-
3353-.lr.ph35:                                         ; preds = %105
3354-  %bound.ld = load i32, ptr %1, align 4
3355-  %bound.ld37 = load i32, ptr %1, align 4
3356-  %bound.ld38 = load i32, ptr %1, align 4
3357:  call void @pim_gemm_entry(ptr %37, ptr %30, ptr %28, i32 %bound.ld, i32 %bound.ld37, i32 %bound.ld38)
3358-  br label %._crit_edge36
3359-
3360-110:                                              ; preds = %145
3361-  %.0333 = phi i32 [ %146, %145 ]
3362-  %111 = load i32, ptr %1, align 4
3363-  %112 = icmp ult i32 0, %111
--
3585-  br i1 %72, label %.lr.ph32, label %112
3586-
3587-.lr.ph32:                                         ; preds = %70
3588-  %bound.ld = load i32, ptr %1, align 4
3589-  %bound.ld48 = load i32, ptr %1, align 4
3590-  %bound.ld49 = load i32, ptr %1, align 4
3591:  call void @pim_gemm_entry(ptr %25, ptr %23, ptr %27, i32 %bound.ld, i32 %bound.ld48, i32 %bound.ld49)
3592-  br label %._crit_edge33
3593-
3594-73:                                               ; preds = %108
3595-  %.01130 = phi i32 [ %109, %108 ]
3596-  %74 = load i32, ptr %1, align 4
3597-  %75 = icmp ult i32 0, %74
--
3955-  br i1 %105, label %.lr.ph39, label %145
3956-
3957-.lr.ph39:                                         ; preds = %103
3958-  %bound.ld = load i32, ptr %1, align 4
3959-  %bound.ld72 = load i32, ptr %1, align 4
3960-  %bound.ld73 = load i32, ptr %1, align 4
3961:  call void @pim_gemm_entry(ptr %24, ptr %26, ptr %28, i32 %bound.ld, i32 %bound.ld72, i32 %bound.ld73)
3962-  br label %._crit_edge40
3963-
3964-106:                                              ; preds = %141
3965-  %.01437 = phi i32 [ %142, %141 ]
3966-  %107 = load i32, ptr %1, align 4
3967-  %108 = icmp ult i32 0, %107
(amaranth) asperkins42@milan3:~/c/p/1/build (main +*%)$ /auto/software/swtree/ubuntu22.04/x86_64/llvm/16.0.6/bin/opt \                                       <- 0s161 |  9:49PM
                                                              -load-pass-plugin ../../../../mm_detect/build/MatMulDetect.so \
                                                              -passes='function(mem2reg,loop-simplify,loop-rotate,indvars,lcssa),function(kernel-detect,gemm-offload)' \
                                                              -o proj_menu_offload.bc proj_menu_O0_nolsr.bc

[kernel-detect] GEMM in '_ZN12_GLOBAL__N_123gemm_loop_i32_to_i64_rmEPKiS1_Pxiii'
  headers: L1=%8 L2=%10 L3=%12
  matrices: A=%0 B=%1 C=%2
  sizes: M=%3 N=%4 K=%5
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_123gemm_loop_i32_to_i64_rmEPKiS1_Pxiii
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_123gemm_loop_i32_to_i64_rmEPKiS1_Pxiii'
  [gemm-offload] >>> Inserted pim_gemm_entry() and bypassed GEMM loop.
[kernel-detect] No GEMM in 'pim_gemm_entry_rowmajor_out'
[gemm-offload] Visiting function: pim_gemm_entry_rowmajor_out
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_118gemm_kernel_i32_rmEPVKiS1_PVxiii'
  headers: L1=%8 L2=%10 L3=%12
  matrices: A=%0 B=%1 C=%2
  sizes: M=%3 N=%4 K=%5
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_118gemm_kernel_i32_rmEPVKiS1_PVxiii
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_118gemm_kernel_i32_rmEPVKiS1_PVxiii'
  [gemm-offload] >>> Inserted pim_gemm_entry() and bypassed GEMM loop.
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_114is_32b_alignedEPKv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_114is_32b_alignedEPKv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_114is_64b_alignedEPKv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_114is_64b_alignedEPKv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_124ptr_in_cfu_reachable_hbmEPKv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_124ptr_in_cfu_reachable_hbmEPKv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_148convert_AB_rowmajor_to_tilemajor_inplace_using_CEPVjS1_S1_j'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_148convert_AB_rowmajor_to_tilemajor_inplace_using_CEPVjS1_S1_j
[kernel-detect] No GEMM in '_ZL16flush_cpu_dcachev'
[gemm-offload] Visiting function: _ZL16flush_cpu_dcachev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_118gemm_tilemajor_cfuEjjjjjjb'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_118gemm_tilemajor_cfuEjjjjjjb
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_124tilemajor_to_rowmajor_16EPVKyPVyj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_124tilemajor_to_rowmajor_16EPVKyPVyj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_111copy_dwordsEPVyPVKyj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_111copy_dwordsEPVyPVKyj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_18fence_ioEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_18fence_ioEv
[kernel-detect] No GEMM in 'pim_gemm_entry'
[gemm-offload] Visiting function: pim_gemm_entry
[kernel-detect] No GEMM in 'do_proj_menu'
[gemm-offload] Visiting function: do_proj_menu
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_116read_menu_choiceEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_116read_menu_choiceEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_118do_seed_hbm_regionEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_118do_seed_hbm_regionEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_123do_seed_identity_matrixEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_123do_seed_identity_matrixEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_122do_seed_32x32_matricesEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_122do_seed_32x32_matricesEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_118do_load_scratchpadEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_118do_load_scratchpadEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_110do_run_macEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_110do_run_macEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_112do_clear_sp2Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_112do_clear_sp2Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_118do_run_tiled_32x32Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_118do_run_tiled_32x32Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_119do_write_sp2_to_hbmEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_119do_write_sp2_to_hbmEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_118do_dump_scratchpadEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_118do_dump_scratchpadEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_114do_cpu_hexdumpEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_114do_cpu_hexdumpEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_121do_run_stripped_32x32Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_121do_run_stripped_32x32Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_115do_host_gemm_32Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_115do_host_gemm_32Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_115do_host_gemm_64Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_115do_host_gemm_64Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_116do_host_gemm_128Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_116do_host_gemm_128Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_116do_host_gemm_256Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_116do_host_gemm_256Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_116do_host_gemm_512Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_116do_host_gemm_512Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_117do_host_gemm_1024Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_117do_host_gemm_1024Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_117do_host_gemm_2048Ev'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_117do_host_gemm_2048Ev
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_117do_probe_hbm_spanEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_117do_probe_hbm_spanEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_129do_seed_rowmajor_power32_menuEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_129do_seed_rowmajor_power32_menuEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_127do_convert_row_to_tile_menuEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_127do_convert_row_to_tile_menuEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_135do_print_tilemajor_schedule_after_TEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_135do_print_tilemajor_schedule_after_TEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_128do_run_cfu_gemm_after_T_menuEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_128do_run_cfu_gemm_after_T_menuEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_124do_bench_end_to_end_menuEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_124do_bench_end_to_end_menuEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_122do_full_rank_gemm_testEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_122do_full_rank_gemm_testEv
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_124do_demo_linear_bias_reluEv'
  headers: L1=%46 L2=%49 L3=%52
  matrices: A=%16 B=%18 C=%20
  sizes: M=%83 N=%78 K=%69
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_124do_demo_linear_bias_reluEv
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_124do_demo_linear_bias_reluEv'
  [gemm-offload] No (A,B,C,M,N,K) arg signature; using detected bases + SCEV.
  [gemm-offload] >>> Inserted pim_gemm_entry() and bypassed GEMM loop.
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_112do_demo_mlp2Ev'
  headers: L1=%167 L2=%170 L3=%173
  matrices: A=%34 B=%37 C=%32
  sizes: M=%204 N=%199 K=%190
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_112do_demo_mlp2Ev'
  headers: L1=%89 L2=%92 L3=%95
  matrices: A=%28 B=%30 C=%32
  sizes: M=%126 N=%121 K=%112
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_112do_demo_mlp2Ev
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_112do_demo_mlp2Ev'
  [gemm-offload] No (A,B,C,M,N,K) arg signature; using detected bases + SCEV.
  [gemm-offload] >>> Inserted pim_gemm_entry() and bypassed GEMM loop.
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_112do_demo_mlp2Ev'
  [gemm-offload] No (A,B,C,M,N,K) arg signature; using detected bases + SCEV.
  [gemm-offload] >>> Inserted pim_gemm_entry() and bypassed GEMM loop.
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_117do_demo_attentionEv'
  headers: L1=%110 L2=%113 L3=%116
  matrices: A=%37 B=%30 C=%28
  sizes: M=%147 N=%142 K=%133
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_117do_demo_attentionEv'
  headers: L1=%65 L2=%68 L3=%71
  matrices: A=%24 B=%26 C=%33
  sizes: M=%103 N=%98 K=%88
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_117do_demo_attentionEv
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_117do_demo_attentionEv'
  [gemm-offload] No (A,B,C,M,N,K) arg signature; using detected bases + SCEV.
  [gemm-offload] >>> Inserted pim_gemm_entry() and bypassed GEMM loop.
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_117do_demo_attentionEv'
  [gemm-offload] C store is not i64; skipping.
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_118do_demo_covarianceEv'
  headers: L1=%73 L2=%76 L3=%79
  matrices: A=%25 B=%23 C=%27
  sizes: M=%110 N=%105 K=%96
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_118do_demo_covarianceEv
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_118do_demo_covarianceEv'
  [gemm-offload] No (A,B,C,M,N,K) arg signature; using detected bases + SCEV.
  [gemm-offload] >>> Inserted pim_gemm_entry() and bypassed GEMM loop.
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_124do_demo_pack_gemm_unpackEv'
  headers: L1=%106 L2=%109 L3=%112
  matrices: A=%24 B=%26 C=%28
  sizes: M=%143 N=%138 K=%129
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_124do_demo_pack_gemm_unpackEv
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_124do_demo_pack_gemm_unpackEv'
  [gemm-offload] No (A,B,C,M,N,K) arg signature; using detected bases + SCEV.
  [gemm-offload] >>> Inserted pim_gemm_entry() and bypassed GEMM loop.
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_112ceil_div_u32Ejj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_112ceil_div_u32Ejj
[kernel-detect] No GEMM in '_ZL17perf_get_mcycle64v'
[gemm-offload] Visiting function: _ZL17perf_get_mcycle64v
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_113report_statusEPKcj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_113report_statusEPKcj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_110tile_indexEjjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_110tile_indexEjjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_113cfu_load_tileEjjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_113cfu_load_tileEjjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_117tile_base_addr_abEjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_117tile_base_addr_abEjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_116tile_base_addr_cEjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_116tile_base_addr_cEjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_111to_cfu_addrEj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_111to_cfu_addrEj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_116status_to_stringEj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_116status_to_stringEj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_119cfu_load_scratchpadEjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_119cfu_load_scratchpadEjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_121tile_base_addr_strideEjjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_121tile_base_addr_strideEjjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_124rowmajor_to_tilemajor_16EPVKjPVjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_124rowmajor_to_tilemajor_16EPVKjPVjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_110copy_wordsEPVjPVKjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_110copy_wordsEPVjPVKjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_110zero_wordsEPVjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_110zero_wordsEPVjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_114load_u64_wordsEPVKjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_114load_u64_wordsEPVKjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_115store_u64_wordsEPVjjy'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_115store_u64_wordsEPVjjy
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_112discard_lineEv'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_112discard_lineEv
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_112prompt_hex32EPKcPj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_112prompt_hex32EPKcPj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_113hexdump_wordsEjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_113hexdump_wordsEjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_117prompt_scratchpadEPj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_117prompt_scratchpadEPj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_111prompt_uintEPKcjPj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_111prompt_uintEPKcjPj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_124check_sp0_against_a_tileEjPKc'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_124check_sp0_against_a_tileEjPKc
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_114check_sp1_tileEjjPKc'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_114check_sp1_tileEjjPKc
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_124check_sp2_against_a_tileEjPKc'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_124check_sp2_against_a_tileEjPKc
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_119cfu_peek_scratchpadEjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_119cfu_peek_scratchpadEjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_121dump_scratchpad_rangeEjjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_121dump_scratchpad_rangeEjjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_119run_host_gemm_benchEi'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_119run_host_gemm_benchEi
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_123to_tile_major_16x16_i32EPKiPiii'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_123to_tile_major_16x16_i32EPKiPiii
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_120gemm_tiled_tilemajorEPKiS1_Piiii'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_120gemm_tiled_tilemajorEPKiS1_Piiii
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_125from_tile_major_16x16_i32EPKiPiii'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_125from_tile_major_16x16_i32EPKiPiii
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_114gemm_referenceEPKiS1_Piiii'
  headers: L1=%8 L2=%10 L3=%12
  matrices: A=%0 B=%1 C=%2
  sizes: M=%3 N=%5 K=%4
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_114gemm_referenceEPKiS1_Piiii
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_114gemm_referenceEPKiS1_Piiii'
  [gemm-offload] C store is not i64; skipping.
[kernel-detect] GEMM in '_ZN12_GLOBAL__N_19gemm_tileEPKiS1_Piiiiiii'
  headers: L1=%11 L2=%13 L3=%19
  matrices: A=%0 B=%1 C=%2
  sizes: M=%3 N=%5 K=%4
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_19gemm_tileEPKiS1_Piiiiiii
  [gemm-offload] GEMM-like loop detected in '_ZN12_GLOBAL__N_19gemm_tileEPKiS1_Piiiiiii'
  [gemm-offload] C store is not i64; skipping.
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_122prompt_dim_power_of_32EPj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_122prompt_dim_power_of_32EPj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_127seed_rowmajor_count_id_zeroEjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_127seed_rowmajor_count_id_zeroEjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_119is_power_of_two_u32Ej'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_119is_power_of_two_u32Ej
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_135schedule_tiled_gemm_tilemajor_printEjjjjjj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_135schedule_tiled_gemm_tilemajor_printEjjjjjj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_120check_output_genericEjjjPKc'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_120check_output_genericEjjjPKc
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_134check_tilemajor_c_equals_a_via_cfuEjjjPKc'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_134check_tilemajor_c_equals_a_via_cfuEjjjPKc
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_115print_cycles_usEPKcy'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_115print_cycles_usEPKcy
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_116cycles_to_us_u64Ey'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_116cycles_to_us_u64Ey
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_126fill_i32_diag_dominant_hbmEPVijji'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_126fill_i32_diag_dominant_hbmEPVijji
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_128rowmajor_to_tilemajor_16_i64EPVKxPVxj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_128rowmajor_to_tilemajor_16_i64EPVKxPVxj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_120compare_i64_matricesEPVKxS1_jPKc'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_120compare_i64_matricesEPVKxS1_jPKc
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_110xorshift32ERj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_110xorshift32ERj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_117alloc_demo_regionEjPjS0_S0_S0_j'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_117alloc_demo_regionEjPjS0_S0_S0_j
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_112fill_i32_hbmEPVijj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_112fill_i32_hbmEPVijj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_125add_bias_relu_i64_inplaceEPVxPVKijj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_125add_bias_relu_i64_inplaceEPVxPVKijj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_116checksum_i64_hbmEPVKxj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_116checksum_i64_hbmEPVKxj
[kernel-detect] No GEMM in '_ZN12_GLOBAL__N_123row_normalize_proxy_i32EPVKiPVijj'
[gemm-offload] Visiting function: _ZN12_GLOBAL__N_123row_normalize_proxy_i32EPVKiPVijj
(amaranth) asperkins42@milan3:~/c/p/1/build (main +*%)$ /auto/software/swtree/ubuntu22.04/x86_64/llvm/16.0.6/bin/llc \                                       <- 0s085 |  9:49PM
                                                            -filetype=obj -o proj_menu_offload.o proj_menu_offload.bc
(amaranth) asperkins42@milan3:~/c/p/1/build (main +*%)$ cp proj_menu_offload.o /home/asperkins42/cfu-playground-cfuaxi/proj/1_16_26/build/src/proj_menu.o    <- 1s467 |  9:50PM
(amaranth) asperkins42@milan3:~/c/p/1/build (main +*%)$ touch /home/asperkins42/cfu-playground-cfuaxi/proj/1_16_26/build/src/proj_menu.o                     <- 0s016 |  9:51PM
```
