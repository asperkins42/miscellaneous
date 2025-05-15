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

I added `git+https://github.com/enjoy-digital/litepcie.git` to scripts/requirements.txt on my machine because the Python command was throwing an error, so I ran this command.
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
