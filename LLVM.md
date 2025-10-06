NOTE: Most of these notes are a direct result of reading Miguel Young’s blog post [“A Gentle Introduction to LLVM IR.”](https://mcyoung.xyz/2023/08/01/llvm-ir/)

# LLVM to offload/detect kernel presence

LLVM is a set of software components that are used in building compilers. The flagship product of LLVM is Clang, the C/C++ compiler. The general flow when using clang looks like this. 

.c → AST → IR → Assembly
<center>This text will be centered.</center>
