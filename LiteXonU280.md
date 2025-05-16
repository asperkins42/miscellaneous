### Trying to Get RiscV core flashed to U280 using instructions from DE10Lite Tutorial

Following the DE10Lite tutorial, these are the initial commands I run
```
$ fish
$ sfpgarun-u280 fish
$ bass module load vitis
$ python3 -m venv --prompt litex .venv
$ source .venv/bin/activate.fish
$ python3 -m litex_boards.targets.xilinx_alveo_u280 --build --load
```

I added `git+https://github.com/enjoy-digital/litepcie.git` to scripts/requirements.txt because the Python command was throwing an error, so I ran this command.
`$ pip install -r scripts/requirements.txt `

At this point, I run the python3 command `$ python3 -m litex_boards.targets.xilinx_alveo_u280 --build --load` again, where it fails. Here is the error log
```
****** Vivado v2024.2 (64-bit)
  **** SW Build 5239630 on Fri Nov 08 22:34:34 MST 2024
  **** IP Build 5239520 on Sun Nov 10 16:12:51 MST 2024
  **** SharedData Build 5239561 on Fri Nov 08 14:39:27 MST 2024
  **** Start of session at: Thu May 15 12:10:21 2025
    ** Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
    ** Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.

source xilinx_alveo_u280.tcl
# create_project -force -name xilinx_alveo_u280 -part xcu280-fsvh2892-2L-e-es1
WARNING: [Device 21-436] No parts matched 'xcu280-fsvh2892-2L-e-es1'
ERROR: [Coretcl 2-106] Specified part could not be found.
INFO: [Common 17-206] Exiting Vivado at Thu May 15 12:10:32 2025...
Traceback (most recent call last):
  File "/usr/lib/python3.10/runpy.py", line 196, in _run_module_as_main
    return _run_code(code, main_globals, None,
  File "/usr/lib/python3.10/runpy.py", line 86, in _run_code
    exec(code, run_globals)
  File "/home/asperkins42/.venv/lib/python3.10/site-packages/litex_boards/targets/xilinx_alveo_u280.py", line 198, in <module>
    main()
  File "/home/asperkins42/.venv/lib/python3.10/site-packages/litex_boards/targets/xilinx_alveo_u280.py", line 188, in main
    builder.build(**parser.toolchain_argdict)
  File "/home/asperkins42/.venv/lib/python3.10/site-packages/litex/soc/integration/builder.py", line 415, in build
    vns = self.soc.build(build_dir=self.gateware_dir, **kwargs)
  File "/home/asperkins42/.venv/lib/python3.10/site-packages/litex/soc/integration/soc.py", line 1498, in build
    return self.platform.build(self, *args, **kwargs)
  File "/home/asperkins42/.venv/lib/python3.10/site-packages/litex/build/xilinx/platform.py", line 100, in build
    return self.toolchain.build(self, *args, **kwargs)
  File "/home/asperkins42/.venv/lib/python3.10/site-packages/litex/build/xilinx/vivado.py", line 141, in build
    return GenericToolchain.build(self, platform, fragment, **kwargs)
  File "/home/asperkins42/.venv/lib/python3.10/site-packages/litex/build/generic_toolchain.py", line 123, in build
    self.run_script(script)
  File "/home/asperkins42/.venv/lib/python3.10/site-packages/litex/build/xilinx/vivado.py", line 433, in run_script
    raise OSError("Error occured during Vivado's script execution.")
OSError: Error occured during Vivado's script execution.
```

At this point, I navigate to `.venv/lib/python3.10/site-packages/litex_boards/platforms/xilinx_alveo_u280.py` and edit line 228, where I remove -es1 from the XilinxUSPlatform init. At this point I re-run the Python command from earlier and it still fails. https://docs.amd.com/r/en-US/ug1314-alveo-u280-reconfig-accel/Creating-a-Vivado-RTL-Project shows that this new part number is the correct one, but https://adaptivesupport.amd.com/s/article/000036719?language=en_US says that as of Vivado 2024.1, some U280 part numbers are removed because they are end of life. Unsure where to go from here. 

### Rollback Vitis
Brett reached out and told me to use an older version of vitis via `bass module load vitis/2020.2` and then rerun the python script. I reloaded the virtual environment after making changes to the U280 script (removing `-es1`) and ran the python program again. Vivado sucessfully created the bitstream, but at this point I cannot load it onto the U280 card. It says that there are no matchine hw_targets. I ran the program again with no -build flag, just to see if I could get any more info from only trying to loat it and this is what I get.

