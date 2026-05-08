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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

 architecture Behavioral of ALU is
begin

    process(i_A, i_B, i_op)

        variable temp9 : signed(8 downto 0);
        variable temp8 : signed(7 downto 0);

    begin

        case i_op is

            when "000" => -- ADD
                temp9 := resize(signed(i_A),9) + resize(signed(i_B),9);
                temp8 := temp9(7 downto 0);

                o_flags(1) <= temp9(8);

            when "001" => -- SUB
                temp9 := resize(signed(i_A),9) - resize(signed(i_B),9);
                temp8 := temp9(7 downto 0);

                o_flags(1) <= temp9(8);

            when "010" => -- AND
                temp8 := signed(i_A and i_B);

                o_flags(1) <= '0';

            when "011" => -- OR
                temp8 := signed(i_A or i_B);

                o_flags(1) <= '0';

            when others =>
                temp8 := (others => '0');

                o_flags(1) <= '0';

        end case;

        o_result <= std_logic_vector(temp8);

        -- N flag
        o_flags(3) <= temp8(7);

        -- Z flag
        if temp8 = 0 then
            o_flags(2) <= '1';
        else
            o_flags(2) <= '0';
        end if;

        -- V flag
        o_flags(0) <= '0';

    end process;

end Behavioral;