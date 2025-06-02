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

### Running code on the LiteX core
```
asperkins42@milan3:~$ fish

Welcome to fish, the friendly interactive shell
asperkins42@milan3:~$ sfpgarun-u280 fish                                                                                                                                                                                                                   <-  7:56PM

Welcome to fish, the friendly interactive shell
asperkins42@milan3:~(fpgarun-u280)$ bass module load vitis/2020.2                                                                                                                                                                                          <-  7:56PM
asperkins42@milan3:~(fpgarun-u280)$ source .venv/bin/activate.fish                                                                                                                                                                                 <- 0s176 |  7:56PM
(litex) asperkins42@milan3:~(fpgarun-u280)$ litex_term /dev/ttyUSB2                                                                                                                                                                                <- 0s001 |  7:56PM

litex> reboot

        __   _ __      _  __
       / /  (_) /____ | |/_/
      / /__/ / __/ -_)>  <
     /____/_/\__/\__/_/|_|
   Build your hardware, easily!

 (c) Copyright 2012-2024 Enjoy-Digital
 (c) Copyright 2007-2015 M-Labs

 BIOS built on May 20 2025 22:58:18
 BIOS CRC passed (4f3804ae)

 LiteX git sha1: --------

--=============== SoC ==================--
CPU:            VexRiscv @ 150MHz
BUS:            wishbone 32-bit @ 4GiB
CSR:            32-bit data
ROM:            128.0KiB
SRAM:           8.0KiB
L2:             8.0KiB
SDRAM:          16.0GiB 64-bit @ 1200MT/s (CL-9 CWL-9)
MAIN-RAM:       1.0GiB

--========== Initialization ============--

Initializing SDRAM @0x40000000...
Switching SDRAM to software control.
Write leveling:
  tCK equivalent taps: 464
  Cmd/Clk scan (0-232)
  |0111  |00011  |00000  |00000| best: 0
  Setting Cmd/Clk delay to 0 taps.
  Data scan:
  m0: |1111111111100000000000000| delay: 00
  m1: |1111111111000000000000001| delay: 00
  m2: |1111111000000000000011111| delay: -
  m3: |1111100000000000000111111| delay: 299
  m4: |1000000000000000111111111| delay: 242
  m5: |1111110000000000000011111| delay: -
  m6: |1111111100000000000000111| delay: 00
  m7: |1111111111000000000000001| delay: 00
Write latency calibration:
m0:6 m1:6 m2:6 m3:0 m4:6 m5:6 m6:6 m7:6 
Read leveling:
  m0, b00: |00000000000000000000000000000000| delays: -
  m0, b01: |00000000000000000000000000000000| delays: -
  m0, b02: |00000000000000000000000000000000| delays: -
  m0, b03: |00000000000000000000000000000000| delays: -
  m0, b04: |11100000000000000000000000000000| delays: 21+-21
  m0, b05: |00000111111111111100000000000000| delays: 174+-97
  m0, b06: |00000000000000000000111111111111| delays: 404+-98
  m0, b07: |00000000000000000000000000000000| delays: -
  best: m0, b06 delays: 404+-100
  m1, b00: |00000000000000000000000000000000| delays: -
  m1, b01: |00000000000000000000000000000000| delays: -
  m1, b02: |00000000000000000000000000000000| delays: -
  m1, b03: |00000000000000000000000000000000| delays: -
  m1, b04: |11111110000000000000000000000000| delays: 51+-51
  m1, b05: |00000000011111111111100000000000| delays: 234+-98
  m1, b06: |00000000000000000000000011111111| delays: 443+-67
  m1, b07: |00000000000000000000000000000000| delays: -
  best: m1, b05 delays: 235+-98
  m2, b00: |00000000000000000000000000000000| delays: -
  m2, b01: |00000000000000000000000000000000| delays: -
  m2, b02: |00000000000000000000000000000000| delays: -
  m2, b03: |00000000000000000000000000000000| delays: -
  m2, b04: |11111110000000000000000000000000| delays: 54+-54
  m2, b05: |00000000001111111111110000000000| delays: 242+-98
  m2, b06: |00000000000000000000000011111111| delays: 444+-66
  m2, b07: |00000000000000000000000000000000| delays: -
  best: m2, b05 delays: 241+-98
  m3, b00: |00000000000000000000000000000000| delays: -
  m3, b01: |00000000000000000000000000000000| delays: -
  m3, b02: |00000000000000000000000000000000| delays: -
  m3, b03: |00000000000000000000000000000000| delays: -
  m3, b04: |00000000000000000000000000000000| delays: -
  m3, b05: |00000000000000000000000000000000| delays: -
  m3, b06: |00000000000000000000000000000000| delays: -
  m3, b07: |00000000000000000000000000000000| delays: -
  best: m3, b04 delays: -
  m4, b00: |00000000000000000000000000000000| delays: -
  m4, b01: |00000000000000000000000000000000| delays: -
  m4, b02: |00000000000000000000000000000000| delays: -
  m4, b03: |00000000000000000000000000000000| delays: -
  m4, b04: |00000000000000000000000000000000| delays: -
  m4, b05: |00000000000000000000000000000000| delays: -
  m4, b06: |00000000000000000000000000000000| delays: -
  m4, b07: |00000000000000000000000000000000| delays: -
  best: m4, b05 delays: -
  m5, b00: |00000000000000000000000000000000| delays: -
  m5, b01: |00000000000000000000000000000000| delays: -
  m5, b02: |00000000000000000000000000000000| delays: -
  m5, b03: |00000000000000000000000000000000| delays: -
  m5, b04: |01111111111111000000000000000000| delays: 108+-103
  m5, b05: |00000000000000001111111111110000| delays: 345+-98
  m5, b06: |00000000000000000000000000000001| delays: 498+-13
  m5, b07: |00000000000000000000000000000000| delays: -
  best: m5, b04 delays: 107+-104
  m6, b00: |00000000000000000000000000000000| delays: -
  m6, b01: |00000000000000000000000000000000| delays: -
  m6, b02: |00000000000000000000000000000000| delays: -
  m6, b03: |00000000000000000000000000000000| delays: -
  m6, b04: |11111111110000000000000000000000| delays: 74+-74
  m6, b05: |00000000000011111111111100000000| delays: 283+-98
  m6, b06: |00000000000000000000000000011111| delays: 466+-45
  m6, b07: |00000000000000000000000000000000| delays: -
  best: m6, b05 delays: 284+-99
  m7, b00: |00000000000000000000000000000000| delays: -
  m7, b01: |00000000000000000000000000000000| delays: -
  m7, b02: |00000000000000000000000000000000| delays: -
  m7, b03: |00000000000000000000000000000000| delays: -
  m7, b04: |11111111000000000000000000000000| delays: 57+-57
  m7, b05: |00000000001111111111110000000000| delays: 246+-99
  m7, b06: |00000000000000000000000011111111| delays: 443+-67
  m7, b07: |00000000000000000000000000000000| delays: -
  best: m7, b05 delays: 246+-98
Switching SDRAM to hardware control.
Memtest at 0x40000000 (2.0MiB)...
  Write: 0x40000000-0x40200000 2.0MiB     
   Read: 0x40000000-0x40200000 2.0MiB     
  bus errors:  48/256
  addr errors: 0/8192
  data errors: 522250/524288
Memtest KO
Memory initialization failed

--============= Console ================--

litex> 
```

