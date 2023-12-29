module Immediate_Sign_Extend_Unit(
  input[7:0] input_data,
  output[15:0] output_data
);

  assign output_data = (input_data[7] == 1'b0) ? 
 							{{8{1'b0}}, input_data} : 
 							{{8{1'b1}}, input_data};

endmodule