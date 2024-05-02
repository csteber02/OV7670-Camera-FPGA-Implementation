//Engineers: Colby Steber
//           Alexander Mellas
           
//Implementation of livestreaming OV7670 Camera to HDMI via FPGA
//FPGA: AMD Urbana, Spartan 7 Chip
//Developed for ECE 385 Spring 2024, University of Illinois Urbana-Champaign
//datasheet for OV7670 https://web.mit.edu/6.111/www/f2016/tools/OV7670_2006.pdf
//All rights reserved
//Code base began from GitHub Repo by amsacks

module camera_madness_star
    (   input logic i_top_clk,
        input logic i_top_rst,
        
        input logic  i_top_cam_start, 
        output logic o_top_cam_done, 
        
        // I/O to camera
        input logic       i_top_pclk, 
        input logic [7:0] i_top_pix_byte,
        input logic       i_top_pix_vsync,
        input logic       i_top_pix_href,
        output logic      o_top_reset,
        output logic      o_top_pwdn,
        output logic      o_top_24clk,
        output logic      o_top_siod,
        output logic      o_top_sioc,
        
    
        // UPDATE: I/O to HDMI
        output logic hdmi_tmds_clk_n,
        output logic hdmi_tmds_clk_p,
        output logic [2:0]hdmi_tmds_data_n,
        output logic [2:0]hdmi_tmds_data_p

    );
    // I/O to VGA 
    logic [2:0] o_top_vga_red, o_top_vga_green, o_top_vga_blue;
    logic       o_top_vga_vsync, o_top_vga_hsync, vde;
    logic o_top_xclk;
    
    
    // Connect cam_top/vga_top modules to BRAM
    logic [11:0] i_bram_pix_data,    o_bram_pix_data;
    logic [8:0] i_bram_pix_data_nine,    o_bram_pix_data_nine;
    logic [18:0] i_bram_pix_addr,    o_bram_pix_addr; 
    logic        i_bram_pix_wr;
           
    // Reset synchronizers for all clock domains
    reg r1_rstn_top_clk,    r2_rstn_top_clk;
    reg r1_rstn_pclk,       r2_rstn_pclk;
    reg r1_rstn_clk25m,     r2_rstn_clk25m;
        
    logic CLK_25MHZ;  //  25MHZ Clock
    logic CLK_125MHZ; // 125MHZ Clock
    logic CLK_24MHZ;  //  24MHZ Clock
    
    
    logic locked; // UPDATE: new
    
    assign i_bram_pix_data_nine = {i_bram_pix_data[11:9], i_bram_pix_data[7:5], i_bram_pix_data[3:1]}; // UPDATE: new
    
    
    //clock wizard: 25MHZ and 125MHZ -- removed reset
    clk_wiz_0 clk_wiz_0 (
        .clk_out1(CLK_25MHZ),
        .clk_out2(CLK_125MHZ),
        .clk_out3(CLK_24MHZ), //clock to be passed to camera, not a true 24MHz
        .locked(locked),
        .clk_in1(i_top_clk)
    );
    
    assign o_top_24clk = CLK_24MHZ; // Supply Camera with 25MHz Clock
    
    logic w_rst_btn_db; 
    
    // Debounce top level button - invert reset to have debounced negedge reset 
    logic i_top_rst_db;
    sync_debounce button_sync (
           .clk    (i_top_clk),
           
           .d      (~i_top_rst),  // Pass Inverse of Active High
           .q      (w_rst_btn_db) // Active Low
        );
    
    // Double FF for negedge reset synchronization - Resets are Active Low
    always_ff @(posedge i_top_clk or negedge w_rst_btn_db)
        begin
            if(!w_rst_btn_db) {r2_rstn_top_clk, r1_rstn_top_clk} <= 0; 
            else              {r2_rstn_top_clk, r1_rstn_top_clk} <= {r1_rstn_top_clk, 1'b1}; 
        end 
    always_ff @(posedge CLK_25MHZ or negedge w_rst_btn_db)
        begin
            if(!w_rst_btn_db) {r2_rstn_clk25m, r1_rstn_clk25m} <= 0; 
            else              {r2_rstn_clk25m, r1_rstn_clk25m} <= {r1_rstn_clk25m, 1'b1}; 
        end
    always_ff @(posedge i_top_pclk or negedge w_rst_btn_db)
        begin
            if(!w_rst_btn_db) {r2_rstn_pclk, r1_rstn_pclk} <= 0; 
            else              {r2_rstn_pclk, r1_rstn_pclk} <= {r1_rstn_pclk, 1'b1}; 
        end 
    
    // FPGA-camera interface
    camera_top 
    #(  .CAM_CONFIG_CLK(100_000_000)    )
    OV7670_cam
    (
        .i_clk(i_top_clk                ), 
        .i_rstn_clk(r2_rstn_top_clk     ), 
        .i_rstn_pclk(r2_rstn_pclk       ),
        
        // I/O for camera init
        .i_cam_start(i_top_cam_start    ),
        .o_cam_done(o_top_cam_done      ), 
        
        // I/O camera
        .i_pclk(i_top_pclk              ),
        .i_pix_byte(i_top_pix_byte      ), 
        .i_vsync(i_top_pix_vsync        ), 
        .i_href(i_top_pix_href          ),
        .o_reset(o_top_reset            ),
        .o_pwdn(o_top_pwdn              ),
        .o_siod(o_top_siod              ),
        .o_sioc(o_top_sioc              ), 
        
        // Outputs from camera to BRAM
        .o_pix_wr(                      ),
        .o_pix_data(i_bram_pix_data     ),
        .o_pix_addr(i_bram_pix_addr     )
    );
    
    
    pixel_memory pixel_memory (
    // BRAM Write signals (cam_top)
	.addra		(i_bram_pix_addr), 
	.clka		(i_top_pclk),  //i_top_pclk
	.dina   	(i_bram_pix_data_nine), //i_bram_pix_data_nine
	.ena		(1'b1), 
	.wea		(1'b1),
	
	// BRAM Read signals (vga_top)
	.addrb		(o_bram_pix_addr), 
	.clkb		(CLK_25MHZ), 
	.dinb       (9'b0),
	.doutb   	(o_bram_pix_data_nine), 
	.enb		(1'b1),
	.web        (1'b0)
);
     
    logic X; 
    logic Y;
    
    vga_top display_interface
    (
        .i_clk25m(CLK_25MHZ              ),
        .i_rstn_clk25m(r2_rstn_clk25m   ), 
        
        // VGA timing signals
        .o_VGA_x(X                      ),
        .o_VGA_y(Y                      ), 
        .o_VGA_vsync(o_top_vga_vsync    ),
        .o_VGA_hsync(o_top_vga_hsync    ), 
        .o_VGA_video(                   ),
        
        // VGA RGB Pixel Data
        .o_VGA_red(o_top_vga_red        ),
        .o_VGA_green(o_top_vga_green    ),
        .o_VGA_blue(o_top_vga_blue      ), 
        .active_nblank(vde),                    // UPDATE: Added
        
        // VGA read/write from/to BRAM
        .i_pix_data(o_bram_pix_data_nine     ), 
        .o_pix_addr(o_bram_pix_addr     )
    );
    
    
    // UPDATE: ADD VGA to HDMI
    // NOTE: IF WE EXPAND TO 12 BIT COLOR REPRESENTATION, THIS IP MUST BE UPDATED
    //Real Digital VGA to HDMI converter
    hdmi_tx_0 vga_to_hdmi (
        //Clocking and Reset
        .pix_clk(CLK_25MHZ),  
        .pix_clkx5(CLK_125MHZ),
        .pix_clk_locked(locked),
        .rst(~r2_rstn_clk25m), // active high
        //Color and Sync Signals
        .red(o_top_vga_red), //o_top_vga_red
        .green(o_top_vga_green), //o_top_vga_green
        .blue(o_top_vga_blue), //o_top_vga_blue
        .hsync(o_top_vga_hsync),
        .vsync(o_top_vga_vsync),
        .vde(vde),
        
        //aux Data (unused)
        .aux0_din(4'b0),
        .aux1_din(4'b0),
        .aux2_din(4'b0),
        .ade(1'b0),
        
        //Differential outputs
        .TMDS_CLK_P(hdmi_tmds_clk_p),          
        .TMDS_CLK_N(hdmi_tmds_clk_n),          
        .TMDS_DATA_P(hdmi_tmds_data_p),         
        .TMDS_DATA_N(hdmi_tmds_data_n)          
    );
    
endmodule
