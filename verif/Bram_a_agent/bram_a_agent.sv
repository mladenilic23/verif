class bram_a_agent extends uvm_agent;
  
	//components
	bram_a_driver bram_a_drv;
	bram_a_sequencer bram_a_seqr;
	bram_a_monitor bram_a_mon;

	 // configuration
   	imdct_config cfg;

   	`uvm_component_utils_begin (bram_a_agent)
  		`uvm_field_object(cfg, UVM_DEFAULT)
   	`uvm_component_utils_end

	// constructor
	function new(string name = "bram_a_agent", uvm_component parent = null);
  		super.new(name, parent);
	endfunction

	// build phase
	function void build_phase(uvm_phase phase);
  		super.build_phase(phase);
    	if(!uvm_config_db#(imdct_config)::get(this, "", "imdct_config", cfg))
        `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})

  		// create components
  		if (cfg.is_active == UVM_ACTIVE) begin
    		bram_a_drv = bram_a_driver::type_id::create("bram_a_drv", this);
    		bram_a_seqr = bram_a_sequencer::type_id::create("bram_a_seqr", this);
    		bram_a_mon = bram_a_monitor::type_id::create("bram_a_mon", this);
  		end
  	endfunction : build_phase

   	function void connect_phase(uvm_phase phase);
      	super.connect_phase(phase);
  		if(cfg.is_active == UVM_ACTIVE) begin
     		bram_a_drv.seq_item_port.connect(bram_a_seqr.seq_item_export);
      	end   
   	endfunction : connect_phase

endclass : bram_a_agent
