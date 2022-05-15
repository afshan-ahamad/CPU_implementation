`include "alumod.v"
`include "regmod.v"
`include "cpu.v"
`include "dmem.v"
`include "dcache.v"
`include "ins_Cache.v"
`include "imem_for_icache.v"

// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
// Author: Kisaru Liyanage
`timescale  1ns/100ps
module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;
    wire C_READ,C_WRITE,busywait,insbusywait;
    wire [7:0] C_Address,C_READDATA,C_WRITEDATA;
    wire mem_write,mem_read,mem_busywait;
    wire [5:0] mem_address,imem_address;
    wire [31:0] mem_writedata,mem_readdata;
    wire imem_busywait,imem_read;
    wire [127:0] mem_instruction;
    /* 
    ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */
    
    // TODO: Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory
   // reg [7:0] instr_mem [1023:0];           //this is a vector of  1024 REGISTER of 8 bit width
    // TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value 
    //       (make sure you include the delay for instruction fetching here)
    //assign #2 INSTRUCTION = {instr_mem[PC[9:0]+10'd3],instr_mem[PC[9:0]+10'd2],instr_mem[PC[9:0]+10'd1],instr_mem[PC[9:0]]}; //takes 32 bits for INSTRUCTION 
    



    //initial
    //begin
        // Initialize instruction memory with the set of instructions you need execute on CPU
        
        // METHOD 1: manually loading instructions to instr_mem
        // {instr_mem[10'd3], instr_mem[10'd2], instr_mem[10'd1], instr_mem[10'd0]} = 32'b00000000000001000000000000000101;
        // {instr_mem[10'd7], instr_mem[10'd6], instr_mem[10'd5], instr_mem[10'd4]} = 32'b00000000000000100000000000001001;
        // {instr_mem[10'd11], instr_mem[10'd10], instr_mem[10'd9], instr_mem[10'd8]} = 32'b00000010000001100000010000000010;
        
        // METHOD 2: loading instr_mem content from instr_mem.mem file
       // $readmemb("./instr_mem.mem", instr_mem);
    //end
    
    /* 
    -----
     CPU
    -----
    */


   cpu mycpu(PC,INSTRUCTION, CLK,RESET,busywait,C_READ,C_WRITE,C_WRITEDATA,C_READDATA,C_Address,insbusywait);
 
   dcache my_dcache(CLK,RESET,C_WRITE,C_READ,C_Address,C_WRITEDATA,C_READDATA,busywait,mem_write,mem_read,mem_address,mem_writedata,mem_readdata,mem_busywait);
                      
   data_memory my_data_memory(CLK,RESET,mem_read,mem_write,mem_address,mem_writedata,mem_readdata,mem_busywait);

 ins_cache myicache  (CLK,PC,RESET,INSTRUCTION,insbusywait,mem_instruction,imem_read,imem_address,imem_busywait);

instruction_memory myinsmem(CLK,imem_read,imem_address,mem_instruction,imem_busywait);
   
                    
   
    

   integer i;
    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
       $dumpfile("cpu_wavedata.vcd");
	$dumpvars(0, cpu_tb);
	for(i=0;i<8;i=i+1)$dumpvars(0, mycpu.myreg.store[i]);
        for(i=0;i<8;i=i+1)$dumpvars(0, my_dcache.Cache_MEM[i]);
         for(i=0;i<8;i=i+1)$dumpvars(0, myicache.iCache[i]);
        CLK = 1'b0;
        RESET = 1'b1;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        #5 RESET=1'b0;
       
        // finish simulation after some time
        #3000
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule
