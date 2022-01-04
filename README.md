# spi_hacc
## Hardware Acceleration using FPGA as SPI Slave
 
 Iteration 1: Computational Hardware Acceleration in FPGA (Prototype)
 
 Target Device: NexysA7-100T (With Raspberry Pi 3 as the host)

 Tool Versions: Xilinx Vivado 2020
 
 The objective of this project is to use the Raspberry Pi 3 as an interface to send tasks to the Nexys A7 FPGA board via SPI connections. A Saleae Logic Analyzer was also used to debug signals and identify noise (and thus work to remove that in each module). Both the RPi3 and the A7 were mounted on a plexiglass frame with a unified power supply to make the entire module portable. The A7 does still have to be connected to a PC first to initially program it with the hardware though. The project implements a basic ALU (arithmetic logic unit) implementation in FPGA with access through SPI from the Raspberry Pi 3.
 
 ![WhatsApp Image 2022-01-04 at 12 48 04 PM](https://user-images.githubusercontent.com/40621421/148103457-a4b58fa9-b041-4e10-a0ae-9d922f81af6f.jpeg)
 
 Between the two devices, the RPi acts as the SPI Master and the A7 acts as the SPI Slave. For this project, only the first set of SPI connections on the RPi were used (MOSI 0, MISO 0, SCLK 0, and CS 0), though a second set were available and could have been connected to the other pins on the A7. Another RPi3 was also available, though I intend to use this for future upgrades to this project.
 
 By connecting the SPI pins in the RPi to the GPIO pins in the A7, a connection is established. The pins in the A7 do have to be programmed via constraints to essentially tell the device what to do with those pins. We use the RPi as an interface to send two operands and an opcode to the A7. This is the most basic form of mathematical operations, but I want the FPGA to execute those operations and send the result back to the RPi3, which is a low-level implementation of hardware acceleration. The protocol implemented was also extremely simple, as will be detailed below.
 
 A Master script was written for the RPi3 to execute (in C, using the SPI library) that sends 5 bytes from the RPi to the FPGA during the MOSI cycle and reads 4 bytes during the MISO cycle. The specifics of this is shown below. The bytes sent contain two operands and an opcode that determines which mathematical operation to perform. This protocol could have been expanded to include the traditional transcation id, etc that allows for implementation of a transaction queue (future update).
 
 MOSI Cycle:
 
      5 Octets - opcode,operand1,operand2  
      Octet1 - OPCODE - ALU Operation to perform     
      Octet2 - OPERAND1-HI [Higher 8bits of the 16-bit OPERAND1]    
      Octet3 = OPERAND1-LO [Lower 8bits of the 16-bit OPERAND1]      
      Octet4 - OPERAND2-HI [Higher 8bits of the 16-bit OPERAND2]
      Octet5 = OPERAND2-LO [Lower 8bits of the 16-bit OPERAND2]
   
 MISO Cycle:
 
      Returns the 32bit RESULT in 4 Octets
      Octet1 - RESULT[31:24]
      Octet2 - RESULT[23:16]
      Octet3 = RESULT[15:8]
      Octet4 - RESULT[7:0]

 Note that any activity within the FPGA can only occur when the RPi sets chip select (CS 0) to active low. The FPGA receives the 5 octets from the MOSI cycle bit-by-bit according to the RPi's serial clock and saves them in a local 40-bit shift register. The information in this register is then broken down by knowing the sizes of each operand/code, and sends each variable to specific modules. Each module within the FPGA itself works off of the FPGA clock, but anything regarding sending or receiving data on the SPI lines is synced to the RPi's serial clock. The most important module inside the FPGA is the ALU. Based on the opcode, the module decides which operation to execute, and does so by saving the result of that operation on the two operands into a 32-bit result. Note that the operands are only 16-bits, so more than sufficient padding for multiplication, division, and overflow has been provided.
 
 This result is then sent to a series of display_digit modules, which all serve to control the cathodes and anodes of the FPGA's LED panel. Based on the value of the bit sent to the module, it'll activate certain cathodes and anodes to display the alphanumeric representation of that value on the panel. Hence, the result of operation will produce at most an 8-byte result (preprending zeroes will be omitted) which can be displayed on each of the 8 panels of the A7.
 
 The same result is also sent back to the top module, which processes it, then sends it out bit-by-bit (most significant bit first) over the MISO line back to the RPi. The RPi itself knows to read X bytes (whether you want it to read 4, or 8, or some number in between) but the FPGA requires an integer counter to know when it has sent all 32 bits (again, synced to the negedge of the serial clock, since it's sampled on the posedge). 
 
 This whole process was rigorously examined and each module involved in the FPGA was thoroughly unit-tested and debugged by writing unique testbench verifications for each module. Additionally, several different values and operations were passed from the RPi to ensure the FPGA could handle overflow and any other edge case it would be presented with. As it stands, all that remains to do to improve this prototype is pipeline the ALU itself to improve cycle efficiency and create a more sophisticated protocol.
