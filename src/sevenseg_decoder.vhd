----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/08/2026 05:34:41 PM
-- Design Name: 
-- Module Name: sevenseg_decoder - Behavioral
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

entity sevenseg_decoder is
    Port (
        i_Hex   : in STD_LOGIC_VECTOR (3 downto 0);
        o_seg_n : out STD_LOGIC_VECTOR (6 downto 0)
    );
end sevenseg_decoder;

architecture Behavioral of sevenseg_decoder is
begin

    process(i_Hex)
    begin

        case i_Hex is

            when "0000" => o_seg_n <= "1000000";
            when "0001" => o_seg_n <= "1111001";
            when "0010" => o_seg_n <= "0100100";
            when "0011" => o_seg_n <= "0110000";
            when "0100" => o_seg_n <= "0011001";
            when "0101" => o_seg_n <= "0010010";
            when "0110" => o_seg_n <= "0000010";
            when "0111" => o_seg_n <= "1111000";
            when "1000" => o_seg_n <= "0000000";
            when "1001" => o_seg_n <= "0010000";

            when others => o_seg_n <= "1111111";

        end case;

    end process;

end Behavioral;