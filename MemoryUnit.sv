module MemoryUnit #(
  parameter fileName = "Ex1.mem")(
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
      $readmemb(fileName, mem, 0, 32767);

    always @(posedge clk)
        begin
          if (e) begin
            if (we) begin          
              mem[address /2 + data * 100] <= data_in;
              #1
              $writememb(fileName, mem);
            end
            else
            data_out <= mem[address / 2 + address % 2 + data * 100];
        end
       end

endmodule