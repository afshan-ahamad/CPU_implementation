       /* 
	loadi   = "00000000";
	mov 	= "00000001";
	add 	= "00000010";
	sub 	= "00000011";
	and 	= "00000100";
	or 	= "00000101";
	j       = "00000110";
	beq	= "00000111";
	lwd 	= "00001000";
	lwi 	= "00001001";
	swd 	= "00001010";
	swi 	= "00001011";
*/
`timescale  1ns/100ps

module cpu(PC, INSTRUCTION, CLK, RESET,BUSYWAIT,READ,WRITE,WRITEDATA,READDATA,ADDRESS,INSBUSYWAIT);  //cpu main module with PC as output and INSTRUCTION CLK RESET as input

input [31:0] INSTRUCTION;                 //32bit input port to input the INSTRUCTION
input CLK,RESET;                          //2 input ports to input the CLK and RESET to the cpu
output reg [31:0] PC;                     //1 32bit output port register to store the program counter
output reg READ,WRITE;                    //output registers to store read and write signals
input BUSYWAIT,INSBUSYWAIT;                           //input port  to input the busywait signals
input [7:0] READDATA;                     //8bit input port to store read data 
output reg [7:0] WRITEDATA;               //8bit output register to store the write data
output [7:0] ADDRESS;                     //8 bit output port to store the address
reg DatamemSelect;                        //register to store data memory select signals
reg WRITEENABLE;                          //register to store WRITEENABLE  signal
reg [7:0] INDATA;                         //8bit reg to store the in data
wire [7:0] aluresult,out1,out2;           //3 8bit wires to output the aluresult out1 and out2
reg select1,select2,select3,select4;      //4 registers to store the select signals
wire select5,and_output;                  //two wires to store intermediate outputs
reg  [2:0] ALUOP;                         //3 bit register to input the ALUOP selections to the alu
wire [7:0] complement;                    // 8 bit wire to output the complement 
reg  [7:0] outmux1,outmux2;              //2 8 bit registers to carry the intermediate outputs from the 1st and 2nd MUXs
reg  [31:0] pc;                          //32bit register to store the pc
wire ZERO,busywait;                               //A REGISTER TO STORE THE ALU OUTPUT SIGNAL OF THE BEQ INSTRUCTION


reg signed [9:0] leftshift;               //10 BIT SIGNED REGISTER TO STORE THE LEFT SHIFTED BINARY VALUE
reg signed [31:0] extended;               //32 BIT SIGNED REGISTER TO STORE THE SIGNED BINARY VALUE
wire  [31:0]target;                       //PC+4+OFFSET




always@(PC)
begin
if(BUSYWAIT==0 && INSBUSYWAIT==0)
#1 pc= pc+4;                             //pc is incremented by 4 bytes after a time interval of 1 time units
end

always@(posedge CLK)                    //always at the positive clock edge
begin
#0.1
if(RESET)                               //when reset is enabled
begin
pc=0;                                   //pc is set to 0
#0.9 PC =  pc;                            //PC is also updated with 0 after a delay of 1 time unit
end
else
if(BUSYWAIT==0 && INSBUSYWAIT==0)
#0.9 PC =  pc;                            //else if BUSYWAIT is 0 PC is updated with the result in pc after a delay of 1 time unit
end




always@(INSTRUCTION)                   //always
begin
#1;
case(INSTRUCTION[31:24])  //first 8 bits of the INSTRUCTION is considered as the case

            
8'b00000010:begin //ADD selecter for add
	 ALUOP= 3'b001; 
         select1=0;
         select2=0;
	 select3=0;
	 select4=0;
	 WRITEENABLE=1;
	DatamemSelect=0;
	 READ=0;
	 WRITE=0;
         end
      
8'b00000011:begin//ADD selecter for sub
	ALUOP= 3'b001;
      	select1=1;
    	select2=0;
	select3=0;
	select4=0;
	WRITEENABLE=1;
	DatamemSelect=0;
	READ=0;
	WRITE=0;
	end                
8'b00000100:begin//AND selecter for and
	ALUOP= 3'b010;  
	select1=0;
        select2=0;
	select3=0;
	select4=0;
	WRITEENABLE=1;
	DatamemSelect=0;
	READ=0;
	WRITE=0;
	end      
8'b00000101:begin //OR selecter for or
	ALUOP= 3'b011;  
	select1=0;
	select2=0; 
	select3=0;
	select4=0;
	WRITEENABLE=1;
	DatamemSelect=0;
	 READ=0;
	 WRITE=0;
	end            
8'b00000001:begin//FORWARD selecter for mov
	ALUOP= 3'b000;
	select1=0;
	select2=0; 
	select3=0;
	select4=0;
	WRITEENABLE=1;
	DatamemSelect=0;
	READ=0;
	 WRITE=0;
	end  
            
8'b00000000:begin  //FORWARD selecter for loadi
	ALUOP= 3'b000;
	select1=0;
	select2=1;
	select3=0;
	select4=0;
	WRITEENABLE=1;
	DatamemSelect=0;
	READ=0;
	 WRITE=0;
	end
8'b00000111:begin  //ADD selecter for beq
	ALUOP= 3'b001;
	select1=1;
	select2=0;
	select3=1;
	select4=0;
	WRITEENABLE=0;
	DatamemSelect=0;
	READ=0;
	 WRITE=0;
	end       
8'b00000110:begin  // selecter for jump
	ALUOP= 3'b100;
	select1=0;
	select2=0;
	select3=0;
	select4=1;
	WRITEENABLE=0;
	DatamemSelect=0;
	READ=0;
	 WRITE=0;
	end  
8'b00001000:begin //selecter for lwd
        ALUOP= 3'b000;
	select1=0;
	select2=0;
	select3=0;
	select4=0;
	WRITEENABLE=1;
	DatamemSelect=1;
	READ=1;
	WRITE=0;
	end
     
8'b00001001:begin //selecter for lwi
        ALUOP= 3'b000;
	select1=0;
	select2=1;
	select3=0;
	select4=0;
	WRITEENABLE=1;
	DatamemSelect=1;
	READ=1;
	WRITE=0;
	end
8'b00001010:begin //selecter for swd
        ALUOP= 3'b000;
	select1=0;
	select2=0;
	select3=0;
	select4=0;
	WRITEENABLE=0;
	DatamemSelect=0;
	READ=0;
	WRITE=1;
	end
8'b00001011:begin //selecter for swi
        ALUOP= 3'b000;
	select1=0;
	select2=1;
	select3=0;
	select4=0;
        DatamemSelect=0;
	WRITEENABLE=0;
	READ=0;
	 WRITE=1;
	end
     
         
endcase
end


always@(negedge BUSYWAIT)           //at the negative edge of the busy wait signal read and write signals are set to zero
begin
READ=0;
WRITE=0;
end


always@(DatamemSelect,aluresult,READDATA)    
begin
if(DatamemSelect)                //if the data memory signal is high then INDATA is set with the READDATA
INDATA=READDATA;
else
INDATA=aluresult;                //else the INDATA is set with the alu result
end


//assign busywait=BUSYWAIT && INSBUSYWAIT;

reg_file myreg (INDATA, out1,out2,INSTRUCTION [18:16], INSTRUCTION[10:8] , INSTRUCTION[2:0] , WRITEENABLE , CLK , RESET,BUSYWAIT,INSBUSYWAIT);
//aluresult as IN,out1,out2,WRITEREG as INSTRUCTION[18:16] ,OUT1ADDRESS as INSTRUCTION[10:8],OUT2ADDRESS as INSTRUCTION[2:0],WRITEENABLE,clk,reset


always@(out1,WRITEDATA)
begin
WRITEDATA=out1;            //always out1 is assigned to the write data register
end


assign #1 complement=(~out2+8'b00000001);   //complement=inverse+1(2's complement of operand 2)


always@(complement,out2,select1)       //always for mux1
begin
if (select1)       //if the instruction is SUB
     outmux1= complement;                //then send the complement as the output of outmux1
else
     outmux1=out2;                         //else send operand 2
end

always@(outmux1,INSTRUCTION,select2)               //always block for mux2
begin
if (select2)       //if the INSTRUCTION is loadi
     outmux2=INSTRUCTION[7:0];             //then output immediate value
else
    outmux2=outmux1;                       //else output operand 2
end

assign and_output=select3 & ZERO;       //ZERO SIGNAL AND SELECT3 SIGNALS ARE PASSED THROUGH AND OPERATION AND THE RESULT IS ASSIGNED IN THE AND_OUTPUT WIRE
assign select5=and_output |select4;    //AND_OUTPUT SIGNAL AND SELECT4 SIGNALS ARE PASSED THROUGH OR OPERATION AND THE RESULT IS ASSIGNED IN THE SELECT5 WIRE
 

always @(INSTRUCTION)
begin
leftshift[1:0]=2'b00;                //THE LEFT MOST TWO BITS ARE SET TO ZERO
leftshift[9:2]=INSTRUCTION[23:16];   //THE REMAINING 8 BITS ARE SET WITH THE REGISTER DESTINATION ADDRESS
extended[9:0]=leftshift[9:0];        //10 BITS OF THE LEFTSHIFT REGISTER IS MOVED TO THE RIGHTMOST 10 BITS OF EXTENDED REGISTER
extended[31:10]={22{leftshift[9]}};  //THE REMAINING LEFTMOST BITS OF THE EXTENDED REGISTER IS FILLED WITH THE SIGN BIT  OF THE LEFTSHIFT REG
end

assign #2 target=extended+PC+4;


always@(target,select5)               //always block for mux
begin
if (select5)       //if the INSTRUCTION is j,beq
     pc=target;    //THEN PC IS SET WITH THE FINAL OFFSET IN THE TARGET REGISTER            
else
    pc=PC+4;       //ELSE pc is updated with the next instruction
end



alu myalu (out1,outmux2,aluresult,ALUOP,ZERO);  //alu is instantiated as myalu
assign ADDRESS=aluresult;                       //assign the alu result to the address wire


endmodule

