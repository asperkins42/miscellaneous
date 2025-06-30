### CFU Playground setup for ArtyA7

I began by following the [setup guide] (https://cfu-playground.readthedocs.io/en/latest/setup-guide.html) for CFU-Playground.
Step 1 was easy, given that the Arty A7 was already connected to zenith2. I setup [FoxyProxy] (https://docs.excl.ornl.gov/quick-start-guides/excl-remote-development#setup-foxyproxy) and [ThinLinc] (https://docs.excl.ornl.gov/~/revisions/tgK4OWTltCS04RkJelGW/quick-start-guides/thinlinc) so that I could access 
the GUI for zenith2. (Be sure that FoxyProxy is set to "Proxy by Pattern" and everything should work if you follow the tutorials linked.)

Step 2 is to clone the repository using `git clone https://github.com/google/CFU-Playground.git`.

Once that has been run, begin Step 3 by running `cd CFU-Playground` and run the setup script `./scripts/setup`. 

Afterward, run `pip install amaranth-yosys` to install Amaranth, which is what we will use to build CFUs. 

Step 4 involves toolchain setup. For the ArtyA7, you can use step 4a which is `make install-sf` then, when that finishes `make enter-sf`. 
When you are building the bitsream later, to use Symbiflow, you must add `USE_SYMBIFLOW` to the end of the command. 

### CFU Playground setup for Alveo U280

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
source amaranth/bin/activate

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
maranth) asperkins42@milan3:~/CFU-Playground (main %=)$ sudo apt install libtinfo5                                               <- 0s042 | 10:33PM
[sudo] password for asperkins42: 
asperkins42 is not in the sudoers file.
This incident has been reported to the administrator.
```

So sorry Steve, I keep asking you to install packages.

At the moment I cannot get any farther without this package installed, but once it is installed, it should be straightforward to finish setup. Really glad I set up the GUI, the terminal was getting old.



