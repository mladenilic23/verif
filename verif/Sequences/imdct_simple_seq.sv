class imdct_simple_seq extends imdct_base_seq;

    `uvm_object_utils (imdct_simple_seq)

    function new(string name = "imdct_simple_seq");
        super.new(name);
    endfunction

    virtual task body();
        // simple example - just send one item
        `uvm_do(req);
    endtask : body 

endclass : imdct_simple_seq
