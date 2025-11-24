### About

This is very basic documentation of what was run in an attempt to make LiteScope work. I added this chunk to our TARGET file so that when LiteX builds using it, we have access to LiteScope. 

```
# LiteScope Analyzer ----------------------------------------------------------------------
        if with_analyzer:
            analyzer_signals = [
                self.cpu.cfu_axi.aw.valid,
                self.cpu.cfu_axi.aw.ready,
                self.cpu.cfu_axi.aw.addr,
                self.cpu.cfu_axi.aw.len,
                self.cpu.cfu_axi.w.valid,
                self.cpu.cfu_axi.w.ready,
                self.cpu.cfu_axi.w.data,
                self.cpu.cfu_axi.w.last,
                self.cpu.cfu_axi.b.valid,
                self.cpu.cfu_axi.b.ready,
                self.cpu.cfu_axi.b.resp,
            ]
            from litescope import LiteScopeAnalyzer
            self.submodules.analyzer = LiteScopeAnalyzer(
                analyzer_signals,
                depth=1024,
                clock_domain="sys"
            )
            self.add_csr("analyzer")
```



### What Codex tried doing
1. make clean; make prog …; make load … as usual.

2. Close any direct litex_term sessions on /dev/ttyUSB2.

3. Start the bridge:
```
./soc/bin/litex_server \
    --uart \
    --uart-port /dev/ttyUSB2 \
    --uart-baudrate 1843200 \
    --bind-port 1234
```

4. Arm LiteScope (new terminal):
```
./scripts/pyrun -m litescope.software.litescope_cli \
    --csr-csv soc/csr.csv \
    --csv     soc/analyzer.csv \
    --dump    analyzer.vcd \
    --offset  0 \
    --length  512 \
    --value-trigger soc_basesoc_vexriscv_aw_valid 0b1
```
It will print the trigger condition and then wait.

5. To drive the menu while the server is running, connect through the server using pySerial’s socket backend, e.g.
`litex_term --port socket://localhost:1234 --speed 1843200`
(or even nc localhost 1234 if you just need raw characters). That session goes through litex_server, so it can coexist with LiteScope.
In that socket-based console, press w to reproduce the hang. The analyzer will fire, upload the data, and analyzer.vcd will be ready for GTKWave.

```
(amaranth) ./soc/bin/litex_server \ <- 17m 13s951 | 12:56PM
--uart
--uart-port /dev/ttyUSB2
--uart-baudrate 1843200
--bind-port 1234

[CommUART] port: /dev/ttyUSB2 / baudrate: 1843200 / tcp port: 1234
Connected with 127.0.0.1:55374

(amaranth) asperkins42@milan3:~/cfu-playground-cfuaxi (main +*%)$ ./scripts/pyrun -m litescope.software.litescope_cli
--csr-csv soc/csr.csv
--csv soc/analyzer.csv
--dump analyzer.vcd
--offset 0
--length 512
--value-trigger soc_basesoc_vexriscv_aw_valid 0b1

Exact: soc_basesoc_vexriscv_aw_valid
Exact: soc_basesoc_vexriscv_aw_valid
Condition: soc_basesoc_vexriscv_aw_valid == 0b1
Traceback (most recent call last):
File "<frozen runpy>", line 198, in _run_module_as_main
File "<frozen runpy>", line 88, in _run_code
File "/home/asperkins42/cfu-playground-cfuaxi/third_party/python/litescope/litescope/software/litescope_cli.py", line 210, in <module>
main()
File "/home/asperkins42/cfu-playground-cfuaxi/third_party/python/litescope/litescope/software/litescope_cli.py", line 206, in main
run_batch(args)
File "/home/asperkins42/cfu-playground-cfuaxi/third_party/python/litescope/litescope/software/litescope_cli.py", line 92, in run_batch
if not add_triggers(args, analyzer, signals):
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
File "/home/asperkins42/cfu-playground-cfuaxi/third_party/python/litescope/litescope/software/litescope_cli.py", line 75, in add_triggers
analyzer.add_trigger(cond=cond)
File "/home/asperkins42/cfu-playground-cfuaxi/third_party/python/litescope/litescope/software/driver/analyzer.py", line 81, in add_trigger
if self.trigger_mem_full.read():
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
File "/home/asperkins42/cfu-playground-cfuaxi/third_party/python/litex/litex/tools/remote/csr_builder.py", line 40, in read
datas = self.readfn(self.addr, length=self.length)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
File "/home/asperkins42/cfu-playground-cfuaxi/third_party/python/litex/litex/tools/litex_client.py", line 66, in read
packet = EtherbonePacket(self.receive_packet(self.socket))
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
File "/home/asperkins42/cfu-playground-cfuaxi/third_party/python/litex/litex/tools/remote/etherbone.py", line 369, in receive_packet
chunk = socket.recv(header_length - len(packet))
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
TimeoutError: timed out
```

