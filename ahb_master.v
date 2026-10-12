module ahb_master(
    input wire Hclk, Hrstn, hr_readyout,
    input wire [1:0] Hresp,
    input wire [31:0] Hrdata,
    
    output reg hwrite, Hready,
    output reg [1:0] Htrans,
    output reg [31:0] hwdata, haddr,
    output reg [2:0] Hburst, Hsize
);

    task single_write(input [31:0] start_addr, input [31:0] data_payload);
    begin

        @(posedge Hclk); #2;
        hwrite = 1;         
        Htrans = 2'b10;    
        Hsize  = 3'b010; 
        Hburst = 3'b000;   
        Hready = 1;        
        haddr  = start_addr;
        
        @(posedge Hclk);
        while(!hr_readyout) @(posedge Hclk); 
        #2;
        Htrans = 2'b00;     
        hwdata = data_payload;
    end
    endtask

    task single_read(input [31:0] start_addr);
    begin

        @(posedge Hclk); #2;
        hwrite = 0;         
        Htrans = 2'b10;   
        Hsize  = 3'b010;    
        Hburst = 3'b000;    
        Hready = 1;
        haddr  = start_addr;

        @(posedge Hclk);
        while(!hr_readyout) @(posedge Hclk); 
        
        #2;
        Htrans = 2'b00;
        
    end
    endtask

    task burst_incr4_write(
        input [31:0] start_addr, 
        input [31:0] d1, input [31:0] d2, input [31:0] d3, input [31:0] d4
    );
    begin
        @(posedge Hclk); #2;
        hwrite = 1;
        Htrans = 2'b10;     
        Hsize  = 3'b010;   
        Hburst = 3'b011;   
        Hready = 1;
        haddr  = start_addr;

        @(posedge Hclk);
        while(!hr_readyout) @(posedge Hclk); 
        #2;
        Htrans = 2'b11;            
        haddr  = start_addr + 4; 
        hwdata = d1;          

        @(posedge Hclk);
        while(!hr_readyout) @(posedge Hclk); 
        #2;
        Htrans = 2'b11; 
        haddr  = start_addr + 8;    
        hwdata = d2;                

        @(posedge Hclk);
        while(!hr_readyout) @(posedge Hclk); 
        #2;
        Htrans = 2'b11; 
        haddr  = start_addr + 12; 
        hwdata = d3;               

        @(posedge Hclk);
        while(!hr_readyout) @(posedge Hclk); 
        #2;
        Htrans = 2'b00;
        hwdata = d4;
    end
    endtask

endmodule
