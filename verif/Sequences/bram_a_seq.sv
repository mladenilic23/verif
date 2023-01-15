class bram_a_seq extends bram_a_base_seq;

	`uvm_object_utils(bram_a_seq)
	
	function new(string name = "bram_a_seq");
		super.new(name);
   	endfunction

  	virtual task body();
  	
  	bram_a_item req;
  	
  	req = bram_a_item::type_id::create("req");
  	
  		forever begin
  	
	  		//start_item(req);
	  		//finish_item(req);
	  		
			start_item(req);
			req.in_data = 32'b00100000000000000000000000000000;
	  		finish_item(req);
	  		
	  		//start_item(req);
	  		//finish_item(req);
			
		end	  	
	endtask : body
endclass : bram_a_seq
