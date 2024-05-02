module camera_init
#(parameter CLK_F = 100_000_000,
    parameter SCCB_F = 400_000)
    (   input logic      i_clk,
        input logic      i_rstn,      
        input logic      i_cam_init_start,
        output logic     o_siod,
        output logic     o_sioc,
        output logic     o_cam_init_done,        
    );
    
    logic [7:0]  w_cam_rom_addr;
    logic [15:0] w_cam_rom_data;    
    logic [7:0]  w_send_addr,    w_send_data;  
    logic        w_start_sccb,   w_ready_sccb; 
    
    camera_rom 
    OV7670_Registers 
    (   .i_clk(i_clk            ),
        .i_rstn(i_rstn          ), 
        
        .i_addr(w_cam_rom_addr  ),
        .o_dout(w_cam_rom_data  )
    );
    
    camera_config 
    #(  .CLK_F(CLK_F)                   )
    OV7670_config
    (   .i_clk(i_clk                    ),
        .i_rstn(i_rstn                  ),
         
         // Ready/Start signals for SCCB: Poll for ready signal to start sending cam ROM data
        .i_i2c_ready(w_ready_sccb       ),
        .o_i2c_start(w_start_sccb       ),
        
        // Start/Done signals for cam init 
        .i_config_start(i_cam_init_start),
        .o_config_done(o_cam_init_done  ),
        
        // Read through cam ROM
        .i_rom_data(w_cam_rom_data      ),
        .o_rom_addr(w_cam_rom_addr      ),
        .o_i2c_addr(w_send_addr         ),
        .o_i2c_data(w_send_data         ) 
    );
      
    sccb_control 
    #(  .CLK_F(CLK_F), 
        .SCCB_F(SCCB_F)         )
    SCCB_HERE 
    (   .i_clk(i_clk            ),
        .i_rstn(i_rstn          ),
        
        // SCCB control signals 
        .i_read(1'b0            ),      
        .i_write(1'b1           ),
        .i_start(w_start_sccb   ),
        .i_restart(1'b0         ),
        .i_stop(1'b0            ),
        .o_ready(w_ready_sccb   ),
        
        // SCCB addr/data signals  
        .i_din(w_send_data      ),
        .i_addr(w_send_addr     ), 
        
        // Slave->Master com signals 
        .o_dout(o_SCCB_dout     ),      
        .o_done(o_data_sent_done),        
        .o_ack(                 ),       
        
        // SCCB Lines
        .io_sda(o_siod          ),      
        .o_scl(o_sioc           )
    );

endmodule