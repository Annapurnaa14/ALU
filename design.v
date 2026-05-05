module eight_bit_ALU_rtl_design #(parameter N =4 OPA,OPB,INP_VALID,CIN,CLK,RST,CMD,CE,MODE,COUT,OFLOW,RES,G,E,L,ERR);

input [N-1:0] OPA,OPB;
input CLK,RST,CE,MODE,CIN;
input [1:0]INP_VALID;
input [3:0] CMD;

output reg [2*N-1:0] RES = {2*N{1'bz}};
output reg COUT = 1'bz;
output reg OFLOW = 1'bz;
output reg G = 1'bz;
output reg E = 1'bz;
output reg L = 1'bz;
output reg ERR = 1'bz;

reg [N-1:0] OPA_1, OPB_1;
reg signed [N:0] signedOPA , signedOPB;
reg signed [2*N:0] signedRES;

reg [N-1:0] Mul_OPA,Mul_OPB;
reg[2*N-1:0] Mul_RES;
reg M1active , M2active;


always @(*) 
 begin
  OPA_1 = {N{1'b0}};
  OPB_1 = {N{1'b0}};
    
  case(INP_VALID)
    2'b00: begin
           end
 
    2'b01: begin
            OPA_1 = OPA;
        end
 
        2'b10: begin
            OPB_1 = OPB;  
        end
 
        2'b11: begin
            OPA_1 = OPA;  
            OPB_1 = OPB;
        end
 
        default: begin
            OPA_1 = {N{1'b0}};
            OPB_1 = {N{1'b0}};
        end
    endcase
end

always@(posedge CLK or posede RST)
      begin
       if (RST) begin
        RES   <= {2*N{1'bz}};
        COUT  <= 1'bz;
        OFLOW <= 1'bz;
        G     <= 1'bz;
        E     <= 1'bz;
        L     <= 1'bz;
        ERR   <= 1'bz;

        Mul_OPA<= {N{1'b0}};
        Mul_OPA<= {N{1'b0}};
        Mul_RES<= {2*N{1'b0}};
        M1active<= 1'b0;
        M1active<= 1'b0;
    end
       else if(CE)                   
        begin
        M1active<=M2active;
        Mul_RES<=(Mul_OPA_1)*(Mul_OPB_1);
    if(CMD==4'b1001 && MODE==1'b1) begin
		Mul_OPA<=OPA_1;
		Mul_OPB<=OPB_1;
		M1active<=1'b1;
		end
      else
	begin
	    M1active<=1'b0;
        end

  if(MODE)         
         begin
            RES<={2*N{1'bz}};
            COUT<=1'bz;
            OFLOW<=1'bz;
            G=1'bz;
            E=1'bz;
            L=1'bz;
            ERR=1'bz;

            case(CMD)            
             4'b0000:             
               begin             
                 RES<={{n{1'b0}},OPA_1} + {{N{1'b0}}, OPB_1};
                 COUT<=RES[N]?1'b1 : 1'b0;
               end

	     4'b0001:             
               begin
                 OFLOW<=(OPA_1<OPB_1)? 1'b1: 1'b0;
                 RES<=OPA_1-OPB_1;
               end

             4'b0010:             
               begin
                 RES<={{n{1'b0}},OPA_1} + {{N{1'b0}}, OPB_1}+CIN;
                 COUT<=RES[N]?1:0;
               end

            4'b0011:            
              begin
                OFLOW<=(OPA<OPB)?1'b1:1'b0;
                RES<=OPA-OPB-CIN;
              end

           4'b0100: begin  		
		if(INP_VALID==2'b01) 
                     RES<=OPA_1+1;
		end               
           4'b0101: begin  		
		if(INP_VALID==2'b01) 
                     RES<=OPA_1-1;
		end 
           4'b0110: begin     
		if(INP_VALID==2'b10) 
                     RES<=OPB_1+1;
		end 
           4'b0111: begin     		
		if(INP_VALID==2'b10) 
                     RES<=OPB_1-1;
	 	end
            4'b1000:     
              begin
                RES={2*{1'bz}};
                    if(OPA_1==OPB_1)
                     begin
                         E<=1'b1, G<=1'bz, L<=1'bz;
             end
            else if(OPA_1>OPB_1)
               begin
                   E=1'bz; G=1'b1, L=1'bz;
               end
            else 
             begin
               E=1'bz, G=1'bz, L=1'b1;
             end
           end
    
 	 4'b1001:
	  begin
		if(M2active)
	          RES <= Mul_RES;
            end

	4'b1010:
	  begin
	    RES<=(OPA_1<<OPB_1)*OPB_1
	 end


	 4'b1011: begin
                    signedOPA_ext = $signed({{1'b0}, OPA_1});                       
                    signedOPB_ext = $signed({{1'b0}, OPB_1});
                    signedRES     = signedOPA_ext + signedOPB_ext;
                    RES   <= signedRES[N-1:0];
                    COUT  <= signedRES[N];
                    OFLOW <= (OPA_1[N-1] == OPB_1[N-1]) && (signedRES[N-1] != OPA_1[N-1]);
                    if ($signed(OPA_1) > $signed(OPB_1)) 
			  begin
                            G <= 1'b1; E <= 1'b0; L <= 1'b0;
                    	  end 
			else if ($signed(OPA_1) == $signed(OPB_1)) 
		       	  begin
                            G <= 1'b0; E <= 1'b1; L <= 1'b0;
                    	  end 
			else 
			  begin
                            G <= 1'b0; E <= 1'b0; L <= 1'b1;
                          end
                end
          
	4'b1100:
	    begin
	       signedOPA_ext = $signed({{1'b0}, OPA_1});                       
               signedOPB_ext = $signed({{1'b0}, OPB_1});
               signedRES = signedOPA_ext + signedOPB_ext;
               RES   <= signedRES[N-1:0];
               COUT  <= signedRES[N];
               OFLOW <= (OPA_1[N-1] == OPB_1[N-1]) && (signedRES[N-1] != OPA_1[N-1]);
	       if ($signed(OPA_1) > $signed(OPB_1)) 
			  begin
                            G <= 1'b1; E <= 1'b0; L <= 1'b0;
                    	  end 
			else if ($signed(OPA_1) == $signed(OPB_1)) 
		       	  begin
                            G <= 1'b0; E <= 1'b1; L <= 1'b0;
                    	  end 
			else 
			  begin
                            G <= 1'b0; E <= 1'b0; L <= 1'b1;
                          end
		end

default:   
            begin
            RES<={2*N{1'bz}};
            COUT<=1'bz;
            OFLOW<=1'bz;
            G<=1'bz;
            E<=1'bz;
            L<=1'bz;
            ERR<=1'bz;
           end
          endcase

         end
        else     
        begin 

           RES<=9'bzzzzzzzzz;
           COUT<=1'bz;
           OFLOW<=1'bz;
           G<=1'bz;
           E<=1'bz;
           L<=1'bz;
           ERR<=1'bz;
           case(CMD)    
                4'b0000: RES <= {{N{1'b0}}, OPA_1 & OPB_1};     
                4'b0001: RES <= {{N{1'b0}}, ~(OPA_1 & OPB_1)};  
                4'b0010: RES <= {{N{1'b0}}, OPA_1 | OPB_1};     
                4'b0011: RES <= {{N{1'b0}}, ~(OPA_1 | OPB_1)};  
                4'b0100: RES <= {{N{1'b0}}, OPA_1 ^ OPB_1};     
                4'b0101: RES <= {{N{1'b0}}, ~(OPA_1 ^ OPB_1)};  
                4'b0110: RES <= {{N{1'b0}}, ~OPA_1};            
                4'b0111: RES <= {{N{1'b0}}, ~OPB_1};            
                4'b1000: RES <= {{N{1'b0}}, OPA_1 >> 1};                              
                4'b1001: RES <= {{N{1'b0}}, OPA_1 << 1};        
                4'b1010: RES <= {{N{1'b0}}, OPB_1 >> 1};        
                4'b1011: RES <= {{N{1'b0}}, OPB_1 << 1};       

             4'b1100: 
                 begin                       
		casex (OPB)
                  8'b0000_X000 : RES=OPA;
       	      	  8'b0000_X001 : RES={OPA_1[6:0], OPA_1[7]}; 
	       	  8'b0000_X010 : RES= {OPA_1[5:0], OPA_1[7:6]};
       	       	  8'b0000_X011 : RES={OPA_1[4:0], OPA_1[7:5]};
		  8'b0000_X100 : RES={OPA_1[3:0], OPA_1[7:4]};
       	       	  8'b0000_X101 : RES={OPA_1[3:0], OPA_1[7:3]};
	          8'b0000_X110 : RES={OPA_1[3:0], OPA_1[7:2]};
       	          8'b0000_X111 : RES={OPA_1[3:0], OPA_1[7:1]};
		  default: RES=OPA;
		endcase
             end

	    4'b1100:
		begin
		ERR = 1'b0;
    		if (OPB[N-1:3] != 0) begin
        	ERR = 1'b1;
        	RES = {1'b0, OPA};
    		end

    		else begin
        	if (OPB[2:0] == 0)
            		RES = {1'b0, OPA};
        	else
            		RES = {1'b0, (OPA << OPB[2:0]) | (OPA >> (N - OPB[2:0]))};
   		 end
		end

 	   4'b1101: begin 
		if(OPB[7:4]==4'b111)
		  ERR = 1'b1;
		else
		ERR = 1'b0;
    		if (OPB[N-1:3] != 0) begin
       			 ERR = 1'b1;
        		 RES = {1'b1, OPA};
    			 end
		else 
		  begin
       		   if (OPB[2:0] == 0)
                   RES = {1'b0, OPA};
               else
            	   RES = {1'b0, (OPA >> OPB[2:0]) | (OPA << (N - OPB[2:0]))};
    		end
		end
             
             default: 
               begin
               RES=9'bzzzzzzzzz;
               COUT=1'bz;
               OFLOW=1'bz;
               G=1'bz;
               E=1'bz;
               L=1'bz;
               ERR=1'bz;
               end
          endcase
     end
    end
   end
endmodule

	
:
