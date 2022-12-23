class bram_b_monitor extends uvm_monitor;
  
	int checks_enable = 1;
   	int coverage_enable = 1;
   	
   	int address = 0;
  
	uvm_analysis_port #(bram_b_item) item_collected_port;
  
  	`uvm_component_utils_begin(bram_b_monitor)
  		`uvm_field_int(checks_enable, UVM_DEFAULT)
      	`uvm_field_int(coverage_enable, UVM_DEFAULT)
   	`uvm_component_utils_end
  
  	// virtual interface reference
  	virtual interface bram_b_if vif;
 
  	// monitor item
  	bram_b_item curr_item;

	// constructor
	function new(string name = "bram_b_monitor", uvm_component parent = null);
  		super.new(name, parent);
      	item_collected_port = new("item_collected_port", this);
	endfunction
	

	function void connect_phase(uvm_phase phase);
      	super.connect_phase(phase);
      	if (!uvm_config_db#(virtual bram_b_if)::get(this, "*", "bram_b_if", vif))
        `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
   	endfunction : connect_phase

	task run_phase(uvm_phase phase);

      	curr_item = bram_b_item::type_id::create("curr_item", this);      
      	
      	forever begin
	         
         	@(posedge vif.clock iff vif.s_en_bram_b) //begin
				curr_item.address = vif.s_addr_bram_b;
					
				curr_item.en = vif.s_en_bram_b;
				curr_item.out_data = vif.s_dout_bram_b;
					
				if(vif.s_we_bram_b === 1)begin
					curr_item.in_data = vif.s_din_bram_b;
					curr_item.we = vif.s_we_bram_b;
				end
					
				//print item
				`uvm_info(get_type_name(), $sformatf("Address of BRAM is: \t%d, data is : \t%d", curr_item.address, vif.s_dout_bram_b), UVM_HIGH)
					
				item_collected_port.write(curr_item);

			//end //(posedge vif.s_en_bram)

		end // forever begin

	endtask : run_phase

endclass : bram_b_monitor
