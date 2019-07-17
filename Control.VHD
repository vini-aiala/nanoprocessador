-- control module
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY control IS
   PORT( Function_Op : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
			Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			Bne		   : OUT STD_LOGIC;
		   Jump        : OUT STD_LOGIC;
			Jal         : OUT STD_LOGIC;
			RegDst 		: OUT STD_LOGIC;
			RegWrite 	: OUT STD_LOGIC;
			ALUSrc		: OUT STD_LOGIC;
			Branch_eq   : OUT STD_LOGIC;
			MemToReg		: OUT STD_LOGIC;
			MemRead		: OUT STD_LOGIC;
			MemWrite		: OUT STD_LOGIC;
			Jr				: OUT STD_LOGIC;
			-- *** Acrescentar a linha abaixo a sua unidade para selecionar as operações
			-- Será mapeado para o execute
			ALUOp 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 ));
END control;

ARCHITECTURE behavior OF control IS

SIGNAL R_format 	: STD_LOGIC;
SIGNAL SW			: STD_LOGIC;
SIGNAL LW			: STD_LOGIC;
SIGNAL Beq			: STD_LOGIC;
SIGNAL Addi       : STD_LOGIC;
SIGNAL Jal_i		: STD_LOGIC;

BEGIN
	-- Code to generate control signals using opcode bits
	R_format 	<=  '1'  WHEN  Opcode = "000000" ELSE '0';
  	SW				<=  '1' 	WHEN  Opcode = "101011" ELSE '0';
	LW				<=  '1' 	WHEN  Opcode = "100011" ELSE '0';
	Beq <= '1' WHEN Opcode = "000100" ELSE '0';
	
	Jal_i <= '1' WHEN Opcode = "000011" ELSE '0';
	
	Jump <= '1'WHEN Opcode = "000010" ELSE '0';
	
	Bne <= '1' WHEN Opcode = "000101" ELSE '0';

	Addi <= '1' WHEN Opcode = "001000" ELSE '0';
	
	Jr <= '1' WHEN R_format = '1' AND Function_Op = "001000" ELSE '0';
	
	Jal <= Jal_i;
	
	RegDst    	<=  R_format;
  	RegWrite 	<=  R_format OR LW OR Jal_i;
	ALUSrc		<=	 LW OR SW OR Addi;
	MemToReg		<=  LW;
	MemRead		<=  LW;
	MemWrite		<=  SW;
	
	Branch_eq <= Beq; 

	-- *** ACRECENTE AS ATRIBUIÇÕES ABAIXO
	ALUOp( 1 ) 	<=  R_format;
	ALUOp( 0 ) 	<=  Beq; -- Beq deve ser 1 quando a instrução for BEQ
	
END behavior;


