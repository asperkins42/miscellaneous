/proj/ -- place our projects (11_30 is the one we are currently working with) are found in this directory

/soc/board_specific_workflows/general.py
	Similar reason as to why workflow_args.py needed to be updated. This wasn't enabling the arguments we were passing to the build so it never got implemented until it was added to this file. 

/soc/board_specific_workflows/workflow_args.py
	This file had to be edited so that EXTRA_LITEX_ARGS="" would be propagated into the SoC build. The --with-hbm flag did not work at first because it wasn't set in this file.

/third_party/python/litex/litex/soc/cores/cpu/vexriscv/core.py
	This file needs to be patched to expose our CFU connections, so that the SoC builder can connect our AXI master on the CFU to the AXI slave on the HBM port. 

/third_party/python/litex/litex/soc/interconnect/axi/axi_full.py
	This was modified because the AXIInterface was defaulting our address_width and id_width values to the wrong values. Since we instantiated a second master on the same interconnect, we needed to go and specify where to pull those values from, instead of just using the values the other was using. 

/third_party/python/litex_boards/litex_boards/targets/xilinx_alveo_u280.py
	We call this target file when building a project. This file connects our AXI interfaces. We also have instantiated the LiteScope here, but have yet to make it work. AW, W, B channels are currently added to the Scope since we are trying to analyze why the Scratchpad->HBM writeback fails. 