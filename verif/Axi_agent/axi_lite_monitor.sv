class axi_lite_monitor extends uvm_monitor;
  
	// control fileds
	bit checks_enable = 1;
	bit coverage_enable = 1;
	bit [31:0] address;
  
	uvm_analysis_port #(axi_lite_item) item_collected_port;

	`uvm_component_utils_begin (axi_lite_monitor)
		`uvm_field_int(checks_enable, UVM_DEFAULT)
      	`uvm_field_int(coverage_enable, UVM_DEFAULT)
   	`uvm_component_utils_end

	//virtual interface reference
	virtual interface axi_lite_if vif;

	axi_lite_item curr_item;
	
	// coverage can go here 
	covergroup write_address;
		option.per_instance = 1;
      	write_address: coverpoint address{
     		bins start = {'h0};
         	bins block_type_00 = {'h4};
         	bins block_type_01 = {'h8};
         	bins block_type_10 = {'h12};
         	bins block_type_11 = {'h16};
     		bins gr = {'h20};
         	bins ch = {4'b0110};
  		}
	endgroup // write_read_address

   	covergroup read_address;
      	option.per_instance = 1;
      	read_address: coverpoint address{
         	bins start = {'h0};
         	bins block_type_00 = {'h4};
         	bins block_type_01 = {'h8};
         	bins block_type_10 = {'h12};
         	bins block_type_11 = {'h16};
     		bins gr = {'h20};
         	bins ch = {'h24};
         	bins ready = {'h28};         
      	}     
   	endgroup
   
   	// ---------------------------------------------------------------------
   
	// constructor
	function new(string name = "axi_lite_monitor", uvm_component parent = null);
  		super.new(name, parent);
  		item_collected_port = new("item_collected_port", this);
  		write_address = new();
  		read_address = new();
	endfunction

	function void connect_phase(uvm_phase phase);
  		super.connect_phase(phase);
      	if (!uvm_config_db#(virtual axi_lite_if)::get(this, "*", "axi_lite_if", vif))
        `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})  
   	endfunction : connect_phase


	task run_phase(uvm_phase phase);
           
		forever begin

			curr_item = axi_lite_item::type_id::create("curr_item", this);
			
         	@(posedge vif.clock)begin
            	if(vif.s_axi_awready )begin		//upisivanje u registre
               		address = vif.s_axi_awaddr;               
               		write_address.sample();
            	end
            	if(vif.s_axi_arready)		//citanje iz registara
               		address = vif.s_axi_araddr;
            	if(vif.s_axi_rvalid)begin
               		read_address.sample();
               		curr_item.data = vif.s_axi_rdata;
               		curr_item.address = vif.s_axi_awaddr;
               		
               		item_collected_port.write(curr_item); //send to scoreboard!!!
            	end
         	end
      	end
   	endtask : run_phase

endclass : axi_lite_monitor
