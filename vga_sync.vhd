----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:29:11 01/29/2014 
-- Design Name: 
-- Module Name:    vga_sync - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_sync is
    port ( clk         : in  std_logic;
           reset       : in  std_logic;
           h_sync      : out std_logic;
           v_sync      : out std_logic;
           v_completed : out std_logic;
           blank       : out std_logic;
           row         : out unsigned(10 downto 0);
           column      : out unsigned(10 downto 0)
     );
end vga_sync;

architecture moore of vga_sync is

signal h_sync_con, h_comp_con, v_sync_con, v_comp_con, h_blank, v_blank : std_logic;
signal row_con, column_con : unsigned(10 downto 0);

begin


	v_sync_inst: entity work.v_sync_gen(moore)
		port map(
			clk => clk,
			reset => reset,
			h_completed => h_comp_con,
			v_sync => v_sync_con,
			blank => v_blank,
			completed => v_comp_con,
			row => row_con
		);
		
	h_sync_inst: entity work.h_sync_gen(moore)
		port map( 
			clk => clk,
			reset => reset,
			h_sync => h_sync_con,
         blank => h_blank,
         completed => h_comp_con,
         column => column_con
     );
	  
	-- Outputs
	h_sync <= h_sync_con;
	v_sync <= v_sync_con;
	v_completed <= v_comp_con;
	blank <= v_blank or h_blank;
   row <= row_con;
   column <= column_con;  
	
		


end moore;

