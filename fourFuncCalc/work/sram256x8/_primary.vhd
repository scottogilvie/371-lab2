library verilog;
use verilog.vl_types.all;
entity sram256x8 is
    port(
        data            : inout  vl_logic_vector(7 downto 0);
        add             : in     vl_logic_vector(7 downto 0);
        nCs             : in     vl_logic;
        nOe             : in     vl_logic;
        nWe             : in     vl_logic
    );
end sram256x8;
