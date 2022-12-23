class imdct_sequencer extends uvm_sequencer#(imdct_item);

    `uvm_component_utils(imdct_sequencer)

    function new(string name = "imdct_sequencer", uvm_component parent = null);
        super.new(name,parent);
    endfunction

endclass : imdct_sequencer