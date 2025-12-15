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
