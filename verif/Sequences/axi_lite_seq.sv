class axi_lite_seq extends axi_lite_base_seq;
      
    `uvm_object_utils (axi_lite_seq)

    function new(string name = "axi_lite_seq");
        super.new(name);
    endfunction

	// body task
  	virtual task body();
		
		req = axi_lite_item::type_id::create("req");
		
		forever begin
  			
  			//block_type_01
  			start_item(req);
  
  				if(!req.randomize() with {req.read_write == 1; req.address == 4; req.data == 2'b01;}) begin
    				`uvm_fatal(get_type_name(), "Failed to randomize.")
  				end
  				 
  			finish_item(req);
  			
  			//gr
  			start_item(req);
  
  				if(!req.randomize() with {req.read_write == 1; req.address == 20; req.data == 0;}) begin 
    				`uvm_fatal(get_type_name(), "Failed to randomize.")
  				end
  				 
  			finish_item(req);
  			
  			//start
  			start_item(req);
  				 
  				if(!req.randomize() with {req.read_write == 1; req.address == 0; req.data == 1;}) begin 
    				`uvm_fatal(get_type_name(), "Failed to randomize.")
  				end  
  
  			finish_item(req);
  			
		end

	endtask : body
  
endclass : axi_lite_seq

