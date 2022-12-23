
package bram_a_agent_pkg;
 
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   //////////////////////////////////////////////////////////
   // include Agent components : driver,monitor,sequencer
   /////////////////////////////////////////////////////////
   import config_pkg::*;   
   
   `include "bram_a_item.sv"
   `include "bram_a_sequencer.sv"
   `include "bram_a_driver.sv"
   `include "bram_a_monitor.sv"
   `include "bram_a_agent.sv"

endpackage



