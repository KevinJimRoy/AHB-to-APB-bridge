module controller_tb();
    reg Hclk, Hrstn, Hwrite, Hwrite_reg, valid;
    reg [31:0] Haddr, Haddr_1, Haddr_2, Hwdata, Hwdata_1, Hwdata_2, Prdata;
    reg [2:0] temp_selx;
    
    wire penable, pwrite, hr_readyout;
    wire [31:0] paddr, pwdata;
    wire [2:0] psel;

    apb_controller dut (
        Hclk, Hrstn, Hwrite, Hwrite_reg, valid, 
        Haddr, Haddr_1, Haddr_2, Hwdata, Hwdata_1, Hwdata_2, Prdata, 
        temp_selx, penable, pwrite, hr_readyout, paddr, pwdata, psel
    );

    initial Hclk = 0;
    always #5 Hclk = ~Hclk;


    initial begin
        Hrstn = 0; valid = 0; Hwrite = 0; Hwrite_reg = 0;
        Haddr = 0; Haddr_1 = 0; Haddr_2 = 0;
        Hwdata = 0; Hwdata_1 = 0; Hwdata_2 = 0;
        Prdata = 0; temp_selx = 0;
        #15;
        Hrstn = 1;

        @(negedge Hclk);
        valid = 1; 
        Hwrite = 0;
        Haddr = 32'h8000_0000; 
        temp_selx = 3'b001;
        
        @(negedge Hclk);
        valid = 0; 
        
        repeat(3) @(negedge Hclk);

        @(negedge Hclk);
        valid = 1; 
        Hwrite = 1; // 1 means Write
        Haddr = 32'h8400_0000; 
        temp_selx = 3'b010;

        @(negedge Hclk);
        Haddr_1 = Haddr; 
        Hwdata = 32'hDEADBEEF;
        valid = 0;

        repeat(3) @(negedge Hclk);

        @(negedge Hclk);
        valid = 1; 
        Hwrite = 1;
        Haddr = 32'h8800_0000;
        temp_selx = 3'b100;

        @(negedge Hclk);

        Hwdata = 32'h1111_1111; 
        Haddr_1 = 32'h8800_0000;
        
        valid = 1; 
        Hwrite = 1;
        Haddr = 32'h8800_0004;

        @(negedge Hclk);
        Hwdata = 32'h2222_2222;

        Haddr_2 = Haddr_1;
        Haddr_1 = 32'h8800_0004;
        Hwrite_reg = 1;
        
        valid = 0;

        repeat(5) @(negedge Hclk);
        $finish;
    end

endmodule
