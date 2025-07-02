from amaranth import C, Module, Signal, signed
from amaranth_cfu import all_words, InstructionBase, InstructionTestBase, simple_cfu
import unittest

class SimdDot(InstructionBase):
    def __init__(self):
        super().__init__()

    def elab(self, m: Module) -> None:
        words = lambda s: all_words(s, 8)  # split into 4 bytes
        self.prods = [Signal(signed(16)) for _ in range(4)]

        for prod, w0, w1 in zip(self.prods, words(self.in0), words(self.in1)):
            m.d.comb += prod.eq(w0.as_signed() * w1.as_signed())

        with m.If(self.start):
            m.d.sync += [
                self.output.eq(sum(self.prods)),
                self.done.eq(1)
            ]
        with m.Else():
            m.d.sync += self.done.eq(0)

# Testing class
class SimdDotTest(InstructionTestBase):
    def create_dut(self):
        return SimdDot()

    def test(self):
        self.verify([
            (0, 0x01020304, 0x05060708, 1*5+2*6+3*7+4*8),
            (0, 0xffffffff, 0xffffffff, (-1)*(-1)+(-1)*(-1)+(-1)*(-1)+(-1)*(-1)),
            (0, 0x7f7f7f7f, 0x7f7f7f7f, 127*127*4),
        ])

def make_cfu():
    return simple_cfu({0: SimdDot()})

if __name__ == "__main__":
    unittest.main()
