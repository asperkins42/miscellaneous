### CFU Playground setup for ArtyA7

I began by following the [setup guide] (https://cfu-playground.readthedocs.io/en/latest/setup-guide.html) for CFU-Playground.
Step 1 was easy, given that the Arty A7 was already connected to zenith2. I setup [FoxyProxy] (https://docs.excl.ornl.gov/quick-start-guides/excl-remote-development#setup-foxyproxy) and [ThinLinc] (https://docs.excl.ornl.gov/~/revisions/tgK4OWTltCS04RkJelGW/quick-start-guides/thinlinc) so that I could access 
the GUI for zenith2. (Be sure that FoxyProxy is set to "Proxy by Pattern" and everything should work if you follow the tutorials linked.)

Step 2 is to clone the repository using `git clone https://github.com/google/CFU-Playground.git`.

Once that has been run, begin Step 3 by running `cd CFU-Playground` and run the setup script `./scripts/setup`. 

Afterward, run `pip install amaranth-yosys` to install Amaranth, which is what we will use to build CFUs. 

Step 4 involves toolchain setup. For the ArtyA7, you can use step 4a which is `make install-sf` then, when that finishes `make enter-sf`. 
When you are building the bitsream later, to use Symbiflow, you must add `USE_SYMBIFLOW` to the end of the command. 
