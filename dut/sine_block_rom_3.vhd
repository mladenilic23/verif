----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/18/2023 07:33:48 AM
-- Design Name: 
-- Module Name: sine_block_rom_3 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sine_block_rom_3 is
    generic (
	       WIDTH : integer := 32;
	       WADDR   : integer := 12
    );
    port(
        address_s_b_3 : in  std_logic_vector(WADDR-1 downto 0);
        dout_s_b_3    : out std_logic_vector(WIDTH-1 downto 0)
    );
end sine_block_rom_3;

architecture Behavioral of sine_block_rom_3 is
  type mem is array ( 0 to 35) of std_logic_vector(WIDTH-1 downto 0);
  constant my_Rom : mem := (
    0 =>  "00000010000110000000000000000000",
    1 =>  "00000110001000000000000000000000",
    2 =>  "00001001101111000000000000000000",
    3 =>  "00001100101100000000000000000000",
    4 =>  "00001110110010000000000000000000",
    5 =>  "00001111110111000000000000000000",
    6 =>  "00001111110111000000000000000000",
    7 =>  "00001110110010000000000000000000",
    8 =>  "00001100101100000000000000000000",
    9 =>  "00001001101111000000000000000000",
    10 => "00000110001000000000000000000000",
    11 => "00000010000110000000000000000000",
    12 => "00000000000000000000000000000000",
    13 => "00000000000000000000000000000000",
    14 => "00000000000000000000000000000000",
    15 => "00000000000000000000000000000000",
    16 => "00000000000000000000000000000000",
    17 => "00000000000000000000000000000000",
    18 => "00000000000000000000000000000000",
    19 => "00000000000000000000000000000000",
    20 => "00000000000000000000000000000000",
    21 => "00000000000000000000000000000000",
    22 => "00000000000000000000000000000000",
    23 => "00000000000000000000000000000000",
    24 => "00000000000000000000000000000000",
    25 => "00000000000000000000000000000000",
    26 => "00000000000000000000000000000000",
    27 => "00000000000000000000000000000000",
    28 => "00000000000000000000000000000000",
    29 => "00000000000000000000000000000000",
    30 => "00000000000000000000000000000000",
    31 => "00000000000000000000000000000000",
    32 => "00000000000000000000000000000000",
    33 => "00000000000000000000000000000000",
    34 => "00000000000000000000000000000000",
    35 => "00000000000000000000000000000000");
    
begin

    main : process(address_s_b_3)
    begin
        dout_s_b_3 <= my_Rom(to_integer(unsigned(address_s_b_3)));
    end process main;

end Behavioral;

