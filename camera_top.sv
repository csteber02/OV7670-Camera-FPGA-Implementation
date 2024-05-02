module camera_top
#(parameter CAM_CONFIG_CLK = 100_000_000)
     (  input logic          i_clk,
        input logic          i_rstn_clk,
        input logic          i_rstn_pclk, 
       
        // Start/Done signals for cam init      
        input logic          i_cam_start,
        output logic         o_cam_done,
        
        // I/O camera
        input logic          i_pclk, 
        input logic [7:0]    i_pix_byte, 
        input logic          i_vsync,
        input logic          i_href,
        output logic         o_reset,     
        output logic         o_pwdn,       
        output logic         o_siod,
        output logic         o_sioc,
        
        // Outputs to BRAM
        output logic         o_pix_wr, 
        output logic [11:0]  o_pix_data,
        output logic [18:0]  o_pix_addr
    );
    
    assign o_reset = 1;       // 0: reset registers   1: normal mode
    assign o_pwdn  = 0;       // 0: normal mode       1: power down mode
       
    logic       w_start_db;
        
    logic w_start_btn_db;
    sync_debounce button_sync_1 (
           .clk    (i_clk),
           
           .d      (i_cam_start),
           .q      (w_start_db)
        );
    
    camera_init 
    #(  .CLK_F(CAM_CONFIG_CLK       ), 
        .SCCB_F(400_000)            )
    configure_cam
    (   .i_clk(i_clk                ),
        .i_rstn(i_rstn_clk          ),
        
        // Start/Done signals for cam init    
        .i_cam_init_start(w_start_db),
        .o_cam_init_done(o_cam_done ),
        
        // SCCB lines
        .o_siod(o_siod              ),
        .o_sioc(o_sioc              ),
        
        // Signals used for testbench
        .o_data_sent_done(          ),
        .o_SCCB_dout(               )
    );
    
    camera_capture
    cam_pixels
    (   // Cam VGA frame timing signals
        .i_pclk(i_pclk         ), 
        .i_vsync(i_vsync       ),
        .i_href(i_href         ),
        
        // Poll for when the cam is done init
        .i_cam_done(o_cam_done ),
        
        .i_D(i_pix_byte        ),
        .o_pix_addr(o_pix_addr ),
        .o_wr(o_pix_wr         ),           
        .o_pix_data(o_pix_data )  
    );
      
endmodule
