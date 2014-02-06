383_Lab1
========

The task for this lab was to create a simple VGA monitor driver using VHDL.
To demonstrate that this code could drive a monitor, it was designed to display a simple test pattern to the monitor screen.  The primary components required were a horizontal sync component, a vertical sync component, a VGA sync component to connect them, and a pixel generator component. There were then combined in a top-level component.

# Functionality

Captain Branchflower checked off Required functionality 2/4/14

# Implementation

## Block Diagram
![alt text](https://raw.github.com/micfloy/383_Lab1/master/block_diagram.png)

The approach to this lab was to begin with the smallest component and then instantiate it in the next higher-level module.  The `h_sync_gen` module was created first.  It followed a simple moore design, using a look-ahead output buffer to ensure accurate timing.


## State Diagram

![Wow! Such state](https://raw.github.com/micfloy/383_Lab1/master/h_sync_state_diagram.png)

This state diagram was used to create an entity for the `h_sync_gen`

```VHDL
entity h_sync_gen is
    port ( clk       : in  std_logic;
           reset     : in  std_logic;
           h_sync    : out std_logic;
           blank     : out std_logic;
           completed : out std_logic;
           column    : out unsigned(10 downto 0)
     );
end h_sync_gen;
```

The look-ahead output buffer architecture, used for both `h_sync_gen` and `v_sync_gen`, followed the same basic design.

- State Register
- Count Register
  - Followed by the counter logic
- Output Buffer
- Next-state Logic
- Look-ahead Output Logic
- Outputs

This basic design ensured that there was no glitching in the code and that all output assignments would be made at the same time when triggered by the rising edge of the clock.

`v_syng_gen` followed an almost identitcal design with slightly different inputs because it also required information about `h_sync_gen`.  Specifically, it had to know when `h_sync_gen` had completed every column in a row and was ready to move on.  Thus the entity declaration was slgihtly different.

```VHDL
entity v_sync_gen is
    port ( clk         : in  std_logic;
           reset       : in std_logic;
           h_completed : in std_logic;
           v_sync      : out std_logic;
           blank       : out std_logic;
           completed   : out std_logic;
           row         : out unsigned(10 downto 0)
     );
end v_sync_gen;
```

##Important note

All memory was created using this same basic design:

```VHD
process(clk,reset)
begin
	if (reset='1') then
		state_reg <= a_video;
	elsif (rising_edge(clk)) then
		state_reg <= state_next;
	end if;
end process;
```

Keeping all memory in this format and not combining more elements than necessary in each block kept the memory components as seperate and identifiable as possible.

The whole code may be referenced to see specific differences, but the overall architecture was the same as `h_sync_gen`.

`vga_sync` was very straightforward and was simply used to link an instantiation of `h_sync_gen` and `v_sync_gen` in order to implement them in the top-level architecture.  Specifically, it took the `h_completed` output from `h_sync_gen` and ran it to the input of `v_sync_gen`.



`pixel_gen` was quite different from the other components.  It required the `row` and`column` outputs from `vga_sync`.  

```VHD
entity pixel_gen is
    port ( row      : in unsigned(10 downto 0);
           column   : in unsigned(10 downto 0);
           blank    : in std_logic;
			  switch_6  : in std_logic;
			  switch_7  : in std_logic;
           r        : out std_logic_vector(7 downto 0);
           g        : out std_logic_vector(7 downto 0);
           b        : out std_logic_vector(7 downto 0));
end pixel_gen;
```

The switches were added after required functionality was acheived, with the purpose of changing the test pattern for 'A' Functionality.  They did not work to change to the screen, but the first test pattern still worked.

```VHD
begin
	process(switch_6, switch_7)
	begin
		if (blank = '1') then
			r <= (others => '0');
			g <= (others => '0');
			b <= (others => '0');
		else
			if(switch_6 = '0') and (switch_7 = '0') then
				if(column < 150) then
					r <= (others => '1');
				elsif(column >= 150) and (row < 200) then
					g <= (others => '1');
				elsif(column >= 150) and (row > 440) then
					b <= (others => '1');
				elsif(column >= 150) and (row >= 200) and (row <= 440) then
					g <= "10001000";
				end if;
```

Finally, `vga_sync` and `pixel_gen` were implemented in the top-level design, `atlys_lab_video`.  This was also connected to a converter component that was not part of the lab, but was provided, along with the insantiation instructions.

```VHD
entity atlys_lab_video is
    port ( 
             clk   : in  std_logic; -- 100 MHz
             reset : in  std_logic;
				 SW6   : in  std_logic;
				 SW7   : in  std_logic;
             tmds  : out std_logic_vector(3 downto 0);
             tmdsb : out std_logic_vector(3 downto 0)
         );
end atlys_lab_video;


architecture bentley of atlys_lab_video is
    -- TODO: Signals, as needed
	 signal serialize_clk, serialize_clk_n : std_logic;
	 
	 signal pixel_clk, h_sync, v_sync, blank : std_logic;
	 
	 signal red_s, green_s, blue_s, clock_s : std_logic;
	 
	 signal red, green, blue : std_logic_vector(7 downto 0);
	 
	 signal row_sig, col_sig : unsigned(10 downto 0);
begin

    -- Clock divider - creates pixel clock from 100MHz clock
    inst_DCM_pixel: DCM
    generic map(
                   CLKFX_MULTIPLY => 2,
                   CLKFX_DIVIDE   => 8,
                   CLK_FEEDBACK   => "1X"
               )
    port map(
                clkin => clk,
                rst   => reset,
                clkfx => pixel_clk
             );

    -- Clock divider - creates HDMI serial output clock
    inst_DCM_serialize: DCM
    generic map(
                   CLKFX_MULTIPLY => 10, -- 5x speed of pixel clock
                   CLKFX_DIVIDE   => 8,
                   CLK_FEEDBACK   => "1X"
               )
    port map(
                clkin => clk,
                rst   => reset,
                clkfx => serialize_clk,
                clkfx180 => serialize_clk_n
            );

	 vga_inst: entity work.vga_sync(moore)
			port map(
				clk  => pixel_clk,
				reset => reset,
				h_sync => h_sync,
				v_sync => v_sync,
				v_completed => open,
				blank => blank,
				row => row_sig,
				column => col_sig
		   );
	 
	 
	 pixel_inst: entity work.pixel_gen(sel_arch)
			port map(
				row => row_sig, 
				column => col_sig, 
				blank => blank,
				switch_6 => SW6,
				switch_7 => SW7,
				r => red, 
				g => green, 
				b => blue
			);
```
Below this went the code already provided.

# Testing

-`h_sync_gen`
  - Primary problem was the sensitivity lists for my processes.  I debugged as best as I could using the step function in my testbench simulation.  Once I realized that I was not including `count_next` in my sensitivity list for the look-ahead ouptut logic it fixed most of my problems.
  - Syntax errors and mistypings cost me a lot of time and forced me to be meticulous when writing large sections of code at once.
  - Another error I encountered was setting `column_next` to `count_reg` instead of `count_next`.  This was very hard to diagnose until I compared my code with Captain Branchflower's and saw the discrepancy.

- `v_sync_gen`
  - Primary problem was correctly implementing the `h_completed` input into the basic format of my `h_sync_gen` architecture.  Captain Branchflower showed me that it should go in an if statement before my next-state logic case assignments, rather than in an if statement inside of my active_video state.

```VHD
process(state_reg, count_reg, h_completed)
	begin
		state_next <= state_reg;
		
		if h_completed = '1' then
			case state_reg is
				when a_video =>
					if count_reg = (480-1) then
						state_next <= f_porch;
					end if;
				when f_porch =>
					if count_reg = (10-1) then
						state_next <= sync_pulse;
					end if;
				when sync_pulse =>
...
```
- `vga_sync`
  - There were very few problems with `vga_sync`.  The only semi-confusing thing that had to be added was assigning the `blank` output to `h_blank or v_blank`.

- `pixel_gen`
  - The primary problem in `pixel_gen` was an error in the way I assigned `r, g, b`.  I first tried to use a combination of if statements and combinational logic.  This resulted in an error, telling me that VHDL could only do this in the 2008 edition, not the one we were using.  Captain Branchflower suggested that I fix this by instead using nested if statements inside of a process.  This worked perfectly.
- `atlys_lab_video`
  - The first problem I encountered was that I had not created enough signals.  The primary work needed in this component was creating all of the signals to connect `vga_sync` with `pixel_gen` and the dvid converter.
  - After my code synthesized correctly, I tried to run it on the FPGA and it did nothing.  Captain Branchflower helped me troubleshoot a few possibilities, such as changing the optimization from speed to area.  Eventually he figured out that the problem was my `constrains.ucf` file had not saved when I tried to create it.  By adding this the code then functioned properly.

#Conclusions

I thought this lab was mostly straightforward.  It combined everything we have learned up to this point in a major way, without being impossible for my current skill level.  The amount of help Captain Branchflower provided everyone in troubleshooting was definitely key.  Without his help most people would not have been able to finish in time.  I think this will become less of an issue as I get used to the common errors and troubleshooting techniques in VHDL and hopefully next lab will be more straightforward.

I think the most useful thing I learned was how to properly implement a look-ahead output buffer.  This concept was very confusing to me, but I believe I am getting the hang of it.

