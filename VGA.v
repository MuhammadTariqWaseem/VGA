module VGA(clk,reset,Start,VR,VG,VB,GPins,H_Sync,V_Sync);
input clk, reset,Start;
output [7:0]VR,VG,VB;
output reg GPins,H_Sync,V_Sync;

parameter H_ACTIVE = 1024 , H_SYNC = 136 , H_BACK_PORCH = 160 , H_FRONT_PORCH = 24 , V_ACTIVE = 768,
          V_SYNC = 6, V_BACK_PORCH = 29, V_FRONT_PORCH = 3;
parameter Idle = 3'd0 , VBP = 3'd1 , HBP = 3'd2 , HA = 3'd3 , HFP = 3'd4 ,
          HS = 3'd5 , VFP = 3'd6 , VS = 3'd7;  
			 
reg [2:0]D,Q;
reg [10:0]X,Y;
reg [8:0]x1,y1;
reg [10:0]A;
reg a,b,c,d,RD;
reg [19:0]ADD;
wire [19:0]Addr;
wire [31:0]Data;
wire CE,OE,W;
wire [31:0]DATA;

always@(posedge clk or posedge reset) begin
	if((reset == 1'b1)) begin 
		X <= 11'd0; 
		Y <= 11'd0;
		x1 <= 9'd0;
		y1 <= 9'd0;
      ADD <= 20'd0;		
	end
	else if(y1 == V_SYNC + V_FRONT_PORCH + H_BACK_PORCH) begin
	   X <= 11'd0; 
		x1 <= 9'd0;
		y1 <= 9'd0;
		Y <= Y + 1;
		ADD <= ADD + 20'd1024;
	end
	else begin
	  if(a) y1 <= y1 + 1;
	  if(b) x1 <= x1 + 1;
	  if(c) X <= X + 1;
	  if(d) Y <= Y + 1;
	end
end

always@(*) begin 
   case(Q)
	   Idle : if(Start) D <= VBP;
		       else D <= Idle;	 
		VBP  : if(y1 == V_BACK_PORCH) D <= HBP;
		       else D <= VBP;		 
		HBP  : if(x1 == H_BACK_PORCH) D <= HA;
		       else D <= HBP;				 
		HA   : if(X == H_ACTIVE) D <= HFP;
		       else D <= HA;				 
		HFP  : if(x1 == H_FRONT_PORCH + H_BACK_PORCH) D <= HS;
		       else D <= HFP;			 
		HS   : if(x1 == H_SYNC + H_FRONT_PORCH + H_BACK_PORCH) D <= VFP;
		       else D <= HS;
		VFP  : if(y1 == V_FRONT_PORCH + V_BACK_PORCH) D <= VS;
		       else D <= VFP;
		VS   : if(y1 == V_SYNC + V_FRONT_PORCH + V_BACK_PORCH) begin
		          if(Y == V_ACTIVE) D <=Idle;
					 else D <= VBP;
				 end
		       else D <= VS;
		default : D <= Idle;
	endcase
end

always@(posedge clk or posedge reset) begin 
   if(reset) begin
	   Q<=3'b000;
	end 
	else Q <= D;
end

always@(Q) begin 
   case(Q)
	   Idle :  begin
		           a <= 0;
					  b <= 0;
					  c <= 0;
					  d <= 0;
					  H_Sync <= 1'b0;
					  V_Sync <= 1'b0;
		        end
	   VBP  :  begin 
		           a <= 1;
					  b <= 0;
					  c <= 0;
					  d <= 0;
					  H_Sync <= 1'b0;
					  V_Sync <= 1'b0;
				  end
		HBP  :  begin 
		           a <= 0;
					  b <= 1;
					  c <= 0;
					  d <= 0;
					  H_Sync <= 1'b0;
					  V_Sync <= 1'b0;
				  end
		HA   :  begin
		           a <= 0;
		           b <= 0;
					  c <= 1;
					  d <= 0;
					  H_Sync <= 1'b0;
					  V_Sync <= 1'b0;
				  end
		HFP  :  begin 
		           a <= 0;
		           c <= 0;
		           b <= 1;
					  d <= 0;
					  V_Sync <= 1'b0;
					  H_Sync <= 1'b0;
				  end
		HS   :  begin  
					  H_Sync <= 1'b1;
					  V_Sync <= 1'b0;
					  b <= 1;
					  a <= 0;
					  c <= 0;
					  d <= 0;
				  end
		VFP  :  begin 
		           b <= 0;
		           a <= 1;
					  c <= 0;
					  d <= 0;
		           H_Sync <= 1'b0;
					  V_Sync <= 1'b0;
				  end
		VS   :  begin 
		           b <= 0;
					  c <= 0;
		           V_Sync <= 1'b1;
					  H_Sync <= 1'b0;
					  if(1 == V_SYNC + V_FRONT_PORCH + V_BACK_PORCH) d <= 1;
                 a <= 1;
				  end
		default : {H_Sync,V_Sync,A,GPins} = 23'd0;
   endcase
end

SRAM #(20,32) S1(
    .clk(clk),
    .reset(reset),
    .sram_addr(Addr),
    .sram_data(Data),
    .sram_ce_n(CE),
    .sram_we_n(W),
    .sram_oe_n(OE),
    .read_enable(RD),
    .write_enable(1'b0),
    .user_addr(ADD + X),
    .user_read_data(DATA)
);

Memory M1(Addr,Data,CE,OE,W);
assign {VR,VG,VB} = DATA[23:0];

endmodule


