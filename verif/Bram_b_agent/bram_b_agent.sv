class bram_b_agent extends uvm_agent;
  
	//components
	bram_b_driver bram_b_drv;
	bram_b_sequencer bram_b_seqr;
	bram_b_monitor bram_b_mon;

	 // configuration
   	imdct_config cfg;

   	`uvm_component_utils_begin (bram_b_agent)
  		`uvm_field_object(cfg, UVM_DEFAULT)
   	`uvm_component_utils_end

	// constructor
	function new(string name = "bram_b_agent", uvm_component parent = null);
  		super.new(name, parent);
	endfunction

	// build phase
	function void build_phase(uvm_phase phase);
  		super.build_phase(phase);
    	if(!uvm_config_db#(imdct_config)::get(this, "", "imdct_config", cfg))
        `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})

  		// create components
  		if (cfg.is_active == UVM_ACTIVE) begin
    		bram_b_drv = bram_b_driver::type_id::create("bram_b_drv", this);
    		bram_b_seqr = bram_b_sequencer::type_id::create("bram_b_seqr", this);
    		bram_b_mon = bram_b_monitor::type_id::create("bram_b_mon", this);
  		end
  	endfunction : build_phase

   	function void connect_phase(uvm_phase phase);
      	super.connect_phase(phase);
  		if(cfg.is_active == UVM_ACTIVE) begin
     		bram_b_drv.seq_item_port.connect(bram_b_seqr.seq_item_export);
      	end   
   	endfunction : connect_phase

endclass : bram_b_agent
