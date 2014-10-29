--   This file is part of Realtimestagram.
--
--   Realtimestagram is free software: you can redistribute it and/or modify
--   it under the terms of the GNU General Public License as published by
--   the Free Software Foundation, either version 2 of the License, or
--   (at your option) any later version.
--
--   Realtimestagram is distributed in the hope that it will be useful,
--   but WITHOUT ANY WARRANTY; without even the implied warranty of
--   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--   GNU General Public License for more details.
--
--   You should have received a copy of the GNU General Public License
--   along with Realtimestagram.  If not, see <http://www.gnu.org/licenses/>.

--! <!------------------------------------------------------------------------------>
--! <!------------------------------------------------------------------------------>
--! \class rgb2hsv
--! \brief Creates seperate Hue Saturation Value channels from rgb signal
--!
--!
--! <!------------------------------------------------------------------------------>
--! <!------------------------------------------------------------------------------>

--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Used for calculation of h_count and v_count port width
use ieee.math_real.all;

--============================================================================--
--!
--!
--!
--!
--! Hue calculation
--! ---------------
--! Hue is calculated following the function:
--! \f[H =\left\{\begin{matrix} \\
--! 0, & R=G=B\\
--! \frac{(G-B)*60^{\circ}}{max(R,G,B)-min(R,G,B)}\textup{mod}\:360^{\circ}, & R \geq G,B\\
--! \frac{(B-R)*60^{\circ}}{max(R,G,B)-min(R,G,B)}+120^{\circ}, & G \geq R,B\\ 
--! \frac{(R-G)*60^{\circ}}{max(R,G,B)-min(R,G,B)}+240^{\circ} & B \geq R,G  \\
--! \end{matrix}\right.\f]
--! Because this does map correctly on the 8 bits of a byte everythin is normalised to the full range of a byte
--!
entity rgb2hsv is
  generic (
    wordsize:             integer := 8    --! input image wordsize in bits
  );
  port (

    -- inputs
    clk:                  in std_logic;       --! completely clocked process
    rst:                  in std_logic;       --! asynchronous reset
    enable:               in std_logic;       --! enables block
 
    pixel_red_i:          in std_logic_vector((wordsize-1) downto 0); --! red input pixel
    pixel_green_i:        in std_logic_vector((wordsize-1) downto 0); --! green input pixel
    pixel_blue_i:         in std_logic_vector((wordsize-1) downto 0); --! blue input pixel

    -- outputs
    pixel_hue_o:          out std_logic_vector((wordsize-1) downto 0); --! hue value of pixel
    pixel_sat_o:          out std_logic_vector((wordsize-1) downto 0); --! saturation of pixel
    pixel_val_o:          out std_logic_vector((wordsize-1) downto 0)  --! value of pixel
  );


    type mux_select_delay is array(0 to 3) of integer range 0 to 2;
    type max_delay is array(0 to 2) of integer range 0 to 2**wordsize;


end entity;

--============================================================================--

architecture behavioural of rgb2hsv is

    
    -- signal declarations
    signal rgdiff:                 integer range -2**wordsize to 2**wordsize;   
    signal brdiff:                 integer range -2**wordsize to 2**wordsize;      
    signal gbdiff:                 integer range -2**wordsize to 2**wordsize;     

    signal c_rgdiff:               integer range -2**wordsize * 43 to 2**wordsize * 43;
    signal c_brdiff:               integer range -2**wordsize * 43 to 2**wordsize * 43;      
    signal c_gbdiff:               integer range -2**wordsize * 43 to 2**wordsize * 43;     

    signal c_rgdiff_d0:            integer range -2**wordsize * 43 to 2**wordsize * 43;
    signal c_brdiff_d0:            integer range -2**wordsize * 43 to 2**wordsize * 43;      
    signal c_gbdiff_d0:            integer range -2**wordsize * 43 to 2**wordsize * 43;     

    signal c_rgdiff_div_max:       integer range -2**wordsize to 2**wordsize;
    signal c_brdiff_div_max:       integer range -2**wordsize to 2**wordsize;      
    signal c_gbdiff_div_max:       integer range -2**wordsize to 2**wordsize;     

    signal rg_mux_in:              integer range -2**wordsize to 2**wordsize;   
    signal br_mux_in:              integer range -2**wordsize to 2**wordsize;      
    signal gb_mux_in:              integer range -2**wordsize to 2**wordsize;     

    signal mux_select:             mux_select_delay;

    -- comparator
    signal r_versus_g_max:         integer range 0 to 2**wordsize;
    signal r_versus_g_min:         integer range 0 to 2**wordsize;
    signal blue_pix_delay:         integer range 0 to 2**wordsize;

    signal b_versus_max:           integer range 0 to 2**wordsize;
    signal b_versus_min:           integer range 0 to 2**wordsize;

    signal max_min_min:            integer range 0 to 2**wordsize;

    signal range_times_255:        integer range 0 to 2**wordsize * 255;     
    signal range_255_div_by_max:   integer range 0 to 2**wordsize;

    signal comp_max:               max_delay;

begin

    hsv2rgb : process(clk, rst)

        variable red_i_int   : integer range 0 to 2**wordsize := 0;
        variable green_i_int : integer range 0 to 2**wordsize := 0;
        variable blue_i_int  : integer range 0 to 2**wordsize := 0;

        variable mux_out  : std_logic_vector(wordsize-1 downto 0) := (others => '0');
        variable sat_out  : std_logic_vector(wordsize-1 downto 0) := (others => '0');

    begin
        if rst = '1' then

           rgdiff <= 0;
           brdiff <= 0;
           gbdiff <= 0;

           c_rgdiff <= 0;
           c_brdiff <= 0;
           c_gbdiff <= 0;

           c_rgdiff_d0 <= 0;
           c_brdiff_d0 <= 0;
           c_gbdiff_d0 <= 0;

           c_rgdiff_div_max <= 0;
           c_brdiff_div_max <= 0;
           c_gbdiff_div_max <= 0;

           rg_mux_in <= 0;
           br_mux_in <= 0;
           gb_mux_in <= 0;

           mux_select <= (others => 0);

           r_versus_g_max <= 0;
           r_versus_g_min <= 0;
           b_versus_max <= 0;
           b_versus_min <= 0;

           range_times_255 <= 0;
           range_255_div_by_max <= 0;

           comp_max <= (others => 0);

        elsif rising_edge(clk) then

            if enable = '1' then
                
                red_i_int   := to_integer(unsigned(pixel_red_i));
                green_i_int := to_integer(unsigned(pixel_green_i));
                blue_i_int  := to_integer(unsigned(pixel_blue_i));

                -- First stage of comparison
                if red_i_int >= green_i_int then
                    r_versus_g_max <= red_i_int;
                    r_versus_g_min <= green_i_int;
                    mux_select(0) <= 0;
                else
                    r_versus_g_max <= green_i_int;
                    r_versus_g_min <= red_i_int;
                    mux_select(0) <= 1;
                end if;
             
                blue_pix_delay <= blue_i_int;

                -- Second stage of comparison
                if r_versus_g_max < blue_pix_delay then
                    b_versus_max <= blue_pix_delay;
                    mux_select(1) <= 2;
                else
                    b_versus_max <= r_versus_g_max;
                    mux_select(1) <= mux_select(0);
                end if;

                if r_versus_g_min > blue_pix_delay then
                    b_versus_min <= blue_pix_delay;
                else
                    b_versus_min <= r_versus_g_min;
                end if;

                comp_max(0) <= b_versus_max;
                comp_max(1 to 2) <= comp_max(0 to 1);
                max_min_min <= b_versus_max - b_versus_min;

                -- Hue calculation
                rgdiff <= (red_i_int - green_i_int);
                brdiff <= (blue_i_int - red_i_int);
                gbdiff <= (green_i_int - blue_i_int);

                c_rgdiff <= 43 * rgdiff;
                c_brdiff <= 43 * brdiff;
                c_gbdiff <= 43 * gbdiff;

                c_rgdiff_d0 <= c_rgdiff;
                c_brdiff_d0 <= c_brdiff;
                c_gbdiff_d0 <= c_gbdiff;

                if max_min_min /= 0 then
                    c_rgdiff_div_max <= (c_rgdiff_d0 / max_min_min) mod 2**wordsize;
                    c_brdiff_div_max <= (c_brdiff_d0 / max_min_min) mod 2**wordsize;
                    c_gbdiff_div_max <= (c_gbdiff_d0 / max_min_min) mod 2**wordsize;
                else
                    c_rgdiff_div_max <= 0;
                    c_brdiff_div_max <= 0;
                    c_gbdiff_div_max <= 0;
                end if;

                gb_mux_in <=        c_gbdiff_div_max;
                br_mux_in <= ( 85 + c_brdiff_div_max) mod 2**wordsize;
                rg_mux_in <= (171 + c_rgdiff_div_max) mod 2**wordsize;

                -- mux delay
                mux_select(2 to 3) <= mux_select(1 to 2);

                -- mux
                if mux_select(3) = 0 then
                    mux_out := std_logic_vector(to_unsigned(gb_mux_in, wordsize));
                elsif mux_select(3) = 1 then
                    mux_out := std_logic_vector(to_unsigned(br_mux_in, wordsize));
                else
                    mux_out := std_logic_vector(to_unsigned(rg_mux_in, wordsize));
                end if;

                pixel_hue_o <= mux_out(wordsize-1 downto 0);

                -- Saturation calculation
                range_times_255 <= max_min_min * 255;

                if comp_max(1) /= 0 then
                    range_255_div_by_max <= ((range_times_255 / comp_max(1)) mod 2**wordsize);
                else
                    range_255_div_by_max <= 0;
                end if;
                sat_out := std_logic_vector(to_unsigned(range_255_div_by_max, wordsize));
                pixel_sat_o <= sat_out;
 
                -- Value calculation
                pixel_val_o <= std_logic_vector(to_unsigned(comp_max(2), wordsize));

            else
                pixel_hue_o <= (others => '0');
                pixel_sat_o <= (others => '0');
                pixel_val_o <= (others => '0');
            end if; -- end if enable = '1'

        end if; -- end if rst = '1'
    end process;

end architecture;
--============================================================================--
