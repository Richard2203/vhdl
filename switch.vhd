library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Switch_LED_Control_Sync is
    port (
        CLK : in std_logic;  -- Señal de reloj
        RESET : in std_logic;  -- Señal de reinicio
        A : in std_logic;  -- Interruptor A
        B : in std_logic;  -- Interruptor B
        LED1 : out std_logic;  -- LED1
        LED2 : out std_logic   -- LED2
    );
end Switch_LED_Control_Sync;

architecture Behavioral of Switch_LED_Control_Sync is
    signal A_reg, B_reg : std_logic;
    signal clk_div : std_logic := '0';
    signal div_count : integer := 0;

    -- Constantes
    constant DIVISOR : integer := 50000000; -- Divisor para 1 Hz (asumiendo 50 MHz de reloj)
begin
    -- Proceso de división de frecuencia
    process (CLK)
    begin
        if rising_edge(CLK) then
            if div_count = DIVISOR - 1 then
                div_count <= 0;
                clk_div <= not clk_div;
            else
                div_count <= div_count + 1;
            end if;
        end if;
    end process;

    -- Proceso síncrono para registrar las entradas A y B
    process (clk_div, RESET)
    begin
        if RESET = '1' then
            A_reg <= '0';
            B_reg <= '0';
        elsif rising_edge(clk_div) then
            A_reg <= A;
            B_reg <= B;
        end if;
    end process;

    -- Asignar las ecuaciones a los LEDs usando los registros de A y B
    LED1 <= A_reg and (not B_reg);
    LED2 <= (not A_reg) and B_reg;
end Behavioral;
