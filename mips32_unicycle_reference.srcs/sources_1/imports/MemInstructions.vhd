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
--X"20080001",
--X"20090001",
--X"200a0001",
--X"200b0001",
--X"200c0001",
--X"200d0001",
--X"200e0001",
--X"200f0001", 
--X"C9086020", -- addv t0 t0 t4
--X"2002000a",
--X"0000000c",


-- test pour LWV  : va loader les valeur a ladresse de at (reg 1) dans $t0 - $t3 (reg 8 a 11)
--X"20100024",
--X"3c011001",
--X"C0280000",  -- lwv $at $ t0
--X"2002000a",
--X"0000000c",

--test pour sw, va initer $t0 a $t3 a des valeurs aleatoire et save les data a partir de 0x10010000
--X"20100024",
--X"3c011001",
--X"20080001",
--X"20090002",
--X"200a0003",
--X"200b0004",
--X"C4280000", -- sw $t0 ($at)
--X"2002000a",
--X"0000000c",

--test pour ADDVS , ajoute 16 de %t0 a $t3
--X"D1080010",
--X"2002000a",
--X"0000000c",

--test pour MOVNV , initie $t0 a $t3 avec 1,2,3,4 et move $t0 a $t4
--X"20080001",
--X"20090002",
--X"200a0003",
--X"200b0004",
--X"CD0C0000", -- move $t0,$t4 -> ADDVS $t0 , $t4 , 0
--X"3402000a",
--X"0000000c",

--test pour SLTV  initie $t0-$t3 a 1,2,3,4  $t4 - $t7  a 0,3,0,5 
--X"20080001",
--X"20090002",
--X"200a0003",
--X"200b0004",
--X"00006020",
--X"200d0003",
--X"00007020",
--X"200f0005",
--X"D50C802A", -- SLTV $s0 , $t0 , $t4   met s0-$s3 a 1 si $t0 < $t4 ... 
--X"3402000a",
--X"0000000c",

--test pour movnz , initie $t0-$t3 avec 3,4,5,6 , initi $t4-$t7 avec 0101 , movnz $t0 , $t4 $s0
--X"20080003",
--X"20090004",
--X"200a0005",
--X"200b0006",
--X"200c0000",
--X"200d0001",
--X"200e0000",
--X"200f0001",
--X"CD0C8000",
--X"2002000a",
--X"0000000c",

--test pour movzv , initie $t0-$t3 avec 3,4,5,6 , initi $t4-$t7 avec 0101 , movzv $t0 , $t4 $s0
--X"20080003",
--X"20090004",
--X"200a0005",
--X"200b0006",
--X"200c0000",
--X"200d0001",
--X"200e0000",
--X"200f0001",
--X"D90C8000",
--X"2002000a",
--X"0000000c",

--test avec des operations non simd
--X"3c011001",
--X"8c280000",
--X"8c290004",
--X"01095020",
--X"ac2a0000",
--X"0149602a",
--X"11800000",
--X"2002000a",
--X"0000000c",

--test verif , 1 addvs, 1 movzv , 1 swv

--X"3c191001",
--X"20080003",
--X"20090004",
--X"200a0005",
--X"200b0006",
--X"D1080010",  --addvs + 16", 
--X"200c0000",
--X"200d0001",
--X"200e0000",
--X"200f0001",
--X"D90C8000", -- move $s0 , $t0 , $t4
--X"C7280000", -- move $t0 , ($t9)
--X"2002000a",
--X"0000000c",

-- Calcul survivant devoir sans SLTI et ADDIU
--X"3c011001",
--X"34240000",
--X"3c011001",
--X"34250040",
--X"3c011001",
--X"34260050",
--X"0c10001d",
--X"3402000a",
--X"0000000c",
--X"00004820",
--X"200f0004",
--X"012f502a",
--X"1140000f",
--X"00096080",
--X"208a0000",
--X"014c5020",
--X"8d4a0000",
--X"20ab0000",
--X"016c5820",
--X"8d6b0000",
--X"016a4020",
--X"20cd0000",
--X"8dae0000",
--X"010e602a",
--X"11800001",
--X"ada80000",
--X"21290001",
--X"0810000a",
--X"03e00008",
--X"00007820",
--X"23bdffec",
--X"afaf0010",
--X"afbf000c",
--X"afa60008",
--X"afa50004",
--X"afa40000",
--X"8fa40000",
--X"8fa50004",
--X"8fa60008",
--X"8fbf000c",
--X"200e0004",
--X"01ee502a",
--X"1140000b",
--X"200800fa",
--X"000f4880",
--X"000f5100",
--X"008a2020",
--X"00c93020",
--X"acc80000",
--X"0c100009",
--X"8faf0010",
--X"21ef0001",
--X"afaf0010",
--X"08100024",
--X"23bd0014",
--X"03e00008",

--calcul survivant SIMD
X"3c011001",
X"34240000",
X"3c011001",
X"34250040",
X"3c011001",
X"34260050",
X"0c100009",
X"3402000a",
X"0000000c",
X"23bdfffc",
X"afb60000",
X"0000b020",
X"200e0004",
X"02ce502a",
X"11400014",
X"00164100",
X"00164880",
X"00c9c020",
X"00884020",
X"00a04820",
X"c12c0000",
X"c1080000",
X"c90c6020",
X"201900fa",
X"0199402a",
X"cd884000",
X"01a8482a",
X"cda94000",
X"01c8482a",
X"cdc94000",
X"01e8482a",
X"cde94000",
X"af080000",
X"22d60001",
X"0810000c",
X"8fb60000",
X"23bd0004",
X"03e00008",







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

