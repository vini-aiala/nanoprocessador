LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Mapear os sinais de entrada e saida para os pinos fisicos da placa
ENTITY Exp05 IS
	PORT(	reset				: IN STD_LOGIC; -- Usar SW0
			clock48MHz		: IN STD_LOGIC; -- Usar clock da placa
			LCD_RS, LCD_E	: OUT	STD_LOGIC;
			LCD_RW, LCD_ON	: OUT STD_LOGIC;
			DATA				: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
			clockPB			: IN STD_LOGIC; -- Usar pushbutton Key1
			SW1	         : IN STD_LOGIC;
			SW2            : IN STD_LOGIC);
END Exp05;

ARCHITECTURE exec OF Exp05 IS
COMPONENT LCD_Display
	PORT(	reset, clk_48Mhz	: IN	STD_LOGIC;
			LCD_RS, LCD_E		: OUT	STD_LOGIC;
			LCD_RW				: OUT STD_LOGIC;
			DATA_BUS				: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
			Linha1 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
			Linha2 : IN STD_LOGIC_VECTOR(127 DOWNTO 0));
END COMPONENT;

COMPONENT Ifetch
	PORT(Clock       :IN STD_LOGIC;
		  Reset       :IN STD_LOGIC;
		  Next_PC_IN  :IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		  PC_OUT	     :OUT STD_LOGIC_VECTOR(9 DOWNTO 2);
		  Instruction :OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		  PC_inc  :OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END COMPONENT;

COMPONENT Execute
	PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			shamt          : IN STD_LOGIC_VECTOR ( 4 DOWNTO 0 );
			R_Format       : IN STD_LOGIC;
			Addi 				: IN STD_LOGIC;
			ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Zero           : OUT STD_LOGIC;
			ALUSrc         : IN STD_LOGIC; -- LW OR SW
			SignExtend		: IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ADD_Result     : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			PC_inc         : IN STD_LOGIC_VECTOR( 31 DOWNTO 0);           
			ALUOp				: IN STD_LOGIC_VECTOR( 1 DOWNTO 0);
			Function_opcode : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 ));
END COMPONENT;

COMPONENT Control
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
			ALUOp 		: OUT STD_LOGIC_VECTOR( 1 DOWNTO 0 ));
END COMPONENT;

COMPONENT Idecode
		  PORT(	read_data_1	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data_2	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Instruction : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				write_data	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );	--Nao precisa de sinal
				RegWrite 	: IN 	STD_LOGIC;
				RegDst 		: IN 	STD_LOGIC;
				Sign_extend : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				shamt       : OUT STD_LOGIC_VECTOR( 4 DOWNTO 0 );
				clock,reset	: IN 	STD_LOGIC );
END COMPONENT;

COMPONENT DMEMORY
	PORT(	read_data 			: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	address 				: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	   	MemRead, Memwrite	: IN 	STD_LOGIC;
         clock,reset			: IN 	STD_LOGIC );
END COMPONENT;

COMPONENT DISPGEN
	PORT (Instruction: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			PC			  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			SW1		  : IN STD_LOGIC;
			SW2		  : IN STD_LOGIC;
			Linha1     : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			Linha2	  : OUT STD_LOGIC_VECTOR(127 DOWNTO 0));
END COMPONENT;

SIGNAL clock       : STD_LOGIC;
SIGNAL PC_OUT		 : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL DataInstr 	 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL read_data_1, read_data_2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL RegDst, RegWrite     : STD_LOGIC;
SIGNAL ALU_Result          : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL Sign_extend : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL MUX_ALU : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL read_datamem: STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL MemToReg, MemRead, MemWrite : STD_LOGIC;
SIGNAL write_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ALUSrc : STD_LOGIC;
SIGNAL shamt: STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL PC_inc, ADD_Result : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL Zero, Bne : STD_LOGIC;
SIGNAL Jump, Addi, Jal : STD_LOGIC;
SIGNAL R_Format: STD_LOGIC;
SIGNAL Jr : STD_LOGIC;
SIGNAL Branch_eq : STD_LOGIC;
SIGNAL Next_PC, Next_PC_MUX: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ALUOp : STD_LOGIC_VECTOR (1 DOWNTO 0);
SIGNAL JumpAddr: STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL Linha1 : STD_LOGIC_VECTOR(127 DOWNTO 0);
SIGNAL Linha2 : STD_LOGIC_VECTOR(127 DOWNTO 0);

