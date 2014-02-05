----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:29:56 01/29/2014 
-- Design Name: 
-- Module Name:    pixel_gen - Behavioral 
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

entity pixel_gen is
    port ( row      : in unsigned(10 downto 0);
           column   : in unsigned(10 downto 0);
           blank    : in std_logic;
           r        : out std_logic_vector(7 downto 0);
           g        : out std_logic_vector(7 downto 0);
           b        : out std_logic_vector(7 downto 0));
end pixel_gen;

architecture sel_arch of pixel_gen is

begin
	
		r <= (others => '0') when (blank = '1') else
			  (others => '1') when (column < 215) and (row < 300) else
			  (others => '0');
			  
		g <= (others => '0') when (blank = '1') else
			  (others => '1') when ((column > 215) and (column < 430) and (row < 300)) or (row > 300) else
			  (others => '0');
			  
	   b <= (others => '0') when (blank = '1') else
			  (others => '1') when ((column > 430) and (row < 300)) or (row > 300) else
			  (others => '0');

--r <= (others => '0') when blank = '1' else
--		(others => '1');
--
--g <= (others => '0');
--
--b <= (others => '0');

end sel_arch;