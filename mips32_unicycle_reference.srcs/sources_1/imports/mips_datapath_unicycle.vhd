---------------------------------------------------------------------------------------------
--
--	Université de Sherbrooke 
--  Département de génie électrique et génie informatique
--
--	S4i - APP4 
--	
--
--	Auteurs: 		Marc-André Tétrault
--					Daniel Dalle
--					Sébastien Roy
-- 
---------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS32_package.all;


entity mips_datapath_unicycle is
Port ( 
	clk 			: in std_ulogic;
	reset 			: in std_ulogic;

	i_alu_funct   	: in std_ulogic_vector(3 downto 0);
	i_RegWrite    	: in std_ulogic;
	i_RegDst      	: in std_ulogic;
	i_MemtoReg    	: in std_ulogic;
	i_branch      	: in std_ulogic;
	i_ALUSrc      	: in std_ulogic;
	i_MemRead 		: in std_ulogic;
	i_MemWrite	  	: in std_ulogic;

    i_MemWriteWide  : in std_ulogic;

	i_jump   	  	: in std_ulogic;
	i_jump_register : in std_ulogic;
	i_jump_link   	: in std_ulogic;
	i_SignExtend 	: in std_ulogic;
	
	i_simdEnable    : in std_ulogic;
	i_WE_large      : in std_ulogic;
    i_MOVEZERO      : in std_ulogic;
	o_Instruction 	: out std_ulogic_vector (31 downto 0);
	o_PC		 	: out std_ulogic_vector (31 downto 0)
);
end mips_datapath_unicycle;

architecture Behavioral of mips_datapath_unicycle is


component MemInstructions is
    Port ( i_addresse : in std_ulogic_vector (31 downto 0);
           o_instruction : out std_ulogic_vector (31 downto 0));
end component;