### TARGET File
```
#!/usr/bin/env python3

#
# This file is part of LiteX-Boards.
#
# Copyright (c) 2021 Sergiu Mosanu <sm7ed@virginia.edu>
# Copyright (c) 2020-2021 Florent Kermarrec <florent@enjoy-digital.fr>
# Copyright (c) 2020 Antmicro <www.antmicro.com>
#
# SPDX-License-Identifier: BSD-2-Clause

# To interface via the serial port use:
#     lxterm /dev/ttyUSBx --speed=115200

import os

from migen import *
from migen.genlib.resetsync import AsyncResetSynchronizer

from litex_boards.platforms import xilinx_alveo_u280

from litex.soc.cores.clock import *
from litex.soc.integration.soc_core import *
from litex.soc.integration.soc import SoCRegion
from litex.soc.integration.builder import *
from litex.soc.interconnect.axi import *
from litex.soc.interconnect.csr import *
from litex.soc.cores.ram.xilinx_usp_hbm2 import USPHBM2

from litex.soc.cores.led import LedChaser
from litedram.modules import MTA18ASF2G72PZ
from litedram.phy import usddrphy

from litepcie.phy.usppciephy import USPPCIEPHY
from litepcie.software import generate_litepcie_software

from litedram.common import *
from litedram.frontend.axi import *

from litescope import LiteScopeAnalyzer

# CRG ----------------------------------------------------------------------------------------------

class _CRG(Module):
    def __init__(self, platform, sys_clk_freq, ddram_channel, with_hbm):
        if with_hbm:
            self.clock_domains.cd_sys     = ClockDomain()
            self.clock_domains.cd_hbm_ref = ClockDomain()
            self.clock_domains.cd_apb     = ClockDomain()
        else: # ddr4
            self.rst = Signal()
            self.clock_domains.cd_sys    = ClockDomain()
            self.clock_domains.cd_sys4x  = ClockDomain()
            self.clock_domains.cd_pll4x  = ClockDomain()
            self.clock_domains.cd_idelay = ClockDomain()

        # # #

        if with_hbm:
            self.submodules.pll = pll = USMMCM(speedgrade=-2)
            pll.register_clkin(platform.request("sysclk", ddram_channel), 100e6)
            pll.create_clkout(self.cd_sys,     sys_clk_freq)
            pll.create_clkout(self.cd_hbm_ref, 100e6)
            pll.create_clkout(self.cd_apb,     100e6)
            platform.add_false_path_constraints(self.cd_sys.clk, self.cd_apb.clk)
        else: # ddr4
            self.submodules.pll = pll = USMMCM(speedgrade=-2)
            self.comb += pll.reset.eq(self.rst)
            pll.register_clkin(platform.request("sysclk", ddram_channel), 100e6)
            pll.create_clkout(self.cd_pll4x, sys_clk_freq*4, buf=None, with_reset=False)
            pll.create_clkout(self.cd_idelay, 600e6) #, with_reset=False
            platform.add_false_path_constraints(self.cd_sys.clk, pll.clkin) # Ignore sys_clk to pll.clkin path created by SoC's rst.

            self.specials += [
                Instance("BUFGCE_DIV",
                    p_BUFGCE_DIVIDE=4,
                    i_CE=1, i_I=self.cd_pll4x.clk, o_O=self.cd_sys.clk),
                Instance("BUFGCE",
                    i_CE=1, i_I=self.cd_pll4x.clk, o_O=self.cd_sys4x.clk),
                # AsyncResetSynchronizer(self.cd_idelay, ~pll.locked),
            ]

            self.submodules.idelayctrl = USIDELAYCTRL(cd_ref=self.cd_idelay, cd_sys=self.cd_sys)

# BaseSoC ------------------------------------------------------------------------------------------

class BaseSoC(SoCCore):
    def __init__(
        self,
        sys_clk_freq=int(150e6),
        ddram_channel=0,
        with_pcie=False,
        with_led_chaser=False,
        with_hbm=False,
        with_analyzer=False,
        **kwargs
    ):

        platform = xilinx_alveo_u280.Platform()
        if with_hbm:
            assert 225e6 <= sys_clk_freq <= 450e6

        # CRG --------------------------------------------------------------------------------------
        self.submodules.crg = _CRG(platform, sys_clk_freq, ddram_channel, with_hbm)

        # SoCCore ----------------------------------------------------------------------------------
        SoCCore.__init__(
            self,
            platform,
            sys_clk_freq,
            ident="LiteX SoC on Alveo U280 (ES1)",
            **kwargs
        )

        # HBM / DRAM -------------------------------------------------------------------------------
        if with_hbm:
            # JTAGBone -----------------------------------------------------------------------------
            #self.add_jtagbone(chain=2) # Chain 1 already used by HBM2 debug probes.

            # Add HBM Core.
            self.submodules.hbm = hbm = ClockDomainsRenamer({"axi": "sys"})(USPHBM2(platform))

            # Get HBM .xci.
            os.system("wget https://github.com/litex-hub/litex-boards/files/6893157/hbm_0.xci.txt")
            os.makedirs("ip/hbm", exist_ok=True)
            os.system("mv hbm_0.xci.txt ip/hbm/hbm_0.xci")

            def _accept_all(_):
                return 1

            print("[u280] Configuring shared HBM port zero for CPU + CFU access.")

            # Connect four of the HBM's AXI interfaces to the main bus of the SoC.
            for i in range(4):
                axi_hbm      = hbm.axi[i]
                axi_lite_hbm = AXILiteInterface(
                    data_width=axi_hbm.data_width,
                    address_width=axi_hbm.address_width,
                )

                cpu_axi_master = AXIInterface(
                    data_width=axi_hbm.data_width,
                    address_width=axi_hbm.address_width,
                    id_width=axi_hbm.id_width,
                )
                self.submodules += AXILite2AXI(axi_lite_hbm, cpu_axi_master)

                masters = [cpu_axi_master]

                if i == 0 and hasattr(self.cpu, "cfu_axi"):
                    cfu_axi = self.cpu.cfu_axi
                    if (cfu_axi.data_width != axi_hbm.data_width or
                            cfu_axi.address_width != axi_hbm.address_width):
                        raise ValueError(
                            "CFU AXI interface width does not match HBM port 0 width."
                        )
                    masters.append(cfu_axi)

                interconnect = AXIInterconnectShared(
                    masters=masters,
                    slaves=[(lambda _: 1, axi_hbm)],
                )
                setattr(self.submodules, f"hbm{i}_ic", interconnect)

                self.bus.add_slave(f"hbm{i}", axi_lite_hbm, SoCRegion(origin=0x4000_0000 + 0x1000_0000*i, size=0x1000_0000)) # 256MB.
            # Link HBM2 channel 0 as main RAM
            self.bus.add_region("main_ram", SoCRegion(origin=0x4000_0000, size=0x1000_0000, linker=True)) # 256MB.

        else:
            # DDR4 SDRAM -------------------------------------------------------------------------------
            if not self.integrated_main_ram_size:
                self.submodules.ddrphy = usddrphy.USPDDRPHY(platform.request("ddram", ddram_channel),
                    memtype          = "DDR4",
                    cmd_latency      = 1, # seems to work better with cmd_latency=1
                    sys_clk_freq     = sys_clk_freq,
                    iodelay_clk_freq = 600e6,
                    is_rdimm         = True)
                self.add_sdram("sdram",
                    phy           = self.ddrphy,
                    module        = MTA18ASF2G72PZ(sys_clk_freq, "1:4"),
                    size          = 0x40000000,
                    l2_cache_size = kwargs.get("l2_size", 8192)
                )

            # Firmware RAM (To ease initial LiteDRAM calibration support) --------------------------
            self.add_ram("firmware_ram", 0x20000000, 0x8000)

        # LiteScope Analyzer ----------------------------------------------------------------------
        if with_analyzer:
            analyzer_signals = [
                self.cpu.cfu_axi.aw.valid,
                self.cpu.cfu_axi.aw.ready,
                self.cpu.cfu_axi.aw.addr,
                self.cpu.cfu_axi.aw.len,
                self.cpu.cfu_axi.w.valid,
                self.cpu.cfu_axi.w.ready,
                self.cpu.cfu_axi.w.data,
                self.cpu.cfu_axi.w.last,
                self.cpu.cfu_axi.b.valid,
                self.cpu.cfu_axi.b.ready,
                self.cpu.cfu_axi.b.resp,
            ]
            from litescope import LiteScopeAnalyzer
            self.submodules.analyzer = LiteScopeAnalyzer(
                analyzer_signals,
                depth=1024,
                clock_domain="sys"
            )
            self.add_csr("analyzer")

        # PCIe -------------------------------------------------------------------------------------
        if with_pcie:
            self.submodules.pcie_phy = USPPCIEPHY(platform, platform.request("pcie_x4"),
                data_width = 128,
                bar0_size  = 0x20000)
            self.add_pcie(phy=self.pcie_phy, ndmas=1)

        # Leds -------------------------------------------------------------------------------------
        if with_led_chaser:
            self.submodules.leds = LedChaser(
                pads         = platform.request_all("gpio_led"),
                sys_clk_freq = sys_clk_freq)

# Build --------------------------------------------------------------------------------------------

def main():
    from litex.soc.integration.soc import LiteXSoCArgumentParser
    parser = LiteXSoCArgumentParser(description="LiteX SoC on Alveo U280")
    target_group = parser.add_argument_group(title="Target options")
    target_group.add_argument("--build",           action="store_true", help="Build design.")
    target_group.add_argument("--load",            action="store_true", help="Load bitstream.")
    target_group.add_argument("--sys-clk-freq",    default=150e6,       help="System clock frequency.") # HBM2 with 250MHz, DDR4 with 150MHz (1:4)
    target_group.add_argument("--ddram-channel",   default="0",         help="DDRAM channel (0, 1, 2 or 3).") # also selects clk 0 or 1
    target_group.add_argument("--with-pcie",       action="store_true", help="Enable PCIe support.")
    target_group.add_argument("--driver",          action="store_true", help="Generate PCIe driver.")
    target_group.add_argument("--with-hbm",        action="store_true", help="Use HBM2.")
    target_group.add_argument("--with-analyzer",   action="store_true", help="Enable Analyzer.")
    target_group.add_argument("--with-led-chaser", action="store_true", help="Enable LED Chaser.")
    builder_args(parser)
    soc_core_args(parser)
    args = parser.parse_args()

    if args.with_hbm:
        args.sys_clk_freq = 250e6

    soc = BaseSoC(
        sys_clk_freq    = int(float(args.sys_clk_freq)),
        ddram_channel   = int(args.ddram_channel, 0),
        with_pcie       = args.with_pcie,
        with_led_chaser = args.with_led_chaser,
        with_hbm        = args.with_hbm,
        with_analyzer   = args.with_analyzer,
        **soc_core_argdict(args)
	)
    builder = Builder(soc, **builder_argdict(args))
    if args.build:
        builder.build()

    if args.driver:
        generate_litepcie_software(soc, os.path.join(builder.output_dir, "driver"))

    if args.load:
        prog = soc.platform.create_programmer()
        prog.load_bitstream(builder.get_bitstream_filename(mode="sram"))

if __name__ == "__main__":
    main()

```
