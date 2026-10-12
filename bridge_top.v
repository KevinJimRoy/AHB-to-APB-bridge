module bridge_top (

    input  wire Hclk, 
    input  wire Hrstn,
    input  wire Hwrite, 
    input  wire Hready,
    input  wire [1:0]  Htrans,
    input  wire [31:0] Haddr, 
    input  wire [31:0] Hwdata,
    
    output wire [31:0] Hrdata,
    output wire [1:0]  Hresp,
    output wire hr_readyout, 
    input  wire [31:0] Prdata,
    
    output wire [2:0]  psel,
    output wire penable, 
    output wire pwrite,
    output wire [31:0] paddr, 
    output wire [31:0] pwdata
);

    wire valid;
    wire [2:0] temp_selx;
    
    wire [31:0] internal_Haddr1, internal_Haddr2;
    wire [31:0] internal_Hwdata1, internal_Hwdata2;
    wire internal_Hwritereg, internal_Hwritereg1;


    ahb_slave_interface AHB_SLAVE (
        .Hclk(Hclk),
        .Hrstn(Hrstn),
        .Hwrite(Hwrite),
        .Hready(Hready),
        .Htrans(Htrans),
        .Haddr(Haddr),
        .Hwdata(Hwdata),
        .Prdata(Prdata),
        

        .valid(valid),
        .temp_selx(temp_selx),
        .Haddr1(internal_Haddr1),
        .Haddr2(internal_Haddr2),
        .Hwdata1(internal_Hwdata1),
        .Hwdata2(internal_Hwdata2),
        .Hwritereg(internal_Hwritereg),
        .Hwritereg1(internal_Hwritereg1),
        
        .Hrdata(Hrdata),
        .Hresp(Hresp)
    );

    apb_controller APB_MASTER (
        .Hclk(Hclk),
        .Hrstn(Hrstn),
        .Hwrite(Hwrite),
        .valid(valid),
        .temp_selx(temp_selx),
        .Haddr(Haddr),
        .Prdata(Prdata),
        .Haddr_1(internal_Haddr1),
        .Haddr_2(internal_Haddr2),
        .Hwdata(Hwdata), // Live data bus
        .Hwdata_1(internal_Hwdata1),
        .Hwdata_2(internal_Hwdata2),
        .Hwrite_reg(internal_Hwritereg),
        
        .penable(penable),
        .pwrite(pwrite),
        .hr_readyout(hr_readyout),
        .paddr(paddr),
        .pwdata(pwdata),
        .psel(psel)
    );

endmodule