--component MemDonnees is
--Port ( 
--	clk : in std_ulogic;
--	reset : in std_ulogic;
--	i_MemRead 	: in std_ulogic;
--	i_MemWrite : in std_ulogic;
--    i_Addresse : in std_ulogic_vector (31 downto 0);
--	i_WriteData : in std_ulogic_vector (31 downto 0);
--    o_ReadData : out std_ulogic_vector (31 downto 0)
--);
--end component;

    component MemDonneesWideDual is
    Port ( 
        clk 		: in std_ulogic;
        reset 		: in std_ulogic;
        i_MemRead	: in std_ulogic;
        i_MemWrite 	: in std_ulogic;
        i_Addresse 	: in std_ulogic_vector (31 downto 0);
        i_WriteData : in std_ulogic_vector (31 downto 0);
        o_ReadData 	: out std_ulogic_vector (31 downto 0);
        
        -- ports pour acc�s � large bus, adresse partag�e
        i_MemReadWide       : in std_ulogic;
        i_MemWriteWide 		: in std_ulogic;
        i_WriteDataWide 	: in std_ulogic_vector (127 downto 0);
        o_ReadDataWide 		: out std_ulogic_vector (127 downto 0)
          );
    end component;

	component BancRegistres is
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
           i_MOVEZERO       : in std_ulogic;
           i_SIMD_enable    : in std_ulogic;
           i_WE_Large       : in std_ulogic;
           o_RS1_DAT1        : out std_ulogic_vector (31 downto 0);
           o_RS1_DAT2        : out std_ulogic_vector (31 downto 0);
           o_RS1_DAT3        : out std_ulogic_vector (31 downto 0);
           o_RS1_DAT4        : out std_ulogic_vector (31 downto 0);
           
           o_RS2_DAT1        : out std_ulogic_vector (31 downto 0);
           o_RS2_DAT2        : out std_ulogic_vector (31 downto 0);
           o_RS2_DAT3        : out std_ulogic_vector (31 downto 0);
           o_RS2_DAT4        : out std_ulogic_vector (31 downto 0));
	end component;

	component alu is
	Port ( 
		i_a			: in std_ulogic_vector (31 downto 0);
		i_b			: in std_ulogic_vector (31 downto 0);
		i_alu_funct	: in std_ulogic_vector (3 downto 0);
		i_shamt		: in std_ulogic_vector (4 downto 0);
		o_result	: out std_ulogic_vector (31 downto 0);
		o_zero		: out std_ulogic
		);
	end component;
   
	constant c_Registre31		 : std_ulogic_vector(4 downto 0) := "11111";
	signal s_zero_alu1        : std_ulogic;
	
    signal s_WriteRegDest_muxout: std_ulogic_vector(4 downto 0);
	
    signal r_PC                    : std_ulogic_vector(31 downto 0);
    signal s_PC_Suivant            : std_ulogic_vector(31 downto 0);
    signal s_adresse_PC_plus_4     : std_ulogic_vector(31 downto 0);
    signal s_adresse_jump          : std_ulogic_vector(31 downto 0);
    signal s_adresse_branche       : std_ulogic_vector(31 downto 0);
    
    signal s_Instruction : std_ulogic_vector(31 downto 0);

    signal s_opcode      : std_ulogic_vector( 5 downto 0);
    signal s_RS          : std_ulogic_vector( 4 downto 0);
    signal s_RT          : std_ulogic_vector( 4 downto 0);
    signal s_RD          : std_ulogic_vector( 4 downto 0);
    signal s_shamt       : std_ulogic_vector( 4 downto 0);
    signal s_instr_funct : std_ulogic_vector( 5 downto 0);
    signal s_imm16       : std_ulogic_vector(15 downto 0);
    signal s_jump_field  : std_ulogic_vector(25 downto 0);
    signal s_reg_data1        : std_ulogic_vector(31 downto 0);
    signal s_reg_data2        : std_ulogic_vector(31 downto 0);
    signal s_AluResult             : std_ulogic_vector(31 downto 0);
    
    signal s_Data2Reg_muxout       : std_ulogic_vector(31 downto 0);
    
    signal s_imm_extended          : std_ulogic_vector(31 downto 0);
    signal s_imm_extended_shifted  : std_ulogic_vector(31 downto 0);
	
    signal s_Reg_Wr_Data           : std_ulogic_vector(31 downto 0);
    signal s_MemoryReadData        : std_ulogic_vector(31 downto 0);
    signal s_AluB_data             : std_ulogic_vector(31 downto 0);
    
    signal s_ReadDataVector        : std_ulogic_vector(127 downto 0);
    signal s_reg_wide_1            : std_ulogic_vector(127 downto 0);
    signal s_reg_wide_2            : std_ulogic_vector(127 downto 0);
    
    -- signaux SIMD
    signal s_Data2Reg2_muxout       : std_ulogic_vector(31 downto 0); -- MUX entre out du read de memoire, des alus et le write_dat de la memoire
    signal s_Data2Reg3_muxout       : std_ulogic_vector(31 downto 0);
    signal s_Data2Reg4_muxout       : std_ulogic_vector(31 downto 0);
    
    
    signal s_AluB_data2       : std_ulogic_vector(31 downto 0); -- MUX  immediate a linput de lalu 
    signal s_AluB_data3       : std_ulogic_vector(31 downto 0);
    signal s_AluB_data4       : std_ulogic_vector(31 downto 0);
    
    
    
    signal s_alutoreg2             : std_ulogic_vector(31 downto 0); --output des alu
    signal s_alutoreg3             : std_ulogic_vector(31 downto 0);
    signal s_alutoreg4             : std_ulogic_vector(31 downto 0);
    
	signal s_reg1toalu2             : std_ulogic_vector(31 downto 0);--entre banc registre et mux / alu
    signal s_reg1toalu3             : std_ulogic_vector(31 downto 0);
    signal s_reg1toalu4             : std_ulogic_vector(31 downto 0);
    
    signal s_reg2toalu2             : std_ulogic_vector(31 downto 0);
    signal s_reg2toalu3             : std_ulogic_vector(31 downto 0);
    signal s_reg2toalu4             : std_ulogic_vector(31 downto 0);
    
    signal s_alutomem               : std_ulogic_vector(127 downto 0);
    signal s_outreg2toMem           : std_ulogic_vector(127 downto 0);
    
    signal s_zero_alu2        : std_ulogic;
    signal s_zero_alu3        : std_ulogic;
    signal s_zero_alu4       : std_ulogic;
    
    
    
