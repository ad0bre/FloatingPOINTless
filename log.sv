function [15:0] log_function;
  input [15:0] val;
  input [15:0] base;
  integer i;
  reg [15:0] temp;

  begin
    temp = val;

    if (val == 0) begin
      $display("Error: log10 of 0 is undefined");
      log_function = 16'h8000;
    end else begin
      log_function = 0;

      for (i = 0; i < 16; i = i + 1) begin
        if (temp >= base) begin
          temp = temp / base;
          log_function = log_function + 1;
        end 
      end
    end
  end
endfunction