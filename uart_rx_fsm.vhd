-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Name Surname (xlogin00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_RX_FSM is
    port(
       CLK              : in    std_logic;
       RST              : in    std_logic;
       DAT              : in    std_logic;
       DATA_FLOW_END    : in    std_logic_vector(3 downto 0);
       CLK_CNT          : in    std_logic_vector(4 downto 0);
       READ_EN          : out   std_logic;
       CLK_CNT_EN       : out   std_logic;
       VALID            : out   std_logic
       );
end entity UART_RX_FSM;

architecture behavioral of UART_RX_FSM is
    type state is (IDLE, WAIT_STATE, RDATA, DATA_VALID);
    signal currState : state := IDLE;
    signal End_Bit : std_logic:= '0';
begin
    -- CLK_CNT_EN <= '0' when currState = DATA_VALID or currState = IDLE else '1';
    -- READ_EN <= '1' when currState = RDATA else '0';
    -- VALID <= '1' when currState = DATA_VALID else '0';
    process(currstate)
    begin
        case currstate is
            when IDLE =>
                CLK_CNT_EN <= '0';
                READ_EN <= '0';
                VALID <= '0';
            when WAIT_STATE =>
                CLK_CNT_EN <= '1';
                READ_EN <= '0';
                VALID <= '0';
            when RDATA =>
                CLK_CNT_EN <= '1';
                READ_EN <= '1';
                VALID <= '0';
                End_Bit <= '1';
            when DATA_VALID =>
                CLK_CNT_EN <= '0';
                READ_EN <= '0';
                VALID <= '1';
                End_Bit <= '0';
        end case;
    end process;
    process (CLK) begin
        if rising_edge(CLK) then
            if RST = '1' then
                currState <= IDLE;
            else 
                case currState is
                    when IDLE =>
                        if DAT = '0' then
                            currState <= WAIT_STATE;
                        end if;
                    when WAIT_STATE =>
                        if End_Bit = '0' and CLK_CNT = "10110" then
                            currState <= RDATA;
                        elsif End_Bit = '1' and CLK_CNT(4) = '1' then
                            currState <= DATA_VALID;
                        end if;
                    when RDATA =>
                        if DATA_FLOW_END(3) = '1' then
                            --End_Bit <= '1';
                            currState <= WAIT_STATE;
                        end if;
                    when DATA_VALID =>
                        --End_Bit <= '0';
                        currState <= IDLE;
                end case;
            end if;
        end if;
    end process;
end behavioral;
