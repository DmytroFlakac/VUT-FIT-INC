-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Name Surname (xlogin00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
port(	
    CLK: 	    in std_logic;
	RST: 	    in std_logic;
	DIN: 	    in std_logic;
	DOUT: 	    out std_logic_vector(7 downto 0);
    DOUT_VLD: 	out std_logic := '0'
);
end UART_RX;  

-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
    signal rd_en        : std_logic;
    signal clk_cnt_en   : std_logic;
    signal out_vld      : std_logic;
    signal clk_cnt      : std_logic_vector(4 downto 0);
    signal read_counter : std_logic_vector(3 downto 0);
    begin
        FSM: entity work.UART_RX_FSM(behavioral)
        port map(
            CLK             => CLK,
            RST             => RST,
            DAT             => DIN,
            DATA_FLOW_END   => read_counter,
            CLK_CNT         => clk_cnt,
            READ_EN         => rd_en,
            CLK_CNT_EN      => clk_cnt_en,
            VALID           => out_vld
        );
    
        DOUT_VLD <= out_vld;
        process (CLK) begin 
            if rising_edge(CLK) then
                if RST = '1' then
                    clk_cnt <= (others => '0');
                    read_counter <= (others => '0');
                else
                    if clk_cnt_en = '1' then
                        clk_cnt <= clk_cnt + 1;
                    else
                        clk_cnt <= (others => '0');
                    end if;

                    if rd_en = '1' and clk_cnt(4) = '1' then
                        DOUT(conv_integer(read_counter)) <= DIN;
                        read_counter <= read_counter + 1;
                        clk_cnt <= (others => '0');
                    elsif rd_en = '0' then
                        read_counter <= (others => '0');
                    end if;
                end if;
            end if;
        end process;
    end behavioral;