class bram_b_sequencer extends uvm_sequencer#(bram_b_item);
  
	`uvm_component_utils(bram_b_sequencer)
    
	function new(string name = "bram_b_sequencer", uvm_component parent = null);
  		super.new(name, parent);
	endfunction

endclass : bram_b_sequencer
