module apb_interface(
    input wire penable, pwrite,
    input wire [2:0] psel,
    input wire [31:0] paddr, pwdata,
    
    output reg [31:0] Prdata,
    output wire penable_out, pwrite_out,
    output wire [2:0] psel_out,
    output wire [31:0] paddr_out, pwdata_out
);
    assign penable_out = penable;
    assign pwrite_out  = pwrite;
    assign psel_out    = psel;
    assign paddr_out   = paddr;
    assign pwdata_out  = pwdata;

    always @(*) begin
        if (~pwrite && penable && (psel != 3'b000)) begin 
            Prdata = $random % 256;    
        end else begin
            Prdata = 32'h0000_0000;
        end
    end

endmodule
