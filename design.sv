module MemoryUnit(
    input clk,
    input we,
  	input e,
  	input data,
    input [15:0] data_in,
  	input [15:0] address,
    output reg [15:0] data_out
    );
    
  reg [15:0] mem[0:32767];

    initial
      $readmemb("Math.mem", mem, 0, 32767);

    always @(posedge clk)
        begin
          if (e) begin
            if (we) begin
                $display("Added value at address %0d: %h", address, data_in);
                
              mem[address /2 + data * 100] <= data_in;
              #1
              $writememb("Math.mem", mem);
            end
            else
              $display("Fetching from address %d - %d: %h", address, address/2 + address %2, mem[address / 2 + address % 2 + data * 100]);
            data_out <= mem[address / 2 + address % 2 + data * 100];
        end
       end

endmodule
// ----------------------------------- MUX

module Mux
    #(parameter width = 16)(
        input [width-1:0] a, b,
        input s,
      output reg[width-1:0] c
    );
    
    always @(*)
    begin
      if(s)
            c <= b;
        else
            c <= a;
    end
    
endmodule

// ---------------------------- Register

module Register
    #(parameter width = 16)(
    input clk,
    input reset,
    input enable,
    input [width-1:0] data_in,
    output reg [width-1:0] data_out
    );
    
  always @(posedge clk, negedge reset)
    begin
        if(!reset)
            data_out <= 0;
      else if(enable) 
            data_out <= data_in;
    end
  
    
endmodule

module Register2
    #(parameter width = 16)(
    input reset,
    input enable,
    input increment,
    input decrement,
    output reg [width-1:0] data_out
    );
    
  always @(posedge increment, posedge decrement,negedge reset)
    begin
        if(!reset)
            data_out <= 65535;
      else if(increment) 
            data_out <= data_out + 2;
      else if(decrement) begin
          	data_out <= data_out - 2;
        $display("DEC %h", decrement);
      end
      
    end
 
    
endmodule




// --------------------------------- CU
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
            $display("HHHAHALLHLLLTTT");
            $finish();
          end
          
          else if(opcode == 6'b011110) begin // PSH
            op_select = 17;
            $display("PSH");
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
            $display("MUL IS HERE");
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
          
          else if(opcode == 6'b011100 || opcode == 6'b100111) begin // LDR rd, addr
            
            op_select = 17;
            c_signals = 6'b100000;
          end
            
          else if(opcode == 6'b011101 || opcode == 6'b101000) begin // STR rd, addr
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
          else if(opcode == 6'b011101 || opcode == 6'b101000) // STR
            c_signals = 10'b0000001110 | DATA_ADDRESS;
          else if(opcode == 6'b011100 || opcode == 6'b100111) // LDR
            c_signals = 10'b0000001010 | DATA_ADDRESS;
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

// ------------------------------------ Register File

module RegisterFile #(parameter width=16)(
    input clk,
    input reset,
    input write_enable,
    input [width-1:0] write_data,
    input [1:0] read_reg,
    input [1:0] write_reg,
  	input dec, // signal used to decrement SP
  	input inc, // signal used to increment SP
    output reg [width-1:0] read_data1,
    output reg [width-1:0] read_data2
);

    localparam REG_R0 = 2'b00;
    localparam REG_R1 = 2'b01;
    localparam REG_R2 = 2'b10;
    localparam REG_SP = 2'b11;

    reg [width-1:0] reg_file [3:0];

    // Internal signals to store the output of Register modules
  	wire [width-1:0] reg_R0_out;
  	wire [width-1:0] reg_R1_out;
  	wire [width-1:0] reg_R2_out;
  	wire [width-1:0] reg_SP_out;
 

    // Instantiate Register modules for each register
  Register #(width) reg_R0 (
        .clk(clk),
        .reset(reset),
    	.enable(write_enable && (write_reg == REG_R0)),
        .data_in(write_data),
    	.data_out(reg_R0_out)
    );

  Register #(width) reg_R1 (
        .clk(clk),
        .reset(reset),
   	 	.enable(write_enable && (write_reg == REG_R1)),
        .data_in(write_data),
    	.data_out(reg_R1_out)
    );

  Register #(width) reg_R2 (
        .clk(clk),
        .reset(reset),
    	.enable(write_enable && (write_reg == REG_R2)),
        .data_in(write_data),
    	.data_out(reg_R2_out)
    );
  
  Register2	#(width) reg_SP(
    .reset(reset),
    .enable(write_enable && (write_reg == REG_SP)),
    .increment(inc),
    .decrement(dec),
    .data_out(reg_SP_out)
    );


    // Read data from selected registers
    always @(clk or negedge reset) begin
        if (!write_enable) begin
            case (read_reg)
                REG_R0: read_data1 = reg_R0_out;
                REG_R1: read_data1 = reg_R1_out;
                REG_R2: read_data1 = reg_R2_out;
                REG_SP:
                  	read_data1 = reg_SP_out;
                default: read_data1 = 0;
            endcase
            case (write_reg)
                REG_R0: read_data2 = reg_R0_out;
                REG_R1: read_data2 = reg_R1_out;
                REG_R2: read_data2 = reg_R2_out;
                REG_SP: read_data2 = reg_SP_out;
                default: read_data2 = 0;
            endcase
        end else begin
            
        end
    end
