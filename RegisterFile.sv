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
  
  Register2 #(width) reg_SP(
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