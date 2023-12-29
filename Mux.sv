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