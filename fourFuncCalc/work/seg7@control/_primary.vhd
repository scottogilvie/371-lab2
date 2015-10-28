library verilog;
use verilog.vl_types.all;
entity seg7Control is
    port(
        ho0             : out    vl_logic_vector(6 downto 0);
        ho1             : out    vl_logic_vector(6 downto 0);
        ho2             : out    vl_logic_vector(6 downto 0);
        ho3             : out    vl_logic_vector(6 downto 0);
        ho4             : out    vl_logic_vector(6 downto 0);
        ho5             : out    vl_logic_vector(6 downto 0);
        \in\            : in     vl_logic_vector(7 downto 0);
        en              : in     vl_logic_vector(2 downto 0)
    );
end seg7Control;
