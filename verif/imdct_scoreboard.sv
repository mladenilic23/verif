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
	
	int unsigned block_type_00, block_type_01, block_type_10, block_type_11;
	int unsigned gr, ch;	
	int start_count = 0; //broj izvrsavanja
  	bit ready;
	int bram_a_que[$];
	int bram_b_que[$];
	string s;
	int bram_a_data, bram_b_data;
	int address_of_data_a = 0;
	int address_of_data_b = 0;
	int ocekivane_vrednosti[0:17] = {4278967220, 44276972, 4225965081, 91025315, 4183740004, 130011893, 4147287539, 164724800, 4113391099, 198106977, 4080269803, 231991472, 4045388439, 268420964, 4006227902, 310820785, 3959585748, 363735046 };
	int i = 0;
	int j = 0;
	
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

				if(bram_a_que[j] == ocekivane_vrednosti[i]) begin
					`uvm_info(get_type_name(), $sformatf("Output match. (%d = %d)",ocekivane_vrednosti[i], bram_a_que[j] ), UVM_LOW)
				end
				else begin 
    				`uvm_error(get_type_name(), $sformatf("Output mismatch. OCEKIVANO: %d, REZULTAT: %d", ocekivane_vrednosti[i], bram_a_que[j]))
				end

				if( i > 17 )begin
					i = 0;
				end		
				
				i++;
				j++;

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

				if(bram_b_que[j] == ocekivane_vrednosti[i]) begin
					`uvm_info(get_type_name(), $sformatf("Output match. (%d = %d)",ocekivane_vrednosti[i], bram_b_que[j] ), UVM_LOW)
				end
				else begin 
    				`uvm_error(get_type_name(), $sformatf("Output mismatch. OCEKIVANO: %d, REZULTAT: %d", ocekivane_vrednosti[i], bram_b_que[j]))
				end

				if( i > 17 )begin
					i = 0;
				end		
				
				i++;
				j++;
				
			end
   		
		end

	endfunction : write_bram_b
	

endclass;
