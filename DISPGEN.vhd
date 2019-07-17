LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY DISPGEN IS
	PORT (Instruction: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			PC			  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			SW1		  : IN STD_LOGIC;
			SW2		  : IN STD_LOGIC;
			Linha1     : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			Linha2	  : OUT STD_LOGIC_VECTOR(127 DOWNTO 0));
END DISPGEN;		
			
ARCHITECTURE gen OF DISPGEN IS
SIGNAL Opcode   		 : STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL RS		 		 : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL RT		 		 : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL RD		 		 : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL J_valor 		 : STD_LOGIC_VECTOR(25 DOWNTO 0);
SIGNAL I_valor 		 : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL Funct			 : STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL Ctrl				 : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL MIPS				 : STD_LOGIC_VECTOR(255 DOWNTO 0);
SIGNAL J_flag	 		 : STD_LOGIC;
SIGNAL Rcom_flag	    : STD_LOGIC;
SIGNAL Rshift_flag	 : STD_LOGIC;
SIGNAL Rjr_flag	    : STD_LOGIC;
SIGNAL D_cmd			 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL D_RS     		 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL D_RT  		    : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL D_RD     		 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL Instr_id		 : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL Shamt 			 : STD_LOGIC_VECTOR(4 DOWNTO 0);

