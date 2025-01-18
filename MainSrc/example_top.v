`timescale 1ns/1ps

//`include "ddr3_controller.vh"


module example_top 
(
	////////////////////////////////////////////////////////////////
	//	External Clock & Reset
	input 			clk_24m,			//	24MHz Crystal
	//input 			clk_25m,			//	25MHz Crystal 
	
	////////////////////////////////////////////////////////////////
	//	CLK
	////////////////////////////////////////////////////////////////
	//	System Clock
	output 			sys_pll_rstn_o, 		
	
	input 			clk_sys,			//	Sys PLL 96MHz
	input			clk_sys_27m, 
	input			clk_sys_ddr,
	input			feed,
	
	input 			sys_pll_lock,		//	Sys PLL Lock
	
	
	//	DDR Clock
	output 			ddr_pll_rstn_o, 
	
	input 			tdqss_clk,			
	input 			core_clk,			//	DDR PLL 200MHz
	input 			tac_clk,			
	input 			twd_clk,			
	
	input 			ddr_pll_lock,		//	DDR PLL Lock
	
	//	hdmi Clock
	output 			hdmi_pll_rstn_o, 
	
	input 			clk_hdmi, 	
	input 			clk_pixel,			//	Sys PLL 148.5MHz	
	input 			clk_pixel_5x,		//	Sys PLL 742.5MHz
	
	input 			hdmi_pll_lock,
    
    // scaler
    output 			scaler_pll_rstn_o,
    input           scaler_pll_48m,
    input           clk_scaler_25m,
    input           clk_150m,
    input           scaler_pll_lock,
	

	////////////////////////////////////////////////////////////////
	//	DDR PLL Phase Shift Interface
	output 	[2:0] 	shift,
	output 	[4:0] 	shift_sel,
	output 			shift_ena,
	
	
	//////////////////////////////////////////////////////////////
	//	DDR Interface Ports
	output 	[15:0] 	addr,
	output 	[2:0] 	ba,
	output 			we,
	output 			reset,
	output 			ras,
	output 			cas,
	output 			odt,
	output 			cke,
	output 			cs,
	
	//	DQ I/O
	input 	[15:0] 	i_dq_hi,
	input 	[15:0] 	i_dq_lo,
	
	output 	[15:0] 	o_dq_hi,
	output 	[15:0] 	o_dq_lo,
	output 	[15:0] 	o_dq_oe,
	
	//	DM O
	output 	[1:0] 	o_dm_hi,
	output 	[1:0] 	o_dm_lo,
	
	//	DQS I/O
	input 	[1:0] 	i_dqs_hi,
	input 	[1:0] 	i_dqs_lo,
	
	input 	[1:0] 	i_dqs_n_hi,
	input 	[1:0] 	i_dqs_n_lo,
	
	output 	[1:0] 	o_dqs_hi,
	output 	[1:0] 	o_dqs_lo,
	
	output 	[1:0] 	o_dqs_n_hi,
	output 	[1:0] 	o_dqs_n_lo,
	
	output 	[1:0] 	o_dqs_oe,
	output 	[1:0] 	o_dqs_n_oe,
	
	//	CK
	output 			clk_p_hi, 
	output 			clk_p_lo, 
	output 			clk_n_hi, 
	output 			clk_n_lo, 
	
	
	////////////////////////////////////////////////////////////////
	//	UART Interface
	//input 		 	uart_rx_i,			//	Support 460800-8-N-1. 
	//output 		 	uart_tx_o, 
	

	////////////////////////////////////////////////////////////////
	//	HDMI interface

	//	input
	input			hdmi_pclk_i,
	input			hdmi_vs_i,
	input			hdmi_hs_i,
	input			hdmi_de_i,
	input	[23:0]	hdmi_data_i,
	output			hdmi_scl_io,
	input			hdmi_sda_io_IN,
	output			hdmi_sda_io_OUT,
	output			adv7611_rstn,
	output			hdmi_sda_io_OE,

	//	output
	output	[2:0]	hdmi_tx_data_n_HI,
	output	[2:0]	hdmi_tx_data_n_LO,
	output	[2:0]	hdmi_tx_data_p_HI,
	output	[2:0]	hdmi_tx_data_p_LO,
	output			hdmi_tx_clk_n_HI,
	output			hdmi_tx_clk_n_LO,
	output			hdmi_tx_clk_p_HI,
	output			hdmi_tx_clk_p_LO,

	///////////////////////////////////////////////////////
	//	LED
	output 	[5:0] 	led_o,			// LED	

	input flag,
    input SCLK,
    input SDI		
);
	localparam	WIDTH = 480;
	localparam	LENGTH = 640;
    reg		[10:0]	OUTPUT_LENGTH;
	reg 	[10:0]	OUTPUT_WIDTH;

	//	Hardware Configuration
	assign clk_p_hi = 1'b0;	//	DDR3 Clock requires 180 degree shifted. 
	assign clk_p_lo = 1'b1;
	assign clk_n_hi = 1'b1;
	assign clk_n_lo = 1'b0; 
	
	//	System Clock Tree Control
	assign sys_pll_rstn_o = 1'b1; 	//	nrst; 	//	Reset whole system when nrst (K2) is pressed. 
	
	//assign dsi_pll_rstn_o = sys_pll_lock; 
	assign ddr_pll_rstn_o = sys_pll_lock; 
	assign hdmi_pll_rstn_o = sys_pll_lock;
   assign scaler_pll_rstn_o = sys_pll_lock; 
	
	wire 			w_pll_lock = sys_pll_lock && ddr_pll_lock && hdmi_pll_lock && scaler_pll_lock; 
	
	//	Synchronize System Resets. 
	reg 			rstn_sys = 0, rstn_pixel = 0, rstn_sys_ddr = 0; 
	wire 			rst_sys = ~rstn_sys, rst_pixel = ~rstn_pixel, rst_sys_ddr = ~rstn_sys_ddr; 
	
	//reg 			rstn_dsi_refclk = 0, rstn_dsi_byteclk = 0; 
	//wire 			rst_dsi_refclk = ~rstn_dsi_refclk, rst_dsi_byteclk = ~rstn_dsi_byteclk; 
	
	reg 			rstn_hdmi = 0; 
	wire 			rst_hdmi = ~rstn_hdmi; 
	
	//reg 			rstn_27m = 0, rstn_54m = 0; 
	//wire 			rst_27m = ~rstn_27m, rst_54m = ~rstn_54m; 
	
	//	Clock Gen
	//always @(posedge clk_27m or negedge w_pll_lock) begin if(~w_pll_lock) rstn_27m <= 0; else rstn_27m <= 1; end
	//always @(posedge clk_54m or negedge w_pll_lock) begin if(~w_pll_lock) rstn_54m <= 0; else rstn_54m <= 1; end
	always @(posedge clk_sys or negedge w_pll_lock) begin if(~w_pll_lock) rstn_sys <= 0; else rstn_sys <= 1; end
	always @(posedge clk_sys_ddr or negedge w_pll_lock) begin if(~w_pll_lock) rstn_sys_ddr <= 0; else rstn_sys_ddr <= 1; end
	always @(posedge clk_pixel or negedge w_pll_lock) begin if(~w_pll_lock) rstn_pixel <= 0; else rstn_pixel <= 1; end
	//always @(posedge dsi_refclk_i or negedge w_pll_lock) begin if(~w_pll_lock) rstn_dsi_refclk <= 0; else rstn_dsi_refclk <= 1; end
	//always @(posedge dsi_byteclk_i or negedge w_pll_lock) begin if(~w_pll_lock) rstn_dsi_byteclk <= 0; else rstn_dsi_byteclk <= 1; end
	always @(posedge clk_hdmi or negedge w_pll_lock) begin if(~w_pll_lock) rstn_hdmi <= 0; else rstn_hdmi <= 1; end
	
	
	localparam 	CLOCK_MAIN 	= 96000000; 	//	System clock using 96MHz. 

	


	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	DDR3 Controller
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	wire			w_ddr3_ui_clk = clk_sys_ddr;
	wire			w_ddr3_ui_rst = rst_sys_ddr;
	wire			w_ddr3_ui_areset = rst_sys_ddr;
	wire			w_ddr3_ui_aresetn = rstn_sys_ddr;
	

	//	General AXI Interface 
	wire	[3:0] 	w_ddr3_awid;
	wire	[31:0]	w_ddr3_awaddr;
	wire	[7:0]		w_ddr3_awlen;
	wire			w_ddr3_awvalid;
	wire			w_ddr3_awready;
	
	wire 	[3:0]  	w_ddr3_wid;
	wire 	[127:0] 	w_ddr3_wdata;
	wire 	[15:0]	w_ddr3_wstrb;
	wire			w_ddr3_wlast;
	wire			w_ddr3_wvalid;
	wire			w_ddr3_wready;
	
	wire 	[3:0] 	w_ddr3_bid;
	wire 	[1:0] 	w_ddr3_bresp;
	wire			w_ddr3_bvalid;
	wire			w_ddr3_bready;
	
	wire	[3:0] 	w_ddr3_arid;
	wire	[31:0]	w_ddr3_araddr;
	wire	[7:0]		w_ddr3_arlen;
	wire			w_ddr3_arvalid;
	wire			w_ddr3_arready;
	
	wire 	[3:0] 	w_ddr3_rid;
	wire 	[127:0] 	w_ddr3_rdata;
	wire			w_ddr3_rlast;
	wire			w_ddr3_rvalid;
	wire			w_ddr3_rready;
	wire 	[1:0] 	w_ddr3_rresp;
	
	
	//	AXI Interface Request
	wire 	[3:0] 	w_ddr3_aid;
	wire 	[31:0] 	w_ddr3_aaddr;
	wire 	[7:0]  	w_ddr3_alen;
	wire 	[2:0]  	w_ddr3_asize;
	wire 	[1:0]  	w_ddr3_aburst;
	wire 	[1:0]  	w_ddr3_alock;
	wire			w_ddr3_avalid;
	wire			w_ddr3_aready;
	wire			w_ddr3_atype;
	
	wire 			w_ddr3_cal_done, w_ddr3_cal_pass; 
	
	//	Do not issue DDR read / write when ~cal_done. 
	reg 			r_ddr_unlock = 0; 
	always @(posedge w_ddr3_ui_clk or negedge w_ddr3_ui_aresetn) begin
		if(~w_ddr3_ui_aresetn)
			r_ddr_unlock <= 0; 
		else
			r_ddr_unlock <= w_ddr3_cal_done; 
	end
	
	DdrCtrl ddr3_ctl_axi (	
		.core_clk		(core_clk),
		.tac_clk		(tac_clk),
		.twd_clk		(twd_clk),	
		.tdqss_clk		(tdqss_clk),
		
		.reset		(reset),
		.cs			(cs),
		.ras			(ras),
		.cas			(cas),
		.we			(we),
		.cke			(cke),    
		.addr			(addr),
		.ba			(ba),
		.odt			(odt),
		
		.o_dm_hi		(o_dm_hi),
		.o_dm_lo		(o_dm_lo),
		
		.i_dq_hi		(i_dq_hi),
		.i_dq_lo		(i_dq_lo),
		.o_dq_hi		(o_dq_hi),
		.o_dq_lo		(o_dq_lo),
		.o_dq_oe		(o_dq_oe),
		
		.i_dqs_hi		(i_dqs_hi),
		.i_dqs_lo		(i_dqs_lo),
		.i_dqs_n_hi		(i_dqs_n_hi),
		.i_dqs_n_lo		(i_dqs_n_lo),
		.o_dqs_hi		(o_dqs_hi),
		.o_dqs_lo		(o_dqs_lo),
		.o_dqs_n_hi		(o_dqs_n_hi),
		.o_dqs_n_lo		(o_dqs_n_lo),
		.o_dqs_oe		(o_dqs_oe),
		.o_dqs_n_oe		(o_dqs_n_oe),
		
		.clk			(w_ddr3_ui_clk),
		.reset_n		(w_ddr3_ui_aresetn),
		
		.axi_avalid		(w_ddr3_avalid && r_ddr_unlock),	//	Enable command only when unlocked. 
		.axi_aready		(w_ddr3_aready),
		.axi_aaddr		(w_ddr3_aaddr),
		.axi_aid		(w_ddr3_aid),
		.axi_alen		(w_ddr3_alen),
		.axi_asize		(w_ddr3_asize),
		.axi_aburst		(w_ddr3_aburst),
		.axi_alock		(w_ddr3_alock),
		.axi_atype		(w_ddr3_atype),
		
		.axi_wid		(w_ddr3_wid),
		.axi_wvalid		(w_ddr3_wvalid),
		.axi_wready		(w_ddr3_wready),
		.axi_wdata		(w_ddr3_wdata),
		.axi_wstrb		(w_ddr3_wstrb),
		.axi_wlast		(w_ddr3_wlast),
		
		.axi_bvalid		(w_ddr3_bvalid),
		.axi_bready		(w_ddr3_bready),
		.axi_bid		(w_ddr3_bid),
		.axi_bresp		(w_ddr3_bresp),
		
		.axi_rvalid		(w_ddr3_rvalid),
		.axi_rready		(w_ddr3_rready),
		.axi_rdata		(w_ddr3_rdata),
		.axi_rid		(w_ddr3_rid),
		.axi_rresp		(w_ddr3_rresp),
		.axi_rlast		(w_ddr3_rlast),
		
		.shift		(shift),
		.shift_sel		(),
		.shift_ena		(shift_ena),
		
		.cal_ena		(1'b1),
		.cal_done		(w_ddr3_cal_done),
		.cal_pass		(w_ddr3_cal_pass)
	);
	
	assign w_ddr3_bready = 1'b1; 
	assign shift_sel = 5'b00100; 		//	ddr_tac_clk always use PLLOUT[2]. 
	
	
	AXI4_AWARMux #(.AID_LEN(4), .AADDR_LEN(32)) axi4_awar_mux (
		.aclk_i			(w_ddr3_ui_clk), 
		.arst_i			(w_ddr3_ui_rst), 
		
		.awid_i			(w_ddr3_awid),
		.awaddr_i			(w_ddr3_awaddr),
		.awlen_i			(w_ddr3_awlen),
		.awvalid_i			(w_ddr3_awvalid),
		.awready_o			(w_ddr3_awready),
		
		.arid_i			(w_ddr3_arid),
		.araddr_i			(w_ddr3_araddr),
		.arlen_i			(w_ddr3_arlen),
		.arvalid_i			(w_ddr3_arvalid),
		.arready_o			(w_ddr3_arready),
		
		.aid_o			(w_ddr3_aid),
		.aaddr_o			(w_ddr3_aaddr),
		.alen_o			(w_ddr3_alen),
		.atype_o			(w_ddr3_atype),
		.avalid_o			(w_ddr3_avalid),
		.aready_i			(w_ddr3_aready)
	);
	
	assign w_ddr3_asize = 4; 		//	Fixed 128 bits (16 bytes, size = 4)
	assign w_ddr3_aburst = 1; 
	assign w_ddr3_alock = 0; 
	
	
	//------------sync the vsync---------------------

	assign adv7611_rstn = 1'b1;
	wire                   [   8:0]         i2c_config_index           ;
	wire                   [  23:0]         i2c_config_data            ;
	wire                   [   8:0]         i2c_config_size            ;
	wire                                    i2c_config_done            ;

	i2c_timing_ctrl #(
		.CLK_FREQ ( 24_000_000 ),
		.I2C_FREQ ( 50000 ))
	u_i2c_timing_ctrl (
		.clk                     ( clk_24m                      ),
		.rst_n                   ( rstn_sys                    ),
		.i2c_sdat_IN             ( hdmi_sda_io_IN              ),
		.i2c_config_size         ( i2c_config_size   [7:0]  ),
		.i2c_config_data         ( i2c_config_data   [23:0] ),

		.i2c_sclk                ( hdmi_scl_io                 ),
		.i2c_sdat_OUT            ( hdmi_sda_io_OUT             ),
		.i2c_sdat_OE             ( hdmi_sda_io_OE              ),
		.i2c_config_index        ( i2c_config_index  [7:0]  ),
		.i2c_config_done         ( i2c_config_done          )
	);

	I2C_ADV7611_Config u_I2C_ADV7611_Config
	(
	.LUT_INDEX                         (i2c_config_index          ),
	.LUT_DATA                          (i2c_config_data           ),
	.LUT_SIZE                          (i2c_config_size           ) 
	);


	wire                       LCD_DCLK ;
	wire                       LCD_VS   ;
	wire                       LCD_HS   ;
	wire                       LCD_DE   ;
	wire      [  31:0]         LCD_DATA ;                  

	assign LCD_DCLK = 		  hdmi_pclk_i  ;
	assign LCD_VS = 		  hdmi_vs_i    ;
	assign LCD_HS = 		  hdmi_hs_i    ;
	assign LCD_DE = 		  hdmi_de_i    ;
	assign LCD_DATA = 		  {8'b0000_0000,hdmi_data_i}  ;
    
    wire [31:0] data_out;
    wire doutvalid;
    
    //wire start;
    //wire scaler_re;
    //wire fifo_dataValid;
    //wire empty;
    //wire full;
    //wire [11:0] count;
    //wire [23:0] fifo_data;
    //wire finish;
    
	reg LCD_VS_2 = 0;
	always @(posedge LCD_VS) begin
		LCD_VS_2 <= LCD_VS_2 + 1;
	end

	wire lcd_vs_in;
	assign lcd_vs_in = LCD_VS_2;
    algorithm_block algo
    (
      .clk_hdmi		(LCD_DCLK		),
      //.clk_slow(clk_scaler_25m),
      .clk_fast		(clk_150m		),
      .vsync_in		(lcd_vs_in		),
      .write_en		(LCD_DE			),
      .data_in		(hdmi_data_i	),
      .outputXRes	(OUTPUT_LENGTH	),
      .outputYRes	(OUTPUT_WIDTH	),

      .doutvalid	(doutvalid		),
      .data_out		(data_out		)
      //.start(start),
      //.scaler_re(scaler_re),
      //.fifo_dataValid(fifo_dataValid),
      //.empty(empty),
      //.count(count),
      //.fifo_data(fifo_data),
      //.finish(finish),
      //.full(full)
    );
    


	////////////////////////////////////////////////////////////////
	//	DDR R/W Control


	wire                            lcd_de;
	wire                            lcd_hs;      
	wire                            lcd_vs;
	wire 					  lcd_request; 
	wire            [7:0]           lcd_red;
	wire            [7:0]           lcd_green;
	wire            [7:0]           lcd_blue;
	wire            [31:0]          lcd_data;


	assign w_ddr3_awid = 0; 
	assign w_ddr3_wid = 0; 
	
	//wire 			w_wframe_vsync; 
	//wire 	[7:0] 	w_axi_tp; 
    wire            lcd_vs2;
    
	axi4_ctrl #(
		.C_RD_END_ADDR	(1920 * 1080 * 4	), 
		.C_W_WIDTH		(32		), 
		.C_R_WIDTH		(32		), 
		.C_ID_LEN		(4		)	) 
	u_axi4_ctrl (
    
        //.out_length		(length_out_hdmi),
		//.out_width		(width_out_hdmi),

		.axi_clk        (w_ddr3_ui_clk       ),
		.axi_reset      (w_ddr3_ui_rst       ),

		.axi_awaddr     (w_ddr3_awaddr       ),
		.axi_awlen      (w_ddr3_awlen        ),
		.axi_awvalid    (w_ddr3_awvalid      ),
		.axi_awready    (w_ddr3_awready      ),

		.axi_wdata      (w_ddr3_wdata        ),
		.axi_wstrb      (w_ddr3_wstrb        ),
		.axi_wlast      (w_ddr3_wlast        ),
		.axi_wvalid     (w_ddr3_wvalid       ),
		.axi_wready     (w_ddr3_wready       ),

		.axi_bid        (0          ),
		.axi_bresp      (0        ),
		.axi_bvalid     (1       ),

		.axi_arid       (w_ddr3_arid         ),
		.axi_araddr     (w_ddr3_araddr       ),
		.axi_arlen      (w_ddr3_arlen        ),
		.axi_arvalid    (w_ddr3_arvalid      ),
		.axi_arready    (w_ddr3_arready      ),

		.axi_rid        (w_ddr3_rid          ),
		.axi_rdata      (w_ddr3_rdata        ),
		.axi_rresp      (0        ),
		.axi_rlast      (w_ddr3_rlast        ),
		.axi_rvalid     (w_ddr3_rvalid       ),
		.axi_rready     (w_ddr3_rready       ),

		.wframe_pclk    (clk_150m           ),
		.wframe_vsync   (lcd_vs_in          ), //w_wframe_vsync   ),		//	Writter VSync. Flush on rising edge. Connect to EOF. 
		.wframe_data_en (doutvalid           ),
		.wframe_data    (data_out            ),
		
		.rframe_pclk    (clk_pixel           ),
		.rframe_vsync   (~lcd_vs             ),		//	Reader VSync. Flush on rising edge. Connect to ~EOF. 
		.rframe_data_en (lcd_request         ),
		.rframe_data    (lcd_data            )
		
		//.tp_o 		(w_axi_tp)
	);
	/*
	wire	divide_clken;

	integer_divider	#(
		.DEVIDE_CNT	(52)	//115200bps * 16
	//	.DEVIDE_CNT	(625)	//9600bps * 16
	)
	u_integer_devider
	(
		//global
		.clk				(clk_sys		),		//96MHz clock
		.rst_n				(w_pll_lock		),    //global reset
		
		//user interface
		.divide_clken		(divide_clken	)
	);

	wire	clken_16bps = divide_clken;
	//---------------------------------
	//Data receive for PC to FPGA.
	wire			rxd_flag;
	wire	[7:0]	rxd_data;
	uart_receiver	u_uart_receiver
	(
		//gobal clock
		.clk			(clk_sys		),
		.rst_n			(w_pll_lock		),
		
		//uart interface
		.clken_16bps	(clken_16bps	),	//clk_bps * 16
		.rxd			(uart_rx_i		),		//uart txd interface
		
		//user interface
		.rxd_data		(rxd_data		),		//uart data receive
		.rxd_flag		(rxd_flag		)  	//uart data receive done
	);
	*/
	
	wire done;
	wire [7:0] inc_length;
	wire [7:0] inc_width;
    wire [3:0] step_de;
    
	SpiSlave16Bits_S spi(
		.flag		(flag		),
		.SCLK		(SCLK		),
		.SDI		(SDI		),

		.inc_length	(inc_length	),
		.inc_width	(inc_width	),
		.done		(done		),
		.step_de	(step_de	)
	);


	//	Output LED
	//reg 	[3:0] 	led;
	reg		[7:0]	background;
	reg 	[10:0]	reg_output_length;
	reg 	[10:0] 	reg_output_width;
	reg		mode = 0;

