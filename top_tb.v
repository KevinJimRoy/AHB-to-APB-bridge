module top_tb();

    reg Hclk;
    reg Hrstn;

    wire Hwrite, Hready, hr_readyout;
    wire [1:0] Htrans, Hresp;
    wire [2:0] Hburst, Hsize;
    wire [31:0] Haddr, Hwdata, Hrdata;

    wire penable, pwrite;
    wire [2:0] psel;
    wire [31:0] paddr, pwdata, Prdata;

    wire penable_out, pwrite_out;
    wire [2:0] psel_out;
    wire [31:0] paddr_out, pwdata_out;

    ahb_master PROCESSOR (
        .Hclk(Hclk), 
        .Hrstn(Hrstn), 
        .hr_readyout(hr_readyout),
        .Hresp(Hresp), 
        .Hrdata(Hrdata),           

        .hwrite(Hwrite), 
        .Hready(Hready), 
        .Htrans(Htrans), 
        .hwdata(Hwdata), 
        .haddr(Haddr),
        .Hburst(Hburst),
        .Hsize(Hsize)
    );

   bridge_top BRIDGE (
        .Hclk(Hclk), 
        .Hrstn(Hrstn), 
        .Hwrite(Hwrite), 
        .Hready(Hready), 
        .Htrans(Htrans), 
        .Haddr(Haddr), 
        .Hwdata(Hwdata), 
        
        .Hrdata(Hrdata), 
        .Hresp(Hresp), 
        .hr_readyout(hr_readyout),

        .Prdata(Prdata), 
        
        .psel(psel), 
        .penable(penable), 
        .pwrite(pwrite), 
        .paddr(paddr), 
        .pwdata(pwdata)
    );

    apb_interface PERIPHERALS (
        .penable(penable), 
        .pwrite(pwrite), 
        .psel(psel), 
        .paddr(paddr), 
        .pwdata(pwdata), 
        
        .Prdata(Prdata),
        
        .penable_out(penable_out), 
        .pwrite_out(pwrite_out), 
        .psel_out(psel_out), 
        .paddr_out(paddr_out), 
        .pwdata_out(pwdata_out)
    );
    initial begin
        Hclk = 0;
        forever #5 Hclk = ~Hclk; 
    end


    initial begin

        Hrstn = 0;
        #20; 
        Hrstn = 1;
        #10;

        $display("[%0t] Starting Single Write...", $time);

        PROCESSOR.single_write(32'h8000_0000, 32'hDEADBEEF);
        
        #30; 

        $display("[%0t] Starting Single Read...", $time);

        PROCESSOR.single_read(32'h8400_0000);

        #30;

        $display("[%0t] Starting INCR4 Burst Write...", $time);

        PROCESSOR.burst_incr4_write(
            32'h8800_0000,   
            32'h1111_1111,   
            32'h2222_2222,  
            32'h3333_3333,  
            32'h4444_4444  
        );

        #100;
        
        $display("[%0t] Simulation Complete!", $time);
        $finish;
    end

endmodule
