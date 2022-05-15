`timescale  1ns/100ps

module reg_file (IN, OUT1 , OUT2, INADDRESS, OUT1ADDRESS , OUT2ADDRESS , WRITE , CLK , RESET,BUSYWAIT,INSBUSYWAIT); //Module for a REGISTER file

input [7:0] IN ;                                //8bit input port to get the input data
output [7:0] OUT1,OUT2;                         //2 8bit output ports to output the data
input  [2:0] INADDRESS,OUT1ADDRESS,OUT2ADDRESS ;//3 3bit input ports to input-address data
input WRITE,CLK,RESET;                          //3 input ports to get the write,clk and reset datas

reg [7:0] store [7:0] ;  
input BUSYWAIT,INSBUSYWAIT;                       //8 8bit registers to store data

initial
begin
#5;
$display("\n\t\t\t---------------------------------------------------------------\n");
$display("\t\ttime\treg0\treg1\treg2\treg3\treg4\treg5\treg6\treg7\n");
$display("\n\t\t\t---------------------------------------------------------------\n");
$monitor($time, "\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d",store[0],store[1],store[2],store[3],store[4],store[5],store[6],store[7]);
end


assign #2 OUT1= store[OUT1ADDRESS];   //after a time delay of two time units data in out1address register is read into the OUT1 port
assign #2 OUT2= store[OUT2ADDRESS];   //after a time delay of two time units data in out2address register is read into the OUT2 port

always @ (posedge  CLK ) //Always at a rising edge of  a clock the following code block is executed
 begin
 # 0.1
 if (WRITE && !BUSYWAIT && !INSBUSYWAIT)             //when write is enabaled
 	begin
	       #0.9  store[INADDRESS] = IN;  //fetch the data to the IN input and after a time delay of 1 time unit it is stored at the address of INADDRESS of the store register
	end
end


always @ (posedge  CLK ) //Always at a rising edge of  a clock the following code block is executed
 begin
if(RESET)           //if reset is enabled all the 8bit registers are set with zero
	begin 
	#1;
	      store[0]=    8'b00000000;
	      store[1]=    8'b00000000;
	      store[2]=    8'b00000000;
              store[3]=    8'b00000000;
	      store[4]=    8'b00000000;
	      store[5]=    8'b00000000;
	      store[6]=    8'b00000000;
	      store[7]=    8'b00000000;
	end
end
endmodule

