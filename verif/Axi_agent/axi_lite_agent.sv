class axi_lite_agent extends uvm_agent;

	`uvm_component_utils_begin (axi_lite_agent)
	`uvm_component_utils_end
	
	//components
	axi_lite_driver axi_driver;
	axi_lite_sequencer axi_sequencer;
	axi_lite_monitor axi_monitor;

	//constructor
	function new(string name = "axi_lite_agent", uvm_component parent = null);
  		super.new(name, parent);
	endfunction

	//build phase
	function void build_phase(uvm_phase phase);
  		super.build_phase(phase);
  		axi_driver = axi_lite_driver::type_id::create("axi_driver", this);
      	axi_sequencer = axi_lite_sequencer::type_id::create("axi_sequencer", this);
      	axi_monitor = axi_lite_monitor::type_id::create("axi_monitor", this);
	endfunction : build_phase

	function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      axi_driver.seq_item_port.connect(axi_sequencer.seq_item_export);      
	endfunction : connect_phase

endclass : axi_lite_agent
