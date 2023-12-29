`include "MemoryUnit.sv"
`include "Mux.sv"
`include "Register.sv"
`include "Register2.sv"
`include "CU.sv"
`include "RegisterFile.sv"
`include "ALU.sv"
`include "Immediate_Sign_Extend_Unit.sv"

module CPU #(
  parameter fileName = "Ex1.mem")(
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
  
  MemoryUnit #(fileName) memory_unit(
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