----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/18/2023 07:16:04 AM
-- Design Name: 
-- Module Name: imdct - Behavioral
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
use IEEE.std_logic_unsigned.all;
--use IEEE.std_logic_arith.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity imdct is
    generic (
	       WIDTH : integer := 32;
	       WADDR   : integer := 12
    );

  	port( 	clk   : in  std_logic;		-- clock input signal
        	reset : in  std_logic;		-- reset signal (1 = reset)
        	start : in  std_logic;		-- start=1 means that this block is activated
        	ready : out std_logic;		-- generate a done signal for one clock pulse when finished
        	din_a   : in  std_logic_vector( WIDTH-1 downto 0 );	-- signals from memory
        	dout_a  : out std_logic_vector( WIDTH-1 downto 0 );
			addr_a  : out std_logic_vector( 32-1 downto 0 );
			we_a    : out std_logic;
			en_a    : out std_logic;
			din_b   : in  std_logic_vector( WIDTH-1 downto 0 );	-- signals from memory
        	dout_b  : out std_logic_vector( WIDTH-1 downto 0 );
			addr_b  : out std_logic_vector( WIDTH-1 downto 0 );
			we_b    : out std_logic;
			en_b    : out std_logic;
			block_type_00 : in std_logic_vector( 1 downto 0 );
			block_type_01 : in std_logic_vector( 1 downto 0 );
			block_type_10 : in std_logic_vector( 1 downto 0 );
			block_type_11 : in std_logic_vector( 1 downto 0 );
			gr    : in std_logic;
			ch    : in std_logic
    	);
end imdct;

