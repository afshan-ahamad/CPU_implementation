/*
Module  : Data Cache 
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description	:

This file presents a skeleton implementation of the cache controller using a Finite State Machine model. Note that this code is not complete.
*/
`timescale  1ns/100ps

module dcache (clock,reset,C_WRITE,C_READ,C_Address,C_WRITEDATA,C_READDATA,busywait,mem_write,mem_read,mem_address,mem_writedata,mem_readdata,mem_busywait);

    input  clock, reset,C_WRITE,C_READ,mem_busywait;
    input [7:0] C_WRITEDATA,C_Address;
    input [31:0] mem_readdata;

    output reg mem_write,mem_read,busywait;
    output reg [5:0] mem_address;
    output reg [7:0] C_READDATA;
    output reg [31:0] mem_writedata;
   
   reg readaccess,writeaccess,dirtybit,validbit;
   reg [1:0] offset;
   reg [2:0] index,tag;
   reg [36:0] Cache_MEM [7:0];
   reg [31:0] BLOCK;
   reg hit;
  
   always@(BLOCK[7:0],BLOCK[15:8],BLOCK[23:16],BLOCK[31:24],offset) //data word is selected based on the offset from the block 
   begin
   #1
   case(offset)
         2'b00 :C_READDATA=BLOCK[7:0]; 
         2'b01 :C_READDATA=BLOCK[15:8];
         2'b10 :C_READDATA=BLOCK[23:16];
         2'b11 :C_READDATA=BLOCK[31:24];

  endcase 
  end
    
   always @(C_Address[5],C_Address[6],C_Address[7],tag[0],tag[1],tag[2],validbit)//tag comparison and deciding whether its a hit or a miss
    begin
    if(tag[0]==C_Address[5] && tag[1]==C_Address[6] && tag[2]==C_Address[7] && validbit)
    #0.9 hit=1'b1;
    else
    # 0.9 hit=1'b0;
    end
    

	
  always @(C_WRITE,C_READ)
	begin
		//Cache access signals are generated based on the read and write signals given to the cache
		busywait = ((C_READ || C_WRITE))? 1 : 0;
		readaccess = (C_READ && !C_WRITE)? 1 : 0;
		writeaccess = (!C_READ && C_WRITE)? 1 : 0;
	end

 always @(posedge clock)begin 
	
		if(readaccess == 1'b1 && hit == 1'b1)begin //read hit
			
			readaccess = 1'b0;
			busywait= 1'b0;
		end
		else if(writeaccess == 1'b1 && hit == 1'b1)begin //write hit
			busywait = 1'b0;
			
			#1
			case(offset)
			
				//Dataword is written to the cache based on the offset
				2'b00	:	Cache_MEM[index][7:0] = C_WRITEDATA;
				2'b01 	:	Cache_MEM[index][15:8] = C_WRITEDATA;
				2'b10 	:	Cache_MEM[index][23:16] = C_WRITEDATA;
				2'b11   :	Cache_MEM[index][31:24] = C_WRITEDATA;
		
			endcase
			Cache_MEM[index][35] = 1'b1;//set dirtybit = 1
                        Cache_MEM[index][36]=1'b1;  //set validbit = 1          	
			writeaccess = 1'b0;
			
		 
		 end
	end
    
  


always @(*)begin
		
		//Cache memory array is seperated as block ,tag ,dirtybit ,validbit ,offset and index
		if(readaccess == 1'b1 || writeaccess == 1'b1)
                begin
		
			#1
                        
			BLOCK =  Cache_MEM[C_Address[4:2]][31:0];
			tag =  Cache_MEM[ C_Address[4:2] ][34:32];
			dirtybit =  Cache_MEM[C_Address[4:2]][35];//dirty bit
			validbit = Cache_MEM[C_Address[4:2]][36];//valid bit
			offset =  C_Address[1:0];
			index =  C_Address[4:2];
			
		end
		
	
	end



/* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001,MEM_WRITE=3'b010,C_MEM_WRITE=3'b011;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((C_READ || C_WRITE) && !dirtybit && !hit)               //memory read 
                    next_state = MEM_READ;
                else if ((C_READ ||C_WRITE) && dirtybit && !hit)            //write-back
                    next_state = MEM_WRITE;
                else
                    next_state = IDLE;
            
            MEM_READ:
                if (!mem_busywait)
                    next_state = C_MEM_WRITE;
                else    
                    next_state = MEM_READ;


           MEM_WRITE:
             if (!mem_busywait)
                    next_state = MEM_READ;	//after memory writing,start the memory reading
                else    
                    next_state = MEM_WRITE;	//write back to the memory
					
	  C_MEM_WRITE:
               if ((C_READ || C_WRITE) && dirtybit && !hit)
                  next_state =C_MEM_WRITE ;
               else 
                  next_state =IDLE ;
              

               
        endcase
    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin
                mem_read = 0;
                mem_write = 0;
                mem_address = 6'dx;
                mem_writedata = 32'dx;
                
                
            end
         
            MEM_READ: 
            begin
                mem_read = 1;
                mem_write = 0;
                mem_address = {tag,index};
                mem_writedata = 32'dx;
                busywait=1;
                

               
               
            end


           		MEM_WRITE: 
            begin
                mem_read  = 1'd0;
                mem_write = 1'd1;
                mem_address ={tag,index};	//data block address from the cache
                mem_writedata =BLOCK;
               busywait=1;
                
               
               
              
            end
			
			C_MEM_WRITE: 
            begin
                mem_read = 1'd0;
                mem_write = 1'd0;
                mem_address = 6'dx;
                mem_writedata = 32'dx;
                 busywait=1;

                
				#1
				Cache_MEM[index][31:0] = mem_readdata;	//write a data block to the cache
				Cache_MEM[index][34:32] = C_Address[7:5];	//tag
				Cache_MEM[index][35] = 1'd0;	//dirty bit
				Cache_MEM[index][36] = 1'd1;	//valid bit
			
            end
            
            
            
            
        endcase
    end
    integer j;
    // sequential logic for state transitioning 
    always @(posedge clock, reset)
    
    begin
        if(reset)
        begin
            state = IDLE;
            busywait=1'b0;
             #1;
             for( j=0;j<8;j=j+1)
            begin
            Cache_MEM[j] = 37'd0;
            end
        end
        
        else begin
            state = next_state;
         end
    end
    /* Cache Controller FSM End */

endmodule
