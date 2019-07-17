LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;  -- Tipo de sinal STD_LOGIC e STD_LOGIC_VECTOR
USE IEEE.STD_LOGIC_ARITH.ALL;  -- Operacoes aritmeticas sobre binarios
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.ALL; -- Componente de memoria

ENTITY Ifetch IS
	PORT(Clock       :IN STD_LOGIC;
		  Reset       :IN STD_LOGIC;
		  Next_PC_IN  :IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		  PC_OUT	     :OUT STD_LOGIC_VECTOR(9 DOWNTO 2);
		  Instruction :OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		  PC_inc  :OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS-- Descreva aqui os demais sinais internos
	SIGNAL PC: 			STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Mem_addr:  STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL Next_PC     : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
	-- Descricao da Memoria
	data_memory: altsyncram -- Declaracao do compomente de memoria
	GENERIC MAP(
		operation_mode	=> "ROM",
		width_a			=> 32, -- tamanho da palavra (Word)
		widthad_a		=> 8,   -- tamanho do barramento de endereco
		lpm_type			=> "altsyncram",
		outdata_reg_a	=> "UNREGISTERED",
		init_file		=> "program.mif",  -- arquivo com estado inicial
		intended_device_family => "Cyclone")
	PORT MAP(
		address_a	=> Mem_addr,
		q_a			=> Instruction, --instrucao
		clock0		=> Clock);  -- sinal de clock da memoria
	
	-- Descricao do somador (soma 1 palavra)
		PC_inc(1 DOWNTO 0) <= "00";
		PC_inc(31 DOWNTO 2) <= PC(31 DOWNTO 2) + 1; 
		
	-- Descricao do registrador (32 bits)
		PROCESS ( Reset, Clock )
		BEGIN
			IF Reset = '1' THEN
				PC <= X"00000000";
			ELSIF Clock'EVENT AND Clock = '1' THEN
				PC <= Next_PC;
			END IF;
		END PROCESS;
	
   -- <Inserir qualquer codigo adicional para interligar as partes: registrador, 
	-- somador e memoria atraves dos sinais internos>
	PC_OUT <= PC(9 DOWNTO 2);
	
	Next_PC <= X"00000000" WHEN Reset = '1' ELSE
					   Next_PC_IN;
	Mem_addr <= Next_PC(9 DOWNTO 2);
END behavior;
