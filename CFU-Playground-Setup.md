## CFU Playground setup for ArtyA7

I began by following the [setup guide] (https://cfu-playground.readthedocs.io/en/latest/setup-guide.html) for CFU-Playground.
Step 1 was easy, given that the Arty A7 was already connected to zenith2. I setup [FoxyProxy] (https://docs.excl.ornl.gov/quick-start-guides/excl-remote-development#setup-foxyproxy) and [ThinLinc] (https://docs.excl.ornl.gov/~/revisions/tgK4OWTltCS04RkJelGW/quick-start-guides/thinlinc) so that I could access 
the GUI for zenith2. (Be sure that FoxyProxy is set to "Proxy by Pattern" and everything should work if you follow the tutorials linked.)

Step 2 is to clone the repository using `git clone https://github.com/google/CFU-Playground.git`.

Once that has been run, begin Step 3 by running `cd CFU-Playground` and run the setup script `./scripts/setup`. 

Afterward, run `pip install amaranth-yosys` to install Amaranth, which is what we will use to build CFUs. 

Step 4 involves toolchain setup. For the ArtyA7, you can use step 4a which is `make install-sf` then, when that finishes `make enter-sf`. 
When you are building the bitsream later, to use Symbiflow, you must add `USE_SYMBIFLOW` to the end of the command. 

## CFU Playground setup for Alveo U280

After cloning the repository to the milan3 node, I entered the fish terminal. Step 3 will throw a Warning saying that Vivado is not found in path if you don't load the Vitis module beforehand, so I amended the instructions in the setup to load that module beforehand. So far the execution is as follows:

```
git clone https://github.com/google/CFU-Playground.git
fish
bass module load vitis/2020.2
cd CFU-Playground
./scripts/setup
```

When I run `pip3 install amaranth-yosys`, I get an error: externally managed environment as shown below. 

```
asperkins42@milan3:~/CFU-Playground (main=)$ pip3 install amaranth-yosys                                                           <- 5s189 |  9:57PM
error: externally-managed-environment

× This environment is externally managed
╰─> To install Python packages system-wide, try apt install
    python3-xyz, where xyz is the package you are trying to
    install.
    
    If you wish to install a non-Debian-packaged Python package,
    create a virtual environment using python3 -m venv path/to/venv.
    Then use path/to/venv/bin/python and path/to/venv/bin/pip. Make
    sure you have python3-full installed.
    
    If you wish to install a non-Debian packaged Python application,
    it may be easiest to use pipx install xyz, which will manage a
    virtual environment for you. Make sure you have pipx installed.
    
    See /usr/share/doc/python3.12/README.venv for more information.

note: If you believe this is a mistake, please contact your Python installation or OS distribution provider. You can override this, at the risk of breaking your Python installation or OS, by passing --break-system-packages.
hint: See PEP 668 for the detailed specification.
```

I got around this by creating a virtual environment called "amaranth" and installed it within this venv.

```
# Create a virtual environment named "amaranth"
python3 -m venv amaranth

# Activate it
source amaranth/bin/activate.fish

# Install your package inside this venv
pip install amaranth-yosys
```

Step 4 sees the installation of a toolchain, for ArtyA7, that is Symbiflow, but it does not support the U280 so we need to use the installed Vivado instead. 

Step 5 is to install the toolchain (only necessary when using a non-Conda option). I did this by downloading [this toolchain] (https://static.dev.sifive.com/dev-tools/freedom-tools/v2020.08/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14.tar.gz) and installing it with these commands, when I get this error. 

```
(amaranth) asperkins42@milan3:~/CFU-Playground (main %=)$ tar xvfz ~/Downloads/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14.tar.gz
(amaranth) asperkins42@milan3:~/CFU-Playground (main %=)$ export PATH=$PATH:$HOME/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14/bin




Command 'date' is available in the following places
 * /bin/date
 * /usr/bin/date
The command could not be located because '/usr/bin:/bin' is not included in the PATH environment variable.
date: command not found
/etc/fish/conf.d/fish_command_timer.fish (line 1): 
date '+%s'
^~~^
in command substitution
	called on line 153 of file /etc/fish/conf.d/fish_command_timer.fish
in function 'fish_command_timer_postexec' with arguments 'export\ PATH=\$PATH:\$HOME/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14/bin\n\n\n\n'
in event handler: handler for generic event “fish_postexec”
/etc/fish/conf.d/fish_command_timer.fish (line 153): Unknown command
  set -l command_end_time (date '+%s')
                          ^~~~~~~~~~~^
in function 'fish_command_timer_postexec' with arguments 'export\ PATH=\$PATH:\$HOME/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14/bin\n\n\n\n'
in event handler: handler for generic event “fish_postexec”
Command 'date' is available in the following places
 * /bin/date
 * /usr/bin/date
The command could not be located because '/bin:/usr/bin' is not included in the PATH environment variable.
date: command not found
/etc/fish/functions/fish_right_prompt.fish (line 1): 
date "+%_I:%M%p"
^~~^
in command substitution
	called on line 7 of file /etc/fish/functions/fish_right_prompt.fish
in function 'fish_right_prompt'
in command substitution
/etc/fish/functions/fish_right_prompt.fish (line 7): Unknown command
   set -l prompt_date (date "+%_I:%M%p")
                      ^~~~~~~~~~~~~~~~~^
in function 'fish_right_prompt'
in command substitution
```

Turns out I broke the PATH because I am in the fish terminal and set a bash-style path, whoops. This was fixed by `set -e PATH` followed by `set -Ux PATH /usr/local/bin /usr/bin /bin /usr/sbin /sbin $HOME/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14/bin`

Once the PATH was fixed, I had another problem I encountered where I had installed the toolchain to the wrong directory. When I added it to path, it looked for it in the HOME directory, but I installed it to the CFU-Playground directory on accident. I moved it and then ran 4 commands as a test. 

```
(amaranth) asperkins42@milan3:~/CFU-Playground (main %=)$ which vivado                                                             <- 0s005 | 10:33PM
/auto/software/swtree/ubuntu22.04/x86_64/Xilinx/Vivado/2020.2/bin/vivado

(amaranth) asperkins42@milan3:~/CFU-Playground (main %=)$ vivado -version                                                          <- 0s004 | 10:33PM
application-specific initialization failed: couldn't load file "librdi_commontasks.so": libtinfo.so.5: cannot open shared object file: No such file or directory
% ^C⏎

(amaranth) asperkins42@milan3:~/CFU-Playground (main %=)$ which riscv64-unknown-elf-gcc                                      130 ↵ <- 3s042 | 10:33PM
/home/asperkins42/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-gcc

(amaranth) asperkins42@milan3:~/CFU-Playground (main %=)$ riscv64-unknown-elf-gcc --version                                        <- 0s005 | 10:33PM
riscv64-unknown-elf-gcc (SiFive GCC 10.1.0-2020.08.2) 10.1.0
Copyright (C) 2020 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

I troubleshot the `vivado -version` problem via ChatGPT and saw that it was because Vivado 2020.2 expects an older version of a file, while this version of Ubuntu supplies a newer file format. This is fixed via a package install. 

```
(amaranth) asperkins42@milan3:~/CFU-Playground (main %=)$ sudo apt install libtinfo5                                               <- 0s042 | 10:33PM
[sudo] password for asperkins42: 
asperkins42 is not in the sudoers file.
This incident has been reported to the administrator.
```

So sorry, Steve, I keep asking you to install packages.

libtinfo5 was installed via a `$ wget http://security.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2ubuntu0.1_amd64.deb` followed by asking Steve to install with `sudo dpkg -i libtinfo5_6.2-0ubuntu2_amd64.deb`

This got libtinfo5 installed, and let me move on to the next problem.

The earlier package amaranth-yosys expects the yosys package to already be installed, which I did not know. So, again, I asked Steve to install it, and he (or Aaron) did. 

Now, we have all of our tools installed (Amaranth, Yosys, RISCV toolchain, Vivado, and probably even more that I am forgetting). I run my check script, and it prints:

```
(amaranth) asperkins42@milan3:~/CFU-Playground (main %=)$ source ~/likelyImportant/vivado-2020.2.fish                                      <- 0s629 |  8:56PM

✅ Environment loaded:
  Vivado:       /auto/software/swtree/ubuntu22.04/x86_64/Xilinx/Vivado/2020.2/bin/vivado
  Vitis:        /auto/software/swtree/ubuntu22.04/x86_64/Xilinx/Vitis/2020.2/bin/vitis
  XRT:          /opt/xilinx/xrt/bin/xbutil
  RISC-V GCC:   /home/asperkins42/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-gcc

  Amaranth:     found at /home/asperkins42/CFU-Playground/amaranth/lib/python3.12/site-packages/amaranth/__init__.py
  Yosys:        /usr/bin/yosys
```

From this point, I run `cd proj/proj_template` and `make clean` to get the directory set up, followed by `make prog TARGET=xilinx_u280 USE_VIVADO=1`.

```
(amaranth) asperkins42@milan3:~/C/p/proj_template (main %=)$ make prog TARGET=xilinx_u280 USE_VIVADO=1                                     <- 0s043 |  9:04PM
/home/asperkins42/CFU-Playground/scripts/pyrun /home/asperkins42/CFU-Playground/proj/proj_template/cfu_gen.py 
make -C /home/asperkins42/CFU-Playground/soc -f /home/asperkins42/CFU-Playground/soc/common_soc.mk prog
make[1]: Entering directory '/home/asperkins42/CFU-Playground/soc'
Building bitstream for xilinx_u280. CFU option: --cpu-cfu /home/asperkins42/CFU-Playground/proj/proj_template/cfu.v
MAKEFLAGS=-j8 /home/asperkins42/CFU-Playground/scripts/pyrun ./common_soc.py --output-dir build/xilinx_u280.proj_template --csr-json build/xilinx_u280.proj_template/csr.json --cpu-cfu  /home/asperkins42/CFU-Playground/proj/proj_template/cfu.v --uart-baudrate 1843200 --target xilinx_u280  --toolchain vivado --build
/home/asperkins42/CFU-Playground/third_party/python/litex/litex/soc/integration/export.py:100: SyntaxWarning: invalid escape sequence '\d'
  version = float(re.findall("\d+\.\d+", l)[-1])
/home/asperkins42/CFU-Playground/third_party/python/litex/litex/soc/cores/cpu/cv32e40p/core.py:78: SyntaxWarning: invalid escape sequence '\$'
  res = re.search('\$\{DESIGN_RTL_DIR\}/(.+)', l)
/home/asperkins42/CFU-Playground/third_party/python/litex/litex/soc/cores/cpu/cv32e40p/core.py:80: SyntaxWarning: invalid escape sequence '\+'
  if re.match('\+incdir\+', l):
/home/asperkins42/CFU-Playground/third_party/python/litex/litex/soc/cores/cpu/cv32e41p/core.py:65: SyntaxWarning: invalid escape sequence '\$'
  res = re.search('\$\{DESIGN_RTL_DIR\}/(.+)', l)
/home/asperkins42/CFU-Playground/third_party/python/litex/litex/soc/cores/cpu/cv32e41p/core.py:67: SyntaxWarning: invalid escape sequence '\+'
  if re.match('\+incdir\+', l):
/home/asperkins42/CFU-Playground/third_party/python/litex/litex/soc/cores/cpu/openc906/core.py:22: SyntaxWarning: invalid escape sequence '\$'
  res = re.search('\$\{CODE_BASE_PATH\}/(.+)', l)
/home/asperkins42/CFU-Playground/third_party/python/litex/litex/soc/cores/cpu/openc906/core.py:24: SyntaxWarning: invalid escape sequence '\+'
  if re.match('\+incdir\+', l):
/home/asperkins42/CFU-Playground/third_party/python/litex/litex/soc/cores/cpu/cva6/core.py:44: SyntaxWarning: invalid escape sequence '\$'
  res = re.search('\$\{CVA6_REPO_DIR\}/(.+)', l)
/home/asperkins42/CFU-Playground/third_party/python/litex/litex/soc/cores/cpu/cva6/core.py:46: SyntaxWarning: invalid escape sequence '\+'
  if re.match('\+incdir\+', l):
Traceback (most recent call last):
  File "/home/asperkins42/CFU-Playground/soc/./common_soc.py", line 57, in <module>
    main()
  File "/home/asperkins42/CFU-Playground/soc/./common_soc.py", line 47, in main
    get_soc_constructor(args.target))
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/asperkins42/CFU-Playground/soc/./common_soc.py", line 30, in get_soc_constructor
    raise ValueError(f'Could not find "{target}" in supported boards: {s}')
ValueError: Could not find "xilinx_u280" in supported boards: adi_adrv2crr_fmc, adi_plutosdr, alchitry_au, alchitry_mojo, aliexpress_stlv7325, aliexpress_xc7k420t, alinx_ax7010, alinx_axu2cga, antmicro_datacenter_ddr4_test_board, antmicro_lpddr4_test_board, arduino_mkrvidor4000, avnet_aesku40, berkeleylab_marble, camlink_4k, colorlight_5a_75x, colorlight_i5, decklink_intensity_pro_4k, decklink_mini_4k, decklink_quad_hdmi_recorder, digilent_arty, digilent_arty_s7, digilent_arty_z7, digilent_atlys, digilent_basys3, digilent_cmod_a7, digilent_genesys2, digilent_nexys4, digilent_nexys4ddr, digilent_nexys_video, digilent_pynq_z1, digilent_zedboard, ebaz4205, efinix_t8f81_dev_kit, efinix_titanium_ti60_f225_dev_kit, efinix_trion_t120_bga576_dev_kit, efinix_trion_t20_bga256_dev_kit, efinix_trion_t20_mipi_dev_kit, efinix_xyloni_dev_kit, ego1, enclustra_mercury_kx2, enclustra_mercury_xu5, fairwaves_xtrx, fpc_iii, gsd_butterstick, gsd_orangecrab, hackaday_hadbadge, hpcstore_xc7k420t, icebreaker, icebreaker_bitsy, jungle_electronics_fireant, kosagi_fomu, kosagi_netv2, krtkl_snickerdoodle, lambdaconcept_ecpix5, lattice_crosslink_nx_evn, lattice_crosslink_nx_vip, lattice_ecp5_evn, lattice_ecp5_vip, lattice_ice40up5k_evn, lattice_versa_ecp5, limesdr_mini_v2, linsn_rv901t, litex_acorn_baseboard, logicbone, machdyne_krote, machdyne_schoko, micronova_mercury2, mist, mnt_rkx7, muselab_icesugar, muselab_icesugar_pro, myminieye_runber, numato_aller, numato_mimas_a7, numato_nereid, numato_tagus, pano_logic_g2, qmtech_10cl006, qmtech_5cefa2, qmtech_ep4cex5, qmtech_ep4cgx150, qmtech_wukong, qmtech_xc7a35t, quicklogic_quickfeather, qwertyembedded_beaglewire, radiona_ulx3s, rcs_arctic_tern_bmc_card, redpitaya, rz_easyfpga, saanlima_pipistrello, scarabhardware_minispartan6, seeedstudio_spartan_edge_accelerator, siglent_sds1104xe, simple, sipeed_tang_nano, sipeed_tang_nano_4k, sipeed_tang_nano_9k, sipeed_tang_primer, sipeed_tang_primer_20k, sqrl_acorn, sqrl_fk33, sqrl_xcu1525, taobao_a_e115fb, terasic_de0nano, terasic_de10lite, terasic_de10nano, terasic_de1soc, terasic_de2_115, terasic_deca, terasic_sockit, tinyfpga_bx, trellisboard, trenz_c10lprefkit, trenz_cyc1000, trenz_max1000, trenz_te0725, trenz_tec0117, tul_pynq_z2, xilinx_ac701, xilinx_alveo_u250, xilinx_alveo_u280, xilinx_kc705, xilinx_kcu105, xilinx_kv260, xilinx_vc707, xilinx_vcu118, xilinx_zcu102, xilinx_zcu104, xilinx_zcu106, xilinx_zcu216, xilinx_zybo_z7, ztex213
make[1]: *** [/home/asperkins42/CFU-Playground/soc/common_soc.mk:115: build/xilinx_u280.proj_template/gateware/xilinx_u280.bit] Error 1
make[1]: Leaving directory '/home/asperkins42/CFU-Playground/soc'
make: *** [../proj.mk:319: prog] Error 2
```

Well shoot. 

Turns out this is a semi-quick fix. I named the board `xilinx_u280` instead of the correct `xilinx_alveo_u280`. We'll give it another shot. 

```
(amaranth) asperkins42@milan3:~/C/p/proj_template (main %=)$ make prog TARGET=xilinx_alveo_u280 USE_VIVADO=1                                                                          2 ↵ <- 1s267 |  9:05PM
/home/asperkins42/CFU-Playground/scripts/pyrun /home/asperkins42/CFU-Playground/proj/proj_template/cfu_gen.py 
make -C /home/asperkins42/CFU-Playground/soc -f /home/asperkins42/CFU-Playground/soc/common_soc.mk prog
make[1]: Entering directory '/home/asperkins42/CFU-Playground/soc'
Building bitstream for xilinx_alveo_u280. CFU option: --cpu-cfu /home/asperkins42/CFU-Playground/proj/proj_template/cfu.v
MAKEFLAGS=-j8 /home/asperkins42/CFU-Playground/scripts/pyrun ./common_soc.py --output-dir build/xilinx_alveo_u280.proj_template --csr-json build/xilinx_alveo_u280.proj_template/csr.json --cpu-cfu  /home/asperkins42/CFU-Playground/proj/proj_template/cfu.v --uart-baudrate 1843200 --target xilinx_alveo_u280  --toolchain vivado --build
Traceback (most recent call last):
  File "/home/asperkins42/CFU-Playground/soc/./common_soc.py", line 57, in <module>
    main()
  File "/home/asperkins42/CFU-Playground/soc/./common_soc.py", line 47, in main
    get_soc_constructor(args.target))
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/asperkins42/CFU-Playground/soc/./common_soc.py", line 31, in get_soc_constructor
    module = importlib.import_module(f'litex_boards.targets.{target}')
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3.12/importlib/__init__.py", line 90, in import_module
    return _bootstrap._gcd_import(name[level:], package, level)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "<frozen importlib._bootstrap>", line 1387, in _gcd_import
  File "<frozen importlib._bootstrap>", line 1360, in _find_and_load
  File "<frozen importlib._bootstrap>", line 1331, in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 935, in _load_unlocked
  File "<frozen importlib._bootstrap_external>", line 995, in exec_module
  File "<frozen importlib._bootstrap>", line 488, in _call_with_frames_removed
  File "/home/asperkins42/CFU-Playground/third_party/python/litex_boards/litex_boards/targets/xilinx_alveo_u280.py", line 35, in <module>
    from litepcie.software import generate_litepcie_software
  File "/home/asperkins42/CFU-Playground/third_party/python/litepcie/litepcie/software/__init__.py", line 2, in <module>
    from distutils.dir_util import copy_tree
ModuleNotFoundError: No module named 'distutils'
make[1]: *** [/home/asperkins42/CFU-Playground/soc/common_soc.mk:115: build/xilinx_alveo_u280.proj_template/gateware/xilinx_alveo_u280.bit] Error 1
make[1]: Leaving directory '/home/asperkins42/CFU-Playground/soc'
make: *** [../proj.mk:319: prog] Error 2
```

Another error, looks like we're missing the module distutils now. Hopefully we won't need Steve or Aaron for this one (we will...). On this Ubuntu, distutils is moved to python3-setuptools, so we will need python3-setuptools installed. 

I asked Aaron about this and he said to just `pip install setuptools` inside of the virtual environment, which worked. Running the command again and I now get this error.

```
****** Vivado v2020.2 (64-bit)
  **** SW Build 3064766 on Wed Nov 18 09:12:47 MST 2020
  **** IP Build 3064653 on Wed Nov 18 14:17:31 MST 2020
    ** Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.

source xilinx_alveo_u280.tcl
# create_project -force -name xilinx_alveo_u280 -part xcu280-fsvh2892-2L-e-es1
WARNING: [Device 21-436] No parts matched 'xcu280-fsvh2892-2L-e-es1'
ERROR: [Coretcl 2-106] Specified part could not be found.
INFO: [Common 17-206] Exiting Vivado at Wed Jul  2 18:54:10 2025...
Traceback (most recent call last):
  File "/home/asperkins42/CFU-Playground/soc/./common_soc.py", line 57, in <module>
    main()
  File "/home/asperkins42/CFU-Playground/soc/./common_soc.py", line 53, in main
    workflow.run()
  File "/home/asperkins42/CFU-Playground/soc/board_specific_workflows/general.py", line 125, in run
    soc_builder = self.build_soc(soc)
                  ^^^^^^^^^^^^^^^^^^^
  File "/home/asperkins42/CFU-Playground/soc/board_specific_workflows/general.py", line 102, in build_soc
    soc_builder.build(run=self.args.build, **kwargs)
  File "/home/asperkins42/CFU-Playground/third_party/python/litex/litex/soc/integration/builder.py", line 357, in build
    vns = self.soc.build(build_dir=self.gateware_dir, **kwargs)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/asperkins42/CFU-Playground/third_party/python/litex/litex/soc/integration/soc.py", line 1277, in build
    return self.platform.build(self, *args, **kwargs)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/asperkins42/CFU-Playground/third_party/python/litex/litex/build/xilinx/platform.py", line 73, in build
    return self.toolchain.build(self, *args, **kwargs)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/asperkins42/CFU-Playground/third_party/python/litex/litex/build/xilinx/vivado.py", line 130, in build
    return GenericToolchain.build(self, platform, fragment, **kwargs)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/asperkins42/CFU-Playground/third_party/python/litex/litex/build/generic_toolchain.py", line 113, in build
    self.run_script(script)
  File "/home/asperkins42/CFU-Playground/third_party/python/litex/litex/build/xilinx/vivado.py", line 376, in run_script
    raise OSError("Error occured during Vivado's script execution.")
OSError: Error occured during Vivado's script execution.
make[1]: *** [/home/asperkins42/CFU-Playground/soc/common_soc.mk:115: build/xilinx_alveo_u280.proj_template/gateware/xilinx_alveo_u280.bit] Error 1
make[1]: Leaving directory '/home/asperkins42/CFU-Playground/soc'
make: *** [../proj.mk:319: prog] Error 2
```

But this is ok! I've had this error before. LiteX is only set up with the engineering sample part # for the U280. I just need to go to the platform definition for the board and fix the name of the device (remove -es1). I have done this and saved the file, now I will re-run the command. 


```
# Build

make clean TARGET=xilinx_alveo_u280
make prog TARGET=xilinx_alveo_u280 USE_VIVADO=1
```

I make clean the directory specifically related to the U280 and then run the make prog command, telling it to use Vivado. This runs all the way through, and then after the bitstream is generated, when the timing is checked, it errors out. That's ok for now, I'll fix the timing later.

Next, I run `make load TARGET=xilinx_alveo_u280 BUILD_JOBS=4 TTY=/dev/ttyUSB2` and pray that ttyUSB2 is the correct one of the three available. I need to figure out how to check them. 

Update: It looks like it was. After about 5 minutes, the kernel was loaded, and I typed `reboot` so LiteX terminal would boot with the golden tests in memory.

```
.
.
.
.
make[1]: Leaving directory '/home/asperkins42/CFU-Playground/proj/proj_template/build'
Running interactively on FPGA Board
make -C /home/asperkins42/CFU-Playground/soc -f /home/asperkins42/CFU-Playground/soc/common_soc.mk load_hook
make[1]: Entering directory '/home/asperkins42/CFU-Playground/soc'
MAKEFLAGS=-j8 /home/asperkins42/CFU-Playground/scripts/pyrun ./common_soc.py --output-dir build/xilinx_alveo_u280.proj_template --csr-json build/xilinx_alveo_u280.proj_template/csr.json --cpu-cfu  /home/asperkins42/CFU-Playground/proj/proj_template/cfu.v --uart-baudrate 1843200 --target xilinx_alveo_u280  --software-load --software-path /home/asperkins42/CFU-Playground/proj/proj_template/build/software.bin
make[1]: Leaving directory '/home/asperkins42/CFU-Playground/soc'
/home/asperkins42/CFU-Playground/soc/bin/litex_term --speed 1843200  --kernel /home/asperkins42/CFU-Playground/proj/proj_template/build/software.bin /dev/ttyUSB2
reboot
�
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
Switching SDRAM to software control.
Write leveling:
  tCK equivalent taps: 468
  Cmd/Clk scan (0-234)
  |0011  |00010  |00000  |00000| best: 0
  Setting Cmd/Clk delay to 0 taps.
  Data scan:
  m0: |1111111111100000000000000| delay: 00
  m1: |1111111111000000000000001| delay: 00
  m2: |1111111000000000000011111| delay: -
  m3: |1111100000000000000111111| delay: 299
  m4: |1100000000000000111111111| delay: 249
  m5: |1111110000000000000011111| delay: -
  m6: |1111111110000000000000111| delay: 00
  m7: |1111111111100000000000001| delay: 00
Write latency calibration:
m0:6 m1:6 m2:6 m3:0 m4:0 m5:6 m6:6 m7:6 
Read leveling:
  m0, b00: |00000000000000000000000000000000| delays: -
  m0, b01: |00000000000000000000000000000000| delays: -
  m0, b02: |00000000000000000000000000000000| delays: -
  m0, b03: |00000000000000000000000000000000| delays: -
  m0, b04: |11100000000000000000000000000000| delays: 17+-17
  m0, b05: |00000111111111111000000000000000| delays: 168+-100
  m0, b06: |00000000000000000001111111111111| delays: 401+-101
  m0, b07: |00000000000000000000000000000000| delays: -
  best: m0, b06 delays: 399+-99
  m1, b00: |00000000000000000000000000000000| delays: -
  m1, b01: |00000000000000000000000000000000| delays: -
  m1, b02: |00000000000000000000000000000000| delays: -
  m1, b03: |00000000000000000000000000000000| delays: -
  m1, b04: |11111100000000000000000000000000| delays: 47+-47
  m1, b05: |00000000011111111111100000000000| delays: 225+-94
  m1, b06: |00000000000000000000000111111111| delays: 438+-74
  m1, b07: |00000000000000000000000000000000| delays: -
  best: m1, b05 delays: 228+-95
  m2, b00: |00000000000000000000000000000000| delays: -
  m2, b01: |00000000000000000000000000000000| delays: -
  m2, b02: |00000000000000000000000000000000| delays: -
  m2, b03: |00000000000000000000000000000000| delays: -
  m2, b04: |11111110000000000000000000000000| delays: 50+-50
  m2, b05: |00000000011111111111100000000000| delays: 235+-96
  m2, b06: |00000000000000000000000011111111| delays: 441+-70
  m2, b07: |00000000000000000000000000000000| delays: -
  best: m2, b05 delays: 235+-97
  m3, b00: |00000000000000000000000000000000| delays: -
  m3, b01: |00000000000000000000000000000000| delays: -
  m3, b02: |00000000000000000000000000000000| delays: -
  m3, b03: |00000000000000000000000000000000| delays: -
  m3, b04: |11111111111100000000000000000000| delays: 93+-93
  m3, b05: |00000000000000111111111111000000| delays: 313+-99
  m3, b06: |00000000000000000000000000001111| delays: 480+-32
  m3, b07: |00000000000000000000000000000000| delays: -
  best: m3, b05 delays: 314+-99
  m4, b00: |00000000000000000000000000000000| delays: -
  m4, b01: |00000000000000000000000000000000| delays: -
  m4, b02: |00000000000000000000000000000000| delays: -
  m4, b03: |11100000000000000000000000000000| delays: 17+-17
  m4, b04: |00001111111111111000000000000000| delays: 167+-105
  m4, b05: |00000000000000000001111111111111| delays: 402+-100
  m4, b06: |00000000000000000000000000000000| delays: -
  m4, b07: |00000000000000000000000000000000| delays: -
  best: m4, b04 delays: 166+-104
  m5, b00: |00000000000000000000000000000000| delays: -
  m5, b01: |00000000000000000000000000000000| delays: -
  m5, b02: |00000000000000000000000000000000| delays: -
  m5, b03: |00000000000000000000000000000000| delays: -
  m5, b04: |11111111111110000000000000000000| delays: 99+-99
  m5, b05: |00000000000000011111111111110000| delays: 333+-98
  m5, b06: |00000000000000000000000000000011| delays: 493+-19
  m5, b07: |00000000000000000000000000000000| delays: -
  best: m5, b04 delays: 99+-99
  m6, b00: |00000000000000000000000000000000| delays: -
  m6, b01: |00000000000000000000000000000000| delays: -
  m6, b02: |00000000000000000000000000000000| delays: -
  m6, b03: |00000000000000000000000000000000| delays: -
  m6, b04: |11111111110000000000000000000000| delays: 74+-74
  m6, b05: |00000000000111111111111110000000| delays: 281+-107
  m6, b06: |00000000000000000000000000111111| delays: 462+-50
  m6, b07: |00000000000000000000000000000000| delays: -
  best: m6, b05 delays: 280+-106
  m7, b00: |00000000000000000000000000000000| delays: -
  m7, b01: |00000000000000000000000000000000| delays: -
  m7, b02: |00000000000000000000000000000000| delays: -
  m7, b03: |00000000000000000000000000000000| delays: -
  m7, b04: |11111110000000000000000000000000| delays: 54+-54
  m7, b05: |00000000011111111111110000000000| delays: 241+-105
  m7, b06: |00000000000000000000000011111111| delays: 440+-71
  m7, b07: |00000000000000000000000000000000| delays: -
  best: m7, b05 delays: 241+-103
Switching SDRAM to hardware control.
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
main> 1

Running TfLM Models menu

TfLM Models
===========
 1: Person Detection int8 model
 x: eXit to previous menu
models> 1

Running Person Detection int8 model
Error_reporter OK!
Input: 9216 bytes, 4 dims: 1 96 96 1


Tests for pdti8 model
=====================
 1: Run with zeros input
 2: Run with no-person input
 3: Run with person input
 g: Run golden tests (check for expected outputs)
 x: eXit to previous menu
pdti8> g

Running Run golden tests (check for expected outputs)
Zeroed 9216 bytes at 0x400ee560
Running pdti8
...............................
"Event","Tag","Ticks"
0,DEPTHWISE_CONV_2D,8701
1,DEPTHWISE_CONV_2D,9066
2,CONV_2D,14697
3,DEPTHWISE_CONV_2D,5537
4,CONV_2D,10231
5,DEPTHWISE_CONV_2D,10223
6,CONV_2D,14745
7,DEPTHWISE_CONV_2D,2417
8,CONV_2D,8219
9,DEPTHWISE_CONV_2D,5040
10,CONV_2D,13352
11,DEPTHWISE_CONV_2D,1150
12,CONV_2D,6737
13,DEPTHWISE_CONV_2D,2278
14,CONV_2D,12947
15,DEPTHWISE_CONV_2D,2647
16,CONV_2D,13559
17,DEPTHWISE_CONV_2D,2334
18,CONV_2D,12714
19,DEPTHWISE_CONV_2D,2906
20,CONV_2D,12783
21,DEPTHWISE_CONV_2D,2219
22,CONV_2D,12859
23,DEPTHWISE_CONV_2D,630
24,CONV_2D,6169
25,DEPTHWISE_CONV_2D,1073
26,CONV_2D,12243
27,AVERAGE_POOL_2D,49
28,CONV_2D,14
29,RESHAPE,1
30,SOFTMAX,8
Perf counters not enabled.
   213M (    212566875 )  cycles total
Copied 9216 bytes at 0x400ee560
Running pdti8
...............................
"Event","Tag","Ticks"
0,DEPTHWISE_CONV_2D,8687
1,DEPTHWISE_CONV_2D,9071
2,CONV_2D,14702
3,DEPTHWISE_CONV_2D,5542
4,CONV_2D,10220
5,DEPTHWISE_CONV_2D,10225
6,CONV_2D,14718
7,DEPTHWISE_CONV_2D,2415
8,CONV_2D,8193
9,DEPTHWISE_CONV_2D,5038
10,CONV_2D,13349
11,DEPTHWISE_CONV_2D,1149
12,CONV_2D,6725
13,DEPTHWISE_CONV_2D,2280
14,CONV_2D,12942
15,DEPTHWISE_CONV_2D,2646
16,CONV_2D,13557
17,DEPTHWISE_CONV_2D,2334
18,CONV_2D,12711
19,DEPTHWISE_CONV_2D,2907
20,CONV_2D,12781
21,DEPTHWISE_CONV_2D,2219
22,CONV_2D,12859
23,DEPTHWISE_CONV_2D,630
24,CONV_2D,6168
25,DEPTHWISE_CONV_2D,1076
26,CONV_2D,12238
27,AVERAGE_POOL_2D,48
28,CONV_2D,14
29,RESHAPE,2
30,SOFTMAX,8
Perf counters not enabled.
   212M (    212472522 )  cycles total
Copied 9216 bytes at 0x400ee560
Running pdti8
...............................
"Event","Tag","Ticks"
0,DEPTHWISE_CONV_2D,8686
1,DEPTHWISE_CONV_2D,9072
2,CONV_2D,14702
3,DEPTHWISE_CONV_2D,5540
4,CONV_2D,10224
5,DEPTHWISE_CONV_2D,10225
6,CONV_2D,14718
7,DEPTHWISE_CONV_2D,2415
8,CONV_2D,8195
9,DEPTHWISE_CONV_2D,5039
10,CONV_2D,13350
11,DEPTHWISE_CONV_2D,1150
12,CONV_2D,6728
13,DEPTHWISE_CONV_2D,2279
14,CONV_2D,12943
15,DEPTHWISE_CONV_2D,2645
16,CONV_2D,13558
17,DEPTHWISE_CONV_2D,2335
18,CONV_2D,12711
19,DEPTHWISE_CONV_2D,2910
20,CONV_2D,12782
21,DEPTHWISE_CONV_2D,2219
22,CONV_2D,12856
23,DEPTHWISE_CONV_2D,629
24,CONV_2D,6165
25,DEPTHWISE_CONV_2D,1075
26,CONV_2D,12237
27,AVERAGE_POOL_2D,48
28,CONV_2D,14
29,RESHAPE,2
30,SOFTMAX,8
Perf counters not enabled.
   212M (    212476908 )  cycles total
OK   Golden tests passed
---

Tests for pdti8 model
=====================
 1: Run with zeros input
 2: Run with no-person input
 3: Run with person input
 g: Run golden tests (check for expected outputs)
 x: eXit to previous menu
pdti8> 
```

## Important things to note

* Pretty sure that I cannot run two virtual environments at once. Either amaranth needs to be installed to the LiteX one or I just don't use amaranth and use Verilog instead.
* I've set up a fish script that should automatically source all of my toolchains and things. It's provided below (and probably in another file in this repository eventually)

```
# Fish shell environment setup for Vivado 2020.2, Vitis, XRT, Amaranth + RISC-V

# Vivado / Vitis / XRT
set -gx XILINX_VIVADO /auto/software/swtree/ubuntu22.04/x86_64/Xilinx/Vivado/2020.2
set -gx XILINX_VITIS /auto/software/swtree/ubuntu22.04/x86_64/Xilinx/Vitis/2020.2
set -gx XILINX_HLS $XILINX_VITIS
set -gx XILINX_VIVADO_HLS $XILINX_VITIS
set -gx XILINX_XRT /opt/xilinx/xrt
set -gx XILINXD_LICENSE_FILE 2100@license.engr.tntech.edu

# Add all tools + your RISC-V GCC to PATH
set -gx PATH \
    $XILINX_VIVADO/bin \
    $XILINX_VITIS/bin \
    $XILINX_VITIS/gnu/aarch64/lin/aarch64-none/bin \
    $XILINX_VITIS/gnu/aarch64/lin/aarch64-linux/bin \
    $XILINX_VITIS/gnu/aarch32/lin/gcc-arm-none-eabi/bin \
    $XILINX_VITIS/gnu/aarch32/lin/gcc-arm-linux-gnueabi/bin \
    $XILINX_VITIS/gnu/arm/lin/bin \
    $XILINX_VITIS/gnu/armr5/lin/gcc-arm-none-eabi/bin \
    $XILINX_VITIS/gnu/microblaze/lin/bin \
    $XILINX_VITIS/gnu/microblaze/linux_toolchain/lin64_le/bin \
    $XILINX_VITIS/tps/lnx64/cmake-3.3.2/bin \
    $XILINX_VITIS/aietools/bin \
    $XILINX_XRT/bin \
    $HOME/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14/bin \
    $PATH

# Print friendly environment summary
echo ""
echo "✅ Environment loaded:"
echo "  Vivado:       "(which vivado)
echo "  Vitis:        "(which vitis)
echo "  XRT:          "(which xbutil)
echo "  RISC-V GCC:   "(which riscv64-unknown-elf-gcc)
echo ""

# Amaranth check: current python (likely from your venv)
echo "  Amaranth:     "(python3 -c "import amaranth; print('found at '+amaranth.__file__)" 2>/dev/null; or echo 'not found')

# Yosys check
echo "  Yosys:        "(which yosys)
echo ""
```
Finally, once setup is complete, this is all you should need to do to program the FPGA again (with the basic implementation)
```
fish
bass module load vitis/2020.2
cd CFU-Playground
source vivado-2020.2.fish									# this will likely be different for you
source amaranth/bin/activate.fish
cd proj/proj_template
make clean TARGET=xilinx_alveo_u280
make prog TARGET=xilinx_alveo_u280 USE_VIVADO=1 EXTRA_LITEX_ARGS="--sys-clk-freq 100e6"		# there are still timing issues 
make load TARGET=xilinx_alveo_u280 BUILD_JOBS=4 TTY=/dev/ttyUSB2
	"ENTER" or "reboot" 									# if needed once flashed		
```





