function [15:0] sqrt_function;
  input [15:0] x;
  reg [15:0] approx, next_approx;
  integer i;

  begin
    if (x <= 0) begin
      sqrt_function = 0;
    end else begin
      approx = 1;
      next_approx = 0;
      repeat (11) begin 
        next_approx = (approx + x/approx) >> 1; 
        approx = next_approx;
      end
      sqrt_function = approx;
    end
  end
endfunction