architecture Behavioral of imdct is

    type state_type is ( idle, get_n, get_half_n, rst_xi_s, send_addr, calc_1, calc_1_v2, calc_2, get_sine_block, windowing_samples, windowing_samples_v2,
                         judge1, judge2, addr_temp_block, get_temp_block, calc_addr_sample_block_step_1, calc_sample_block_step_1,
                         get_temp_block_step_2,calc_sample_block_step_2,addr_temp_block_v1_step_3, get_temp_block_v1_step_3,
                         addr_temp_block_v2_step_3, get_temp_block_v2_step_3, calc_sample_block_step_3, calc_sample_block_step_3_v2,addr_temp_block_v1_step_4,
                         get_temp_block_v1_step_4, addr_temp_block_v2_step_4, get_temp_block_v2_step_4, calc_sample_block_step_4, calc_sample_block_step_4_v2,
                         addr_temp_block_step_5, calc_sample_block_step_5, calc_sample_block_step_6,
                         overlap_addr_sample_block, overlap_get_sample_block, overlap_addr_prev_sample, overlap_get_prev_sample,
                         overlap_send_data, overlap_send_data_v2, overlap_addr_sample_block_step_2, overlap_get_sample_block_step_2, overlap_prev_samples_addr,
                         overlap_prev_samples_send_data, judge3, send_data_to_adder, reset_prev_samples, reset_sample_tamp, calc_1_v1, windowing_samples_v1
                          );
  	
  	signal present_state,next_state: state_type;

  	signal gr_s : std_logic;
  	signal ch_s : std_logic;

    --counter
    signal block_s, win_s, i_s, k_s, x_s : integer;
    signal block_s_next, win_s_next, i_s_next, k_s_next, x_s_next : integer;
    signal win_temp_s, win_temp_s_next : integer;
    signal smp_s , smp_s_next : integer;

    signal n_s, n_s_next : integer;
    signal half_n_s , half_n_s_next : integer;
    signal bram_adr_pointer, bram_adr_pointer_next : integer;
    signal bram_pointer, bram_pointer_next : std_logic;
    
    signal block_type_s, block_type_s_next : std_logic_vector( 1 downto 0 );
    
    signal xi_s, xi_s_next: std_logic_vector(WIDTH-1 downto 0);

    -- dout from ROM memory
    signal dout_s_b_s, dout_s_b_s_next : std_logic_vector(WIDTH-1 downto 0);
    
    --cos_rom_0
    signal address_cos_0_s : std_logic_vector(10-1 downto 0);
    signal dout_cos_0_s : std_logic_vector(WIDTH-1 downto 0);

    --cos_rom_1
    signal address_cos_1_s : std_logic_vector(8-1 downto 0);
    signal dout_cos_1_s : std_logic_vector(WIDTH-1 downto 0);
    
    --sine_block_rom_1
    signal address_s_b_1_s : std_logic_vector(WADDR-1 downto 0);
    signal dout_s_b_1_s : std_logic_vector(WIDTH-1 downto 0); 
    
    --sine_block_rom_2
    signal address_s_b_2_s : std_logic_vector(WADDR-1 downto 0);
    signal dout_s_b_2_s : std_logic_vector(WIDTH-1 downto 0); 
    
    --sine_block_rom_3
    signal address_s_b_3_s : std_logic_vector(WADDR-1 downto 0);
    signal dout_s_b_3_s : std_logic_vector(WIDTH-1 downto 0); 
    
    --sine_block_rom_4
    signal address_s_b_4_s : std_logic_vector(WADDR-1 downto 0);
    signal dout_s_b_4_s : std_logic_vector(WIDTH-1 downto 0); 
    
    --sample_block_bram
    signal en_sample_block_s, we_sample_block_s : std_logic;
	signal addr_sample_block_s : std_logic_vector(WADDR-1 downto 0);
	signal do_sample_block_s : std_logic_vector(WIDTH-1 downto 0);
    signal di_sample_block_s : std_logic_vector(WIDTH-1 downto 0);
	signal sample_block_s, sample_block_s_next : std_logic_vector(WIDTH-1 downto 0);
    
     --temp_block_bram
    signal en_temp_block_s, we_temp_block_s : std_logic;
	signal addr_temp_block_s : std_logic_vector(WADDR-1 downto 0);
	signal di_temp_block_s, do_temp_block_s : std_logic_vector(WIDTH-1 downto 0);
    signal temp_block_value_1_s, temp_block_value_1_s_next : std_logic_vector(WIDTH-1 downto 0);
    signal temp_block_value_2_s, temp_block_value_2_s_next : std_logic_vector(WIDTH-1 downto 0);

     --prev_samples_0
    signal en_prev_samples_0_s, we_prev_samples_0_s : std_logic;
	signal addr_prev_samples_0_s : std_logic_vector(WADDR-1 downto 0);
	signal di_prev_samples_0_s, do_prev_samples_0_s : std_logic_vector(WIDTH-1 downto 0);
    
     --prev_samples_1
    signal en_prev_samples_1_s, we_prev_samples_1_s : std_logic;
	signal addr_prev_samples_1_s : std_logic_vector(WADDR-1 downto 0);
	signal di_prev_samples_1_s, do_prev_samples_1_s : std_logic_vector(WIDTH-1 downto 0);
    
    signal prev_samples_s, prev_samples_s_next : std_logic_vector(WIDTH-1 downto 0);
    
    signal z_temp, z_temp_next : std_logic_vector(WIDTH-1 downto 0);
    
    -- float point adder
    signal x_a                      ,  x_a_next                    : STD_LOGIC_VECTOR (31 downto 0);
    signal y_a                      ,  y_a_next                    : STD_LOGIC_VECTOR (31 downto 0);
    signal z_a                      ,  z_a_next                    : STD_LOGIC_VECTOR (31 downto 0);
    
    -- float point multiplication
    signal x_m             , x_m_next            :  STD_LOGIC_VECTOR (31 downto 0);
    signal y_m             , y_m_next            :  STD_LOGIC_VECTOR (31 downto 0);
    signal z_m             , z_m_next            :  STD_LOGIC_VECTOR (31 downto 0);
    signal z_m_64          , z_m_64_next         :  STD_LOGIC_VECTOR (63 downto 0);    
        
    component cos_rom
        port(
            address_cos_0 : in  std_logic_vector(10-1 downto 0);
            dout_cos_0   : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;
 
    component cos_rom_1
        port(
            address_cos_1 : in  std_logic_vector(8-1 downto 0);
            dout_cos_1   : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component; 
    
    component sine_block_rom_1
        port(
            address_s_b_1 : in  std_logic_vector(WADDR-1 downto 0);
            dout_s_b_1   : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;  
    
    component sine_block_rom_2
        port(
            address_s_b_2 : in  std_logic_vector(WADDR-1 downto 0);
            dout_s_b_2   : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;
    
    component sine_block_rom_3
        port(
            address_s_b_3 : in  std_logic_vector(WADDR-1 downto 0);
            dout_s_b_3   : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component; 
    
    component sine_block_rom_4
        port(
            address_s_b_4 : in  std_logic_vector(WADDR-1 downto 0);
            dout_s_b_4   : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;          

    component sample_block_bram
        port(
            clk_sample_block : in std_logic;
            reset_sample_block: in std_logic;
	        en_sample_block : in std_logic;
	        we_sample_block : in std_logic;
	        addr_sample_block : in std_logic_vector(WADDR-1 downto 0);
	        di_sample_block : in std_logic_vector(WIDTH-1 downto 0);
	        do_sample_block : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;

    component temp_block_bram
        port(
            clk_temp_block : in std_logic;
            reset_temp_block: in std_logic;
	        en_temp_block : in std_logic;
	        we_temp_block : in std_logic;
	        addr_temp_block : in std_logic_vector(WADDR-1 downto 0);
	        di_temp_block : in std_logic_vector(WIDTH-1 downto 0);
	        do_temp_block : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;

    component prev_samples_0
        port(
	        clk_prev_samples_0   : in std_logic;
            reset_prev_samples_0 : in std_logic;
	        en_prev_samples_0    : in std_logic;
	        we_prev_samples_0    : in std_logic;
	        addr_prev_samples_0  : in std_logic_vector(WADDR-1 downto 0);
	        di_prev_samples_0    : in std_logic_vector(WIDTH-1 downto 0);
	        do_prev_samples_0    : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;
    
    component prev_samples_1
        port(
            clk_prev_samples_1   : in std_logic;
            reset_prev_samples_1 : in std_logic;
	        en_prev_samples_1    : in std_logic;
	        we_prev_samples_1    : in std_logic;
	        addr_prev_samples_1  : in std_logic_vector(WADDR-1 downto 0);
	        di_prev_samples_1    : in std_logic_vector(WIDTH-1 downto 0);
	        do_prev_samples_1    : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;

begin
    
   c0: cos_rom
       port map(
	       address_cos_0 => address_cos_0_s,
	       dout_cos_0    => dout_cos_0_s
       );    

   c1: cos_rom_1
       port map(
	       address_cos_1 => address_cos_1_s,
	       dout_cos_1    => dout_cos_1_s
       );   

   c2: sine_block_rom_1
       port map(
	       address_s_b_1 => address_s_b_1_s,
	       dout_s_b_1    => dout_s_b_1_s
       );
        
   c3: sine_block_rom_2
       port map(
	       address_s_b_2 => address_s_b_2_s,
	       dout_s_b_2    => dout_s_b_2_s
       );
        
   c4: sine_block_rom_3
       port map(
	       address_s_b_3 => address_s_b_3_s,
	       dout_s_b_3    => dout_s_b_3_s
       );
        
   c5: sine_block_rom_4
       port map(
	       address_s_b_4 => address_s_b_4_s,
	       dout_s_b_4    => dout_s_b_4_s
       );

    c6: sample_block_bram
        port map(
            clk_sample_block   => clk,
            reset_sample_block => reset,
	        en_sample_block    => en_sample_block_s,
	        we_sample_block    => we_sample_block_s,
	        addr_sample_block  => addr_sample_block_s,
	        di_sample_block    => di_sample_block_s,
	        do_sample_block    => do_sample_block_s
        );

    c7: temp_block_bram
        port map(
            clk_temp_block   => clk,
            reset_temp_block => reset,
	        en_temp_block    => en_temp_block_s,
	        we_temp_block    => we_temp_block_s,
	        addr_temp_block  => addr_temp_block_s,
	        di_temp_block    => di_temp_block_s,
	        do_temp_block    => do_temp_block_s
        );

    c8: prev_samples_0
        port map(
            clk_prev_samples_0   => clk,
            reset_prev_samples_0 => reset,
	        en_prev_samples_0    => en_prev_samples_0_s,
	        we_prev_samples_0    => we_prev_samples_0_s,
	        addr_prev_samples_0  => addr_prev_samples_0_s,
	        di_prev_samples_0    => di_prev_samples_0_s,
	        do_prev_samples_0    => do_prev_samples_0_s
        );

    c9: prev_samples_1
        port map(
            clk_prev_samples_1   => clk,
            reset_prev_samples_1 => reset,
	        en_prev_samples_1    => en_prev_samples_1_s,
	        we_prev_samples_1    => we_prev_samples_1_s,
	        addr_prev_samples_1  => addr_prev_samples_1_s,
	        di_prev_samples_1    => di_prev_samples_1_s,
	        do_prev_samples_1    => do_prev_samples_1_s
        );

    process(clk, reset)  
    begin
          	if reset = '0' then               
	  			present_state <= idle;
	  			n_s <= 0;
                half_n_s <= 0;
                block_type_s <= (others => '0');
                bram_adr_pointer <= 0;
                bram_pointer <= '0';
                win_temp_s <= 0;
                xi_s <= (others => '0');
                sample_block_s <= (others => '0');
                prev_samples_s <= (others => '0');
                temp_block_value_1_s <= (others => '0');
                temp_block_value_2_s <= (others => '0');
	  			dout_s_b_s <= (others => '0');
	  			z_temp <= (others => '0');
	  			
     	   	elsif (rising_edge(clk)) then
          		present_state <= next_state;
          		n_s <= n_s_next;
                half_n_s <= half_n_s_next;
                block_type_s <= block_type_s_next;
                bram_adr_pointer <= bram_adr_pointer_next;
                bram_pointer <= bram_pointer_next; 
                win_temp_s <= win_temp_s_next;
                xi_s <= xi_s_next;
                sample_block_s <= sample_block_s_next;
                prev_samples_s <= prev_samples_s_next;
                temp_block_value_1_s <= temp_block_value_1_s_next;
                temp_block_value_2_s <= temp_block_value_2_s_next;
          		dout_s_b_s <= dout_s_b_s_next;
          		z_temp <= z_temp_next;
          		x_m             <= x_m_next;
                y_m             <= y_m_next;
                z_m             <= z_m_next;
                z_m_64          <= z_m_64_next;
                x_a             <= x_a_next;
                y_a             <= y_a_next;
                z_a             <= z_a_next;
			end if;
    end process;

    -- counter   
    process(clk, reset)
    begin
          	if reset = '0' then               
	  			block_s <= 0;
	  			win_s   <= 0;
	  			i_s     <= 0;
	  			k_s     <= 0;
	  			x_s     <= 0;
	  			smp_s <= 0;
     	   	elsif (rising_edge(clk)) then
          		block_s <= block_s_next;
          		win_s   <= win_s_next;
          		i_s     <= i_s_next;
          		k_s     <= k_s_next;
          		x_s     <= x_s_next;
          		smp_s <= smp_s_next;
			end if;
    end process;

    process( present_state, block_s, win_s, i_s, k_s, x_s, smp_s, start,block_type_s, block_type_00, block_type_01, block_type_10, block_type_11, n_s, gr, ch, bram_adr_pointer, bram_pointer, half_n_s, din_a, din_b,
             dout_cos_0_s, xi_s, k_s_next, dout_s_b_1_s, dout_s_b_2_s, dout_s_b_3_s, dout_s_b_4_s,
             dout_s_b_s, i_s_next, win_s_next, win_temp_s, do_sample_block_s, do_temp_block_s, temp_block_value_1_s,
             temp_block_value_2_s, do_prev_samples_0_s, do_prev_samples_1_s,  sample_block_s, prev_samples_s, block_s_next, 
             smp_s_next, dout_cos_1_s, z_temp, x_m, y_m, z_m, z_m_64, x_a, y_a, z_a )
    begin
    
        --default:
        next_state  <= present_state;
        block_s_next <= block_s;
        win_s_next <= win_s;
        i_s_next <= i_s;
        k_s_next <= k_s;
        x_s_next <= x_s;
        smp_s_next <= smp_s;
        n_s_next <= n_s;
        half_n_s_next <= half_n_s;
        block_type_s_next <= block_type_s;
        bram_adr_pointer_next <= bram_adr_pointer;
        bram_pointer_next <= bram_pointer;
        win_temp_s_next <= win_temp_s;
        xi_s_next <= xi_s;
        sample_block_s_next <= sample_block_s;
        prev_samples_s_next <= prev_samples_s;
        temp_block_value_1_s_next <= temp_block_value_1_s;
        temp_block_value_2_s_next <= temp_block_value_2_s;
        z_temp_next <= z_temp;
        en_a <= '0';
        we_a <= '0';
        addr_a <= (others => '0');
        dout_a <= (others => '0');
        en_b <= '0';
        we_b <= '0';
        addr_b <= (others => '0');
        dout_b <= (others => '0');
        dout_s_b_s_next <= dout_s_b_s;
        en_temp_block_s <= '0';
        we_temp_block_s <= '0';
        addr_temp_block_s <= (others => '0');
        di_temp_block_s <= (others => '0');
        en_sample_block_s <= '0';
        we_sample_block_s <= '0';
        addr_sample_block_s <= (others => '0');
        di_sample_block_s <= (others => '0');
        en_prev_samples_0_s <= '0';
        we_prev_samples_0_s <= '0';
        addr_prev_samples_0_s <= (others => '0');
        di_prev_samples_0_s <= (others => '0');
        en_prev_samples_1_s <= '0';
        we_prev_samples_1_s <= '0';
        addr_prev_samples_1_s <= (others => '0');
        di_prev_samples_1_s <= (others => '0');
        address_cos_0_s <= (others => '0');
        address_cos_1_s <= (others => '0');
        address_s_b_1_s <= (others => '0');
        address_s_b_2_s <= (others => '0');
        address_s_b_3_s <= (others => '0');
        address_s_b_4_s <= (others => '0');
        x_m_next            <= x_m;
        y_m_next            <= y_m;
        z_m_next            <= z_m;
        z_m_64_next         <= z_m_64;
        x_a_next                     <= x_a;
        y_a_next                     <= y_a;
        z_a_next                     <= z_a;
        ready <= '0';
        
        case present_state is
            when idle =>
                ready <= '1';
                
                if (start = '1') then
                    block_s_next <= 0;
                    win_s_next <= 0;
                    i_s_next <= 0;
                    k_s_next <= 0;
                    x_s_next <= 0;
                    smp_s_next <= 0;
                    next_state <= reset_prev_samples;
                else
                    next_state <= idle;
                end if;
        
            when reset_prev_samples =>
                en_prev_samples_0_s <= '1';
                we_prev_samples_0_s <= '1';
                addr_prev_samples_0_s <=  std_logic_vector(to_unsigned( i_s , WADDR ));
                di_prev_samples_0_s <= std_logic_vector(to_unsigned( 0 , WIDTH ));
                
                en_prev_samples_1_s <= '1';
                we_prev_samples_1_s <= '1';
                addr_prev_samples_1_s <=  std_logic_vector(to_unsigned( i_s , WADDR ));
                di_prev_samples_1_s <= std_logic_vector(to_unsigned( 0 , WIDTH ));
                
                if( i_s < 575 ) then
                    i_s_next <= i_s + 1;
                    next_state <= reset_prev_samples;
                else
                    i_s_next <= 0;
                   next_state <= reset_sample_tamp;
                end if;
                
            when reset_sample_tamp =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '1';
                addr_sample_block_s <=  std_logic_vector(to_unsigned( i_s , WADDR ));
                di_sample_block_s <= std_logic_vector(to_unsigned( 0 , WIDTH ));
                
                en_temp_block_s <= '1';
                we_temp_block_s <= '1';
                addr_temp_block_s <=  std_logic_vector(to_unsigned( i_s , WADDR ));
                di_temp_block_s <= std_logic_vector(to_unsigned( 0 , WIDTH ));
                
                if( i_s < 35 ) then
                    i_s_next <= i_s + 1;
                    next_state <= reset_sample_tamp;
                else
                    i_s_next <= 0;
                    if(gr = '0' and ch = '0') then
                        block_type_s_next <= block_type_00;
                    elsif (gr = '0' and ch = '1') then
                        block_type_s_next <= block_type_01; 
                    elsif (gr = '1' and ch = '0') then
                        block_type_s_next <= block_type_10;
                    else 
                        block_type_s_next <= block_type_11;
                    end if;
                        next_state <= get_n;
                 end if;    
                
            when get_n =>
            
                if( block_type_s = "10" ) then
                    n_s_next <= 12;
                else
                    n_s_next <= 36;            
                end if;
                
                next_state <= get_half_n;
                
            when get_half_n =>
                half_n_s_next <= n_s / 2;
                
                if( gr = '0' and ch = '0' ) then
                    bram_adr_pointer_next <= 0;
                    bram_pointer_next <= '0';
                elsif( gr = '0' and ch = '1' ) then
                    bram_adr_pointer_next <= 576;
                    bram_pointer_next <= '0';
                elsif( gr = '1' and ch = '0' ) then
                    bram_adr_pointer_next <= 0;
                    bram_pointer_next <= '1';
                elsif( gr = '1' and ch = '1' ) then
                    bram_adr_pointer_next <= 576;
                    bram_pointer_next <= '1';
                end if;
                
                next_state <= rst_xi_s;
                
            when rst_xi_s =>
                xi_s_next <= std_logic_vector(to_unsigned( 0 , WIDTH ));
                next_state <= calc_1;
                
            when calc_1 =>
                if( bram_pointer = '0' ) then    
                    en_a <= '1';
                    we_a <= '0';
                    addr_a <= std_logic_vector(to_unsigned( ( ( bram_adr_pointer + ( 18 * block_s + half_n_s * win_s + k_s ) ) * 4 ), 32 ));
                    x_m_next <= din_a;
                elsif( bram_pointer = '1' ) then
                    en_b <= '1';
                    we_b <= '0';
                    addr_b <= std_logic_vector(to_unsigned( ( ( bram_adr_pointer + ( 18 * block_s + half_n_s * win_s + k_s ) ) * 4 ), 32 ));
                    x_m_next <= din_b;
                end if;
                
                if ( block_type_s = "10" ) then
                    address_cos_1_s <= std_logic_vector(to_unsigned( k_s + ( i_s * 6 ) , 8 ));
                    y_m_next <= dout_cos_1_s;
                else
                    address_cos_0_s <= std_logic_vector(to_unsigned( k_s + ( i_s * 18 ) , 10 ));
                    y_m_next <= dout_cos_0_s;
                end if;
                next_state <= calc_1_v1;
            
            when calc_1_v1 =>
                z_m_64_next <= std_logic_vector(signed(x_m) * signed(y_m));
                next_state <= calc_1_v2;
     
            when calc_1_v2 =>
                z_m_next <= z_m_64(59 downto 28);
                
                next_state <= calc_2;
            
            when calc_2 =>
            
                 xi_s_next <= std_logic_vector( signed(z_m) + signed(xi_s) );
                
                if( k_s < ( half_n_s - 1 ) ) then
                    k_s_next <= k_s + 1;
                    next_state <= calc_1;
                else
                    next_state <= get_sine_block;
                    k_s_next <= 0;
                end if;
                
            when get_sine_block =>
                    
                if( block_type_s = "00" ) then
                    address_s_b_1_s <= std_logic_vector(to_unsigned( i_s , WADDR ));
                    dout_s_b_s_next <= dout_s_b_1_s;
                elsif( block_type_s = "01" ) then
                    address_s_b_2_s <= std_logic_vector(to_unsigned( i_s , WADDR ));
                    dout_s_b_s_next <= dout_s_b_2_s;
                elsif( block_type_s = "10" ) then
                    address_s_b_3_s <= std_logic_vector(to_unsigned( i_s , WADDR ));
                    dout_s_b_s_next <= dout_s_b_3_s;
                elsif( block_type_s = "11" ) then
                    address_s_b_4_s <= std_logic_vector(to_unsigned( i_s , WADDR ));
                    dout_s_b_s_next <= dout_s_b_4_s;
                end if; 
                
                next_state <= windowing_samples;
                
            when windowing_samples =>
                z_m_64_next <= std_logic_vector(signed(xi_s) * signed(dout_s_b_s));
                next_state <= windowing_samples_v1;
            
            when windowing_samples_v1 =>
                z_m_next <= z_m_64(59 downto 28);
                next_state <= windowing_samples_v2;
            
            when windowing_samples_v2 =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '1';
                addr_sample_block_s <=  std_logic_vector(to_unsigned( ( win_s * n_s + i_s ) , WADDR ));
                di_sample_block_s <= z_m;                        
              
                if( i_s < ( n_s - 1 ) ) then
                    i_s_next <= i_s + 1;
                    next_state <= rst_xi_s;
                else
                    i_s_next <= 0;
                if( block_type_s = "10" ) then
                    win_temp_s_next <= 3;
                else 
                    win_temp_s_next <= 1;
                end if;
                    next_state <= judge1;
                end if;
            
            when judge1 =>
                if( win_s < ( win_temp_s - 1 ) ) then
                    win_s_next <= win_s + 1;
                    next_state <= rst_xi_s;
                else 
                    win_s_next <= 0;
                    next_state <= judge2;
                end if;    
            
            when judge2 =>
                if( block_type_s = "10" ) then
                    next_state <= addr_temp_block;
                else 
                    next_state <= overlap_addr_sample_block;
                end if;
            
            when addr_temp_block =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '0';
                addr_sample_block_s <=  std_logic_vector(to_unsigned( x_s, WADDR ));
                next_state <= get_temp_block;
                
            when get_temp_block =>             
                en_temp_block_s <= '1';
                we_temp_block_s <= '1';
                addr_temp_block_s <=  std_logic_vector(to_unsigned( x_s, WADDR ));

                di_temp_block_s <= do_sample_block_s;
                
                if ( x_s < ( 36 - 1) ) then
                    x_s_next <= x_s + 1;
                    next_state <= addr_temp_block;
                else
                    x_s_next <= 0;
                    i_s_next <= 0;
                    next_state <= calc_sample_block_step_1;
                end if;                

            when calc_sample_block_step_1 =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '1';
                addr_sample_block_s <=  std_logic_vector(to_unsigned( i_s, WADDR ));
                di_sample_block_s <= std_logic_vector(to_unsigned( 0, WIDTH ));
                i_s_next <= i_s + 1;
                
                if ( i_s < (6 - 1) ) then    
                    next_state <= calc_sample_block_step_1;
                else
                    next_state <= get_temp_block_step_2;
                end if;    
    
            when get_temp_block_step_2 =>
                en_temp_block_s <= '1';
                we_temp_block_s <= '0';
                addr_temp_block_s <=  std_logic_vector(to_unsigned( ( 0 + i_s - 6 ), WADDR ));
 
                next_state <= calc_sample_block_step_2;

            when calc_sample_block_step_2 =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '1';
                addr_sample_block_s <=  std_logic_vector(to_unsigned( i_s, WADDR ));
                di_sample_block_s <= do_temp_block_s;
                i_s_next <= i_s + 1;
                
                if ( i_s < (12 - 1) ) then    
                    next_state <= get_temp_block_step_2;
                else
                    next_state <= addr_temp_block_v1_step_3;
                end if;

            when addr_temp_block_v1_step_3 =>
                en_temp_block_s <= '1';
                we_temp_block_s <= '0';
                addr_temp_block_s <=  std_logic_vector(to_unsigned( ( 0 + i_s - 6 ), WADDR ));
                next_state <= get_temp_block_v1_step_3;

            when get_temp_block_v1_step_3 =>
                temp_block_value_1_s_next <= do_temp_block_s;next_state <= addr_temp_block_v2_step_3;                
 
            when addr_temp_block_v2_step_3 =>
                en_temp_block_s <= '1';
                we_temp_block_s <= '0';
                addr_temp_block_s <=  std_logic_vector(to_unsigned( ( 12 + i_s - 12 ), WADDR ));
                next_state <= get_temp_block_v2_step_3;
 
            when get_temp_block_v2_step_3 =>
                temp_block_value_2_s_next <= do_temp_block_s;
                next_state <= calc_sample_block_step_3;             

            when calc_sample_block_step_3 =>
                z_a_next <= std_logic_vector( signed(temp_block_value_1_s) + signed(temp_block_value_2_s) );
                next_state <= calc_sample_block_step_3_v2;       

            when calc_sample_block_step_3_v2 =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '1';
                addr_sample_block_s <=  std_logic_vector(to_unsigned( i_s, WADDR ));
                di_sample_block_s <= z_a;
                
                i_s_next <= i_s + 1;
                
                if ( i_s < (18 - 1) ) then
                    next_state <= addr_temp_block_v1_step_3;
                else
                    next_state <= addr_temp_block_v1_step_4;
                end if;     

            when addr_temp_block_v1_step_4 =>
                en_temp_block_s <= '1';
                we_temp_block_s <= '0';
                addr_temp_block_s <=  std_logic_vector(to_unsigned( ( 12 + i_s - 12 ), WADDR ));
                next_state <= get_temp_block_v1_step_4;
                
            when get_temp_block_v1_step_4 =>
                temp_block_value_1_s_next <= do_temp_block_s;
            
                next_state <= addr_temp_block_v2_step_4;

            when addr_temp_block_v2_step_4 =>
                en_temp_block_s <= '1';
                we_temp_block_s <= '0';
                addr_temp_block_s <=  std_logic_vector(to_unsigned( ( 24 + i_s - 18 ), WADDR ));
                next_state <= get_temp_block_v2_step_4;

            when get_temp_block_v2_step_4 =>
                temp_block_value_2_s_next <= do_temp_block_s;
                next_state <= calc_sample_block_step_4;             

            when calc_sample_block_step_4 =>
                z_a_next <= std_logic_vector( signed(temp_block_value_1_s) + signed(temp_block_value_2_s) );
                
                next_state <= calc_sample_block_step_4_v2;   
            
            when calc_sample_block_step_4_v2 =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '1';
                addr_sample_block_s <=  std_logic_vector(to_unsigned( i_s, WADDR ));
                di_sample_block_s <= z_a;
                i_s_next <= i_s + 1;
                
                if ( i_s < (24 - 1) ) then
                    next_state <= addr_temp_block_v1_step_4;
                else
                    next_state <= addr_temp_block_step_5;
                end if;
    
            when addr_temp_block_step_5 =>
                en_temp_block_s <= '1';
                we_temp_block_s <= '0';
                addr_temp_block_s <=  std_logic_vector(to_unsigned( ( 24 + i_s - 18 ), WADDR ));
                next_state <= calc_sample_block_step_5;
    
            when calc_sample_block_step_5 =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '1';
                addr_sample_block_s <=  std_logic_vector(to_unsigned( i_s, WADDR ));
                di_sample_block_s <= do_temp_block_s;
                i_s_next <= i_s + 1;
                
                if ( i_s < (30 - 1) ) then
                    next_state <= addr_temp_block_step_5;
                else
                    next_state <= calc_sample_block_step_6;
                end if;

            when calc_sample_block_step_6 =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '1';
                addr_sample_block_s <= std_logic_vector(to_unsigned( i_s, WADDR ));
                di_sample_block_s <= std_logic_vector(to_unsigned( 0, WIDTH ));
                i_s_next <= i_s + 1;
                
                if ( i_s < (36 - 1) ) then
                    next_state <= calc_sample_block_step_6;
                else
                    i_s_next <= 0;
                    next_state <= overlap_addr_sample_block;
                end if;
            
            when overlap_addr_sample_block =>
                en_sample_block_s <= '1';
                we_sample_block_s <= '0';
                addr_sample_block_s <=  std_logic_vector(to_unsigned( i_s, WADDR ));
                next_state <= overlap_get_sample_block;
                
            when overlap_get_sample_block =>    
                sample_block_s_next <= do_sample_block_s;
                next_state <= overlap_addr_prev_sample;
            
            when overlap_addr_prev_sample =>
                en_prev_samples_0_s <= '1';
                we_prev_samples_0_s <= '0';
                addr_prev_samples_0_s <=  std_logic_vector(to_unsigned( i_s + smp_s, WADDR ));
                
                en_prev_samples_1_s <= '1';
                we_prev_samples_1_s <= '0';
                addr_prev_samples_1_s <=  std_logic_vector(to_unsigned( i_s + smp_s, WADDR ));
                next_state <= overlap_get_prev_sample;
            
            when overlap_get_prev_sample =>    
                
                if( ch = '0' ) then
                    prev_samples_s_next <= do_prev_samples_0_s;
                else
                    prev_samples_s_next <= do_prev_samples_1_s;
                end if;
                next_state <= overlap_send_data;
            
            when overlap_send_data =>
                z_a_next <= std_logic_vector( signed(sample_block_s) + signed(prev_samples_s) );
                
                next_state <= overlap_send_data_v2;   
                
            when overlap_send_data_v2 =>
                if( bram_pointer = '0' ) then    
                    en_a <= '1';
                    we_a <= '1';
                    addr_a <= std_logic_vector(to_unsigned( ( ( bram_adr_pointer + ( smp_s + i_s ) ) * 4 ), 32 ));
                    dout_a <= z_a;
                elsif( bram_pointer = '1' ) then
                    en_b <= '1';
                    we_b <= '1';
                    addr_b <= std_logic_vector(to_unsigned( ( ( bram_adr_pointer + ( smp_s + i_s ) ) * 4 ), 32 ));
                    dout_b <= z_a;
                end if;
                
                next_state <= overlap_addr_sample_block_step_2;
            
            when overlap_addr_sample_block_step_2 =>    
                en_sample_block_s <= '1';
                we_sample_block_s <= '0';
                addr_sample_block_s <=  std_logic_vector(to_unsigned( 18 + i_s, WADDR ));
                next_state <= overlap_get_sample_block_step_2;

            when overlap_get_sample_block_step_2 =>
                sample_block_s_next <= do_sample_block_s;
                next_state <= overlap_prev_samples_send_data;

            when overlap_prev_samples_send_data =>
                if( ch = '0' ) then
                    en_prev_samples_0_s <= '1';
                    we_prev_samples_0_s <= '1';
                    addr_prev_samples_0_s <=  std_logic_vector(to_unsigned( i_s + smp_s, WADDR ));
                    di_prev_samples_0_s <= sample_block_s;
                else
                    en_prev_samples_1_s <= '1';
                    we_prev_samples_1_s <= '1';
                    addr_prev_samples_1_s <=  std_logic_vector(to_unsigned( i_s + smp_s, WADDR ));
                    di_prev_samples_1_s <= sample_block_s;
                end if;
                
                if ( i_s < ( 18 - 1 ) ) then
                    i_s_next <= i_s + 1;
                    next_state <= overlap_addr_sample_block;
                else
                    i_s_next <= 0;
                    smp_s_next <= smp_s + 18; 
                    next_state <= judge3;
                end if;
            
            when judge3 =>
                if( block_s < ( 32 - 1 ) ) then
                    block_s_next <= block_s + 1;
                    next_state <= rst_xi_s;
                else
                    win_s_next <= 0;
                    next_state <= idle;   
                end if; 
                
            when others => next_state <= idle;
        
        end case;
    end process;

end Behavioral;

