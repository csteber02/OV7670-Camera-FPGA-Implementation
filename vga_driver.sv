module vga_driver
#(parameter hDisp  = 640, 
    parameter hFp    = 16,
    parameter hPulse = 96,
    parameter hBp    = 48,   
    parameter vDisp  = 480,
    parameter vFp    = 10,   
    parameter vPulse = 2,
    parameter vBp    = 33)
    (   input logic          i_clk,
        input logic          i_rstn,
        output logic [9:0]   o_x_counter,
        output logic [9:0]   o_y_counter,
        output logic         o_video,
        output logic         o_hsync,
        output logic         o_vsync
    );
     
     // Horizonal timing     hEND = 800
     localparam hEND        = hDisp + hFp + hPulse + hBp; 
     localparam hSyncStart  = hDisp + hFp;
     localparam hSyncEnd    = hDisp + hFp + hPulse;
             
     // Vertical timing      vEND = 524
     localparam vEND        = vDisp + vFp + vPulse + vBp;
     localparam vSyncStart  = vDisp + vFp;
     localparam vSyncEnd    = vDisp + vFp + vPulse;
     
     reg [9:0] hc;
     reg [9:0] vc; 
     
     always_ff @(posedge i_clk or negedge i_rstn)
        begin
            if(!i_rstn) begin
                hc      <= 0;
                vc      <= 0;
            end
            else begin
                if(hc == hEND-1)
                begin
                    hc <= 0;
                    if(vc == vEND-1)
                    vc <= 0; 
                    else
                        vc <= vc + 1'b1;
                end 
                else
                    hc <= hc + 1'b1; 
            end
        end 
        
     // Output (x,y) coordinates of the pixel and timing signals
     assign o_x_counter = hc;
     assign o_y_counter = vc;
     assign o_video     = ((hc >= 0) && (hc < hDisp) && (vc >= 0)  && (vc < vDisp)); 
     assign o_hsync     = ~((hc >= hSyncStart) && (hc < hSyncEnd));
     assign o_vsync     = ~((vc >= vSyncStart) && (vc < vSyncEnd)); 
                        
endmodule
