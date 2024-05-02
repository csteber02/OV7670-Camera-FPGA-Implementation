module camera_capture
    (   input logic         i_pclk,
        input logic         i_vsync,
        input logic         i_href,    
        input logic  [7:0]  i_D,
        input logic         i_cam_done,
        output logic  [18:0] o_pix_addr, 
        output logic  [11:0] o_pix_data,      
        output reg         o_wr                   
    );
       
    // Negative/Positive Edge Detection of vsync for frame start/frame done signal
    reg         r1_vsync,    r2_vsync; 
    logic        frame_start, frame_done;
    
    initial { r1_vsync, r2_vsync } = 0; 
    always_ff @(posedge i_pclk)
            {r2_vsync, r1_vsync} <= {r1_vsync, i_vsync}; 
  
    assign frame_start = (r1_vsync == 0) && (r2_vsync == 1);    // Negative Edge of vsync
    assign frame_done  = (r1_vsync == 1) && (r2_vsync == 0);    // Positive Edge of vsync
     
    // FSM for capturing pixel data in pclk domain
    localparam [1:0] WAIT   = 2'd0,
                     IDLE   = 2'd1,
                     CAPTURE = 2'd2;
    
    reg        r_half_data;             
    reg [1:0]  SM_state;
    reg [3:0]  pixel_data;
                                                                         
    always_ff @(posedge i_pclk)
        begin
            r_half_data         <= 0;
            o_wr                <= 0;
            o_pix_data          <= o_pix_data;  
            o_pix_addr          <= o_pix_addr;
            SM_state            <= WAIT;
            case(SM_state)
                WAIT: 
                    begin
                        // Skip the first two frames on start-up
                        SM_state    <= (frame_start && i_cam_done) ? IDLE : WAIT;
                    end
                IDLE:        
                    begin
                        SM_state   <= (frame_start) ? CAPTURE : IDLE;
                        o_pix_addr <= 0;
                        o_pix_data <= 0; 
                    end
                CAPTURE:
                    begin
                        SM_state   <= (frame_done) ? IDLE : CAPTURE;
                        o_pix_addr <= (r_half_data) ? o_pix_addr + 1'b1 : o_pix_addr;   
                        if(i_href)
                            begin 
                                 // Register first byte
                                 if(!r_half_data)   
                                    pixel_data <= i_D[3:0];      
                                 r_half_data    <= ~r_half_data;                       
                                 o_wr           <= (r_half_data) ? 1'b1 : 1'b0;
                                 o_pix_data     <= (r_half_data) ? {pixel_data, i_D} : o_pix_data; 
                            end 
                    end  
            endcase
        end
             
endmodule