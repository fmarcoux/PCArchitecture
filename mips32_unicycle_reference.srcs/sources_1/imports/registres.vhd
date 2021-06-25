---------------------------------------------------------------------------------------------
--
--	Université de Sherbrooke 
--  Département de génie électrique et génie informatique
--
--	S4i - APP4 
--	
--
--	Auteur: 		Marc-André Tétrault
--					Daniel Dalle
--					Sébastien Roy
-- 
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS32_package.all;

entity BancRegistres is
    Port ( clk              : in  std_ulogic;
           reset            : in  std_ulogic;
           i_RS1            : in  std_ulogic_vector (4 downto 0);
           i_RS2            : in  std_ulogic_vector (4 downto 0);
           
           i_Wr_DAT1         : in  std_ulogic_vector (31 downto 0);
           i_Wr_DAT2         : in  std_ulogic_vector (31 downto 0);
           i_Wr_DAT3         : in  std_ulogic_vector (31 downto 0);
           i_Wr_DAT4         : in  std_ulogic_vector (31 downto 0);
           
           i_WDest          : in  std_ulogic_vector (4 downto 0);
           i_WE 	        : in  std_ulogic;
           
           i_SIMD_enable    : in std_ulogic;
           
           o_RS1_DAT1        : out std_ulogic_vector (31 downto 0);
           o_RS1_DAT2        : out std_ulogic_vector (31 downto 0);
           o_RS1_DAT3        : out std_ulogic_vector (31 downto 0);
           o_RS1_DAT4        : out std_ulogic_vector (31 downto 0);
           
           o_RS2_DAT1        : out std_ulogic_vector (31 downto 0);
           o_RS2_DAT2        : out std_ulogic_vector (31 downto 0);
           o_RS2_DAT3        : out std_ulogic_vector (31 downto 0);
           o_RS2_DAT4        : out std_ulogic_vector (31 downto 0));
end BancRegistres;

architecture comport of BancRegistres is
    signal regs: RAM(0 to 31) := (29 => X"100103F0", -- registre $SP
                                others => (others => '0'));
begin
    process( clk )
    begin
        if clk='1' and clk'event then
            if i_WE = '1' and reset = '0' and i_WDest /= "00000" then
                regs( to_integer( unsigned(i_WDest))) <= i_Wr_DAT1;
                if i_SIMD_enable = '1' then
                    regs( to_integer( unsigned(i_WDest)+1)) <= i_Wr_DAT2;
                    regs( to_integer( unsigned(i_WDest)+2)) <= i_Wr_DAT3;
                    regs( to_integer( unsigned(i_WDest)+3)) <= i_Wr_DAT4;
                end if;
            end if;
        end if;
    end process;
    
    o_RS1_DAT1 <= regs( to_integer(unsigned(i_RS1)));
    o_RS1_DAT2 <= regs( to_integer(unsigned(i_RS1)+1));
    o_RS1_DAT3 <= regs( to_integer(unsigned(i_RS1)+2));
    o_RS1_DAT4 <= regs( to_integer(unsigned(i_RS1)+3));
    o_RS2_DAT1 <= regs( to_integer(unsigned(i_RS2)));
    o_RS2_DAT2 <= regs( to_integer(unsigned(i_RS2)+1));
    o_RS2_DAT3 <= regs( to_integer(unsigned(i_RS2)+2));
    o_RS2_DAT4 <= regs( to_integer(unsigned(i_RS2)+3));
    
end comport;