begin

o_PC	<= r_PC; -- permet au synthétiseur de sortir de la logique. Sinon, il enlève tout...

------------------------------------------------------------------------
-- simplification des noms de signaux et transformation des types
------------------------------------------------------------------------
s_opcode        <= s_Instruction(31 downto 26);
s_RS            <= s_Instruction(25 downto 21);
s_RT            <= s_Instruction(20 downto 16);
s_RD            <= s_Instruction(15 downto 11);
s_shamt         <= s_Instruction(10 downto  6);
s_instr_funct   <= s_Instruction( 5 downto  0);
s_imm16         <= s_Instruction(15 downto  0);
s_jump_field	<= s_Instruction(25 downto  0);

s_alutomem(127 downto 96) <= s_Alutoreg4;
s_alutomem(95 downto 64) <= s_Alutoreg3;
s_alutomem(63 downto 32) <= s_Alutoreg2;
s_alutomem(31 downto 0) <= s_AluResult;

s_outreg2toMem(127 downto 96) <= s_reg2toalu4; --Le contenu du registre  a l'adresse rt(out banc de registre 2) va vers le write data de la memoire (pour sw)
s_outreg2toMem(95 downto 64) <= s_reg2toalu3;
s_outreg2toMem(63 downto 32) <= s_reg2toalu2;
s_outreg2toMem(31 downto 0) <= s_reg_data2;

------------------------------------------------------------------------


