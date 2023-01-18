`uvm_analysis_imp_decl(_axi_lite)
`uvm_analysis_imp_decl(_bram_a)
`uvm_analysis_imp_decl(_bram_b)

class imdct_scoreboard extends uvm_scoreboard;
	
	//control fileds
   	bit checks_enable = 1;
   	bit coverage_enable = 1;
   	
	axi_lite_item axi_tr_clone;
	bram_a_item bram_a_tr_clone;
	bram_b_item bram_b_tr_clone;
	
	int block_type_00, block_type_01, block_type_10, block_type_11;
	int gr, ch;	
	int start_count = 0; //broj izvrsavanja
  	bit ready;
	int unsigned bram_a_que[$];
	int unsigned bram_b_que[$];
	string s;
	int bram_a_data, bram_b_data;
	int address_of_data_a = 0;
	int address_of_data_b = 0;
	  
	uvm_analysis_imp_axi_lite#(axi_lite_item, imdct_scoreboard) axi_lite_collected_port;
	uvm_analysis_imp_bram_a#(bram_a_item, imdct_scoreboard) bram_a_collected_port;
	uvm_analysis_imp_bram_b#(bram_b_item, imdct_scoreboard) bram_b_collected_port;

	`uvm_component_utils_begin(imdct_scoreboard)
      `uvm_field_int(checks_enable, UVM_DEFAULT)
      `uvm_field_int(coverage_enable, UVM_DEFAULT)
   	`uvm_component_utils_end

	function new(string name = "imdct_scoreboard", uvm_component parent);
		super.new(name,parent);
		axi_lite_collected_port = new("axi_lite_collected_port", this);
		bram_a_collected_port = new("bram_a_collected_port", this);
		bram_b_collected_port = new("bram_b_collected_port", this);
	endfunction

	
	function void write_axi_lite(axi_lite_item axi_tr);

		$cast(axi_tr_clone, axi_tr.clone());
	
		if(checks_enable) begin
 			
			//block_type_00
			if(axi_tr_clone.address == 4) begin
				block_type_00 = axi_tr_clone.data;
		    	`uvm_info(get_type_name(), $sformatf("BLOCK_TYPE_00 : %d", block_type_00), UVM_LOW)
		    end	
			    
			//block_type_01
			else if(axi_tr_clone.address == 8) begin
				block_type_01 = axi_tr_clone.data;
		    	`uvm_info(get_type_name(), $sformatf("BLOCK_TYPE_01 : %d", block_type_01), UVM_LOW)
			end
				
			//block_type_10
			else if(axi_tr_clone.address == 12) begin
				block_type_10 = axi_tr_clone.data;
		    	`uvm_info(get_type_name(), $sformatf("BLOCK_TYPE_10 : %d", block_type_10), UVM_LOW)
			end
				
			//block_type_11
			else if(axi_tr_clone.address == 16) begin
				block_type_11 = axi_tr_clone.data;
		    	`uvm_info(get_type_name(), $sformatf("BLOCK_TYPE_11 : %d", block_type_11), UVM_LOW)
			end
			
 			//gr
			else if(axi_tr_clone.address == 20) begin
				gr = axi_tr_clone.data;
		    	`uvm_info(get_type_name(), $sformatf("GR : %d", gr), UVM_LOW)
			end
				
			//ch
			else if(axi_tr_clone.address == 24) begin
				ch = axi_tr_clone.data;
		    	`uvm_info(get_type_name(), $sformatf("CH : %d", ch), UVM_LOW)
			end
		
			//start
			else if(axi_tr_clone.address == 0) begin
			
    			if(axi_tr_clone.data == 1) begin
     				`uvm_info(get_type_name(), $sformatf("IMDCT started (start_count: %d)", start_count), UVM_LOW)
    				start_count++;
   				end
   				
			end
  				
			//ready	
			else if(axi_tr_clone.address == 28) begin
			
    			if(axi_tr_clone.data == 1) begin
     				ready = 1;
 					`uvm_info(get_type_name(), "READY is 1.", UVM_LOW)
   				end
   				
			end
				
			//Ako pokusamo da pristupimo registru koji ne postoji
			if(axi_tr_clone.address == 0 || axi_tr_clone.address == 4 || axi_tr_clone.address == 8 || axi_tr_clone.address == 12 || axi_tr_clone.address == 16 || axi_tr_clone.address == 20 || axi_tr_clone.address == 24 || axi_tr_clone.address == 28) begin
				`uvm_info(get_type_name(), $sformatf("AXI DATA SCOREBOARD: \n%s", axi_tr_clone.sprint()), UVM_DEBUG)
			end
			else begin
				`uvm_error(get_type_name(), $sformatf("Register with the address of %d doesn't exist.",axi_tr_clone.address))
			end
			
		end
	
	endfunction : write_axi_lite
	

	function void write_bram_a(bram_a_item bram_a_tr);
	
		

		$cast(bram_a_tr_clone, bram_a_tr.clone());
	    	 		
		if(checks_enable) begin
     		//provera validnosti podatka (da li je enable na 1)
			if(bram_a_tr_clone.en !== 1) begin 
    			`uvm_error(get_type_name(), "Bram A data is not valid because en is at 0.")
   			end
   			else begin
    			`uvm_info(get_type_name(), "Bram A data is valid.", UVM_LOW)
   			end
   		
   			//cekiranje adrese
			if(bram_a_tr_clone.we == 1) begin

				bram_a_que.push_back(bram_a_tr_clone.in_data); //punim queue A sa podacima
   				`uvm_info(get_type_name(), $sformatf("BRAM_A QUE: \n%p", bram_a_que), UVM_LOW)
				
  				if(4*address_of_data_a == bram_a_tr_clone.address) begin
    				`uvm_info(get_type_name(),"Address of A is okay.", UVM_LOW)
  				end
  				else begin
    				`uvm_error(get_type_name(),$sformatf("Address of A is %d, it should be %d", bram_a_tr_clone.address, 4*address_of_data_a))
  				end

  				address_of_data_a++;
				
			end
		end
	endfunction : write_bram_a
	
	
	function void write_bram_b(bram_b_item bram_b_tr);

		$cast(bram_b_tr_clone, bram_b_tr.clone());
	 	
		if(checks_enable) begin
     		//provera validnosti podatka (da li je enable na 1)
			if(bram_b_tr_clone.en !== 1) begin 
    			`uvm_error(get_type_name(), "Bram B data is not valid because en is at 0.")
   			end
   			else begin
    			`uvm_info(get_type_name(), "Bram B data is valid.", UVM_LOW)
   			end
   					
   			//cekiranje adrese
			if(bram_b_tr_clone.we == 1) begin

				bram_b_que.push_back(bram_b_tr_clone.in_data); //punim queue B sa podacima
				`uvm_info(get_type_name(), $sformatf("BRAM_B QUE: \n%p", bram_b_que), UVM_LOW)
				
  				if(4*address_of_data_b == bram_b_tr_clone.address) begin
    				`uvm_info(get_type_name(), "Address of B is okay!", UVM_LOW)
  				end
  				else begin
    				`uvm_error(get_type_name(),$sformatf("Address of B is %d, it should be %d", bram_b_tr_clone.address, 4*address_of_data_b))
  				end

  				address_of_data_b++;
				
			end
   		
		end

	endfunction : write_bram_b
	
	
	function void check_phase(uvm_phase phase);
	
		//check for bram a 
 		if(start_count !== 0) begin
			assert_epmty_queue_bram_a_after_pop_front: assert (bram_a_que.size() == 0)
	  		begin
	    		s = "\n Queue bram_a is empty! \n";
	    		//print message
	    		`uvm_info(get_type_name(), $sformatf("%s", s), UVM_HIGH)
	  		end 
	  		else begin
	    		s = $sformatf("\n Queue koji sadrzi podatke iz bram_a nije prazan, sadrzi %0d: \n" ,bram_a_que.size());
	    		//print message
      			`uvm_error(get_type_name(), $sformatf("%s", s))
	    
	    	foreach (bram_a_que[i]) begin
	      	`uvm_info(get_type_name(), $sformatf("Transakcija [%d] :", i), UVM_LOW)
	    	end
  			end
	  
  			//check for bram b 
			assert_epmty_queue_bram_b_after_pop_front: assert (bram_b_que.size() == 0)
	  		begin
	    		s = "\n Queue bram_b is empty! \n";
	    		// print message
	    		`uvm_info(get_type_name(), $sformatf("%s", s), UVM_HIGH)
	  		end
  	 		else begin
	    		s = $sformatf("\n Queue koji sadrzi podatke iz bram_b nije prazan, sadrzi %0d: \n" ,bram_b_que.size());
	    		//print message
      			`uvm_error(get_type_name(), $sformatf("%s", s))
	    
	    	foreach (bram_b_que[i]) begin
	      	`uvm_info(get_type_name(), $sformatf("Transakcija [%d] :", i), UVM_LOW)
	    	end
	  		end
	  
			`uvm_info( get_type_name(), $sformatf("Number of imdct is %d. ", start_count), UVM_LOW)
   			start_count = 0; // vrati start_count na 0 za sledeci ciklus
 		end
 	
   		else begin //ako nema starta
    		`uvm_info(get_type_name(), "IMDCT wasn't started.", UVM_LOW)
   		end
   	
	endfunction: check_phase

endclass;
