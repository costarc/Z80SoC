-- File generated by hex2romvhdl.sh
-- by Ronivon C. Costa - ronivon.costa@gmail.com
-- Fri Jun 10 10:59:15 BRT 2016
--
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
--Library XilinxCoreLib;

entity rom is
        port(
                Clk        : in std_logic;
                A          : in std_logic_vector(13 downto 0);
                D          : out std_logic_vector(7 downto 0)
        );
end rom;

architecture behaviour of rom is

signal A_sig : std_logic_vector(13 downto 0);

begin

process (Clk)
begin
 if Clk'event and Clk = '1' then
    A_sig <= A;
 end if;
end process;

process (A_sig)
begin
    case to_integer(unsigned(A_sig)) is
             when 00000 => D <= x"3E";
             when 00001 => D <= x"BB";
             when 00002 => D <= x"D3";
             when 00003 => D <= x"01";
             when 00004 => D <= x"31";
             when 00005 => D <= x"00";
             when 00006 => D <= x"70";
             when 00007 => D <= x"3E";
             when 00008 => D <= x"44";
             when 00009 => D <= x"32";
             when 00016 => D <= x"3C";
             when 00017 => D <= x"32";
             when 00018 => D <= x"12";
             when 00019 => D <= x"42";
             when 00020 => D <= x"C3";
             when 00021 => D <= x"8E";
             when 00022 => D <= x"00";
             when 00023 => D <= x"CD";
             when 00024 => D <= x"CE";
             when 00025 => D <= x"00";
             when 00032 => D <= x"38";
             when 00033 => D <= x"01";
             when 00034 => D <= x"CB";
             when 00035 => D <= x"47";
             when 00036 => D <= x"C4";
             when 00037 => D <= x"41";
             when 00038 => D <= x"00";
             when 00039 => D <= x"CD";
             when 00040 => D <= x"38";
             when 00041 => D <= x"01";
             when 00048 => D <= x"38";
             when 00049 => D <= x"01";
             when 00050 => D <= x"CB";
             when 00051 => D <= x"57";
             when 00052 => D <= x"C4";
             when 00053 => D <= x"8E";
             when 00054 => D <= x"00";
             when 00055 => D <= x"CD";
             when 00056 => D <= x"38";
             when 00057 => D <= x"01";
             when 00064 => D <= x"DC";
             when 00065 => D <= x"2A";
             when 00066 => D <= x"DA";
             when 00067 => D <= x"57";
             when 00068 => D <= x"01";
             when 00069 => D <= x"00";
             when 00070 => D <= x"01";
             when 00071 => D <= x"ED";
             when 00072 => D <= x"42";
             when 00073 => D <= x"54";
             when 00080 => D <= x"00";
             when 00081 => D <= x"C9";
             when 00082 => D <= x"CD";
             when 00083 => D <= x"44";
             when 00084 => D <= x"01";
             when 00085 => D <= x"2A";
             when 00086 => D <= x"D4";
             when 00087 => D <= x"57";
             when 00088 => D <= x"CD";
             when 00089 => D <= x"25";
             when 00096 => D <= x"D4";
             when 00097 => D <= x"57";
             when 00098 => D <= x"CD";
             when 00099 => D <= x"91";
             when 00100 => D <= x"00";
             when 00101 => D <= x"C9";
             when 00102 => D <= x"CD";
             when 00103 => D <= x"1B";
             when 00104 => D <= x"01";
             when 00105 => D <= x"CD";
             when 00112 => D <= x"21";
             when 00113 => D <= x"00";
             when 00114 => D <= x"00";
             when 00115 => D <= x"2A";
             when 00116 => D <= x"D4";
             when 00117 => D <= x"57";
             when 00118 => D <= x"CD";
             when 00119 => D <= x"25";
             when 00120 => D <= x"01";
             when 00121 => D <= x"01";
             when 00128 => D <= x"CD";
             when 00129 => D <= x"91";
             when 00130 => D <= x"00";
             when 00131 => D <= x"CD";
             when 00132 => D <= x"1B";
             when 00133 => D <= x"01";
             when 00134 => D <= x"CD";
             when 00135 => D <= x"38";
             when 00136 => D <= x"01";
             when 00137 => D <= x"CB";
             when 00144 => D <= x"57";
             when 00145 => D <= x"54";
             when 00146 => D <= x"5D";
             when 00147 => D <= x"21";
             when 00148 => D <= x"9E";
             when 00149 => D <= x"00";
             when 00150 => D <= x"01";
             when 00151 => D <= x"20";
             when 00152 => D <= x"00";
             when 00153 => D <= x"ED";
             when 00160 => D <= x"20";
             when 00161 => D <= x"20";
             when 00162 => D <= x"20";
             when 00163 => D <= x"7A";
             when 00164 => D <= x"38";
             when 00165 => D <= x"30";
             when 00166 => D <= x"73";
             when 00167 => D <= x"6F";
             when 00168 => D <= x"63";
             when 00169 => D <= x"20";
             when 00176 => D <= x"20";
             when 00177 => D <= x"53";
             when 00178 => D <= x"70";
             when 00179 => D <= x"61";
             when 00180 => D <= x"72";
             when 00181 => D <= x"74";
             when 00182 => D <= x"61";
             when 00183 => D <= x"6E";
             when 00184 => D <= x"2D";
             when 00185 => D <= x"33";
             when 00192 => D <= x"01";
             when 00193 => D <= x"CB";
             when 00194 => D <= x"5F";
             when 00195 => D <= x"28";
             when 00196 => D <= x"04";
             when 00197 => D <= x"AF";
             when 00198 => D <= x"D3";
             when 00199 => D <= x"15";
             when 00200 => D <= x"C9";
             when 00201 => D <= x"3E";
             when 00208 => D <= x"00";
             when 00209 => D <= x"ED";
             when 00210 => D <= x"5B";
             when 00211 => D <= x"D6";
             when 00212 => D <= x"57";
             when 00213 => D <= x"01";
             when 00214 => D <= x"08";
             when 00215 => D <= x"00";
             when 00216 => D <= x"ED";
             when 00217 => D <= x"B0";
             when 00224 => D <= x"01";
             when 00225 => D <= x"09";
             when 00226 => D <= x"77";
             when 00227 => D <= x"18";
             when 00228 => D <= x"FE";
             when 00229 => D <= x"FF";
             when 00230 => D <= x"81";
             when 00231 => D <= x"81";
             when 00232 => D <= x"91";
             when 00233 => D <= x"91";
             when 00240 => D <= x"E5";
             when 00241 => D <= x"21";
             when 00242 => D <= x"00";
             when 00243 => D <= x"00";
             when 00244 => D <= x"CD";
             when 00245 => D <= x"1B";
             when 00246 => D <= x"01";
             when 00247 => D <= x"E1";
             when 00248 => D <= x"46";
             when 00249 => D <= x"3E";
             when 00256 => D <= x"23";
             when 00257 => D <= x"E5";
             when 00258 => D <= x"ED";
             when 00259 => D <= x"52";
             when 00260 => D <= x"E1";
             when 00261 => D <= x"20";
             when 00262 => D <= x"E6";
             when 00263 => D <= x"C9";
             when 00264 => D <= x"21";
             when 00265 => D <= x"77";
             when 00272 => D <= x"10";
             when 00273 => D <= x"C9";
             when 00274 => D <= x"D3";
             when 00275 => D <= x"11";
             when 00276 => D <= x"C9";
             when 00277 => D <= x"D3";
             when 00278 => D <= x"12";
             when 00279 => D <= x"C9";
             when 00280 => D <= x"D3";
             when 00281 => D <= x"13";
             when 00288 => D <= x"0C";
             when 00289 => D <= x"ED";
             when 00290 => D <= x"61";
             when 00291 => D <= x"C1";
             when 00292 => D <= x"C9";
             when 00293 => D <= x"C5";
             when 00294 => D <= x"0E";
             when 00295 => D <= x"12";
             when 00296 => D <= x"ED";
             when 00297 => D <= x"69";
             when 00304 => D <= x"01";
             when 00305 => D <= x"C9";
             when 00306 => D <= x"D3";
             when 00307 => D <= x"02";
             when 00308 => D <= x"C9";
             when 00309 => D <= x"D3";
             when 00310 => D <= x"03";
             when 00311 => D <= x"C9";
             when 00312 => D <= x"DB";
             when 00313 => D <= x"20";
             when 00320 => D <= x"C9";
             when 00321 => D <= x"DB";
             when 00322 => D <= x"80";
             when 00323 => D <= x"C9";
             when 00324 => D <= x"2A";
             when 00325 => D <= x"D4";
             when 00326 => D <= x"57";
             when 00327 => D <= x"01";
             when 00328 => D <= x"BF";
             when 00329 => D <= x"12";
             when 00336 => D <= x"B1";
             when 00337 => D <= x"20";
             when 00338 => D <= x"F7";
             when 00339 => D <= x"C9";
             when others  => D <= "ZZZZZZZZ";
        end case;
end process;
end;
