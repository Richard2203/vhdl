library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ClockDisplay is
    port (
        CLK : in std_logic;
        RESET : in std_logic;
        SEGMENTS : out std_logic_vector(6 downto 0);
        DIGIT : out std_logic_vector(3 downto 0)
    );
end ClockDisplay;

architecture Behavioral of ClockDisplay is

    -- Constantes
    constant DIVISOR : integer := 50000000; -- Divisor para convertir 50 MHz a 1 Hz

    -- Señales
    signal clk_div : std_logic := '0';
    signal div_count : integer range 0 to DIVISOR-1 := 0;
    signal digit_selector : integer range 0 to 3 := 0;
    signal hours : std_logic_vector(4 downto 0) := "00000"; -- Almacena las horas (0-23)
    signal minutes : std_logic_vector(5 downto 0) := "000000"; -- Almacena los minutos (0-59)
    signal display_value : std_logic_vector(3 downto 0) := "0000";
    signal segments_temp : std_logic_vector(6 downto 0);

    -- Función para convertir un número a segmentos de 7 segmentos
    function bin_to_7seg (bin : std_logic_vector(3 downto 0)) return std_logic_vector is
        variable segs : std_logic_vector(6 downto 0);
    begin
        case bin is
            when "0000" => segs := "1000000"; -- 0
            when "0001" => segs := "1111001"; -- 1
            when "0010" => segs := "0100100"; -- 2
            when "0011" => segs := "0110000"; -- 3
            when "0100" => segs := "0011001"; -- 4
            when "0101" => segs := "0010010"; -- 5
            when "0110" => segs := "0000010"; -- 6
            when "0111" => segs := "1111000"; -- 7
            when "1000" => segs := "0000000"; -- 8
            when "1001" => segs := "0010000"; -- 9
            when others => segs := "1111111"; -- Apagado
        end case;
        return segs;
    end bin_to_7seg;

begin
    -- Proceso de división de frecuencia
    process (CLK)
    begin
        if rising_edge(CLK) then
            if div_count = DIVISOR-1 then
                div_count <= 0;
                clk_div <= not clk_div;
            else
                div_count <= div_count + 1;
            end if;
        end if;
    end process;

    -- Proceso del reloj (incrementar minutos y horas)
    process (clk_div, RESET)
    begin
        if RESET = '1' then
            minutes <= "000000"; -- Reiniciar minutos
            hours <= "00000"; -- Reiniciar horas
        elsif rising_edge(clk_div) then
            if minutes = "111011" then -- 59 minutos
                minutes <= "000000"; -- Reiniciar minutos
                if hours = "10111" then -- 23 horas
                    hours <= "00000"; -- Reiniciar horas
                else
                    hours <= hours + 1; -- Incrementar horas
                end if;
            else
                minutes <= minutes + 1; -- Incrementar minutos
            end if;
        end if;
    end process;

    -- Proceso de multiplexación de displays de 7 segmentos
    process (CLK)
    begin
        if rising_edge(CLK) then
            case digit_selector is
                when 0 =>
                    display_value <= minutes(3 downto 0); -- Minutos unidad
                    DIGIT <= "1110"; -- Activar primer display
                when 1 =>
                    display_value <= minutes(5 downto 4) & "00"; -- Minutos decena
                    DIGIT <= "1101"; -- Activar segundo display
                when 2 =>
                    display_value <= hours(3 downto 0); -- Horas unidad
                    DIGIT <= "1011"; -- Activar tercer display
                when 3 =>
                    display_value <= hours(4) & "000"; -- Horas decena
                    DIGIT <= "0111"; -- Activar cuarto display
                when others =>
                    display_value <= "0000"; -- Desactivar displays
            end case;
            digit_selector <= digit_selector + 1;
        end if;
    end process;

    -- Asignar segmentos de 7 segmentos
    segments_temp <= bin_to_7seg(display_value);
    SEGMENTS <= segments_temp;

end Behavioral;
