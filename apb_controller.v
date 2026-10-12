module apb_controller(
    input Hclk, Hrstn, Hwrite, Hwrite_reg, valid,
    input [31:0] Haddr, Haddr_1, Haddr_2, Hwdata, Hwdata_1, Hwdata_2, Prdata,
    input [2:0] temp_selx,
    output reg penable, pwrite, hr_readyout,
    output reg [31:0] paddr, pwdata,
    output reg [2:0] psel
);

    reg penable_temp, pwrite_temp, hr_readyout_temp;
    reg [2:0] psel_temp;
    reg [31:0] paddr_temp, pwdata_temp;

    parameter 
        ST_IDLE     = 3'b000,
        ST_WAIT     = 3'b001, 
        ST_WRITEP   = 3'b010,
        ST_WRITE    = 3'b011,
        ST_WENABLE  = 3'b100,
        ST_WENABLEP = 3'b101,
        ST_READ     = 3'b110,
        ST_RENABLE  = 3'b111;

    reg [2:0] present, next;
    always @(posedge Hclk) begin
        if (!Hrstn) present <= ST_IDLE;
        else present <= next;
    end

    always @(*) begin
        case (present)
            ST_IDLE: begin
                if (valid & Hwrite) next = ST_WAIT;
                else if (valid & !Hwrite) next = ST_READ;
                else next = ST_IDLE; 
            end

            ST_WAIT: begin
                if (valid) next = ST_WRITEP;
                else next = ST_WRITE;
            end

            ST_WRITE: begin
                if (valid) next = ST_WENABLEP;
                else next = ST_WENABLE;
            end

            ST_WRITEP: begin
                next = ST_WENABLEP;
            end

            ST_WENABLEP: begin
                if (!Hwrite_reg) next = ST_READ;
                else if (valid) next = ST_WRITEP;
                else next = ST_WRITE;
            end

            ST_WENABLE: begin
                if (!valid) next = ST_IDLE;
                else if (Hwrite) next = ST_WAIT;
                else next = ST_READ;
            end

            ST_READ: begin
                next = ST_RENABLE;
            end

            ST_RENABLE: begin
                if (!valid) next = ST_IDLE;
                else if (Hwrite) next = ST_WAIT;
                else next = ST_READ;
            end

            default: begin
               next = ST_IDLE;
            end
        endcase 
    end
    always @(*) begin
        paddr_temp       = paddr;
        pwdata_temp      = pwdata;
        pwrite_temp      = pwrite;
        psel_temp        = psel;
        penable_temp     = penable;
        hr_readyout_temp = hr_readyout;

        case(present)
            ST_IDLE: begin
                if (valid && !Hwrite) begin
                    paddr_temp       = Haddr;
                    pwrite_temp      = Hwrite;
                    psel_temp        = temp_selx;
                    penable_temp     = 0;
                    hr_readyout_temp = 0;
                end else if (valid && Hwrite) begin
                    psel_temp        = 0;
                    penable_temp     = 0;
                    hr_readyout_temp = 1; 
                end else begin
                    psel_temp        = 0;
                    penable_temp     = 0;
                    hr_readyout_temp = 1; 
                end
            end

            ST_WAIT: begin
                penable_temp     = 0;
                hr_readyout_temp = 0; 
            end

            ST_READ: begin
                paddr_temp       = Haddr;
                pwrite_temp      = Hwrite;
                psel_temp        = temp_selx;
                penable_temp     = 0;
                hr_readyout_temp = 0;
            end

            ST_WRITE: begin
                paddr_temp       = Haddr_1; 
                pwdata_temp      = Hwdata;
                pwrite_temp      = Hwrite;
                psel_temp        = temp_selx;
                penable_temp     = 0;
                hr_readyout_temp = 0;
            end

            ST_WRITEP: begin
                paddr_temp       = Haddr_2; 
                pwdata_temp      = Hwdata;
                pwrite_temp      = Hwrite_reg;
                psel_temp        = temp_selx;
                penable_temp     = 0;
                hr_readyout_temp = 0;
            end

            ST_RENABLE, ST_WENABLE, ST_WENABLEP: begin
                penable_temp     = 1;
                hr_readyout_temp = 1;
            end

        endcase
    end

    always @(posedge Hclk) begin
        if (!Hrstn) begin
            paddr       <= 0;
            pwdata      <= 0;
            pwrite      <= 0;
            psel        <= 0;
            penable     <= 0;
            hr_readyout <= 1; 
        end else begin
            paddr       <= paddr_temp;
            pwdata      <= pwdata_temp;
            pwrite      <= pwrite_temp;
            psel        <= psel_temp;
            penable     <= penable_temp;
            hr_readyout <= hr_readyout_temp;
        end
    end

endmodule