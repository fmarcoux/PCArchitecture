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

entity MemDonneesWideDual is
Port ( 
	clk 		: in std_ulogic;
	reset 		: in std_ulogic;
	i_MemRead	: in std_ulogic;
	i_MemWrite 	: in std_ulogic;
    i_Addresse 	: in std_ulogic_vector (31 downto 0);
	i_WriteData : in std_ulogic_vector (31 downto 0);
    o_ReadData 	: out std_ulogic_vector (31 downto 0);
	
	-- ports pour accès à large bus, adresse partagée
	i_MemReadWide       : in std_ulogic;
	i_MemWriteWide 		: in std_ulogic;
	i_WriteDataWide 	: in std_ulogic_vector (127 downto 0);
    o_ReadDataWide 		: out std_ulogic_vector (127 downto 0)
);
end MemDonneesWideDual;

architecture Behavioral of MemDonneesWideDual is
    signal ram_DataMemory : RAM(0 to 255) := ( -- type défini dans le package
------------------------
-- Insérez vos donnees ici
------------------------

--donnes test mirroir
--X"12345678",
--X"87654321",
--X"bad0face",
--X"00000001",
--X"00000002",
--X"00000003",
--X"00000004",
--X"00000005",
--X"00000006",
--X"5555cccc",



--donnes calcul des survivants
X"00000003", 
X"00000002", 
X"00000004", 
X"00000003", 
X"00000005", 
X"00000004", 
X"00000000", 
X"00000003", 
X"00000003", 
X"00000002", 
X"00000004", 
X"00000003", 
X"00000003", 
X"00000002", 
X"00000002", 
X"00000005",  -- fin met
X"00000002",
X"00000004",
X"00000000",
X"00000004", -- fin sinput
 -- soutput est a 0 


------------------------
-- Fin de votre code
------------------------
    others => X"00000000");

    signal s_MemoryIndex 	: integer range 0 to 255; -- 0-127
	signal s_MemoryRangeValid 	: std_ulogic;
	
    signal s_WideMemoryRangeValid  : std_ulogic;

begin
    -- Transformation de l'adresse en entier à interval fixés
    s_MemoryIndex 	<= to_integer(unsigned(i_Addresse(9 downto 2)));
	s_MemoryRangeValid <= '1' when i_Addresse(31 downto 10) = (X"10010" & "00") else '0'; 


	s_WideMemoryRangeValid <= '1' when (i_Addresse(31 downto 10) = (X"10010" & "00") and i_Addresse(3 downto 2) = "00") else '0'; 
	
	-- message de simulation
	assert (i_MemWriteWide = '1' and  i_Addresse(4 downto 0) = "00000") report "mauvais alignement de l'adresse pour une ecriture large" severity warning;
	
	
	-- Partie pour l'écriture
	process( clk )
    begin
        if clk='1' and clk'event then
            if i_MemWriteWide = '1' and reset = '0' and s_WideMemoryRangeValid = '1' then
				ram_DataMemory(s_MemoryIndex + 3) <= i_WriteDataWide(127 downto 96);
				ram_DataMemory(s_MemoryIndex + 2) <= i_WriteDataWide( 95 downto 64);
				ram_DataMemory(s_MemoryIndex + 1) <= i_WriteDataWide( 63 downto 32);
				ram_DataMemory(s_MemoryIndex + 0) <= i_WriteDataWide( 31 downto  0);
            elsif i_MemWrite = '1' and reset = '0' and s_MemoryRangeValid = '1' then
                ram_DataMemory(s_MemoryIndex) <= i_WriteData;
            end if;
        end if;
    end process;

    -- Valider que nous sommes dans le segment de mémoire, avec 256 addresses valides
    o_ReadData <= ram_DataMemory(s_MemoryIndex) when s_MemoryRangeValid = '1'
                    else (others => '0');
	
	-- valider le segment et l'alignement de l'adresse
	o_ReadDataWide <= ram_DataMemory(s_MemoryIndex + 3) & 
					  ram_DataMemory(s_MemoryIndex + 2) & 
					  ram_DataMemory(s_MemoryIndex + 1) & 
					  ram_DataMemory(s_MemoryIndex + 0)   when s_WideMemoryRangeValid = '1'
					else (others => '0');

end Behavioral;
