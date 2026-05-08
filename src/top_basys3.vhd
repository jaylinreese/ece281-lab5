--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 

component controller_fsm
    Port (
        i_reset : in std_logic;
        i_adv   : in STD_LOGIC;
        o_cycle : out STD_LOGIC_VECTOR (3 downto 0)
        );
       end component;
       
       component ALU
         Port (
            i_A  : in std_logic_vector (7 downto 0);
            i_B  : in std_logic_vector (7 downto 0);
            i_op  : in std_logic_vector (2 downto 0);
            o_result  : out std_logic_vector (7 downto 0);
            o_flags  : out std_logic_vector (3 downto 0)
          );
    end component;
    
    component sevenseg_decoder
        Port (
            i_val : in std_logic_vector(3 downto 0);
            o_seg : out std_logic_vector(6 downto 0)
        );
    end component;

    signal cycle       : std_logic_vector(3 downto 0);

    signal regA        : std_logic_vector(7 downto 0) := (others => '0');
    signal regB        : std_logic_vector(7 downto 0) := (others => '0');

    signal alu_out     : std_logic_vector(7 downto 0);
    signal alu_flags   : std_logic_vector(3 downto 0);

    signal display_val : std_logic_vector(3 downto 0);

begin

    -- FSM
    FSM0 : controller_fsm
        port map(
            i_reset => btnU,
            i_adv   => btnC,
            o_cycle => cycle
        );

    -- ALU
    ALU0 : ALU
        port map(
            i_A      => regA,
            i_B      => regB,
            i_op     => sw(2 downto 0),
            o_result => alu_out,
            o_flags  => alu_flags
        );

    -- Seven Segment Decoder
    SSD0 : sevenseg_decoder
        port map(
            i_val => display_val,
            o_seg => seg
        );

    -- Register Loading
    process(btnC, btnU)
    begin

        if btnU = '1' then

            regA <= (others => '0');
            regB <= (others => '0');

        elsif rising_edge(btnC) then

            case cycle is

                when "0010" =>
                    regA <= sw;

                when "0100" =>
                    regB <= sw;

                when others =>
                    null;

            end case;

        end if;

    end process;

    -- Display Logic
    process(cycle, regA, regB, alu_out)
    begin

        case cycle is

            when "0001" =>
                display_val <= "0000";

            when "0010" =>
                display_val <= regA(3 downto 0);

            when "0100" =>
                display_val <= regB(3 downto 0);

            when "1000" =>
                display_val <= alu_out(3 downto 0);

            when others =>
                display_val <= "0000";

        end case;

    end process;

    -- LEDs
    led(3 downto 0) <= cycle;
    led(15 downto 12) <= alu_flags;

    -- Enable rightmost seven segment
    an <= "1110";

end top_basys3_arch;