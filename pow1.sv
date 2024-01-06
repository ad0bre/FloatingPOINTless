function [15:0] pow1_function;
  input [15:0] base; 
  input [15:0] exponent;
  reg [15:0] result;// result will be limited to 16 bits
  reg [15:0] i;// iterator

  begin
    result = 1;
    for (i = 0; i < exponent; i = i + 1) begin
      result = result * base;
    end
    pow1_function = result;
  end
endfunction
