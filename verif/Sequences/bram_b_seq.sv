class bram_b_seq extends bram_b_base_seq;

	`uvm_object_utils(bram_b_seq)
	
	function new(string name = "bram_b_seq");
		super.new(name);
   	endfunction

  	virtual task body();
  	
  	bram_b_item req;
  	
  	req = bram_b_item::type_id::create("req");
  	
  		forever begin
  	
	  		//start_item(req);
	  		//finish_item(req);
	  		
			start_item(req);
			req.in_data = 32'b01000000000000000000000000000000;
	  		finish_item(req);
	  		
	  		//start_item(req);
	  		//finish_item(req);
			
		end	  	
	endtask : body
endclass : bram_b_seq
