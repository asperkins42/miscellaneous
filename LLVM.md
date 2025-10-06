NOTE: Most of these notes are a direct result of reading Miguel Young’s blog post [“A Gentle Introduction to LLVM IR.”](https://mcyoung.xyz/2023/08/01/llvm-ir/)

# LLVM to offload/detect kernel presence

LLVM is a set of software components that are used in building compilers. The flagship product of LLVM is Clang, the C/C++ compiler. The general flow when using clang looks like this. 

.c → AST → IR → Assembly

C code is parsed into an [Abstract Syntax Tree](https://www.lenovo.com/us/en/glossary/ast/?orgRef=https%253A%252F%252Fwww.google.com%252F) (AST), which is a hierarchical representation of the code’s structure. It abstracts away details like punctuation and formatting, leaving only the essential elements of the code’s structure. 

The AST is then lowered. This consists of rewriting more complex semantic constructs in terms of simpler ones (for example, ‘while’ and ‘foreach’ loops can be rewritten in terms of ‘for’ loops). This means that the rest of the code only has to deal with the smaller, simpler building blocks, as opposed to more complex ones.

At this point, we have our Intermediate Representation, IR. (AST is also one of these, I think). This IR is then run through an optimizer (which is what LLVM often refers to), and finally, after it is fully optimized, it is compiled into machine code.

# Setting Up LLVM

```
# get and install clang and llvm
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 16
sudo apt update
sudo apt install clang-16 llvm-16 llvm-16-dev lld-16

# sanity checks to make sure everything is installed properly
clang-16 --version              
opt-16 --version
llvm-config-16 --version

# make a simple project
mkdir -p ~/mm_detect/{build,sample}
cd ~/mm_detect

# in mm_detect place CMakeLists.txt, kernel_detect.cpp
#    mm_detect/sample/mm.c    <--- other kernel files go here, this is where the program will check kernels.

# build the plugin
cd ~/mm_detect/build
cmake -DLLVM_DIR=/usr/lib/llvm-16/lib/cmake/llvm ..
make -j
# -> produces ./MatMulDetect.so

# run detector with opt-16 on IR
clang-16 -O1 -c -emit-llvm ../sample/mm.c -o mm.bc
opt-16 -load-pass-plugin ./MatMulDetect.so -passes="matmul-detect" -disable-output mm.bc 
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

# Source Files

CMakeLists.txt
```
cmake_minimum_required(VERSION 3.13)

# Use whichever compilers worked for you (g++ or clang++)
# If clang++ gave you trouble, leave CMAKE_CXX_COMPILER as g++.
set(CMAKE_C_COMPILER clang-16)
set(CMAKE_CXX_COMPILER g++)  # or clang++-16 if you prefer and it works

project(MatMulDetect LANGUAGES C CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(LLVM 16 REQUIRED CONFIG PATHS /usr/lib/llvm-16/lib/cmake/llvm)
message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION} in ${LLVM_DIR}")
list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
include(HandleLLVMOptions)

# Important: tell LLVM CMake to link the shared libLLVM if available
set(LLVM_LINK_LLVM_DYLIB ON)

add_library(MatMulDetect SHARED ../matmul_detect.cpp)
set_target_properties(MatMulDetect PROPERTIES PREFIX "")

target_include_directories(MatMulDetect PRIVATE ${LLVM_INCLUDE_DIRS})
target_compile_definitions(MatMulDetect PRIVATE ${LLVM_DEFINITIONS})

# Link ONLY the monolithic shared LLVM; do NOT list component libs
target_link_libraries(MatMulDetect PRIVATE LLVM)
```
