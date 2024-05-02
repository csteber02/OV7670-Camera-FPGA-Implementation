module camera_rom
    (   input logic        i_clk,
        input logic        i_rstn,
        input logic  [7:0] i_addr,
        output reg [15:0] o_dout
    );
    
    // Registers for OV7670 for configuration of RGB 444 
    always_ff @(posedge i_clk or negedge i_rstn) begin
        if(!i_rstn) o_dout <= 0; 
        else begin 
            case(i_addr)
            0:  o_dout <= 16'h12_80;  // COM7:        Reset SCCB registers fine
            1:  o_dout <= 16'hFF_F0;  // Delay         fine
            2:  o_dout <= 16'h12_04;  // COM7,        Set RGB color output fine
            3:  o_dout <= 16'h11_00;  // CLKRC        Internal PLL matches input clock (24 MHz). okay den
            4:  o_dout <= 16'h0C_00;  // COM3,        *Leave as default. fine
            5:  o_dout <= 16'h3E_00;  // COM14,       *Leave as default. No scaling, normal pclock fine
            6:  o_dout <= 16'h04_00;  // COM1,        *Leave as default. Disable CCIR656 fine
            7:  o_dout <= 16'h8C_02;  // RGB444       Enable RGB444 mode with xR GB. fine
            8:  o_dout <= 16'h40_D0;  // COM15,       Output full range for RGB 444. fine
            9:  o_dout <= 16'h3a_04;  // TSLB         set correct output data sequence (magic) fine
            10: o_dout <= 16'h14_4A;  // COM9         MAX AGC value x4 (changed to default)
            11: o_dout <= 16'h4F_B3;  // MTX1         all of these are magical matrix coefficients
            12: o_dout <= 16'h50_B3;  // MTX2
            13: o_dout <= 16'h51_00;  // MTX3
            14: o_dout <= 16'h52_3d;  // MTX4
            15: o_dout <= 16'h53_A7;  // MTX5
            16: o_dout <= 16'h54_E4;  // MTX6
            17: o_dout <= 16'h58_9E;  // MTXS
            18: o_dout <= 16'h3D_88;  // COM13        sets gamma enable, does not preserve reserved bits, may be wrong? (changed to default)
            19: o_dout <= 16'h17_11;  // HSTART       start high 8 bits (setting to default to see what happens) same below
            20: o_dout <= 16'h18_61;  // HSTOP        stop high 8 bits //these kill the odd colored line
            21: o_dout <= 16'h32_80;  // HREF         edge offset fine
            22: o_dout <= 16'h19_03;  // VSTART       start high 8 bits fine
            23: o_dout <= 16'h1A_7B;  // VSTOP        stop high 8 bits fine
            24: o_dout <= 16'h03_00;  // VREF         vsync edge offset (change to default)
            25: o_dout <= 16'h0F_43;  // COM6         reset timings (change to deault)
            26: o_dout <= 16'h1E_07;  // MVFP         disable mirror / flip (change to default) Maybe black sun enabled?
            27: o_dout <= 16'h33_08;  // CHLF         magic value from the internet (defaulted)
            28: o_dout <= 16'h3C_68;  // COM12        no HREF when VSYNC low (defaulted)
            29: o_dout <= 16'h69_00;  // GFIX         fix gain control fine
            30: o_dout <= 16'h74_00;  // REG74        Digital gain control fine
            31: o_dout <= 16'hB0_84;  // RSVD         magic value from the internet *required* for good color (unknown value)
            32: o_dout <= 16'hB1_0C;  // ABLC1        defaulted (changed from default)
            33: o_dout <= 16'hB2_0e;  // RSVD         more magic internet values (unknown) possible problem?
            34: o_dout <= 16'hB3_82;  // THL_ST       fine (changed from default)
            //begin mystery scaling numbers
            35: o_dout <= 16'h70_3a;  // SCALING_XSC          *Leave as default. No test pattern output. fine
            36: o_dout <= 16'h71_35;  // SCALING_YSC          *Leave as default. No test pattern output. fine
            37: o_dout <= 16'h72_11;  // SCALING DCWCTR       *Leave as default. Vertical down sample by 2. Horizontal down sample by 2. 
            38: o_dout <= 16'h73_00;  // SCALING PCLK_DIV     defaulted
            39: o_dout <= 16'ha2_02;  // SCALING PCLK DELAY   *Leave as deafult. fine
            //gamma curve values
           40: o_dout <= 16'h7a_20;  // SLOP
           41: o_dout <= 16'h7b_10;  // GAM1
           42: o_dout <= 16'h7c_1e;  // GAM2
           43: o_dout <= 16'h7d_35;  // GAM3
           44: o_dout <= 16'h7e_5a;  // GAM4
           45: o_dout <= 16'h7f_69;  // GAM5
           46: o_dout <= 16'h80_76;  // GAM6
           47: o_dout <= 16'h81_80;  // GAM7
           48: o_dout <= 16'h82_88;  // GAM8
           49: o_dout <= 16'h83_8f;  // GAM9
           50: o_dout <= 16'h84_96;  // GAM10
           51: o_dout <= 16'h85_a3;  // GAM11 
           52: o_dout <= 16'h86_af;  // GAM12
           53: o_dout <= 16'h87_c4;  // GAM13
           54: o_dout <= 16'h88_d7;  // GAM14
           55: o_dout <= 16'h89_e8;  // GAM15