BEGIN
	Ctrl <= SW1 & SW2;
	
	Rjr_flag <=  '1' WHEN Opcode = "000000" AND Funct = "001000" ELSE '0';
	Rshift_flag <=  '1' WHEN Opcode = "000000" AND (Funct = "000000" OR Funct = "000010") ELSE '0';
	Rcom_flag <= '1' WHEN Opcode = "000000" AND NOT(Funct = "000000" OR Funct = "000010" OR Funct = "001000") ELSE '0';
	J_flag <= '1' WHEN Opcode = "000010" OR Opcode = "000011" ELSE '0';
	
	--J, R e I
	Opcode  <= Instruction(31 DOWNTO 26);
	--R e I
	RS		  <= Instruction(25 DOWNTO 21);
	RT		  <= Instruction(20 DOWNTO 16);
	--R
	RD		  <= Instruction(15 DOWNTO 11);
	Funct   <= Instruction(5 DOWNTO 0);
	Shamt   <= Instruction(10 DOWNTO 6);
	--I 
	I_valor <= Instruction(15 DOWNTO 0);
	--J
	J_valor <= Instruction(25 DOWNTO 0);
	
	D_cmd <= X"20" & X"20" & X"20" & X"6A" WHEN Opcode = "000010" ELSE --j/
				X"20" & X"6A" & X"61" & X"6C" WHEN Opcode = "000011" ELSE --jal/
				X"20" & X"61" & X"6E" & X"64" WHEN Opcode = "000000" AND Funct = "100100" ELSE --and/
				X"20" & X"20" & X"6F" & X"72" WHEN Opcode = "000000" AND Funct = "100101" ELSE --or/
				X"20" & X"61" & X"64" & X"64" WHEN Opcode = "000000" AND Funct = "100000" ELSE --add/
				X"20" & X"20" & X"6A" & X"72" WHEN Opcode = "000000" AND Funct = "001000" ELSE --jr/
				X"20" & X"73" & X"6C" & X"6C" WHEN Opcode = "000000" AND Funct = "000000" ELSE --sll/
				X"20" & X"73" & X"72" & X"6C" WHEN Opcode = "000000" AND Funct = "000010" ELSE --srl/
				X"20" & X"73" & X"75" & X"62" WHEN Opcode = "000000" AND Funct = "100010" ELSE --sub/
				X"20" & X"73" & X"6C" & X"74" WHEN Opcode = "000000" AND Funct = "101010" ELSE --slt/
				X"61" & X"64" & X"64" & X"69" WHEN Opcode = "001000" ELSE --addi/
				X"20" & X"62" & X"6E" & X"65" WHEN Opcode = "000101" ELSE --bne/
				X"20" & X"62" & X"65" & X"71" WHEN Opcode = "000100" ELSE --beq/
				X"20" & X"20" & X"6C" & X"77" WHEN Opcode = "100011" ELSE --lw/
				X"20" & X"20" & X"73" & X"77" WHEN Opcode = "101011" ELSE --sw/
				X"20" & X"20" & X"20" & X"20";

	WITH RS SELECT
	D_RS <=  X"7A" & X"65" & X"72" & X"6F" WHEN "00000", --zero
				X"61" & X"74" & X"20" & X"20" WHEN "00001", --at
				X"76" & X"00" & X"20" & X"20" WHEN "00010", --v0
				X"76" & X"01" & X"20" & X"20" WHEN "00011", --v1
				X"61" & X"00" & X"20" & X"20" WHEN "00100", --a0
				X"61" & X"01" & X"20" & X"20" WHEN "00101", --a1
				X"61" & X"02" & X"20" & X"20" WHEN "00110", --a2
				X"61" & X"03" & X"20" & X"20" WHEN "00111", --a3
				X"74" & X"00" & X"20" & X"20" WHEN "01000", --t0
				X"74" & X"01" & X"20" & X"20" WHEN "01001", --t1
				X"74" & X"02" & X"20" & X"20" WHEN "01010", --t2
				X"74" & X"03" & X"20" & X"20" WHEN "01011", --t3
				X"74" & X"04" & X"20" & X"20" WHEN "01100", --t4
				X"74" & X"05" & X"20" & X"20" WHEN "01101", --t5
				X"74" & X"06" & X"20" & X"20" WHEN "01110", --t6
				X"74" & X"07" & X"20" & X"20" WHEN "01111", --t7
				X"73" & X"00" & X"20" & X"20" WHEN "10000", --s0
				X"73" & X"01" & X"20" & X"20" WHEN "10001", --s1
				X"73" & X"02" & X"20" & X"20" WHEN "10010", --s2
				X"73" & X"03" & X"20" & X"20" WHEN "10011", --s3
				X"73" & X"04" & X"20" & X"20" WHEN "10100", --s4
				X"73" & X"05" & X"20" & X"20" WHEN "10101", --s5
				X"73" & X"06" & X"20" & X"20" WHEN "10110", --s6
				X"73" & X"07" & X"20" & X"20" WHEN "10111", --s7
				X"74" & X"08" & X"20" & X"20" WHEN "11000", --t8
				X"74" & X"09" & X"20" & X"20" WHEN "11001", --t9
				X"6B" & X"00" & X"20" & X"20" WHEN "11010", --k0
				X"6B" & X"01" & X"20" & X"20" WHEN "11011", --k1
				X"67" & X"70" & X"20" & X"20" WHEN "11100", --gp
				X"61" & X"70" & X"20" & X"20" WHEN "11101", --ap
				X"66" & X"70" & X"20" & X"20" WHEN "11110", --fp
				X"72" & X"61" & X"20" & X"20" WHEN "11111", --ra
				X"20" & X"20" & X"20" & X"20" WHEN OTHERS;
	
	WITH RT SELECT
	D_RT <=  X"7A" & X"65" & X"72" & X"6F" WHEN "00000", --zero
				X"61" & X"74" & X"20" & X"20" WHEN "00001", --at
				X"76" & X"00" & X"20" & X"20" WHEN "00010", --v0
				X"76" & X"01" & X"20" & X"20" WHEN "00011", --v1
				X"61" & X"00" & X"20" & X"20" WHEN "00100", --a0
				X"61" & X"01" & X"20" & X"20" WHEN "00101", --a1
				X"61" & X"02" & X"20" & X"20" WHEN "00110", --a2
				X"61" & X"03" & X"20" & X"20" WHEN "00111", --a3
				X"74" & X"00" & X"20" & X"20" WHEN "01000", --t0
				X"74" & X"01" & X"20" & X"20" WHEN "01001", --t1
				X"74" & X"02" & X"20" & X"20" WHEN "01010", --t2
				X"74" & X"03" & X"20" & X"20" WHEN "01011", --t3
				X"74" & X"04" & X"20" & X"20" WHEN "01100", --t4
				X"74" & X"05" & X"20" & X"20" WHEN "01101", --t5
				X"74" & X"06" & X"20" & X"20" WHEN "01110", --t6
				X"74" & X"07" & X"20" & X"20" WHEN "01111", --t7
				X"73" & X"00" & X"20" & X"20" WHEN "10000", --s0
				X"73" & X"01" & X"20" & X"20" WHEN "10001", --s1
				X"73" & X"02" & X"20" & X"20" WHEN "10010", --s2
				X"73" & X"03" & X"20" & X"20" WHEN "10011", --s3
				X"73" & X"04" & X"20" & X"20" WHEN "10100", --s4
				X"73" & X"05" & X"20" & X"20" WHEN "10101", --s5
				X"73" & X"06" & X"20" & X"20" WHEN "10110", --s6
				X"73" & X"07" & X"20" & X"20" WHEN "10111", --s7
				X"74" & X"08" & X"20" & X"20" WHEN "11000", --t8
				X"74" & X"09" & X"20" & X"20" WHEN "11001", --t9
				X"6B" & X"00" & X"20" & X"20" WHEN "11010", --k0
				X"6B" & X"01" & X"20" & X"20" WHEN "11011", --k1
				X"67" & X"70" & X"20" & X"20" WHEN "11100", --gp
				X"61" & X"70" & X"20" & X"20" WHEN "11101", --ap
				X"66" & X"70" & X"20" & X"20" WHEN "11110", --fp
				X"72" & X"61" & X"20" & X"20" WHEN "11111", --ra
				X"20" & X"20" & X"20" & X"20" WHEN OTHERS;
				
	WITH RD SELECT
	D_RD <=  X"7A" & X"65" & X"72" & X"6F" WHEN "00000", --zero
				X"61" & X"74" & X"20" & X"20" WHEN "00001", --at
				X"76" & X"00" & X"20" & X"20" WHEN "00010", --v0
				X"76" & X"01" & X"20" & X"20" WHEN "00011", --v1
				X"61" & X"00" & X"20" & X"20" WHEN "00100", --a0
				X"61" & X"01" & X"20" & X"20" WHEN "00101", --a1
				X"61" & X"02" & X"20" & X"20" WHEN "00110", --a2
				X"61" & X"03" & X"20" & X"20" WHEN "00111", --a3
				X"74" & X"00" & X"20" & X"20" WHEN "01000", --t0
				X"74" & X"01" & X"20" & X"20" WHEN "01001", --t1
				X"74" & X"02" & X"20" & X"20" WHEN "01010", --t2
				X"74" & X"03" & X"20" & X"20" WHEN "01011", --t3
				X"74" & X"04" & X"20" & X"20" WHEN "01100", --t4
				X"74" & X"05" & X"20" & X"20" WHEN "01101", --t5
				X"74" & X"06" & X"20" & X"20" WHEN "01110", --t6
				X"74" & X"07" & X"20" & X"20" WHEN "01111", --t7
				X"73" & X"00" & X"20" & X"20" WHEN "10000", --s0
				X"73" & X"01" & X"20" & X"20" WHEN "10001", --s1
				X"73" & X"02" & X"20" & X"20" WHEN "10010", --s2
				X"73" & X"03" & X"20" & X"20" WHEN "10011", --s3
				X"73" & X"04" & X"20" & X"20" WHEN "10100", --s4
				X"73" & X"05" & X"20" & X"20" WHEN "10101", --s5
				X"73" & X"06" & X"20" & X"20" WHEN "10110", --s6
				X"73" & X"07" & X"20" & X"20" WHEN "10111", --s7
				X"74" & X"08" & X"20" & X"20" WHEN "11000", --t8
				X"74" & X"09" & X"20" & X"20" WHEN "11001", --t9
				X"6B" & X"00" & X"20" & X"20" WHEN "11010", --k0
				X"6B" & X"01" & X"20" & X"20" WHEN "11011", --k1
				X"67" & X"70" & X"20" & X"20" WHEN "11100", --gp
				X"61" & X"70" & X"20" & X"20" WHEN "11101", --ap
				X"66" & X"70" & X"20" & X"20" WHEN "11110", --fp
				X"72" & X"61" & X"20" & X"20" WHEN "11111", --ra
				X"20" & X"20" & X"20" & X"20" WHEN OTHERS;
				
	--Criacao da linha
	Instr_id <= Rjr_flag & Rshift_flag & Rcom_flag & J_flag;
	WITH Instr_id SELECT
	MIPS <= D_cmd & X"20" & X"24" & D_rT & X"2C" & X"20" & X"20" & X"20" & X"20" & X"20" & X"24" & D_rs & X"2C" & X"20" & X"0" & I_valor(15 DOWNTO 12) & X"0" & I_valor(11 DOWNTO 8) & X"0" & I_valor(7 DOWNTO 4) & X"0" & I_valor(3 DOWNTO 0) & X"20" & X"20" & X"20" & X"20" & X"20" WHEN "0000",
			  D_cmd & X"20" & X"0" & "00" & J_Valor (25 DOWNTO 24) & X"0"  & J_Valor (23 DOWNTO 20) & X"0"  & J_Valor (19 DOWNTO 16) & X"0"  & J_Valor (15 DOWNTO 12) & X"0"  & J_Valor (11 DOWNTO 8) & X"0"  & J_Valor (7 DOWNTO 4) & X"0"  & J_Valor (3 DOWNTO 0) & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" WHEN "0001",
			  D_cmd & X"20" & X"24" & D_rD & X"2C" & X"20" & X"20" & X"20" & X"20" & X"20" & X"24" & D_rS & X"2C" & X"20" & X"24" & D_rT & X"20" & X"20" & X"20" & X"20" WHEN "0010",
			  D_cmd & X"20" & X"24" & D_rD & X"2C" & X"20" & X"20" & X"20" & X"20" & X"20" & X"24" & D_rs & X"2C" & X"20" & X"0" & "000" & Shamt(4) & X"0" & Shamt(3 DOWNTO 0) & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" WHEN "0100",
			  D_cmd & X"20" & X"24" & D_rS & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" WHEN "1000",
			  X"45" & X"72" & X"72" & X"6F" & X"75" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" WHEN OTHERS;
	
	
	--Linha 1
	WITH Ctrl SELECT 
	Linha1 <= X"4D" & X"49" & X"50" & X"53" & X"20" & X"20" & X"50" & X"43" & X"3D" & X"00" & X"00" & X"00" & X"0" & PC(7 DOWNTO 4) & X"0" & PC(3 DOWNTO 0) & X"20" & X"20" WHEN "00" | "01", --MIPS PC=XXX
				 MIPS(255 DOWNTO 128) WHEN OTHERS;
	
	--Linha 2
	WITH Ctrl SELECT
	Linha2 <= X"49" & X"6E" & X"73" & X"74" & X"3D" & X"0" & Instruction (31 DOWNTO 28) & X"0" & Instruction (27 DOWNTO 24) & X"0" & Instruction (23 DOWNTO 20) & X"0" & Instruction (19 DOWNTO 16) & X"0" & Instruction (15 DOWNTO 12) & X"0" & Instruction (11 DOWNTO 8) & X"0" & Instruction (7 DOWNTO 4) & X"0" & Instruction (3 DOWNTO 0) & X"20" & X"20" & X"20" WHEN "00",--INST=XXXXXXXX
				 X"52" & X"65" & X"73" & X"75" & X"6C" & X"74" & X"3D" & X"0" & write_data (31 DOWNTO 28) & X"0" & write_data (27 DOWNTO 24) & X"0" & write_data (23 DOWNTO 20) & X"0" & write_data (19 DOWNTO 16) & X"0" & write_data (15 DOWNTO 12) & X"0" & write_data (11 DOWNTO 8) & X"0" & write_data (7 DOWNTO 4) & X"0" & write_data (3 DOWNTO 0) & X"20" WHEN "01", --Result=XXXXXXX
				 MIPS(127 DOWNTO 0) WHEN OTHERS;
	
	
	
END gen;