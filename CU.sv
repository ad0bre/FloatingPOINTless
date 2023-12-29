module CU(
  input clk, rst_b,
  input [5:0] opcode_i,
  input [3:0] flags,
  output reg [15:0] c_signals,
  output reg [4:0] op_select
);
  
  localparam IF = 3'b000;
  localparam ID = 3'b001;
  localparam Ex = 3'b010;
  localparam Mem = 3'b011;
  localparam WB = 3'b100;
  
  localparam SELECT_PC = 12'b000000000001;
  localparam SELECT_ADDR = 12'b000000000010;
  localparam WRITE_ENABLE = 12'b000000000100;
  localparam MEMORY_ENABLE = 12'b000000001000;
  localparam WRITE_REGISTER_ENABLE = 12'b000000010000;
  localparam SELECT_ALU_OPD = 12'b000000100000;
  localparam SELECT_WRITE_DATA = 12'b000001000000;
  localparam SELECT_WRITE_DATA_MEMORY = 12'b000001000000;
  localparam LOAD_INSTRUCTION = 12'b000100000000;
  localparam UPDATE_PC = 12'b001000000000;
  localparam DECREMENT_SP = 12'b000010000000;
  localparam INCREMENT_SP = 12'b010000000000;
  localparam DATA_ADDRESS = 16'b0010000000000000; 
  
  
  reg [2:0] st, st_nxt;
  reg [5:0] opcode;
 
  
  always @(st)
    if(st == Ex)
      opcode <= opcode_i;
  
  always @( clk)
    begin
      op_select = 0;
      
      case(st)
        
        IF: begin
          c_signals = LOAD_INSTRUCTION | MEMORY_ENABLE;
          st_nxt = ID;
        end
        
        
        ID: begin
          st_nxt = Ex;
          c_signals = c_signals | SELECT_PC | UPDATE_PC;
        end
        
        Ex: begin
          st_nxt = Mem;  // Next state
          c_signals = 0;
          
          if(opcode == 6'b000000) begin //HLT
            $finish();
          end
          
          else if(opcode == 6'b011110) begin // PSH
            op_select = 17;
            c_signals = SELECT_ALU_OPD | DECREMENT_SP;
          end
          
          else if(opcode == 6'b011111) begin // POP
            op_select = 17;
            c_signals = SELECT_ALU_OPD | SELECT_ADDR;
          end
          
          else if(opcode == 6'b100110) begin // RET
            op_select = 16;
            c_signals = SELECT_ALU_OPD | SELECT_ADDR;
          end
          
          else if(opcode == 6'b100101) begin // JMS
            op_select = 16;
            c_signals = SELECT_ADDR;
          end
        
          
          else if(opcode == 6'b100100) begin // BRA
            c_signals = UPDATE_PC;
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
          
          else if(opcode == 6'b010111) begin
            op_select = 18; //CMP rd, imm
            c_signals = 0;
          end
          
          if(opcode == 6'b010110) begin
            op_select = 18; //CMP r1, r2
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
          
          else if(opcode == 6'b000101) begin //LSR rd, rs
            op_select = 4;
            c_signals = SELECT_ALU_OPD;
          end
          
          else if(opcode == 6'b000110) begin //LSL rd, rs
            op_select = 3;
            c_signals = SELECT_ALU_OPD;
          end
          
          else if(opcode == 6'b000111) begin //RSR rd, rs
            op_select = 6;
            c_signals = SELECT_ALU_OPD;
          end
          
          else if(opcode == 6'b001000) begin //RSL rd, rs
            op_select = 5;
            c_signals = SELECT_ALU_OPD;
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
            // ALU out will select the address in data memory
            // Address is given by immediate value => reset c[5]
            // Because we have to select mux_3_out opselect is 17
            // We have the value from the selected register in read_data_2
            // Set c[8] to enable ALU
            op_select = 17;
            c_signals = 0;
          end
          
        end
        
        Mem: begin
          st_nxt = WB;
          c_signals = 0;
      		
          if(opcode == 6'b000011 || opcode == 6'b000001)
            c_signals = 10'b0000100000;
          else if(opcode == 6'b100101)
            c_signals = 16'b0001000000001110;
          else if(opcode == 6'b011101) // STR
            c_signals = 10'b0000001110 | DATA_ADDRESS;
          else if(opcode == 6'b011100) // LDR
            c_signals =  10'b0000001010 | DATA_ADDRESS;
          else if(opcode == 6'b011110)
            c_signals = 10'b0000001110;
          else if(opcode == 6'b011111)
            c_signals = 10'b0000001010;
          else if(opcode == 6'b100110)
            c_signals = 10'b0000001010;
        end
        
        WB: begin
          st_nxt = IF;
          if(opcode == 6'b100110)
            c_signals = 12'b111001000000;
          else if(opcode == 6'b011100)
            c_signals = 7'b1010000;
          else if(opcode == 6'b100111 || opcode == 6'b101000 || opcode == 6'b101100 || opcode == 6'b101011 || opcode == 6'b101001 || opcode == 6'b101101)
            c_signals = c_signals | 10'b0000010000;
          else if(opcode == 6'b101000)
            c_signals = 0;
          else if(opcode == 6'b100111)
            c_signals = 12'b000001010000;
          else if(opcode == 6'b100101)
            c_signals = 16'b000001010000000;
          else if(opcode[5] == 1)
            c_signals = 0;
          else if(opcode == 6'b011111)
            c_signals =12'b010001010000;
          else if(opcode == 6'b100111)
            c_signals = 12'b000001010000;
          else if(opcode != 6'b011101 && opcode != 6'b010110 && opcode != 6'b010111 && opcode != 6'b011110)
          	c_signals = c_signals | 10'b0000010000;
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