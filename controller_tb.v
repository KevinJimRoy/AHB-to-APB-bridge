module controller_tb();
    reg Hclk, Hrstn, Hwrite, Hwrite_reg, valid;
    reg [31:0] Haddr, Haddr_1, Haddr_2, Hwdata, Hwdata_1, Hwdata_2, Prdata;
    reg [2:0] temp_selx;
    
    wire penable, pwrite, hr_readyout;
    wire [31:0] paddr, pwdata;
    wire [2:0] psel;

    // DUT Instantiation
    apb_controller dut (
        Hclk, Hrstn, Hwrite, Hwrite_reg, valid, 
        Haddr, Haddr_1, Haddr_2, Hwdata, Hwdata_1, Hwdata_2, Prdata, 
        temp_selx, penable, pwrite, hr_readyout, paddr, pwdata, psel
    );

    // Clock Generation
    initial Hclk = 0;
    always #5 Hclk = ~Hclk;

    // Test Stimulus
    initial begin
        // 0. Initialize everything to zero
        Hrstn = 0; valid = 0; Hwrite = 0; Hwrite_reg = 0;
        Haddr = 0; Haddr_1 = 0; Haddr_2 = 0;
        Hwdata = 0; Hwdata_1 = 0; Hwdata_2 = 0;
        Prdata = 0; temp_selx = 0;

        // Hold reset for a few cycles, then release it
        #15;
        Hrstn = 1;

        // -----------------------------------------------------------
        // TEST CASE 1: Single Read 
        // Path: ST_IDLE -> ST_READ -> ST_RENABLE -> ST_IDLE
        // -----------------------------------------------------------
        @(negedge Hclk);
        valid = 1; 
        Hwrite = 0; // 0 means Read
        Haddr = 32'h8000_0000; 
        temp_selx = 3'b001;
        
        @(negedge Hclk);
        // The FSM is now in ST_READ. We pull valid to 0 so no more requests happen.
        valid = 0; 
        
        // Wait 3 clock cycles to let the FSM finish and return to IDLE
        repeat(3) @(negedge Hclk);

        // -----------------------------------------------------------
        // TEST CASE 2: Single Write
        // Path: ST_IDLE -> ST_WAIT -> ST_WRITE -> ST_WENABLE -> ST_IDLE
        // -----------------------------------------------------------
        @(negedge Hclk);
        valid = 1; 
        Hwrite = 1; // 1 means Write
        Haddr = 32'h8400_0000; 
        temp_selx = 3'b010;

        @(negedge Hclk);
        // The FSM is now in ST_WAIT. The data has finally arrived!
        // We simulate the pipeline interface doing its job by shifting the address:
        Haddr_1 = Haddr; 
        Hwdata = 32'hDEADBEEF; // The payload data
        valid = 0; // Signal that the processor is done sending requests

        // Wait 3 clock cycles to let it finish writing and return to IDLE
        repeat(3) @(negedge Hclk);

        // -----------------------------------------------------------
        // TEST CASE 3: Pipelined Write (The Avalanche)
        // Path: ST_IDLE -> ST_WAIT -> ST_WRITEP -> ST_WENABLEP -> ST_IDLE
        // -----------------------------------------------------------
        // Start Transfer A
        @(negedge Hclk);
        valid = 1; 
        Hwrite = 1;
        Haddr = 32'h8800_0000; // Address A
        temp_selx = 3'b100;

        @(negedge Hclk);
        // FSM is in ST_WAIT. 
        // 1. Data A arrives.
        Hwdata = 32'h1111_1111; 
        Haddr_1 = 32'h8800_0000; // Address A shifts into pipeline
        
        // 2. But wait! The processor immediately fires Transfer B!
        valid = 1;  // VALID STAYS HIGH!
        Hwrite = 1;
        Haddr = 32'h8800_0004; // Address B arrives on the live bus

        @(negedge Hclk);
        // FSM saw valid=1 during ST_WAIT, so it jumped to ST_WRITEP!
        // 1. Data B arrives.
        Hwdata = 32'h2222_2222;
        // 2. The pipeline shifts again.
        Haddr_2 = Haddr_1; // Address A shifts deep into the pipeline (Haddr_2)
        Haddr_1 = 32'h8800_0004; // Address B shifts into Haddr_1
        Hwrite_reg = 1; // The write signal pipeline shift
        
        valid = 0; // Okay, the avalanche is over. Let the bridge finish.

        // Wait 5 clock cycles to observe the bridge clearing the pipeline
        repeat(5) @(negedge Hclk);

        // End the simulation
        $finish;
    end

endmodule