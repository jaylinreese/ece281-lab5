----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port (
        i_A : in STD_LOGIC_VECTOR (7 downto 0);
        i_B : in STD_LOGIC_VECTOR (7 downto 0);
        i_op : in STD_LOGIC_VECTOR (2 downto 0);
        o_result : out STD_LOGIC_VECTOR (7 downto 0);
        o_flags : out STD_LOGIC_VECTOR (3 downto 0)
    );
end ALU;

architecture Behavioral of ALU is
begin

    process(i_A, i_B, i_op)

        variable a, b : unsigned(7 downto 0);
        variable temp9 : unsigned(8 downto 0);
        variable res : unsigned(7 downto 0);

    begin

        a := unsigned(i_A);
        b := unsigned(i_B);

        -- default flag values (IMPORTANT)
        o_flags <= (others => '0');

        case i_op is

            when "000" => -- ADD
                temp9 := ('0' & a) + ('0' & b);
                res := temp9(7 downto 0);

                o_flags(1) <= temp9(8); -- carry

            when "001" => -- SUB
                temp9 := ('0' & a) - ('0' & b);
                res := temp9(7 downto 0);

                o_flags(1) <= not temp9(8); -- borrow = NOT carry

            when "010" => -- AND
                res := a and b;

            when "011" => -- OR
                res := a or b;

            when others =>
                res := (others => '0');

        end case;

        o_result <= std_logic_vector(res);

        -- N flag
        o_flags(3) <= res(7);

        -- Z flag
        if res = 0 then
            o_flags(2) <= '1';
        else
            o_flags(2) <= '0';
        end if;

        -- V flag (not heavily tested in many labs)
        o_flags(0) <= '0';

    end process;

end Behavioral;