always@(negedge w_pll_lock or posedge done)
	begin
		if(!w_pll_lock)
			begin
				//led <= 4'd1;
				background <= 8'd0;
				reg_output_length <= LENGTH;
				reg_output_width <= WIDTH;
			end
		else if (done)
          begin
            if(inc_length == 8'b00000000&&inc_width == 8'b00000000)
              mode <=0;
            else if(inc_length == 8'b11111111&&inc_width == 8'b11111111)
              mode <=1;
			else begin
				reg_output_length <= inc_length[7] ? reg_output_length + inc_length[6:0] : reg_output_length - inc_length[6:0];
				reg_output_width <= inc_width[7] ? reg_output_width + inc_width[6:0] : reg_output_width - inc_width[6:0];
				background <= background + 8'h10;
            end
          end
		else
			begin
				reg_output_length <= reg_output_length;
				reg_output_width <= reg_output_width;
				background <= background;
			end
	end

	always @(negedge w_pll_lock or negedge lcd_vs_in) 
	begin
		if (!w_pll_lock) 
			begin
				OUTPUT_LENGTH <= LENGTH;
				OUTPUT_WIDTH <= WIDTH;
			end 
		else if (!lcd_vs_in) 
			begin
				OUTPUT_LENGTH <= reg_output_length;
				OUTPUT_WIDTH <= reg_output_width;
			end
		else
			begin
				OUTPUT_LENGTH <= OUTPUT_LENGTH;
				OUTPUT_WIDTH <= OUTPUT_WIDTH;
			end
	end

	reg [10:0] length_out_hdmi;
	reg [10:0] width_out_hdmi;
	reg [10:0] length_out_hdmi_delay;
	reg [10:0] width_out_hdmi_delay;
	always @(negedge w_pll_lock or negedge lcd_vs) 
	begin
		if (!w_pll_lock) 
			begin
				length_out_hdmi <= LENGTH;
				width_out_hdmi <= WIDTH;
				length_out_hdmi_delay <= LENGTH;
				width_out_hdmi_delay <= WIDTH;
			end 
		else if (!lcd_vs) 
			begin
				length_out_hdmi_delay <= OUTPUT_LENGTH;
				width_out_hdmi_delay <= OUTPUT_WIDTH;
				length_out_hdmi <= length_out_hdmi_delay;
				width_out_hdmi <= width_out_hdmi_delay;
			end
		else
			begin
				length_out_hdmi <= length_out_hdmi;
				width_out_hdmi <= width_out_hdmi;
			end
	end



	assign led_o[0] = ~w_pll_lock;
    //assign led_o[4] = !full;
    //assign led_o[5] = !empty;

		////////////////////////////////////////////////////////////////
	//  LCD Timing Driver
	
	//reg 	[11:0]		h_disp = 12'd640	;
	//reg		[11:0]		v_sync = 12'd2		;
	//reg		[11:0]		v_back = 12'd33		;
	//reg		[11:0]		v_disp = 12'd480	;
	

	
	hdmi_driver u_hdmi_driver
	(
	    //  global clock
	    .clk        (clk_pixel   ),
	    .rst_n      (rstn_pixel), 
		//  parameter
		//.v_sync		(v_sync		),
		//.v_back		(v_back		),
        .output_width   (width_out_hdmi       ),
        .output_length  (length_out_hdmi      ),
		.background	({background, background[3:0], background[7:4], background}	),
	    
	    //  lcd interface
	    .lcd_dclk   (               ),
	    .lcd_blank  (               ),
	    .lcd_sync   (               ),
	    .lcd_request(lcd_request    ), 	//	Request data 1 cycle ahead. 
	    .lcd_hs     (lcd_hs         ),
	    .lcd_vs     (lcd_vs         ),
        //.lcd_vs2    (lcd_vs2        ),
	    .lcd_en     (lcd_de         ),
	    .lcd_rgb    ({lcd_red,lcd_green,lcd_blue}),
	    
	    //  user interface
	    .lcd_data   (lcd_data[23:0] )
	);
	
	
	hdmi_tx_ip u_hdmi_tx_ip
	(
		.pixelclk		(clk_pixel		),       // system clock
		.pixelclk5x		(clk_pixel_5x	),     // system clock x5
		.rstin			(~rstn_pixel	),          // reset
		.blue_din		(lcd_blue		),       // Blue data in
		.green_din		(lcd_green		),      // Green data in
		.red_din		(lcd_red		),        // Red data in
		.hsync			(~lcd_hs			),          // hsync data
		.vsync			(~lcd_vs			),          // vsync data
		.de				(lcd_de			),             // data enable
	//	output [2:0]	dataout_h,
	//	output [2:0]	dataout_l,
	//	output			clk_h,
	//	output			clk_l,
		.data_p_h		(hdmi_tx_data_p_HI	),
		.data_p_l		(hdmi_tx_data_p_LO	),
		.clk_p_h 		(hdmi_tx_clk_p_HI 	),
		.clk_p_l 		(hdmi_tx_clk_p_LO 	),
		.data_n_h		(hdmi_tx_data_n_HI	),
		.data_n_l		(hdmi_tx_data_n_LO	),
		.clk_n_h 		(hdmi_tx_clk_n_HI 	),
		.clk_n_l 		(hdmi_tx_clk_n_LO 	),
		
		.txc_o			(), 
		.txd0_o			(), 
		.txd1_o			(), 
		.txd2_o			()
	);
		
endmodule