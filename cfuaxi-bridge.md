```
soc/bin/litex_term --speed 1843200 \
  --kernel proj/example_cfu_v_9_22_25/build/software.bin \
  --kernel-adr 0x50000000 \
  /dev/ttyUSB2
```
This code can be run after `make prog` so that the kernel address can be specified. The way that I have been working on moving the main_ram region around
(from 0x40000000 to 0x50000000) resulted in the kernel not being loaded to the right spot and broke make load. This fixes that.

Currently, the mission is to get AXI communication working over this bridge so that the CFU and HBM can communicate directly. I have moved some of the default
regions around (hbm 0-3 were originally CPU WB bridges at 0x40000000-0x70000000, now hbm 1-3 are from 0x50000000-0x70000000, and hbm 0 is a CFU AXI bridge.)
