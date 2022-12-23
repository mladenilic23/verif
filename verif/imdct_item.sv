class imdct_item extends uvm_sequence_item;

    `uvm_object_utils_begin(imdct_item)   
    `uvm_object_utils_end

    function new(string name = "imdct_item");
        super.new(name);
    endfunction 

endclass : imdct_item