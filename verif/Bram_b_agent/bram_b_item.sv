class bram_b_item extends uvm_sequence_item;
  
	// item fields
  	bit [31:0] out_data;
  	bit [31:0] in_data;
 	bit [31:0] address;
  	bit en;
  	bit we;
    
  	`uvm_object_utils_begin(bram_b_item)
    	`uvm_field_int(out_data, UVM_ALL_ON)
    	`uvm_field_int(in_data, UVM_ALL_ON)
    	`uvm_field_int(address, UVM_ALL_ON)
    	`uvm_field_int(en, UVM_ALL_ON)
    	`uvm_field_int(we, UVM_ALL_ON)
  	`uvm_object_utils_end

	// constructor
	function new(string name = "bram_b_item");
  		super.new(name);
	endfunction

endclass : bram_b_item
