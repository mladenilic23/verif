class bram_a_sequencer extends uvm_sequencer#(bram_a_item);
  
	`uvm_component_utils(bram_a_sequencer)
    
	function new(string name = "bram_a_sequencer", uvm_component parent = null);
  		super.new(name, parent);
	endfunction

endclass : bram_a_sequencer
