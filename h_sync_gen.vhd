----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:27:27 01/29/2014 
-- Design Name: 
-- Module Name:    h_sync_gen - Behavioral 
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

entity h_sync_gen is
    port ( clk       : in  std_logic;
           reset     : in  std_logic;
           h_sync    : out std_logic;
           blank     : out std_logic;
           completed : out std_logic;
           column    : out unsigned(10 downto 0)
     );
end h_sync_gen;

architecture look_ahead_buffer_arch of h_sync_gen is
	type h_sync_state is
		(a_video, f_porch, sync_pulse, b_porch, completed_state);
	signal state_reg, state_next : h_sync_state;	
	signal count_reg, count_next, column_buf_reg, column_next : unsigned(10 downto 0);
	signal h_sync_buf_reg, h_sync_next, blank_buf_reg, blank_next, completed_buf_reg, 
			 completed_next: std_logic;
begin

	-- state register
	process(clk,reset)
	begin
		if (reset='1') then
			state_reg <= a_video;
		elsif (clk'event and clk='1') then
			state_reg <= state_next;
		end if;
	end process;
	
	process(clk, reset)
	begin
		if(reset='1') then
			count_reg <= (others => '0');
		elsif (clk'event and clk='1') then
			count_reg <= count_next;
		end if;
	end process;
	
	-- output buffer
	process(clk, reset)
	begin
		if (reset='1') then
			h_sync_buf_reg <= '0';
			blank_buf_reg <= '0';
			completed_buf_reg <= '0';
			column_buf_reg <= (others => '0');
		elsif (clk'event and clk='1') then
			h_sync_buf_reg <= h_sync_next;
			blank_buf_reg <= blank_next;
			completed_buf_reg <= completed_next;
			column_buf_reg <= column_next;
		end if;
	end process;
	
	count_next <= (others => '0') when state_reg /= state_next else
						count_reg + 1;
	
	-- next-state logic
	process(state_reg, count_reg)
	begin
		case state_reg is
		
			when a_video =>
				if count_reg = "01010000000" then
					state_next <= f_porch;
				else
					state_next <= a_video;
				end if;
			when f_porch =>
				if count_reg = "00000010000" then
					state_next <= sync_pulse;
				else
					state_next <= f_porch;
				end if;
			when sync_pulse =>
				if count_reg = "00001100000" then
					state_next <= b_porch;
				else
					state_next <= sync_pulse;
				end if;
			when b_porch =>
				if count_reg = "00000101111" then
					state_next <= completed_state;
				else
					state_next <= b_porch;
				end if;
			when completed_state =>
				if count_reg = "00000110000" then
					state_next <= a_video;
				else
					state_next <= completed_state;
				end if;
			end case;
		end process;
		
		-- look-ahead output logic
		process(state_next)
		begin
			h_sync_next <= '0';
			blank_next <= '0';
			completed_next <= '0';
			column_next <= (others => '0');
			case state_next is
				when a_video =>
					h_sync_next <= '0';
					blank_next <= '0';
					completed_next <= '0';
					column_next <= count_reg;
				when f_porch =>
					h_sync_next <= '0';
					blank_next <= '1';
					completed_next <= '0';
					column_next <= (others => '0');
				when sync_pulse =>
					h_sync_next <= '1';
					blank_next <= '1';
					completed_next <= '0';
					column_next <= (others => '0');
				when b_porch =>
					h_sync_next <= '0';
					blank_next <= '1';
					completed_next <= '0';
					column_next <= (others => '0');
				when completed_state =>
					h_sync_next <= '0';
					blank_next <= '1';
					completed_next <= '1';
					column_next <= (others => '0');
				end case;
			end process;
					
	-- Outputs 				
	h_sync <= h_sync_buf_reg;
	blank <= blank_buf_reg;
	completed <= completed_buf_reg;
	column <= column_buf_reg;

end look_ahead_buffer_arch;