endmodule


// ---------------------------------- ALU
module ALU(
  input enable,
  input [4:0] operation,
  input [15:0] data_in1,
  input [15:0] data_in2,
  output reg [15:0] data_out,
  output reg [3:0] flags
);
  
  reg [15:0]tmp;

  always @(posedge enable or negedge enable)
  begin
    case (operation)
      
      5'b10010: //cmp
        begin
        	tmp = data_in1 - data_in2;
      		flags <= 4'b0000;
          flags[3] <= (tmp == 0) ? 1 : 0; // zero flag
          flags[2] <= (tmp[15] == 1) ? 1 : 0; // negative flag
          flags[1] <= (data_in1[15] & ~data_in2[15] & ~tmp[15]) | (~data_in1[15] & data_in2[15] & tmp[15]); // carry flag
          flags[0] <= (data_in1[15] != data_in2[15] && tmp[15] != data_in1[15]) ? 1 : 0; // overflow flag
        end
      
      
      4'b0001: // add
        begin
          data_out = data_in1 + data_in2;
          flags <= 4'b0000;
          flags[3] <= (data_out == 0) ? 1 : 0; // zero flag
          flags[2] <= (data_out[15] == 1) ? 1 : 0; //negative flag
          flags[1] <= (data_out[15] & data_in1[15] & ~data_in2[15]) | (~data_out[15] & ~data_in1[15] & data_in2[15]); // carry flag
          flags[0] <= (data_in1[15] == data_in2[15] && data_out[15] != data_in1[15]) ? 1 : 0; // overflow flag
        end
      
      
      4'b0010: // sub
        begin
          data_out = data_in1 - data_in2;
          flags[3] <= (data_out == 16'b0) ? 1 : 0; // zero flag
          flags[2] <= (data_out[15] == 1) ? 1 : 0; // negative flag
          flags[1] <= (data_in1[15] & ~data_in2[15] & ~data_out[15]) | (~data_in1[15] & data_in2[15] & data_out[15]); // carry flag
          flags[0] <= (data_in1[15] != data_in2[15] && data_out[15] != data_in1[15]) ? 1 : 0; // overflow flag
        end
      
      
      4'b0011: // lsl
  		begin
    		flags <= 4'b0000;
          	data_out = data_in1 << (data_in2 - 1);
          flags[1] <= (data_out[15] == 1) ? 1 : 0; //carry
          	data_out = data_in1 << data_in2;
          flags[3] <= (data_out == 16'b0) ? 1 : 0; //zero
          flags[2] <= (data_out[15] == 1) ? 1 : 0; //neg
          flags[0] <= 0;  //overflow
  		end

      4'b0100: // lsr
  		begin
    		flags <= 4'b0000;
          	data_out = data_in1 >> (data_in2 - 1);
          flags[1] <= (data_out[0] == 1) ? 1 : 0; // carry
          	data_out = data_in1 >> data_in2;
          flags[3] <= (data_out == 16'b0) ? 1 : 0; //zero
          flags[2] <= (data_out[15] == 1) ? 1 : 0; //neg
          flags[0] <= 0; //overflow
  		end

      4'b0101: // rsl
  		begin
          data_out = (data_in1 << data_in2) | (data_in1 >> (16 - data_in2));
    		flags <= 4'b0000; 
          flags[3] <= (data_out == 16'b0) ? 1 : 0; // zero 
          flags[2] <= (data_out[15] == 1) ? 1 : 0; // neg
          flags[1] <= (data_out[0] == 1) ? 1 : 0; // carry
          flags[0] <= 0;  //overflow
  		end

	4'b0110: // rsr
  		begin
          data_out = (data_in1 >> data_in2) | (data_in2 << (16-data_in2));
    		flags <= 4'b0000;
    		flags[3] <= (data_out == 16'b0) ? 1 : 0; 
    		flags[2] <= (data_out[15] == 1) ? 1 : 0; 
    		flags[1] <= (data_in1[15] == 1) ? 1 : 0; 
    		flags[0] <= 0; 
  		end
      
      
      4'b0111: // mul
  		begin
    		data_out = data_in1 * data_in2;
    		flags <= 4'b0000; // Reset all flags
          flags[3] <= (data_out == 16'b0) ? 1 : 0; // zero
          flags[2] <= (data_out[15] == 1) ? 1 : 0; //negative
          flags[1] <= 0; //carry
          flags[0] <= 0; // overflow
  		end

	4'b1000: // div
  		begin
    		if (data_in2 != 16'b0)
    		begin
      			data_out = data_in1 / data_in2;
      			flags <= 4'b0000; 
      			flags[3] <= (data_out == 16'b0) ? 1 : 0; 
      			flags[2] <= (data_out[15] == 1) ? 1 : 0;
      			flags[1] <= 0; 
      			flags[0] <= 0;
    		end
  		end

     4'b1001: // mod
  		begin
    		if (data_in2 != 16'b0) // Check for modulo by zero
    		begin
      			data_out = data_in1 % data_in2;
      			flags <= 4'b0000; 
      			flags[3] <= (data_out == 16'b0) ? 1 : 0; 
      			flags[2] <= (data_out[15] == 1) ? 1 : 0; 
      			flags[1] <= 0; 
      			flags[0] <= 0; 
    		end
  		end

      4'b1010: // and
  		begin
    		data_out = data_in1 & data_in2;
    		flags <= 4'b0000; 
    		flags[3] <= (data_out == 16'b0) ? 1 : 0; 
    		flags[2] <= (data_out[15] == 1) ? 1 : 0;
    		flags[1] <= 0;
    		flags[0] <= 0;
  		end

		4'b1011: // or
  		begin
    		data_out = data_in1 | data_in2;
    		flags <= 4'b0000; 
    		flags[3] <= (data_out == 16'b0) ? 1 : 0; 
    		flags[2] <= (data_out[15] == 1) ? 1 : 0; 
    		flags[1] <= 0;
    		flags[0] <= 0;
  		end

		4'b1100: // xor
  		begin
    		data_out = data_in1 ^ data_in2;
    		flags <= 4'b0000; 
    		flags[3] <= (data_out == 16'b0) ? 1 : 0; 
    		flags[2] <= (data_out[15] == 1) ? 1 : 0; 
    		flags[1] <= 0;
    		flags[0] <= 0;
  		end

		4'b1101: // not
  		begin
    		data_out = ~data_in1;
    		flags <= 4'b0000; 
    		flags[3] <= (data_out == 16'b0) ? 1 : 0; 
    		flags[2] <= (data_out[15] == 1) ? 1 : 0; 
    		flags[1] <= 0;
    		flags[0] <= 0;
  		end

		4'b1110: // increment
  		begin
    		data_out = data_in1 + 1;
    		flags <= 4'b0000; 
    		flags[3] <= (data_out == 16'b0) ? 1 : 0; 
    		flags[2] <= (data_out[15] == 1) ? 1 : 0;
    		flags[1] <= (data_in1 == 16'b1111111111111110) ? 1 : 0; 
    		flags[0] <= 0; 
  		end

		4'b1111: // decrement
  		begin
    		data_out = data_in1 - 1;
    		flags <= 4'b0000;
    		flags[3] <= (data_out == 16'b0) ? 1 : 0; 
    		flags[2] <= (data_out[15] == 1) ? 1 : 0; 
    		flags[1] <= (data_in1 == 16'b0000000000000001) ? 1 : 0; 
    		flags[0] <= 0; 
  		end
      	
      	5'b10000: // mov
  		begin
    		data_out = data_in1;
    		flags <= flags;
  		end
      
        5'b10001: // mov
         begin
            data_out = data_in2;
            flags <= flags;
         end

    endcase
  end

endmodule

// -------------------------------------- SignExtend

module Immediate_Sign_Extend_Unit(
  input[7:0] input_data,
  output[15:0] output_data
);

  assign output_data = (input_data[7] == 1'b0) ? 
 							{{8{1'b0}}, input_data} : 
 							{{8{1'b1}}, input_data};

endmodule

// ---------------------------- CPU

module CPU(
  input clk, rst_b
);
  
  wire[15:0] control_signals;
  wire[15:0] pc_input;
  wire[15:0] pc_output;
  
  wire[15:0] add_output;
  wire[3:0] add_flags;
  
  wire[15:0] add2_output;
  
  wire[15:0] alu_output;
  wire[15:0] memory_address;
  
  wire[15:0] read_data2;
  wire[15:0] memory_out;
  
  wire[15:0] memory_data;
  
  wire [3:0] alu_flags;
  wire [15:0] write_data;
  
  wire [15:0] read_data;
  wire [15:0] sign_extended_data;
  wire [15:0] write_data_memory;
  wire [15:0] instruction_out;
  
  wire [15:0] mux3_out;
  wire [4:0] op_select;
  
  wire [1:0] read_reg;
  
  wire[15:0] branch_output;
  
  Register #(16) PC (
    .clk(clk),
    .reset(rst_b),
    .enable(control_signals[9]),
    .data_in(pc_input),
    .data_out(pc_output)
  );
  
  ALU Add (
    .enable(clk),
    .operation(5'b00001),
    .data_in1(16'b0000000000000010),
    .data_in2(pc_output),
    .data_out(add_output),
    .flags(add_flags)
  );
  
  Mux #(16) mux9(
    .a(add2_output),
    .b(write_data),
    .s(control_signals[11]),
    .c(branch_output)
  );
  
  Mux #(16) mux(
    .a(branch_output),
    .b(add_output),
    .s(control_signals[0]),
    .c(pc_input)
  );
  
  Mux #(16) mux2(
    .a(pc_output),
    .b(alu_output),
    .s(control_signals[1]),
    .c(memory_address)
  );
  
  MemoryUnit memory_unit(
    .clk(clk),
    .we(control_signals[2]),
    .e(control_signals[3]),
    .data_in(memory_data),
    .address(memory_address),
    .data_out(memory_out),
    .data(control_signals[13])
  );
  
  CU control_unit(
    .clk(clk),
    .rst_b(rst_b),
    .opcode_i(instruction_out[15:10]),
    .flags(alu_flags),
    .c_signals(control_signals),
    .op_select(op_select)
  );
  
  RegisterFile #(16)rg (
    .clk(clk),
    .reset(rst_b),
    .write_enable(control_signals[4]),
    .write_data(write_data),
    .dec(control_signals[7]),
    .inc(control_signals[10]),
    .read_reg(instruction_out[7:6]),
    .write_reg(instruction_out[9:8]),
    .read_data1(read_data),
    .read_data2(read_data2)
  );
  
  Immediate_Sign_Extend_Unit sign_extend_unit(
    .input_data(instruction_out[7:0]),
    .output_data(sign_extended_data)
  );
  
  Mux #(16) mux3(
    .a(sign_extended_data),
    .b(read_data),
    .s(control_signals[5]),
    .c(mux3_out)
  );
  
  ALU alu (
    .enable(clk),
    .operation(op_select),
    .data_in1(read_data2),
    .data_in2(mux3_out),
    .data_out(alu_output),
    .flags(alu_flags)
  );
  
  ALU alu_rez (
    .enable(clk),
    .operation(5'b00001),
    .data_in1(add_output),
    .data_in2(mux3_out << 1),
    .data_out(add2_output),
    .flags(add_flags)
  );
  
  
  Mux #(16) mux4(
    .a(alu_output),
    .b(memory_out),
    .s(control_signals[6]),
    .c(write_data)
  );
  
  Mux #(16) mux_mem_data(
    .a(read_data2),
    .b(pc_output ),
    .s(control_signals[12]),
    .c(memory_data)
  );
  
  
  
  Register #(16) InstructionBuffer (
    .clk(~clk),
    .reset(rst_b),
    .enable(control_signals[8]),
    .data_in(memory_out),
    .data_out(instruction_out)
  );
  
  
  
endmodule
