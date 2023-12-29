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
      end
    end
endmodule