//            //AGC and AEC
           56: o_dout <= 16'h13_02;  // COM8     disable AGC / AEC (changed from e0)
           57: o_dout <= 16'h00_00;  // set gain reg to 0 for AGC
           58: o_dout <= 16'h10_08;  // set ARCJ reg to 0
           59: o_dout <= 16'h0d_40;  // magic reserved bit for COM4
           60: o_dout <= 16'h14_18;  // COM9, 4x gain + magic bit
           61: o_dout <= 16'ha5_05;  // BD50MAX
           62: o_dout <= 16'hab_07;  // DB60MAX
           63: o_dout <= 16'h24_95;  // AGC upper limit
           64: o_dout <= 16'h25_33;  // AGC lower limit
           65: o_dout <= 16'h26_e3;  // AGC/AEC fast mode op region
           66: o_dout <= 16'h9f_78;  // HAECC1
           67: o_dout <= 16'ha0_68;  // HAECC2
           68: o_dout <= 16'ha1_03;  // magic
           69: o_dout <= 16'ha6_d8;  // HAECC3
           70: o_dout <= 16'ha7_d8;  // HAECC4
           71: o_dout <= 16'ha8_f0;  // HAECC5
           72: o_dout <= 16'ha9_90;  // HAECC6
           73: o_dout <= 16'haa_94;  // HAECC7
           74: o_dout <= 16'h13_aE;  // COM8, enable AGC / AEC
           75: o_dout <= 16'h69_06;     
            //rest of registers
            76: o_dout <= 16'h01_FF;  // blue channel gain
            77: o_dout <= 16'h02_00; //red channel gain
            78: o_dout <= 16'h05_00; //U/B level, automatically updated from chip
            79: o_dout <= 16'h06_00; //Y/Gb, automatically updated from chip
            80: o_dout <= 16'h07_00; //exposure value
            81: o_dout <= 16'h08_00; //rave
            82: o_dout <= 16'h09_01; //com2
            83: o_dout <= 16'h0e_61; //com5 (reserved) magic from internet
            84: o_dout <= 16'h15_00; //com10
            85: o_dout <= 16'h1b_00; //pixel delay
            86: o_dout <= 16'h20_04; //ADC reference adjustment 1x
            87: o_dout <= 16'h28_80; //Gb channel bias
            88: o_dout <= 16'h2a_00; //dummy pixel insert MSB (off)
            89: o_dout <= 16'h2b_00; //dummy pixel insert LSB (off)
            90: o_dout <= 16'h2c_80; //R channel bias
            91: o_dout <= 16'h2d_00; //insert dummy lines vertical (off)
            92: o_dout <= 16'h2e_00; //insert dummy lines horizontal (off)
            93: o_dout <= 16'h2f_00; //Y/G channel avg value
            94: o_dout <= 16'h30_08; //hsync delay rising edge
            95: o_dout <= 16'h31_30; //hsync delay falling edge
            96: o_dout <= 16'h34_11; //array reference control
            97: o_dout <= 16'h37_3f; //ADC control
            98: o_dout <= 16'h38_01; //analog common mode control
            99: o_dout <= 16'h39_00; //adc offset
            100: o_dout <= 16'h3b_00; //com11, possible adjustment
            101: o_dout <= 16'h3f_00; //edge enhancement, can adjust
            102: o_dout <= 16'h41_06; //com16, can adjust
            103: o_dout <= 16'h42_00; //com17, can adjust
            104: o_dout <= 16'h43_14; //reserved
            105: o_dout <= 16'h44_f0; //reserved
            106: o_dout <= 16'h45_45; //reserved
            107: o_dout <= 16'h46_61; //reserved
            108: o_dout <= 16'h47_51; //reserved
            109: o_dout <= 16'h48_79; //reserved
            110: o_dout <= 16'h4b_00; //UV average enable (off)
            111: o_dout <= 16'h4c_00; //denoise strength (def a possible register to change)
            112: o_dout <= 16'h55_00; //brightness control (maybe change if needed)
            113: o_dout <= 16'h56_40; //contrast control (maybe change if needed)
            114: o_dout <= 16'h57_80; //contrast center (probably ok)
            115: o_dout <= 16'h62_00; //lens correction x coord (leave alone)
            116: o_dout <= 16'h63_00; //lens correction y coord (leave alone)
            117: o_dout <= 16'h64_50; //RGB correction (possible?)
            118: o_dout <= 16'h65_30; //radius of center compensation (fine im sure)
            119: o_dout <= 16'h66_00; //lens correction enable for regs, may need on
            120: o_dout <= 16'h67_80; //manual U value
            121: o_dout <= 16'h68_00; //manual V value
            122: o_dout <= 16'h6a_00; //G channel gain (possible change)
            123: o_dout <= 16'h6b_0a; //PLL control and other stuff
            124: o_dout <= 16'h6c_02; //AWB control 3
            125: o_dout <= 16'h6d_55; //AWB control 2
            126: o_dout <= 16'h6e_c0; //awb control 1
            127: o_dout <= 16'h6f_9a; //awb control 0
            128: o_dout <= 16'h75_0F; //edge enhancement lower limit
            129: o_dout <= 16'h76_01; //pixel enhancements
            130: o_dout <= 16'h77_10; //denoise offset, def look in to
            131: o_dout <= 16'h92_00; //dummy line low 8 bits (off)
            132: o_dout <= 16'h93_00; //dummy line high 8 bits (off)
            133: o_dout <= 16'h94_50; //lens correction refer to datasheet
            134: o_dout <= 16'h95_50; //lens correction refer to datasheet
            135: o_dout <= 16'h9d_99; //50Hz band filtering
            136: o_dout <= 16'h9e_7f; //60Hz band filtering
            137: o_dout <= 16'ha4_00; //more dummy bits (off)
            138: o_dout <= 16'hac_00; //probably dont even touch this
            139: o_dout <= 16'had_80; //R Gain for LED output frame
            140: o_dout <= 16'hae_80; //G gain for LED output frame
            141: o_dout <= 16'haf_80; //B gain for LED output frame
            142: o_dout <= 16'hb5_04; //ABLC stable range
            143: o_dout <= 16'hbe_00; //black compensation for blue (def check)
            144: o_dout <= 16'hbf_00; //black compensation for red
            145: o_dout <= 16'hc0_00; //black compensation gb
            146: o_dout <= 16'hc1_00; //black compensation for gr
            147: o_dout <= 16'hc9_c0; //saturation control
            148: o_dout <= 16'h16_02; //mystery value
           default: o_dout <= 16'hFF_FF;         //mark end of ROM
            endcase
        end
    end
endmodule