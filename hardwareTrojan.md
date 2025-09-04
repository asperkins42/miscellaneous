### asperkins42 Hardware Trojan Documentation (v2)

## What does it do?

This circuit, under normal operating conditions, will roll a random number between 0 and 7 (inclusive) when the button is pressed. This is meant to act as a potential "dice roller" for a game like Yahtzee, Monopoly, etc. When the Trojan is activated via the switch, the dice lock up, and no numbers are able to be rolled until the Trojan is deactivated. This showcases how hardware could potentially be inserted to rig a game in one's favor. 

## Circuit Behavior
![alt text](images/asperkins42_hardwareTrojanImg1.jpg "HWT 1")

In the above image, you can see the majority of the Hardware Trojan circuit. 
Beginning at the top left, we have the XOR chip. This chip acts as an enable for the ring-oscillator part of this circuit. When the Trojan is not active, the XOR gate outputs a 1, allowing the ROs to begin oscillation. When the Trojan goes high, the XOR output changes to 0, which stops the oscillation of the ring oscillators. Two of the four available XOR gates are used in this circuit. 

The chip to the right of the XOR gate is a NAND gate. This acts as the first stage of the ring oscillator and allows the oscillators to be turned on and off. Two NAND gates are used, one for each of the ROs. 

The remaining six chips on the top row are the rest of the ring oscillators. The top row uses all available inverters (3 per side, per chip) for a total of 18 inverters + the NAND gate on top, giving the top RO 19 stages. The bottom RO has only 17 stages, leaving out the last two inverters of the last chip. This is done so that the oscillations have a larger variance in frequency. When we tested with two ROs of the same length, the output on the seven-segment display only ever read 0 or 7, since the signals were too close in frequency and would be all 1's or all 0's after the D-Flip Flop stage (we will discuss that in a moment).

On the second row, the first chip is a counter. Each RO feeds into the input of the counter, and the most significant outputs of the two counters are used as inputs for the first three D-Flip Flops (The top row of the next three chips). One counter controls the input to the first of the three streaming DFFs, while the other counter controls all three of the clocks. This makes it so that on every clock edge, the input advances one stage. The second set of DFFs (the bottom row of the same three chips) handles the storage of the current value. The output of the top three DFFs feed into the input of the bottom three DFFs, and these are clocked by a button (that I have just noticed is absent from the picture, but would connect the red (5V) wire to the white wire at the end of the breadboard we are currently on). When this button is pressed, the value that is currently being output by the top three DFFs is locked into the bottom three DFFs and is output on their Q pin. These three bits are then fed into a hexadecimal decoder (the final black IC on this breadboard) whose most significant value is held to 0V. The outputs of this decoder are connected to the seven-segment display as shown. The green LED was used in debugging and did make its way into the final PCB design. All it does is illuminate when the button is pressed. 

## Trojan Activation 
![alt text](images/asperkins42_hardwareTrojanImg2.jpg "HWT 2")

In this image, you can see the bottom two breadboards, where not much is going on. Breadboard 3 houses the on/off switch for the Trojan, along with the AND gate, the capacitors, and the resistors that make up the Trojan. When the switch is turned on, 5V is supplied to the AND gate and the RC circuit. The RC circuit has a time constant (around 4 seconds) so that once the capacitor fully charges, both inputs to the AND gate go high, resulting in a 1 being output. The 1 is then propagated to the XOR gates from the beginning, which locks the circuit into whichever number was currently rolled. 

The bottom breadboard simply has a voltage regulator that takes in 9V and outputs 5V. 

## Variations Compared to PCB

The PCB version of this Trojan works in the same way; there are simply a couple of variations to the layout. First off, the layout is similar to the breadboard, but had to be adapted to fit the 9V battery and its housing. There is also an additional switch added between the 9V battery and the voltage regulator, giving the user an off switch if desired. 

There are two versions of the PCB. One is a clean version, with no Trojan on the board at all. The other is an "attacked" version that has the Trojan on board, which is still activated by the switch. 

## Things to note!
The Trojan activation does not work exactly as calculated. The time it takes from Trojan trigger to activation was calculated to be ~4 seconds, but in the actual implementation, it is more like 10 seconds. The random number generation also biases certain numbers.

<img width="1286" height="893" alt="image" src="https://github.com/user-attachments/assets/e501f18c-8d8c-4568-84d2-62020a3dfbb5" />


<img width="1207" height="842" alt="image" src="https://github.com/user-attachments/assets/09eebc1f-36c4-4ac4-921f-05c3371900c4" />


