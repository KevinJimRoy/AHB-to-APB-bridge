module top_tb();

    // ========================================================
    // 1. SYSTEM SIGNALS (Clock & Reset)
    // ========================================================
    reg Hclk;
    reg Hrstn;

    // ========================================================
    // 2. AHB INTERCONNECT WIRES (Master <-> Bridge)
    // ========================================================
    wire Hwrite, Hready, hr_readyout;
    wire [1:0] Htrans, Hresp;
    wire [2:0] Hburst, Hsize;
    wire [31:0] Haddr, Hwdata, Hrdata;

    // ========================================================
    // 3. APB INTERCONNECT WIRES (Bridge <-> Slave)
    // ========================================================
    wire penable, pwrite;
    wire [2:0] psel;
    wire [31:0] paddr, pwdata, Prdata;

    // Output probes from the APB slave (for waveform viewing)
    wire penable_out, pwrite_out;
    wire [2:0] psel_out;
    wire [31:0] paddr_out, pwdata_out;

    // ========================================================
    // 4. INSTANTIATE THE AHB MASTER BFM (The Processor)
    // ========================================================
    ahb_master PROCESSOR (
        .Hclk(Hclk), 
        .Hrstn(Hrstn), 
        .hr_readyout(hr_readyout), // Receives stall signal from Bridge
        .Hresp(Hresp), 
        .Hrdata(Hrdata),           // Receives read data from Bridge
        
        // Outputs driving the bus
        .hwrite(Hwrite), 
        .Hready(Hready), 
        .Htrans(Htrans), 
        .hwdata(Hwdata), 
        .haddr(Haddr),
        .Hburst(Hburst),
        .Hsize(Hsize)
    );

    // ========================================================
    // 5. INSTANTIATE THE DUT (The Bridge Top Module)
    // ========================================================
   bridge_top BRIDGE (
        // AHB Face
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

        // APB Face
        .Prdata(Prdata), 
        
        .psel(psel), 
        .penable(penable), 
        .pwrite(pwrite), 
        .paddr(paddr), 
        .pwdata(pwdata)
    );

    // ========================================================
    // 6. INSTANTIATE THE APB SLAVE BFM (The Peripherals)
    // ========================================================
    apb_interface PERIPHERALS (
        .penable(penable), 
        .pwrite(pwrite), 
        .psel(psel), 
        .paddr(paddr), 
        .pwdata(pwdata), 
        
        .Prdata(Prdata), // Sends random read data back to Bridge
        
        // Probes for waveform debugging
        .penable_out(penable_out), 
        .pwrite_out(pwrite_out), 
        .psel_out(psel_out), 
        .paddr_out(paddr_out), 
        .pwdata_out(pwdata_out)
    );

    // ========================================================
    // 7. CLOCK GENERATION
    // ========================================================
    initial begin
        Hclk = 0;
        forever #5 Hclk = ~Hclk; // 100MHz clock
    end

    // ========================================================
    // 8. TEST SEQUENCE
    // ========================================================
    initial begin
        // ----------------------------------------------------
        // A. SYSTEM RESET
        // ----------------------------------------------------
        Hrstn = 0;
        #20; 
        Hrstn = 1;
        #10;

        // ----------------------------------------------------
        // B. TEST 1: SINGLE WRITE TO PERIPHERAL 1 (temp_selx = 001)
        // ----------------------------------------------------
        $display("[%0t] Starting Single Write...", $time);
        // Address: 0x8000_0000 | Data: 0xDEADBEEF
        PROCESSOR.single_write(32'h8000_0000, 32'hDEADBEEF);
        
        // Wait for the bridge to finish settling
        #30; 

        // ----------------------------------------------------
        // C. TEST 2: SINGLE READ FROM PERIPHERAL 2 (temp_selx = 010)
        // ----------------------------------------------------
        $display("[%0t] Starting Single Read...", $time);
        // Address: 0x8400_0000 
        PROCESSOR.single_read(32'h8400_0000);
        
        // The slave BFM will generate a random number and send it back.
        // Wait for it to clear.
        #30;

        // ----------------------------------------------------
        // D. TEST 3: PIPELINED BURST WRITE TO PERIPHERAL 3 (temp_selx = 100)
        // ----------------------------------------------------
        $display("[%0t] Starting INCR4 Burst Write...", $time);
        // This will force the FSM into the ST_WRITEP avalanche states!
        PROCESSOR.burst_incr4_write(
            32'h8800_0000,   // Start Address
            32'h1111_1111,   // Data 1
            32'h2222_2222,   // Data 2
            32'h3333_3333,   // Data 3
            32'h4444_4444    // Data 4
        );

        // Give the bridge time to drain the final data beat
        #100;
        
        $display("[%0t] Simulation Complete!", $time);
        $finish;
    end

endmodule