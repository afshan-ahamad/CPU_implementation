
`timescale  1ns/100ps

module ins_cache (clock,PC,reset,c_instruction,c_busywait,mem_instruction,imem_read,imem_address,imem_busywait);

    input  clock, reset,imem_busywait;  //imem_busywait:busywait signal which comes from the ins memory to the ins cache
    input [31:0] PC;
    input [127:0] mem_instruction;      //data block which comes from ins_mem to the ins_cache
    
    output reg imem_read,c_busywait;   //imem_read:read signal which goes into the memory from the cache
    output reg [5:0] imem_address;     //address which goes from the ins cache into the ins memory
    output reg [31:0] c_instruction;   //instruction that goes into the cpu from the ins cache
    
    reg [31:0] instruction;            //temp reg to store the instruction           

   reg [1:0]  offset;
   reg [2:0]  index;
   reg [2:0]  PCaddress_tag,tag;
   reg [131:0] iCache [7:0];           //8 132 bits instruction cache to store instructions
   reg [127:0] BLOCK;                 //128 bit instruction block
   reg hit;
   reg validbit;
  


always @(*)begin
		
		
		//one time unit delay for extracting the stored values values
		#1;

           //splitting the CPU given address in to tag,index and offset

            offset         =  PC[3:2];
			index          =  PC[6:4];
            PCaddress_tag  =  PC[9:7]; 
             
    
            //finding the correct cache entry and extracting the stored data block,
            //tag and valid bits 
            //This extraction was done based on the index extracted from address      
			BLOCK    =  iCache[index][127:0];      //instruction block
			tag      =  iCache[index][130:128];    //tag value
			validbit =  iCache[index][131];        //valid bit
			
			
		
		
	
end

/*
//instruction in the cache is seperated into segments

assign #1  BLOCK    = iCache[ PC[6:4]][127:0];      //instruction block
assign #1  tag      = iCache[ PC[6:4]][130:128];    //tag value
assign #1  validbit = iCache[ PC[6:4]][131];        //valid bit
assign #1  index    = PC[6:4];				        //index of the cache entry
assign #1  offset   = PC[3:2];				        //offset

*/

//tag comparison and deciding whether its a hit or a miss 
always @(PCaddress_tag,tag,validbit)
begin

if(tag==PCaddress_tag && validbit)

begin

  //if it is a successfull making hit high and giving a delay of 0.9 time unit
  #0.9 hit=1'b1;

end  


else
begin

  //if it is a unsuccessfull making hit low and giving a delay of 0.9 time unit
  #0.9 hit=1'b0;

end 

end

/*
//tag comparison and deciding whether its a hit or a miss
   
    
//assign #0.9 hit=(tag==PCaddress_tag && validbit) ? 1:0;
*/







  //instruction word is selected based on the offset from the block 
   always@(BLOCK[31:0],BLOCK[63:32],BLOCK[95:64],BLOCK[127:96],offset) 

   begin

   //1 time unit delay for extracting the data block
   //this delay will overlap with tag comaprison delay of 0.9    
  
   #1;
   case(offset)
         2'b00 :instruction=BLOCK[31:0]; 
         2'b01 :instruction=BLOCK[63:32];
         2'b10 :instruction=BLOCK[95:64];
         2'b11 :instruction=BLOCK[127:96];
   
  endcase
 
  end
    



   
    


always @(posedge clock)begin

if(!hit) begin

//In the event of a miss, the cpu must be stalled
c_busywait = 1'b1;

end

else

//if it is hit we dont want to stall the cpu
c_busywait=1'b0;

end


//**********************************************************
//                   READ-HIT
//**********************************************************


//Read hits are handeled Asynchronously
always @(instruction)
begin

//when hit is detected,instruction is sent to the CPU
//this the data block which is extracted using the offset
if(hit)begin
	
c_instruction = instruction;

end

end


		

	




/* Cache Controller FSM Start */

    parameter IDLE = 2'b00, IMEM_READ = 2'b01,IC_WRITE=2'b10;
    reg [1:0] state, nextstate;

    // combinational next state logic
    always @(*)
    begin
        case (state)

            IDLE:
            begin

            if(!hit)
              nextstate=IMEM_READ;
            else
              nextstate=IDLE; 
            
            end


           IMEM_READ:

           begin

            if(!imem_busywait)
               nextstate=IC_WRITE;
            else
                nextstate=IMEM_READ;

            end
           
           IC_WRITE:
             
               nextstate=IDLE; 
            
           
               
        endcase

    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin
               imem_read = 0;
               imem_address = 6'dx;
               
            end
         
            IMEM_READ: 
            begin
                imem_read = 1;
                imem_address ={tag,index};   //a 6 bit address to read from instruction memory
                c_busywait=1;
                
            end


          
	        IC_WRITE:
            begin
                imem_read = 1'd0;
                imem_address = 6'dx;
                
                //this writing operation happens in the instruction cache block after fetching the  memory
               //there is 1 time unit delay for this operation
                 #1;
				iCache[index][127:0]   = mem_instruction;	//write a data block to the cache
				iCache[index][130:128] = PCaddress_tag;	    //tag received from CPU address
			    iCache[index][131]   = 1'd1;	            //valid bit
                //validbit               = 1'd1;	            //valid bit
			
            end
            
            
            
            
        endcase
    end



    integer j;
   
    always @(posedge clock, reset)
    
    begin
        if(reset)
        begin
            state = IDLE;
            c_busywait=1'b0;
             #1;
             for( j=0;j<8;j=j+1)
            begin
            iCache[j] = 131'b0;
            end
        end
        
        else begin
            state = nextstate;
         end
    end
    /* Cache Controller FSM End */

endmodule
