### asperkins42 Hardware Trojan Documentation (v2)
![alt text](images/asperkins42_hardwareTrojanImg1.jpg "HWT 1")

In the above image, you can see the majority of the Hardware Trojan circuit. 

Beginning at the top left, we have the XOR chip. This chip acts as an enable for the ring-oscillator part of this circuit. When the Trojan is not active, the XOR gate outputs a 1, allowing the ROs to begin oscillation. When the Trojan goes high, the XOR output changes to 0, which stops the oscillation of the ring oscillators. Two of the four available XOR gates are used in this circuit. 

The chip to the right of the XOR gate is a NAND gate. This acts as the first stage of the ring oscillator, and allows the oscillators to be turned on and off. Two NAND gates are used, one for each of the ROs. 

The remaining six chips on the top row are the rest of the ring oscillators. The top row uses all available inverters (3 per side, per chip) for a total of 18 inverters + the NAND gate on top, giving the top RO 19 stages. The bottom RO has only 17 stages, leaving out the last two inverters of the last chip. This is done so the oscillations have a larger variance in frequency. When we tested with two ROs of the same length, the output on the seven-segment display only ever read 0 or 7, since the signals were too close in frequency and would be all 1's or all 0's after the D-Flip Flop stage (we will discuss that in a moment).

On the second row, the first chip is a counter. Each RO feeds into the input of the counter, and the most significant outputs of the two counters are used as inputs for the first three D-Flip Flops (The top row of the next three chips). One counter controls the input to the first of the three streaming DFFs, while the other counter controls all three of the clocks. This makes it so that on every clock edge, the input advances one stage. The second set of DFFs (the bottom row of the same three chips) handles the storage of the current value. The output of the top three DFFs feed into the input of the bottom three DFFs, and these are clocked by a button (that I have just noticed is absent from the picture, but would connect the red (5V) wire to the white wire at the end of the breadboard we are currently on). When this button is pressed, the value that is currently being output by the top three DFFs is locked into the bottom three DFFs and is output on their Q pin. These three bits are then fed into a hexadecimal decoder (the final black IC on this breadboard) whose most significant value is held to 0V. The outputs of this decoder are connected to the seven-segment display as shown. 

## Trojan Activation 
