Open a new terminal an execute the command below

**`$ ssh login.excl.ornl.gov

The terminal will prompt you by asking for you XCAMS password. After putting your password in, you will get a "Welcome to the Experimental Computing Laboratory" message. At this point, run **ssh-keygen** to generate a new SSH pair. 

After the pair is generated, run **`$ ssh-copy-id login.excl.ornl.gov`

When prompted, type yes to copy the new key to ORNL. Exit to reload. Now ssh into the login node again using the command from earlier. From here, you should be able to run **`ssh zenith

Exit twice now to fully log out of ExCL. Now run **`$ scp username@login.excl.ornl.gov:.ssh/id_rsa .ssh/id_rsa

It will prompt you for your password again. Now run **`$ scp username@login.excl.ornl.gov:.ssh/id_rsa.pub .ssh/id_rsa.pub

This should be the last time it asks you for your password. Run a **ls -al .ssh** to make sure the keys are copied. You should now be able to **ssh** into **login.excl.ornl.gov** without needing to enter your password. **Exit ORNL again**

**cd .ssh** and run **ls**. If a config file does not exits, create one with **touch config**. Open the config file in a text editor and add these lines.

```
Host excl
    HostName login.excl.ornl.gov

Host zenith
    ProxyJump excl 
    
Host zenith2
    ProxyJump excl 
```

After this file is created, you should be able to run **$ ssh zenith** to ssh into the zenith node without a password. 

**Using VSCode**
Open VSCode and install the "Remote - SSH" extension. There should now be a Remotes section on the left side menu bar. Clicking the arrow will connect you to that host. You should be able to open a new terminal and see that you are in the zenith node.

In VSCode, go to settings, search "lockfiles" and make sure the **Remote.SSH: Lockfiles in Tmp** box is checked. 

**Running LiteX and Loading a Kernel**

Connect to zenith, then run **git clone https://code.ornl.gov/seg/public/litex-setup-de10lite.git

This will load Brett's tutorial repository onto the zenith node. Make sure you have setup a Python virtual environment by running these commands.

```
python3 -m venv --prompt litex .venv
source .venv/bin/activate.fish
pip install -r scripts/requirements.txt
```

At this point, you should simply be able to follow the ExCL tutorial Brett posted to load the code onto the board. 

```
# Open shell session with allocated FPGA.
fish
sfpgarun-arty-a7 fish

# Load the Vitis/Vivado module
bass module load vitis

# Run commands using the FPGA
# Use this command to see FPGA Environment variables set by Slurm.
env | grep SLURM_FPGA

# Example load command.
python -m litex_boards.targets.digilent_arty --variant a7-100 --build --load

```
Now, navigate to the software directory and run Make. Once you have the app.bin file, you should be able to load it by running `litex_term /dev/ttyUSB1 --kernel software/app.bin `

When I asked him about it yesterday, Aaron said that we should be able to use either $SLURM_FPGA_FILE or $SLURM_FPGA_NAME in place of "/dev/ttyUSB1". 