------------------------------------------------------------------------
-- Compteur de programme et mise à jour de valeur
------------------------------------------------------------------------
process(clk)
begin
    if(clk'event and clk = '1') then
        if(reset = '1') then
            r_PC <= X"00400000";
        else
            r_PC <= s_PC_Suivant;
        end if;
    end if;
end process;

s_adresse_PC_plus_4				<= std_ulogic_vector(unsigned(r_PC) + 4);
s_adresse_jump					<= s_adresse_PC_plus_4(31 downto 28) & s_jump_field & "00";
s_imm_extended_shifted			<= s_imm_extended(29 downto 0) & "00";
s_adresse_branche				<= std_ulogic_vector(unsigned(s_imm_extended_shifted) + unsigned(s_adresse_PC_plus_4));

-- note, "i_jump_register" n'est pas dans les figures de COD5
s_PC_Suivant		<= s_adresse_jump when i_jump = '1' else
                       s_reg_data1 when i_jump_register = '1' else
					   s_adresse_branche when (i_branch = '1' and s_zero_alu1 = '1') else
					   s_adresse_PC_plus_4;
					   

------------------------------------------------------------------------
-- Mémoire d'instructions
------------------------------------------------------------------------
inst_MemInstr: MemInstructions
Port map ( 
	i_addresse => r_PC,
    o_instruction => s_Instruction
    );

-- branchement vers le décodeur d'instructions
o_instruction <= s_Instruction;
	
------------------------------------------------------------------------
-- Banc de Registres
------------------------------------------------------------------------
-- Multiplexeur pour le registre en écriture
s_WriteRegDest_muxout <= c_Registre31 when i_jump_link = '1' else 
                         s_rt         when i_RegDst = '0' else 
						 s_rd;
       
inst_Registres: BancRegistres 
port map ( 
	clk          => clk,
	reset        => reset,
	i_RS1        => s_rs,
	i_RS2        => s_rt,
	
	i_SIMD_enable=> i_SIMDenable,
	i_WE_Large   => i_WE_Large,
	
	i_Wr_DAT1    => s_Data2Reg_muxout,
	i_Wr_DAT2    => s_Data2Reg2_muxout,
	i_Wr_DAT3    => s_Data2Reg3_muxout,
	i_Wr_DAT4    => s_Data2Reg4_muxout,
	
	i_WDest      => s_WriteRegDest_muxout,
	i_WE         => i_RegWrite,
	i_MOVEZERO   => i_MOVEZERO,
	o_RS1_DAT1   => s_reg_data1,
	o_RS1_DAT2   => s_reg1toalu2,
	o_RS1_DAT3   => s_reg1toalu3,
	o_RS1_DAT4   => s_reg1toalu4,

	o_RS2_DAT1   => s_reg_data2,
	o_RS2_DAT2   => s_reg2toalu2,
	o_RS2_DAT3   => s_reg2toalu3,
	o_RS2_DAT4   => s_reg2toalu4
	);
	

------------------------------------------------------------------------
-- ALU (instance, extension de signe et mux d'entrée pour les immédiats)
------------------------------------------------------------------------
-- extension de signe
s_imm_extended <= std_ulogic_vector(resize(  signed(s_imm16),32)) when i_SignExtend = '1' else -- extension de signe à 32 bits
				  std_ulogic_vector(resize(unsigned(s_imm16),32)); 

-- Mux pour immédiats 
s_AluB_data <= s_reg_data2 when i_ALUSrc = '0' else s_imm_extended;
s_AluB_data2 <= s_reg2toalu2 when i_ALUSrc = '0' else s_imm_extended;
s_AluB_data3 <= s_reg2toalu3 when i_ALUSrc = '0' else s_imm_extended;
s_AluB_data4 <= s_reg2toalu4 when i_ALUSrc = '0' else s_imm_extended;

inst_Alu: alu 
port map( 
	i_a         => s_reg_data1,
	i_b         => s_AluB_data,
	i_alu_funct => i_alu_funct,
	i_shamt     => s_shamt,
	o_result    => s_AluResult,
	o_zero      => s_zero_alu1
	);

inst_Alu2: alu 
port map( 
	i_a         => s_reg1toalu2,
	i_b         => s_AluB_data2,
	i_alu_funct => i_alu_funct,
	i_shamt     => s_shamt,
	o_result    => s_Alutoreg2,
	o_zero      => s_zero_alu2
	);
	
inst_Alu3: alu 
port map( 
	i_a         => s_reg1toalu3,
	i_b         => s_AluB_data3,
	i_alu_funct => i_alu_funct,
	i_shamt     => s_shamt,
	o_result    => s_Alutoreg3,
	o_zero      => s_zero_alu3
	);
	
inst_Alu4: alu 
port map( 
	i_a         => s_reg1toalu4,
	i_b         => s_AluB_data4,
	i_alu_funct => i_alu_funct,
	i_shamt     => s_shamt,
	o_result    => s_Alutoreg4,
	o_zero      => s_zero_alu4
	);
------------------------------------------------------------------------
-- Mémoire de données
------------------------------------------------------------------------
-- signal pour combiner les sorties des alu
 
inst_MemDonnees : MemDonneesWideDual
Port map( 
	clk 		=> clk,
	reset 		=> reset,
	i_MemRead	=> i_MemRead,
	i_MemWrite	=> i_MemWrite,
    i_Addresse	=> s_AluResult,
	i_WriteData => s_reg_data2,
    o_ReadData	=> s_MemoryReadData,
    
    -- ports pour acc�s � large bus, adresse partag�e
    i_MemReadWide     => i_MemRead,  
    i_MemWriteWide 	  => i_MemWriteWide,	
    i_WriteDataWide   => s_outreg2toMem,	
    o_ReadDataWide 	  => s_ReadDataVector	
    
    
	);
	

------------------------------------------------------------------------
-- Mux d'écriture vers le banc de registres
------------------------------------------------------------------------

--Alu 1 : 
s_Data2Reg_muxout    <= s_adresse_PC_plus_4 when i_jump_link = '1' else
					    s_AluResult         when i_MemtoReg = '0' else 
						s_MemoryReadData;

--Alu 2
s_Data2Reg2_muxout    <= s_Alutoreg2  when i_MemtoReg = '0' else 
                         s_ReadDataVector(63 downto 32);

--Alu3
s_Data2Reg3_muxout    <= s_Alutoreg3  when i_MemtoReg = '0' else 
                         s_ReadDataVector(95 downto 64);

--Alu4    
s_Data2Reg4_muxout    <= s_Alutoreg4  when i_MemtoReg = '0' else 
                         s_ReadDataVector(127 downto 96 );    
 
 --Choix entre la sortie de la RAM ou de l'alu pour ecrire dans les WR_write du registre dependant de MemtoReg
 --MemtoReg =1  lorque  LW ou LWV
        
end Behavioral;
