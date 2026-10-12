module slave_interface_tb();
reg Hclk, Hrstn, Hwrite, Hready;
reg [31:0] Prdata,Haddr,Hwdata;
reg [1:0] Htrans;
wire [31:0] Haddr1,Haddr2,Hwdata1,Hwdata2,Hrdata;
wire Hwritereg,Hwritereg1,valid;
wire  [2:0] temp_selx;
wire [1:0] Hresp;


ahb_slave_interface dut(
    .Hclk(Hclk),       
    .Hrstn(Hrstn),
    .Hwrite(Hwrite),
    .Hready(Hready),
    .Prdata(Prdata),
    .Haddr(Haddr),
    .Hwdata(Hwdata),
    .Htrans(Htrans),
    .Haddr1(Haddr1),
    .Haddr2(Haddr2),
    .Hwdata1(Hwdata1),
    .Hwdata2(Hwdata2),
    .Hwritereg(Hwritereg),
    .Hwritereg1(Hwritereg1),
    .valid(valid),
    .temp_selx(temp_selx),
    .Hrdata(Hrdata),
    .Hresp(Hresp)
);

initial Hclk = 0;
always #5 Hclk = ~Hclk;

    initial begin
        Hrstn = 0;
        Hwrite = 0;
        Hready = 0;
        Haddr = 0;
        Hwdata = 0;
        Htrans = 0;
        Prdata = 0;

        #10;
        Hrstn = 1;
        Hready = 1;
        #10;
        Hwrite = 1;
        Htrans = 2'b10;
        Haddr = 32'h8000_0004;
        Hwdata = 32'hDEADBEEF;

        #20;

        Htrans = 2'b00; 
        Haddr = 32'h8000_0008;

        #30;
        $finish;
    end



endmodule