```
(litex) asperkins42@milan3:~(fpgarun-u280)$ python3 -m litex_boards.targets.xilinx_alveo_u280 --load                          <- 3m 2s665 |  4:32PM
INFO:USMMCM:Creating USMMCM, speedgrade -2.
INFO:USMMCM:Registering Differential ClkIn of 100.00MHz.
INFO:USMMCM:Creating ClkOut0 pll4x of 600.00MHz (+-10000.00ppm).
INFO:USMMCM:Creating ClkOut1 idelay of 600.00MHz (+-10000.00ppm).
INFO:SoC:        __   _ __      _  __  
INFO:SoC:       / /  (_) /____ | |/_/  
INFO:SoC:      / /__/ / __/ -_)>  <    
INFO:SoC:     /____/_/\__/\__/_/|_|  
INFO:SoC:  Build your hardware, easily!
INFO:SoC:--------------------------------------------------------------------------------
INFO:SoC:Creating SoC... (2025-05-16 16:32:57)
INFO:SoC:--------------------------------------------------------------------------------
INFO:SoC:FPGA device : xcu280-fsvh2892-2L-e.
INFO:SoC:System clock: 150.000MHz.
INFO:SoCBusHandler:Creating Bus Handler...
INFO:SoCBusHandler:32-bit wishbone Bus, 4.0GiB Address Space.
INFO:SoCBusHandler:Adding reserved Bus Regions...
INFO:SoCBusHandler:Bus Handler created.
INFO:SoCCSRHandler:Creating CSR Handler...
INFO:SoCCSRHandler:32-bit CSR Bus, 32-bit Aligned, 16.0KiB Address Space, 2048B Paging, big Ordering (Up to 32 Locations).
INFO:SoCCSRHandler:Adding reserved CSRs...
INFO:SoCCSRHandler:CSR Handler created.
INFO:SoCIRQHandler:Creating IRQ Handler...
INFO:SoCIRQHandler:IRQ Handler (up to 32 Locations).
INFO:SoCIRQHandler:Adding reserved IRQs...
INFO:SoCIRQHandler:IRQ Handler created.
INFO:SoC:--------------------------------------------------------------------------------
INFO:SoC:Initial SoC:
INFO:SoC:--------------------------------------------------------------------------------
INFO:SoC:32-bit wishbone Bus, 4.0GiB Address Space.
INFO:SoC:32-bit CSR Bus, 32-bit Aligned, 16.0KiB Address Space, 2048B Paging, big Ordering (Up to 32 Locations).
INFO:SoC:IRQ Handler (up to 32 Locations).
INFO:SoC:--------------------------------------------------------------------------------
INFO:SoC:Controller ctrl added.
INFO:SoC:CPU vexriscv added.
INFO:SoC:CPU vexriscv adding IO Region 0 at 0x80000000 (Size: 0x80000000).
INFO:SoCBusHandler:io0 Region added at Origin: 0x80000000, Size: 0x80000000, Mode:  RW, Cached: False, Linker: False.
INFO:SoC:CPU vexriscv overriding sram mapping from 0x01000000 to 0x10000000.
INFO:SoC:CPU vexriscv setting reset address to 0x00000000.
INFO:SoC:CPU vexriscv adding Bus Master(s).
INFO:SoCBusHandler:cpu_bus0 added as Bus Master.
INFO:SoCBusHandler:cpu_bus1 added as Bus Master.
INFO:SoC:CPU vexriscv adding Interrupt(s).
INFO:SoC:CPU vexriscv adding SoC components.
INFO:SoCBusHandler:rom Region added at Origin: 0x00000000, Size: 0x00020000, Mode:  RX, Cached:  True, Linker: False.
INFO:SoCBusHandler:rom added as Bus Slave.
INFO:SoC:RAM rom added Origin: 0x00000000, Size: 0x00020000, Mode:  RX, Cached:  True, Linker: False.
INFO:SoCBusHandler:sram Region added at Origin: 0x10000000, Size: 0x00002000, Mode: RWX, Cached:  True, Linker: False.
INFO:SoCBusHandler:sram added as Bus Slave.
INFO:SoC:RAM sram added Origin: 0x10000000, Size: 0x00002000, Mode: RWX, Cached:  True, Linker: False.
INFO:SoCIRQHandler:uart IRQ allocated at Location 0.
INFO:SoCIRQHandler:timer0 IRQ allocated at Location 1.
INFO:SoCBusHandler:main_ram Region added at Origin: 0x40000000, Size: 0x40000000, Mode: RWX, Cached:  True, Linker: False.
INFO:SoCBusHandler:main_ram added as Bus Slave.
INFO:SoCBusHandler:firmware_ram Region added at Origin: 0x20000000, Size: 0x00008000, Mode: RWX, Cached:  True, Linker: False.
INFO:SoCBusHandler:firmware_ram added as Bus Slave.
INFO:SoC:RAM firmware_ram added Origin: 0x20000000, Size: 0x00008000, Mode: RWX, Cached:  True, Linker: False.

****** Vivado v2020.2 (64-bit)
  **** SW Build 3064766 on Wed Nov 18 09:12:47 MST 2020
  **** IP Build 3064653 on Wed Nov 18 14:17:31 MST 2020
    ** Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.

WARNING: 'open_hw' is deprecated, please use 'open_hw_manager' instead.
open_hw_manager
INFO: [Labtools 27-2285] Connecting to hw_server url TCP:localhost:3121
INFO: [Labtools 27-3415] Connecting to cs_server url TCP:localhost:3042
INFO: [Labtools 27-3414] Connected to existing cs_server.
ERROR: [Labtoolstcl 44-469] There is no current hw_target.
WARNING: [Labtoolstcl 44-128] No matching hw_devices were found.
ERROR: [Common 17-161] Invalid option value '' specified for 'objects'.
WARNING: [Labtoolstcl 44-128] No matching hw_devices were found.
ERROR: [Common 17-161] Invalid option value '' specified for 'objects'.
WARNING: [Labtoolstcl 44-128] No matching hw_devices were found.
ERROR: [Common 17-161] Invalid option value '' specified for 'hw_device'.
WARNING: [Labtoolstcl 44-128] No matching hw_devices were found.
ERROR: [Labtoolstcl 44-5] Could not find current or explicit device for command
INFO: [Common 17-206] Exiting Vivado at Fri May 16 16:33:10 2025...
```