BEGIN
	LCD_ON <= '1';
	-- O componente LCD_Display mostra 11 digitios hexadecimais, 44 bits
	-- Mapeie os 10 bits do PC concatenados com os 32 bits da instrucao
	-- Concatene bits 0 a esquerda para completar
	-- <insira aqui o que visualizar>
	clock <= NOT clockPB;
	
	Addi <= '1' WHEN DataInstr(31 DOWNTO 26) = "001000" ELSE '0';
				
	JumpAddr <= PC_inc(31 DOWNTO 28) & DataInstr(25 DOWNTO 0) & "00" WHEN Jr = '0' ELSE read_data_1;
	
	Next_PC_MUX <= ADD_Result WHEN ((Branch_eq AND Zero) OR (Bne AND NOT Zero)) = '1' ELSE PC_inc;
	
	write_data <= ALU_Result WHEN MemToReg = '0' AND Jal = '0' ELSE
					  PC_inc WHEN RegWrite = '1' AND Jal = '1' ELSE
					  read_datamem;
	
	Next_PC <= Next_PC_MUX WHEN Jump = '0' AND Jal = '0' AND Jr = '0'
				  ELSE JumpAddr;
	
	R_Format <= '1' WHEN DataInstr(31 DOWNTO 26) = "000000"
					ELSE '0';
	
	lcd: LCD_Display
	PORT MAP(	reset				=> reset,
					clk_48Mhz		=> clock48MHz,
					LCD_RS			=> LCD_RS,
					LCD_E				=> LCD_E,
					LCD_RW			=> LCD_RW,
					DATA_BUS			=> DATA,
					Linha1    		=> Linha1,
					Linha2 			=> Linha2);
	
	IFT: Ifetch
	PORT MAP(Clock     => clock,
		  PC_inc	     => PC_inc,
		  Next_PC_IN     => Next_PC,
		  Reset       => reset,
		  PC_OUT	     => PC_OUT,
		  Instruction => DataInstr);
		  
		  
	IDC: Idecode
	PORT MAP(
		read_data_1  => read_data_1,
		read_data_2  => read_data_2,
		RegDst => RegDst,
		shamt => shamt,
		RegWrite => RegWrite,
		Instruction => DataInstr,
		write_data => write_data,
		Sign_extend => Sign_extend,
		clock => clock,
		reset => reset);
		  
	ALU: Execute
	PORT MAP(
		Read_data_1 => read_data_1,
		Read_data_2 => read_data_2,
		ALU_Result => ALU_Result,
		shamt => shamt,
		ADD_Result => ADD_Result,
		R_Format => R_Format,
		PC_inc => PC_inc,
		SignExtend => Sign_Extend,
		Zero => Zero,
		ALUSrc => ALUSrc,
		ALUOp => ALUOp,
		Addi => Addi,
		Function_opcode => DataInstr(5 DOWNTO 0));
		
		
	CTR: Control
	PORT MAP(
		Function_Op => DataInstr(5 DOWNTO 0),
		Opcode => DataInstr(31 DOWNTO 26),
		RegDst => RegDst,
		Jump => Jump,
		Bne => Bne,
		RegWrite => RegWrite,
		MemToReg => MemToReg,
		MemRead => MemRead,
		MemWrite => MemWrite,
		ALUSrc => ALUSrc,
		Branch_eq => Branch_eq,
		ALUOp => ALUOp,
		Jr => Jr,
		Jal => Jal);
		
	DMM: DMEMORY
	PORT MAP(
		read_data  => read_datamem,
		address    => ALU_Result(7 DOWNTO 0),
		write_data => read_data_2,
		MemRead => MemRead,
		Memwrite => MemWrite,
		clock => clock,
		reset => reset);
		
	DGN: DISPGEN
	PORT MAP (Instruction => DataInstr,
			PC			   => PC_OUT,
			write_data  => write_data,
			SW1		   => SW1,
			SW2		   => SW2,
			Linha1      => Linha1,
			Linha2	   => Linha2);
END exec;