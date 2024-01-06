module CU(
  input clk, rst_b,
  input [5:0] opcode,
  input [3:0] flags,
  output reg [15:0] c_signals,
  output reg [4:0] op_select
);
  
  // 5 stages for each instruction
  localparam IF = 3'b000;
  localparam ID = 3'b001;
  localparam Ex = 3'b010;
  localparam Mem = 3'b011;
  localparam WB = 3'b100;
  

  localparam SELECT_PC = 12'b000000000001; // c0 - Select NPC value
  localparam SELECT_ADDR = 12'b000000000010; // c1 - Select address to write in memory
  localparam MEMORY_WRITE_ENABLE = 12'b000000000100; // c2 - memory write enable
  localparam MEMORY_ENABLE = 12'b000000001000; // c3 - memory enable
  localparam WRITE_ENABLE_REGISTER = 12'b000000010000; // c4 - write enable reg file
  localparam SELECT_ALU_OPD = 12'b000000100000; //c5 - select imm or reg value
  localparam SELECT_WRITE_DATA = 12'b000001000000; // c6 - Select data to write in reg file
  localparam DECREMENT_SP = 12'b000010000000; // c7 - Decrement SP
  localparam LOAD_INSTRUCTION = 12'b000100000000; // c8 - Write in IB
  localparam UPDATE_PC = 12'b001000000000; // c9 - Update NPC
  localparam INCREMENT_SP = 12'b010000000000; // c10 - Increment SP
  localparam SELECT_BRANCH_ADDRESS = 12'b100000000000; // c11 - select BA or JMSA
  localparam SELECT_MEMORY_WRITE_DATA = 16'b0001000000000000;  // c12 -select data to write in memory
  localparam DATA = 16'b0010000000000000;  // c13 -we have to fetch data from memory
  
  
  reg [2:0] st, st_nxt; // current state, next_state
  
  always @( clk)
    begin
      op_select = 0;
      case(st)
        
        /*
          STAGE 1: Instruction fetch
          Load instruction from memory
        */
        IF: begin
          st_nxt = ID; // Next stage is Instruction Decode
          c_signals = LOAD_INSTRUCTION | MEMORY_ENABLE;
        end
        
        /*
          STAGE 2: Instruction decode
          Decode the instructions and update PC
        */
        ID: begin
          st_nxt = Ex; // Next stage is Instruction Execute
          c_signals = c_signals | SELECT_PC | UPDATE_PC;
        end
        
        /*
          STAGE 3: Instruction execute
          Chose input for ALU
            Select operation to execute
            Update PC for Branch
        */
        Ex: begin
          st_nxt = Mem; // Next stage is Memory Access
          c_signals = 0;
          
          if(opcode == 6'b000000) begin //HLT
            $finish(); // Stop the simulation
          end
          
          else if(opcode == 6'b011110) begin // PSH
            op_select = 17; // Pass the SP through ALU
            c_signals = SELECT_ALU_OPD | DECREMENT_SP;
          end
          
          else if(opcode == 6'b011111) begin // POP
            op_select = 17; // Pass the SP through ALU
            c_signals = SELECT_ALU_OPD | SELECT_ADDR;
          end
          
          else if(opcode == 6'b100110) begin // RET
            op_select = 16; // Pass the SP through ALU
            c_signals = SELECT_ALU_OPD | SELECT_ADDR;
          end
          
          else if(opcode == 6'b100101) begin // JMS
            op_select = 16; // Pass the SP through ALU
            c_signals = SELECT_ADDR;
          end
        
          else if(opcode == 6'b100100) begin // BRA
            c_signals = UPDATE_PC; // We dont use this ALU
          end
          
          else if(opcode == 6'b100000) begin // BRZ
            if(flags[3]) // We update PC only if zero flag is set
              c_signals = UPDATE_PC; 
            else
                c_signals = 0;
          end
          
          else if(opcode == 6'b100001) begin // BRN
            if(flags[2]) // We update PC only if negative flag is set
              c_signals = UPDATE_PC;
            else
                c_signals = 0;
          end
          
          else if(opcode == 6'b100010) begin // BRC
            if(flags[1]) // We update PC only if carry flag is set
              c_signals = UPDATE_PC;
            else
                c_signals = 0;
          end
          
          else if(opcode == 6'b100011) begin // BRO
            if(flags[0]) // We update PC only if overflow flag is set
              c_signals = UPDATE_PC;
            else
                c_signals = 0;
          end
          
          else if(opcode == 6'b010111) begin //CMP rd, imm
            op_select = 18; 
            c_signals = 0;
          end
          
          if(opcode == 6'b010110) begin //CMP r1, r2
            op_select = 18; 
            c_signals = SELECT_ALU_OPD;
          end
          
          if(opcode == 6'b000001) begin //ADD rd, rs
            op_select = 1;
            c_signals = SELECT_ALU_OPD;
          end
          
          else if(opcode == 6'b100111) begin //POW rd, rs
            op_select = 19;
            c_signals = SELECT_ALU_OPD;
          end
          
          else if(opcode == 6'b101000) begin// POW rd, imm
            op_select = 19;
            c_signals = 0;
          end
          
          else if(opcode == 6'b101100) begin// LOG2 rd
            op_select = 20;
            c_signals = 0;
          end
          
          else if(opcode == 6'b101011) begin// LOG10 rd
            op_select = 21;
            c_signals = 0;
          end
          
          else if(opcode == 6'b101001) begin// SQRT rd
            op_select = 22;
            c_signals = 0;
          end
          
          else if(opcode == 6'b101101) begin
            op_select = 23;
            c_signals = 0;
          end
          
          else if(opcode == 6'b000011) begin //SUB rd, rs
            op_select = 2;
            c_signals = SELECT_ALU_OPD;
          end
          
          else if(opcode == 6'b000101) begin //LSR rd, imm
            op_select = 4;
            c_signals = 0;
          end
          
          else if(opcode == 6'b000110) begin //LSL rd, imm
            op_select = 3;
            c_signals = 0;
          end
          
          else if(opcode == 6'b000111) begin //RSR rd, imm
            op_select = 6;
            c_signals = 0;
          end
          
          else if(opcode == 6'b001000) begin //RSL rd, imm
            op_select = 5;
            c_signals = 0;
          end
          
          else if(opcode == 6'b001001) begin //MUL rd, rs
            op_select = 7;
            c_signals = SELECT_ALU_OPD;
          end
          
          else if(opcode == 6'b001011) begin //DIV rd, rs
            op_select = 8;
            c_signals = SELECT_ALU_OPD;
          end
          
          else if(opcode == 6'b001101) begin //MOD rd, rs
            op_select = 9;
            c_signals = SELECT_ALU_OPD;
          end
          
          else if(opcode == 6'b011010) begin //MOV rd, rs
            op_select = 17;
            c_signals = SELECT_ALU_OPD;
          end
          
          else if(opcode == 6'b001111) begin //AND rd, rs
            op_select = 10;
            c_signals = SELECT_ALU_OPD;
          end
          
          else if(opcode == 6'b010001) begin //OR rd, rs
            op_select = 11;
            c_signals = SELECT_ALU_OPD;
          end
          
          else if(opcode == 6'b010011) begin //XOR rd, rs
            op_select = 12;
            c_signals = SELECT_ALU_OPD;
          end
          
          else if(opcode == 6'b010101) begin //NOT rd
            op_select = 13;
            c_signals = SELECT_ALU_OPD;
          end
          
          else if(opcode == 6'b011000) begin //INC rd
            op_select = 14;
            c_signals = SELECT_ALU_OPD;
          end
          
          else if(opcode == 6'b011001) begin //DEC rd
            op_select = 15;
            c_signals = SELECT_ALU_OPD;
          end
          
          else if(opcode == 6'b011011) begin// MOV imm
            op_select = 17;
            c_signals = 0;
          end
          
          else if(opcode == 6'b000010) begin // ADD imm
            op_select = 1;
            c_signals = 0;
          end
          
          else if(opcode == 6'b000100) begin // SUB imm
            op_select = 2;
            c_signals = 0;
          end
          
          else if(opcode == 6'b001010) begin // MUL imm
            op_select = 7;
            c_signals = 0;
          end
          
          else if(opcode == 6'b001100) begin // DIV imm
            op_select = 8;
            c_signals = 0;
          end
          
          else if(opcode == 6'b001110) begin // MOD imm
            op_select = 9;
            c_signals = 0;
          end
          
          else if(opcode == 6'b010000) begin // AND imm
            op_select = 10;
            c_signals = 0;
          end
          
          else if(opcode == 6'b010010) begin // OR imm
            op_select = 11;
            c_signals = 0;
          end
          
          else if(opcode == 6'b010100) begin // XOR imm
            op_select = 12;
            c_signals = 0;
          end
          
          else if(opcode == 6'b011100) begin // LDR rd, addr
            
            op_select = 17;
            c_signals = 0;
          end
            
          else if(opcode == 6'b011101) begin // STR rd, addr
            op_select = 17;
            c_signals = 0;
          end
          
        end
        /*
        STAGE 4: Memory Access
          Read write from memory
            JMP, STR, LDR, PSH, POP, RET
        */
        Mem: begin
          st_nxt = WB;
          c_signals = 0;
          if(opcode == 6'b100101) // JMP
              c_signals = SELECT_ADDR | MEMORY_WRITE_ENABLE | MEMORY_ENABLE | SELECT_MEMORY_WRITE_DATA;
          else if(opcode == 6'b011101) // STR
            c_signals = SELECT_ADDR | MEMORY_WRITE_ENABLE | MEMORY_ENABLE | DATA;
          else if(opcode == 6'b011100) // LDR
            c_signals =  SELECT_ADDR | MEMORY_ENABLE | DATA;
          else if(opcode == 6'b011110) // PSH
            c_signals = SELECT_ADDR | MEMORY_WRITE_ENABLE | MEMORY_ENABLE;
          else if(opcode == 6'b011111 || opcode == 6'b100110) // POP, RET
            c_signals =  SELECT_ADDR | MEMORY_ENABLE;
        end
        
        /*
        STAGE 5: Write Back
          Write in reg file
        */
        WB: begin
          st_nxt = IF;
          if(opcode == 6'b100110) // RET
              c_signals = SELECT_BRANCH_ADDRESS | INCREMENT_SP | UPDATE_PC;
          else if(opcode == 6'b011100) // LDR
             c_signals = SELECT_WRITE_DATA | WRITE_ENABLE_REGISTER;
          else if(opcode == 6'b100111 || opcode == 6'b101000 || opcode == 6'b101100 || opcode == 6'b101011 || opcode == 6'b101001 || opcode == 6'b101101) // Math ops
            c_signals = c_signals | WRITE_ENABLE_REGISTER;
          else if(opcode == 6'b100101) // JMS
            c_signals = DECREMENT_SP| UPDATE_PC;
          else if(opcode[5] == 1) // Branching
            c_signals = 0;
          else if(opcode == 6'b011111) // POP
            c_signals = WRITE_ENABLE_REGISTER | SELECT_WRITE_DATA | INCREMENT_SP;
          else if(opcode != 6'b011101 && opcode != 6'b010110 && opcode != 6'b010111 && opcode != 6'b011110) // STR, CMP rr, CMP imm, PSH 
            c_signals = c_signals | WRITE_ENABLE_REGISTER;
          else 
            c_signals = 0;
        end
      endcase
    end
  
  always @(posedge clk, negedge rst_b) // set next state
    if(!rst_b)
        st <= IF;
    else
        st <= st_nxt;
  
endmodule