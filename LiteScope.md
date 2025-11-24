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
