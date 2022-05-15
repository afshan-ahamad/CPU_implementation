`timescale  1ns/100ps

module FORWARD(DATA2,Result);  //Module to forward the data to the output  
input [7:0] DATA2;             //Declaration of 8 bit input port
output  [7:0] Result;           //Declarartion of one 8 bit output port

assign #1 Result=DATA2;  //Data2 is assigned to the output port after a time delay of 1 time unit

endmodule


module ADD(DATA1,DATA2,Result); //Module to add data

input [7:0] DATA1,DATA2;        //Declaration of two 8 bit input ports
output [7:0] Result;            //Declarartion of one 8 bit output port



  assign #2 Result= DATA1 + DATA2;
                           //After a time delay of 2 time units Data1 and Data2 is added and assigned to result

endmodule


module AND(DATA1,DATA2,Result); //Module for the AND operation

input [7:0] DATA1,DATA2;        //Declaration of two 8 bit input ports
output [7:0] Result;            //Declarartion of one 8 bit output port


  assign #1 Result= DATA1 & DATA2;
                       //After a time delay of 1 time unit Data1 and Data2 are AND and then assigned to result

endmodule


module OR(DATA1,DATA2,Result); //Module for the OR operation
input [7:0] DATA1,DATA2;       //Declaration of two 8 bit input ports
output [7:0] Result;           //Declarartion of one 8 bit output port


  assign #1 Result=DATA1 | DATA2;
                          //After a time delay of 1 time unit Data1 and Data2 goes through  OR operation and assigned to the result



endmodule



module alu(DATA1, DATA2, RESULT, SELECT,ZERO); //Main module for the ALU

input [7:0] DATA1,DATA2;                  //Declaration of two 8 bit input ports
input [2:0] SELECT;                       //Declarartion of one 2 bit output port port
output reg [7:0] RESULT;	          //Declarartion of one 8 bit output port register	
output reg ZERO;                 	//Declarartion of one bit output port register	
wire [7:0] WFORWARD,WADD,WAND,WOR;      //Declarartion of four 8 bit wires



FORWARD F1 (DATA2,WFORWARD);        //instantiating FORWARD module as F1
ADD F2 (DATA1, DATA2,WADD);        //instantiating ADD module as F2
AND F3 (DATA1, DATA2,WAND);        //instantiating AND module as F3
OR F4 (DATA1, DATA2,WOR);         //instantiating OR modue as F4

always@(SELECT,WFORWARD,WADD,WAND,WOR) //always block is executed when either one of the sesitivity list is triggered
begin
case(SELECT)                          

3'b000:  RESULT=WFORWARD;      //When select is 000 output of FORWARD to result
3'b001:  RESULT=WADD;          //When select is 001 output of ADD to result
3'b010:  RESULT=WAND;          //When select is 010 output of AND to result
3'b011:  RESULT=WOR; 	       //When select is 011 output of OR to result

endcase

if(RESULT==8'b00000000)
ZERO=1'b1;
else
ZERO=1'b0;

end

endmodule


