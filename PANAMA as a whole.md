In this file I will describe (or refer to other files to do so) the way that our project functions. 

PANAMA as it stands is built on a few different toolchains:
- CFU-Playground (CFU-Playground-Setup.md)
	- amaranth-yosys (we don't really use but Tutorial has us install it.)
	- a toolchain (we use vivado via `bass module load vitis/2020.2`)
	- libtinfo5 (provides a package Vivado expects to see, since our newer Ubuntu provides a different package.)
	- RISC-V toolchain
- LLVM (LLVM.md)
	- LLVM16
	- Clang 16
	- other tools (install instructions in LLVM.md)

CFU-Playground lets us build SoCs using the LiteX workflow, also allowing us to add in a Custom Function Unit (CFU) so that we can accelerate specific instructions. LLVM is the tool that we will use to detect certain patterns in our source code so that we can call our offloading-compatible versions to act instead. 

### CFU-Playground

After following the instructions in CFU-Playground-Setup.md, you should be met with a menu similar to this. 

```
        __   _ __      _  __
       / /  (_) /____ | |/_/
      / /__/ / __/ -_)>  <
     /____/_/\__/\__/_/|_|
   Build your hardware, easily!

 (c) Copyright 2012-2022 Enjoy-Digital
 (c) Copyright 2007-2015 M-Labs

 BIOS built on Jul  2 2025 19:05:20
 BIOS CRC passed (b99f5fb0)

 LiteX git sha1: b9a1fec30

--=============== SoC ==================--
CPU:		VexRiscv_FullCfu @ 150MHz
BUS:		WISHBONE 32-bit @ 4GiB
CSR:		32-bit data
ROM:		128KiB
SRAM:		8KiB
L2:		8KiB
SDRAM:		1048576KiB 64-bit @ 1200MT/s (CL-9 CWL-9)

--========== Initialization ============--
Initializing SDRAM @0x40000000...
Memtest at 0x40000000 (2.0MiB)...
  Write: 0x40000000-0x40200000 2.0MiB     
   Read: 0x40000000-0x40200000 2.0MiB     
Memtest OK
Memspeed at 0x40000000 (Sequential, 2.0MiB)...
  Write speed: 132.4MiB/s
   Read speed: 109.3MiB/s

--============== Boot ==================--
Booting from serial...
Press Q or ESC to abort boot completely.
sL5DdSMmkekro
[LITEX-TERM] Received firmware download request from the device.
[LITEX-TERM] Uploading /home/asperkins42/CFU-Playground/proj/proj_template/build/software.bin to 0x40000000 (943808 bytes)...
[LITEX-TERM] Upload calibration... (inter-frame: 10.00us, length: 64)
[LITEX-TERM] Upload complete (158.6KB/s).
[LITEX-TERM] Booting the device.
[LITEX-TERM] Done.
Executing booted program at 0x40000000

--============= Liftoff! ===============--
Hello, World!

CFU Playground
==============
 1: TfLM Models menu
 2: Functional CFU Tests
 3: Project menu
 4: Performance Counter Tests
 5: TFLite Unit Tests
 6: Benchmarks
 7: Util Tests
 8: Embench IoT
 d: Donut demo
```

This menu means that LiteX is running the project code and we are in a good place. Navigating to 3 brings you to the **Project Menu** which is found in the proj_menu.cc file of whatever proj folder you are working in. (/proj/example_cfu_v/src/proj_menu.cc is a good place to start).

This is where we have been building other programs to run on the synthesized SoC. Also inside the project folder is the cfu.v file. (Again for our example found at /proj/example_cfu_v/cfu.v). These two files can work together to send instructions from the softcore CPU to be executed on the CFU. 

If we include "cfu.h" at the top of our proj_menu.cc file, we have access to a large number of custom instructions: 8 cfu_ops (cfu_op0-cfu_op7), each of these having 128 possible function codes. Each cfu_opX instruction is passed to the CFU, which determines which instruction it is via the 10 funct_id bits. Each call also passes 2 32-bit values and expects a 32-bit return. 

Using this, we can build a CFU that can accelerate specific operations when called via a certain cfu_op instruction. Our work currently uses only cfu_op0 and a handful of function codes to create a general matrix multiplication accelerator. 

One issue with this approach is the bottleneck that occurs only being able to pass 64 bits worth of information to the CFU with every cfu_op call. This is where our project comes into play. Alongside the CFU-CPU bridge ports, we instantiate an AXI Master in the cfu.v file. Then, we go back to the TARGET file declaring our SoC and allow it to pull this new AXI Master onto the build so that our CFU has **direct access** to the contents of an HBM memory region (HBM0). Some other files have to be changed, and those (along with a brief summary of the other files we have modified) can be found in the **PANAMA_vs_CFU-Playground.md** file. 

Now that our project can access HBM, we can simply point the CFU to a memory address and use the 256-bit AXI bridge to load much more data without having to pass through the Wishbone bus at all. This allows us to reference HBM addresses in our C code and cfu_op calls, and then through a little bit of localizing, the CFU and CPU will both look to the same locations. 

Now we have a system in place that can run code on the CPU, offload a function to the CFU, pull data directly from memory to compute on, and (eventually) write back data to the HBM as well. This accelerator + NMC architecture should speed up the execution of the GEMM operation. 
### LLVM

LLVM comes into play and can be described in greater detail in the LLVM.md file. Essentially, now that we have the whole end-to-end system in place for data transfers, we wanted to find a way to automatically determine if a kernel is present in the C code. We do this via an LLVM pass, which transforms the C code into an intermediate representation that shows the loop structure of the code. GEMM has a fairly identifiable loop structure, so we run a pass looking for that structure over our code. 

If we detect the presence of GEMM in the file, we are planning to dynamically offload it to our compute engine. We can pull the matrix dimensions and base addresses from the LLVM pass at the moment and are working on the dynamic replacement right now. The algorithm for dynamic matrix multiplication has been tested and seems to work in our software, so the next step is to integrate it with our replacement scheme so that when GEMM is found in software, the software version does NOT execute and instead the results are determined by our hardware-enabled CFU algorithm. 

### What's left?

* **HBM Writeback**
	* Currently reads from HBM to scratchpads work for our GEMM engine. We need to investigate the AXI handshake via LiteScope to determine why the scratchpad to HBM writes are not working.

* **Dynamic Replacement** 
	* We have our detection working, along with our code that takes in matrix bases and dimensions and schedules the tiled-GEMM computation via cfu_op commands. We just need to make it so that the proj_menu.cc file gets scanned, and the GEMM computation gets replaced with our CFU-enabled tiled-GEMM if detected. 
	  
	  
