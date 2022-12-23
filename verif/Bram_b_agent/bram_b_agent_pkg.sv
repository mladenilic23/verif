
package bram_b_agent_pkg;
 
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   //////////////////////////////////////////////////////////
   // include Agent components : driver,monitor,sequencer
   /////////////////////////////////////////////////////////
   import config_pkg::*;   
   
   `include "bram_b_item.sv"
   `include "bram_b_sequencer.sv"
   `include "bram_b_driver.sv"
   `include "bram_b_monitor.sv"
   `include "bram_b_agent.sv"

endpackage



