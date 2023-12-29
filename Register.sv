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