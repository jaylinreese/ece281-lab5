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

        clk     : in std_logic;
        sw      : in std_logic_vector(7 downto 0);

        btnU    : in std_logic;
        btnC    : in std_logic;
        btnL    : in std_logic;

        led     : out std_logic_vector(15 downto 0);

        seg     : out std_logic_vector(6 downto 0);

        an      : out std_logic_vector(3 downto 0)

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
        i_A : in STD_LOGIC_VECTOR (7 downto 0);
        i_B : in STD_LOGIC_VECTOR (7 downto 0);
        i_op : in STD_LOGIC_VECTOR (2 downto 0);
        o_result : out STD_LOGIC_VECTOR (7 downto 0);
        o_flags : out STD_LOGIC_VECTOR (3 downto 0)
    );
end component;

component sevenseg_decoder
    Port (
        i_Hex   : in std_logic_vector(3 downto 0);
        o_seg_n : out std_logic_vector(6 downto 0)
    );
end component;

component twos_comp
    port (
        i_bin  : in std_logic_vector(7 downto 0);
        o_sign : out std_logic;
        o_hund : out std_logic_vector(3 downto 0);
        o_tens : out std_logic_vector(3 downto 0);
        o_ones : out std_logic_vector(3 downto 0)
    );
end component;

component TDM4
generic (
    constant k_WIDTH : natural := 7
);
port (
    i_clk   : in std_logic;
    i_reset : in std_logic;

    i_D3 : in std_logic_vector(6 downto 0);
    i_D2 : in std_logic_vector(6 downto 0);
    i_D1 : in std_logic_vector(6 downto 0);
    i_D0 : in std_logic_vector(6 downto 0);

    o_data : out std_logic_vector(6 downto 0);
    o_sel  : out std_logic_vector(3 downto 0)
);
end component;

component clock_divider
generic (
    constant k_DIV : natural := 100000
);
port (
    i_clk   : in std_logic;
    i_reset : in std_logic;
    o_clk   : out std_logic
);
end component;

signal cycle : std_logic_vector(3 downto 0);

signal regA : std_logic_vector(7 downto 0) := (others => '0');
signal regB : std_logic_vector(7 downto 0) := (others => '0');

signal alu_out : std_logic_vector(7 downto 0);
signal alu_flags : std_logic_vector(3 downto 0);

signal display_byte : std_logic_vector(7 downto 0);

signal sign : std_logic;

signal hund : std_logic_vector(3 downto 0);
signal tens : std_logic_vector(3 downto 0);
signal ones : std_logic_vector(3 downto 0);

signal seg0 : std_logic_vector(6 downto 0);
signal seg1 : std_logic_vector(6 downto 0);
signal seg2 : std_logic_vector(6 downto 0);
signal seg3 : std_logic_vector(6 downto 0);

signal slow_clk : std_logic;

begin

FSM0 : controller_fsm
port map(
    i_reset => btnU,
    i_adv   => btnC,
    o_cycle => cycle
);

ALU0 : ALU
port map(
    i_A      => regA,
    i_B      => regB,
    i_op     => sw(2 downto 0),
    o_result => alu_out,
    o_flags  => alu_flags
);

CLKDIV0 : clock_divider
generic map(
    k_DIV => 100000
)
port map(
    i_clk   => clk,
    i_reset => btnL,
    o_clk   => slow_clk
);

TC0 : twos_comp
port map(
    i_bin  => display_byte,
    o_sign => sign,
    o_hund => hund,
    o_tens => tens,
    o_ones => ones
);

SSD0 : sevenseg_decoder
port map(
    i_Hex   => ones,
    o_seg_n => seg0
);

SSD1 : sevenseg_decoder
port map(
    i_Hex   => tens,
    o_seg_n => seg1
);

SSD2 : sevenseg_decoder
port map(
    i_Hex   => hund,
    o_seg_n => seg2
);

seg3 <= "0111111" when sign = '1' else "1111111";

TDM0 : TDM4
generic map(
    k_WIDTH => 7
)
port map(
    i_clk   => slow_clk,
    i_reset => btnL,

    i_D3 => seg3,
    i_D2 => seg2,
    i_D1 => seg1,
    i_D0 => seg0,

    o_data => seg,
    o_sel  => an
);

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

process(cycle, regA, regB, alu_out)
begin

    case cycle is

        when "0001" =>
            display_byte <= (others => '0');

        when "0010" =>
            display_byte <= regA;

        when "0100" =>
            display_byte <= regB;

        when "1000" =>
            display_byte <= alu_out;

        when others =>
            display_byte <= (others => '0');

    end case;

end process;

led(3 downto 0) <= cycle;

led(15 downto 12) <= alu_flags;

end top_basys3_arch;