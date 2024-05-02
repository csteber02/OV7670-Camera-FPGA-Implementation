`ifdef SYNTHESIS
parameter COUNTER_WIDTH = 15; 
`else
parameter COUNTER_WIDTH = 1;
`endif

module sync_debounce (
    input wire clk, 
    input wire d, 
    output reg q
);

    reg ff1, ff2;
    reg [COUNTER_WIDTH : 0] counter;
    
    always @(posedge clk) begin
        ff1 <= d; // flop input once
        ff2 <= ff1; // flop input twice

        // Change button only when 2^(COUNTER_WIDTH) stable input cycles are recorded 
        if (~(ff1 ^ ff2)) begin // detect an input difference per clock cycle
            if (~counter[COUNTER_WIDTH]) begin
                counter <= counter + 1'b1; // waiting for input to become stable
            end else begin
                q <= ff2; // input is idle
            end
        end else begin
            counter <= 0; // reset counter when bounce detected
        end
    end

endmodule


