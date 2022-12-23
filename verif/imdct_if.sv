parameter integer WIDTH = 32;
parameter integer ADDRESS  = 32;   		
parameter integer C_S_AXI_DATA_WIDTH	= 32;
parameter integer C_S_AXI_ADDR_WIDTH	= 5;

interface axi_lite_if (input clock, logic reset_n);
   // Ports of Axi Slave Bus Interface S_AXI
   
	logic [C_S_AXI_ADDR_WIDTH-1 : 0] 		s_axi_awaddr ;
	logic [2 : 0]                      		s_axi_awprot ;
	logic                              		s_axi_awvalid ;
	logic                              		s_axi_awready;
	logic [C_S_AXI_DATA_WIDTH-1 : 0] 		s_axi_wdata ;
	logic [(C_S_AXI_DATA_WIDTH/8)-1 : 0] 	s_axi_wstrb = 4'b1111; // width=4
	logic                                  	s_axi_wvalid ;
	logic                                  	s_axi_wready;
	logic [1 : 0]                          	s_axi_bresp;
	logic                                  	s_axi_bvalid;
	logic                                  	s_axi_bready ;
	logic [C_S_AXI_ADDR_WIDTH-1 : 0]     	s_axi_araddr ;
	logic [2 : 0]                          	s_axi_arprot ;
	logic                                  	s_axi_arvalid ;
	logic                                  	s_axi_arready;
	logic [C_S_AXI_DATA_WIDTH-1 : 0]     	s_axi_rdata;
	logic [1 : 0]                          	s_axi_rresp;
	logic                                  	s_axi_rvalid;
	logic                                  	s_axi_rready ;
   
endinterface : axi_lite_if

interface bram_a_if (input clock, logic reset_n);
	logic                           		s_en_bram_a;
	logic [ADDRESS-1 : 0]              		s_addr_bram_a;
	logic [WIDTH-1 : 0]                		s_din_bram_a;
	logic [WIDTH-1 : 0]                		s_dout_bram_a;
   	logic 	                            	s_we_bram_a;
endinterface : bram_a_if

interface bram_b_if (input clock, logic reset_n);
	logic                           		s_en_bram_b;
	logic [ADDRESS-1 : 0]              		s_addr_bram_b;
	logic [WIDTH-1 : 0]                		s_din_bram_b;
	logic [WIDTH-1 : 0]                		s_dout_bram_b;
   	logic 	                            	s_we_bram_b;
endinterface : bram_b_if
