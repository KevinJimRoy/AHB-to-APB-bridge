module ahb_master(
    input wire Hclk, Hrstn, hr_readyout,
    input wire [1:0] Hresp,
    input wire [31:0] Hrdata,
    
    output reg hwrite, Hready,
    output reg [1:0] Htrans,
    output reg [31:0] hwdata, haddr,
    output reg [2:0] Hburst, Hsize
);

    // ========================================================
    // TASK: SINGLE WRITE
    // ========================================================
    task single_write(input [31:0] start_addr, input [31:0] data_payload);
    begin
        // 1. ADDRESS PHASE
        @(posedge Hclk); #2;
        hwrite = 1;         // 1 = Write
        Htrans = 2'b10;     // NONSEQUENTIAL
        Hsize  = 3'b010;    // 32-bit transfer
        Hburst = 3'b000;    // SINGLE transfer
        Hready = 1;         // Master is ready
        haddr  = start_addr;

        // 2. WAIT FOR SLAVE TO BE READY
        @(posedge Hclk);
        while(!hr_readyout) @(posedge Hclk); // Stall if slave pulls ready LOW
        
        // 3. DATA PHASE (Send data, and return to IDLE)
        #2;
        Htrans = 2'b00;     // Return bus to IDLE
        hwdata = data_payload;
    end
    endtask

    // ========================================================
    // TASK: SINGLE READ
    // ========================================================
    task single_read(input [31:0] start_addr);
    begin
        // 1. ADDRESS PHASE
        @(posedge Hclk); #2;
        hwrite = 0;         // 0 = Read
        Htrans = 2'b10;     // NONSEQUENTIAL
        Hsize  = 3'b010;    
        Hburst = 3'b000;    
        Hready = 1;
        haddr  = start_addr;

        // 2. WAIT FOR SLAVE TO FETCH DATA
        @(posedge Hclk);
        while(!hr_readyout) @(posedge Hclk); // Stall until slave has the data
        
        // 3. IDLE THE BUS
        #2;
        Htrans = 2'b00; // Return bus to IDLE
        
        // At this exact moment, Hrdata contains the valid read data!
    end
    endtask

    // ========================================================
    // TASK: INCR4 BURST WRITE (4 back-to-back incrementing writes)
    // ========================================================
    task burst_incr4_write(
        input [31:0] start_addr, 
        input [31:0] d1, input [31:0] d2, input [31:0] d3, input [31:0] d4
    );
    begin
        // --- BEAT 1: Address 1 (NONSEQ) ---
        @(posedge Hclk); #2;
        hwrite = 1;
        Htrans = 2'b10;     // NONSEQ for the first transfer of a burst
        Hsize  = 3'b010;    // 32-bit width
        Hburst = 3'b011;    // INCR4 (4-beat incrementing burst)
        Hready = 1;
        haddr  = start_addr;

        // --- BEAT 2: Address 2 (SEQ) + Data 1 ---
        @(posedge Hclk);
        while(!hr_readyout) @(posedge Hclk); 
        #2;
        Htrans = 2'b11;             // SEQ for the remaining burst transfers
        haddr  = start_addr + 4;    // Increment address by 4 bytes
        hwdata = d1;                // Pipeline data 1

        // --- BEAT 3: Address 3 (SEQ) + Data 2 ---
        @(posedge Hclk);
        while(!hr_readyout) @(posedge Hclk); 
        #2;
        Htrans = 2'b11; 
        haddr  = start_addr + 8;    // Increment address
        hwdata = d2;                // Pipeline data 2

        // --- BEAT 4: Address 4 (SEQ) + Data 3 ---
        @(posedge Hclk);
        while(!hr_readyout) @(posedge Hclk); 
        #2;
        Htrans = 2'b11; 
        haddr  = start_addr + 12;   // Increment address
        hwdata = d3;                // Pipeline data 3

        // --- CLEANUP: IDLE Bus + Data 4 ---
        // The address phase is over, we just need to deliver the final data payload
        @(posedge Hclk);
        while(!hr_readyout) @(posedge Hclk); 
        #2;
        Htrans = 2'b00;             // IDLE
        hwdata = d4;                // Pipeline final data
    end
    endtask

endmodule