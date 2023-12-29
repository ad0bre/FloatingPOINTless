function [15:0] exp_function;
  input [15:0] x;
  real result, term;
  integer i;

  begin
    result = 1.0; 
    term = 1.0;
    for (i = 1; i < 100; i = i + 1) begin
      term = term * x / i;
      result = result + term;  
    end
    exp_function = result;
  end
endfunction

