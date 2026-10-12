module apb_interface(
    // --------------------------------------------------------
    // Inputs directly from the Bridge's APB Master Face
    // --------------------------------------------------------
    input wire penable, pwrite,
    input wire [2:0] psel,
    input wire [31:0] paddr, pwdata,
    
    // --------------------------------------------------------
    // Output back to the Bridge
    // --------------------------------------------------------
    output reg [31:0] Prdata,
    
    // --------------------------------------------------------
    // "Probe" Outputs (Used by the testbench to verify signals arrived)
    // --------------------------------------------------------
    output wire penable_out, pwrite_out,
    output wire [2:0] psel_out,
    output wire [31:0] paddr_out, pwdata_out
);

    // Pass the incoming signals out to the testbench probes
    assign penable_out = penable;
    assign pwrite_out  = pwrite;
    assign psel_out    = psel;
    assign paddr_out   = paddr;
    assign pwdata_out  = pwdata;

    // Dummy Peripheral Response Logic
    always @(*) begin
        // If it's a READ (!pwrite), in the Access Phase (penable == 1), 
        // AND one of the peripherals is actually selected (psel != 0)
        if (~pwrite && penable && (psel != 3'b000)) begin
            
            // Generate a random 8-bit value (0 to 255) to simulate reading a sensor
            Prdata = $random % 256; 
            
        end else begin
            // Default to 0 when not actively being read
            Prdata = 32'h0000_0000;
        end
    end

endmodule