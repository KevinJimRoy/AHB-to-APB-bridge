module ahb_slave_interface( 
	input Hclk, Hrstn, Hwrite, Hready,
	input [31:0] Prdata,Haddr,Hwdata,
	input [1:0] Htrans,
	output reg [31:0] Haddr1,Haddr2,Hwdata1,Hwdata2,
	output reg Hwritereg,Hwritereg1,
	output reg valid,
	output reg [2:0] temp_selx,
	output [31:0] Hrdata,
	output [1:0] Hresp
);

// pipeline logic for address
always@(posedge Hclk) begin
	if (!Hrstn) begin
		Haddr1 <=0;
		Haddr2 <=0;
	end else begin
		Haddr1<=Haddr;
		Haddr2<=Haddr1;
	end
end

// pipeline logic for data
always @(posedge Hclk) begin
	if (!Hrstn) begin
		Hwdata1 <=0;
		Hwdata2 <=0;
	end else begin
		Hwdata1<=Hwdata;
		Hwdata2<=Hwdata1;
	end
end

// pipeline logic for write
always @(posedge Hclk) begin
	if (!Hrstn) begin
		Hwritereg <=0;
		Hwritereg1 <=0;
	end else begin
		Hwritereg<=Hwrite;
		Hwritereg1<=Hwritereg;
	end
end

//combinational logic for temp_selx
always @(*) begin
	if (Haddr >=32'h8000_0000 && Haddr < 32'h8400_0000) begin
		temp_selx=3'b001;
	end else if (Haddr >=32'h8400_0000 && Haddr < 32'h8800_0000) begin
		temp_selx=3'b010;
	end else if (Haddr >=32'h8800_0000 && Haddr < 32'h8c00_0000) begin
		temp_selx=3'b100;
	end else temp_selx =3'b0;
end


//combinational logic for valid
always @(*) begin
	if((Haddr >=32'h8000_0000 && Haddr <= 32'h8c00_0000) && (Hready==1) && ((Htrans ==2'b10)||(Htrans ==2'b11))) begin
		valid =1'b1;
	end else valid=1'b0;

end

assign Hresp =2'b0;
assign Hrdata=Prdata;


endmodule