LiteX fails startup tests when trying to run the litex_term command. Uncertain why this happens, but the issue seems similar to ones that occurred when running the DE10Lite at first. Attempting to resolve by using HBM 

```
asperkins42@milan3:~$ fish

Welcome to fish, the friendly interactive shell
asperkins42@milan3:~$ sfpgarun-u280 fish                                                                                                                                                                                     <-  8:10PM

Welcome to fish, the friendly interactive shell
asperkins42@milan3:~(fpgarun-u280)$ bass module load vitis/2020.2                                                                                                                                                            <-  8:10PM
asperkins42@milan3:~(fpgarun-u280)$ python3 -m venv --prompt litex .venv                                                                                                                                             <- 0s170 |  8:10PM
asperkins42@milan3:~(fpgarun-u280)$ source .venv/bin/activate.fish                                                                                                                                                   <- 1s742 |  8:10PM
(litex) asperkins42@milan3:~(fpgarun-u280)$ python3 -m litex_boards.targets.xilinx_alveo_u280 --build --load --with-hbm --sys-clk-freq 50e6
```
After running the Python command shown at the end of the last block, I uploaded the app.bin file to see if it would run on the HBM-enabled FPGA and this is the result. It uploaded and booted, but I think there are some error in alignment and so the program didn't execute properly. Looking into this currently.
```
(litex) asperkins42@milan3:~(fpgarun-u280)$ litex_term /dev/ttyUSB2 --kernel litex-setup-de10lite/software/app.bin                                                                                               <- 1m 59s481 |  8:30PM

litex> reboot

        __   _ __      _  __
       / /  (_) /____ | |/_/
      / /__/ / __/ -_)>  <
     /____/_/\__/\__/_/|_|
   Build your hardware, easily!

 (c) Copyright 2012-2024 Enjoy-Digital
 (c) Copyright 2007-2015 M-Labs

 BIOS built on Jun  2 2025 00:10:39
 BIOS CRC passed (79c923db)

 LiteX git sha1: --------

--=============== SoC ==================--
CPU:            VexRiscv @ 250MHz
BUS:            wishbone 32-bit @ 4GiB
CSR:            32-bit data
ROM:            128.0KiB
SRAM:           8.0KiB
MAIN-RAM:       256.0MiB

--========== Initialization ============--

Memtest at 0x40000000 (2.0MiB)...
  Write: 0x40000000-0x40200000 2.0MiB     
   Read: 0x40000000-0x40200000 2.0MiB     
Memtest OK
Memspeed at 0x40000000 (Sequential, 2.0MiB)...
  Write speed: 52.8MiB/s
   Read speed: 20.4MiB/s

--============== Boot ==================--
Booting from serial...
Press Q or ESC to abort boot completely.
sL5DdSMmkekro
[LITEX-TERM] Received firmware download request from the device.
[LITEX-TERM] Uploading litex-setup-de10lite/software/app.bin to 0x40000000 (13816 bytes)...
[LITEX-TERM] Upload calibration... (inter-frame: 10.00us, length: 64)
[LITEX-TERM] Upload complete (9.8KB/s).
[LITEX-TERM] Booting the device.
[LITEX-TERM] Done.
Executing booted program at 0x40000000

--============= Liftoff! ===============--
```
