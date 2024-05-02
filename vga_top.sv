module vga_top
    (   input logic          i_clk25m,
        input logic          i_rstn_clk25m,
        
        // VGA driver signals
        output logic [9:0]   o_VGA_x,
        output logic [9:0]   o_VGA_y, 
        output logic         o_VGA_vsync,
        output logic         o_VGA_hsync, 
        output logic         o_VGA_video,
        output logic [2:0]   o_VGA_red, o_VGA_green, o_VGA_blue, // UPDATE: 9-bit rep
        output logic         active_nblank,        // vde signal
        
        // VGA read from BRAM 
        input  logic [8:0] i_pix_data, // UPDATE: 9-bit rep
        output reg  [18:0] o_pix_addr
    );
    
    vga_driver
    #(  .hDisp(640), 
        .hFp(16), 
        .hPulse(96), 
        .hBp(48), 
        .vDisp(480), 
        .vFp(10), 
        .vPulse(2),
        .vBp(33)                )
    vga_timing_signals
    (   .i_clk(i_clk25m         ),
        .i_rstn(i_rstn_clk25m   ),
        
        // VGA timing signals
        .o_x_counter(o_VGA_x    ),
        .o_y_counter(o_VGA_y    ),
        .o_video(o_VGA_video    ), 
        .o_vsync(o_VGA_vsync    ),
        .o_hsync(o_VGA_hsync    )
    );
    
    reg [2:0]   r_VGA_R, r_VGA_G, r_VGA_B; // UPDATE: 3 bit representation
    reg [1:0]   r_SM_state;
    localparam [1:0]    WAIT_1  = 0,
                        WAIT_2  = 'd1,  
                        READ    = 'd2;
                          
    always_ff @(posedge i_clk25m or negedge i_rstn_clk25m)
    if(!i_rstn_clk25m)
    begin
        r_SM_state <= WAIT_1;
        o_pix_addr <= 0; 
    end
    else
        case(r_SM_state)
        // Skip two frames
        WAIT_1: r_SM_state <= (o_VGA_x == 640 && o_VGA_y == 480) ? WAIT_2 : WAIT_1;
        WAIT_2: r_SM_state <= (o_VGA_x == 640 && o_VGA_y == 480) ? READ : WAIT_2; 
        READ: begin
            // Currently active video 
            if((o_VGA_y < 480) && (o_VGA_x < 639))
                o_pix_addr <= (o_pix_addr == 307199) ? 0 : o_pix_addr + 1'b1;
            else begin           
            // Next clock is active video 
            if( (o_VGA_x == 799) && ( (o_VGA_y == 524) || (o_VGA_y < 480) ) )
                o_pix_addr <= o_pix_addr + 1'b1;
            // Next clock not active video 
            else if(o_VGA_y >= 480)
                o_pix_addr <= 0;
            end
        end 
        endcase
    
    // Valid Video selects between a black RGB Pixel and BRAM pixel data 
    always_comb
        begin
            if(o_VGA_video)
                begin
                    r_VGA_R = i_pix_data[8:6];    // UPDATE: 3-bit rep
                    r_VGA_G = i_pix_data[5:3];
                    r_VGA_B = i_pix_data[2:0];
                end
            else begin
                    r_VGA_R = 0; 
                    r_VGA_G = 0;
                    r_VGA_B = 0;
            end
        end 
    
    assign o_VGA_red    = r_VGA_R;
    assign o_VGA_green  = r_VGA_G;
    assign o_VGA_blue   = r_VGA_B;
    
    
    
    //Added for vde signal
    //only display pixels between horizontal 0-639 and vertical 0-479 (640x480)
    reg display; 
    always_comb begin
    if ((o_VGA_x >= 10'b1010000000) | (o_VGA_y >= 10'b0111100000))
        display = 1'b0;
    else
        display = 1'b1;
    end
    
    assign active_nblank = display;

    
endmodule
