
package imdct_pkg;

   import uvm_pkg::*;      // import the UVM library   
 `include "uvm_macros.svh" // Include the UVM macros

    import axi_lite_agent_pkg::*;
    import simple_pkg::*;
    import config_pkg::*;
    import bram_a_agent_pkg::*;
    import bram_b_agent_pkg::*;
    `include "imdct_scoreboard.sv"
    `include "imdct_env.sv"
    `include "test_base.sv"
    `include "test_simple.sv"
    `include "test_simple_2.sv"   

endpackage : imdct_pkg

 `include "imdct_if.sv"


