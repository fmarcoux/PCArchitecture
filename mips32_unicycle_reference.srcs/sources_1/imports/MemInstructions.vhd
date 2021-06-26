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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; -- requis pour la fonction "to_integer"
use work.MIPS32_package.all;

entity MemInstructions is
Port ( 
    i_addresse 		: in std_ulogic_vector (31 downto 0);
    o_instruction 	: out std_ulogic_vector (31 downto 0)
);
end MemInstructions;

architecture Behavioral of MemInstructions is
    signal ram_Instructions : RAM(0 to 255) := (
------------------------
-- Insérez votre code ici
------------------------
--  TestMirroir original
--X"20100024",
--X"3c011001",
--X"00300821",
--X"8c240000",
--X"0004c820",
--X"0c100007",
--X"08100015",
--X"00805020",
--X"00001020",
--X"200cffff",
--X"340b8000",
--X"000b5c00",
--X"20090020",
--X"11200006",
--X"00021042",
--X"014b4024",
--X"00481025",
--X"000a5040",
--X"2129ffff",
--X"0810000d",
--X"03e00008",
--X"00402820",
--X"22100004",
--X"3c011001",
--X"00300821",
--X"ac220000",
--X"2002000a",
--X"0000000c",

--test ADDV -- registre a regarder : 8 a 11 (0x1) et 11 a 15(0x1) (0x1 + 0x1 dans chaque reg) destination t0 = 8 a 11
X"20100024",
X"3c011001",
X"00300821",
X"8c240000",
X"0004c820",
X"20080001",
X"20090001",
X"200a0001",
X"200b0001",
X"200c0001",
X"200d0001",
X"200e0001",
X"200f0001",
X"C9086000", -- ADDV 
X"0810001d",
X"00805020",
X"00001020",
X"200cffff",
X"340b8000",
X"000b5c00",
X"20090020",
X"11200006",
X"00021042",
X"014b4024",
X"00481025",
X"000a5040",
X"2129ffff",
X"08100015",
X"03e00008",
X"2002000a",
X"0000000c",




------------------------
-- Fin de votre code
------------------------
    others => X"00000000"); --> SLL $zero, $zero, 0  

    signal s_MemoryIndex : integer range 0 to 255;

begin
    -- Conserver seulement l'indexage des mots de 32-bit/4 octets
    s_MemoryIndex <= to_integer(unsigned(i_addresse(9 downto 2)));

    -- Si PC vaut moins de 127, présenter l'instruction en mémoire
    o_instruction <= ram_Instructions(s_MemoryIndex) when i_addresse(31 downto 10) = (X"00400" & "00")
                    -- Sinon, retourner l'instruction nop X"00000000": --> AND $zero, $zero, $zero  
                    else (others => '0');

end Behavioral;

