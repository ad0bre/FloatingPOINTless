`include "pow1.sv"
`include "log.sv"
`include "sqrt.sv"
`include "exp.sv"

module ALU(
  input enable,
  input [4:0] operation,
  input [15:0] data_in1,
  input [15:0] data_in2,
  output reg [15:0] data_out,
  output reg [3:0] flags
);
  
  reg [15:0]tmp;

  


  always @(posedge enable or negedge enable)
  begin
    case (operation)
      
      5'b10010: //cmp
        begin
        	tmp = data_in1 - data_in2;
      		flags <= 4'b0000;
          flags[3] <= (tmp == 0) ? 1 : 0; // zero flag
          flags[2] <= (tmp[15] == 1) ? 1 : 0; // negative flag
          flags[1] <= (data_in1[15] & ~data_in2[15] & ~tmp[15]) | (~data_in1[15] & data_in2[15] & tmp[15]); // carry flag
          flags[0] <= (data_in1[15] != data_in2[15] && tmp[15] != data_in1[15]) ? 1 : 0; // overflow flag
        end
      
      
      5'b00001: // add
        begin
          data_out = data_in1 + data_in2;
          flags <= 4'b0000;
          flags[3] <= (data_out == 0) ? 1 : 0; // zero flag
          flags[2] <= (data_out[15] == 1) ? 1 : 0; //negative flag
          flags[1] <= (data_out[15] & data_in1[15] & ~data_in2[15]) | (~data_out[15] & ~data_in1[15] & data_in2[15]); // carry flag
          flags[0] <= (data_in1[15] == data_in2[15] && data_out[15] != data_in1[15]) ? 1 : 0; // overflow flag
        end
      
      
      5'b00010: // sub
        begin
          data_out = data_in1 - data_in2;
          flags[3] <= (data_out == 16'b0) ? 1 : 0; // zero flag
          flags[2] <= (data_out[15] == 1) ? 1 : 0; // negative flag
          flags[1] <= (data_in1[15] & ~data_in2[15] & ~data_out[15]) | (~data_in1[15] & data_in2[15] & data_out[15]); // carry flag
          flags[0] <= (data_in1[15] != data_in2[15] && data_out[15] != data_in1[15]) ? 1 : 0; // overflow flag
        end
      
      
      5'b00011: // lsl
  		begin
    		flags <= 4'b0000;
          	data_out = data_in1 << (data_in2 - 1);
          flags[1] <= (data_out[15] == 1) ? 1 : 0; //carry
          	data_out = data_in1 << data_in2;
          flags[3] <= (data_out == 16'b0) ? 1 : 0; //zero
          flags[2] <= (data_out[15] == 1) ? 1 : 0; //neg
          flags[0] <= 0;  //overflow
  		end

      5'b00100: // lsr
  		begin
    		flags <= 4'b0000;
          	data_out = data_in1 >> (data_in2 - 1);
          flags[1] <= (data_out[0] == 1) ? 1 : 0; // carry
          	data_out = data_in1 >> data_in2;
          flags[3] <= (data_out == 16'b0) ? 1 : 0; //zero
          flags[2] <= (data_out[15] == 1) ? 1 : 0; //neg
          flags[0] <= 0; //overflow
  		end

      5'b00101: // rsl
  		begin
          data_out = (data_in1 << data_in2) | (data_in1 >> (16 - data_in2));
    		flags <= 4'b0000; 
          flags[3] <= (data_out == 16'b0) ? 1 : 0; // zero 
          flags[2] <= (data_out[15] == 1) ? 1 : 0; // neg
          flags[1] <= (data_out[0] == 1) ? 1 : 0; // carry
          flags[0] <= 0;  //overflow
  		end

	5'b00110: // rsr
  		begin
          data_out = (data_in1 >> data_in2) | (data_in2 << (16-data_in2));
    		flags <= 4'b0000;
    		flags[3] <= (data_out == 16'b0) ? 1 : 0; 
    		flags[2] <= (data_out[15] == 1) ? 1 : 0; 
    		flags[1] <= (data_in1[15] == 1) ? 1 : 0; 
    		flags[0] <= 0; 
  		end
      
      
      5'b00111: // mul
  		begin
    		data_out = data_in1 * data_in2;
    		flags <= 4'b0000; // Reset all flags
          flags[3] <= (data_out == 16'b0) ? 1 : 0; // zero
          flags[2] <= (data_out[15] == 1) ? 1 : 0; //negative
          flags[1] <= 0; //carry
          flags[0] <= 0; // overflow
  		end

	5'b01000: // div
  		begin
    		if (data_in2 != 16'b0)
    		begin
      			data_out = data_in1 / data_in2;
      			flags <= 4'b0000; 
      			flags[3] <= (data_out == 16'b0) ? 1 : 0; 
      			flags[2] <= (data_out[15] == 1) ? 1 : 0;
      			flags[1] <= 0; 
      			flags[0] <= 0;
    		end
  		end

     5'b01001: // mod
  		begin
    		if (data_in2 != 16'b0) // Check for modulo by zero
    		begin
      			data_out = data_in1 % data_in2;
      			flags <= 4'b0000; 
      			flags[3] <= (data_out == 16'b0) ? 1 : 0; 
      			flags[2] <= (data_out[15] == 1) ? 1 : 0; 
      			flags[1] <= 0; 
      			flags[0] <= 0; 
    		end
  		end

      5'b01010: // and
  		begin
    		data_out = data_in1 & data_in2;
    		flags <= 4'b0000; 
    		flags[3] <= (data_out == 16'b0) ? 1 : 0; 
    		flags[2] <= (data_out[15] == 1) ? 1 : 0;
    		flags[1] <= 0;
    		flags[0] <= 0;
  		end

		5'b01011: // or
  		begin
    		data_out = data_in1 | data_in2;
    		flags <= 4'b0000; 
    		flags[3] <= (data_out == 16'b0) ? 1 : 0; 
    		flags[2] <= (data_out[15] == 1) ? 1 : 0; 
    		flags[1] <= 0;
    		flags[0] <= 0;
  		end

		5'b01100: // xor
  		begin
    		data_out = data_in1 ^ data_in2;
    		flags <= 4'b0000; 
    		flags[3] <= (data_out == 16'b0) ? 1 : 0; 
    		flags[2] <= (data_out[15] == 1) ? 1 : 0; 
    		flags[1] <= 0;
    		flags[0] <= 0;
  		end

		5'b01101: // not
  		begin
    		data_out = ~data_in1;
    		flags <= 4'b0000; 
    		flags[3] <= (data_out == 16'b0) ? 1 : 0; 
    		flags[2] <= (data_out[15] == 1) ? 1 : 0; 
    		flags[1] <= 0;
    		flags[0] <= 0;
  		end

		5'b01110: // increment
  		begin
    		data_out = data_in1 + 1;
    		flags <= 4'b0000; 
    		flags[3] <= (data_out == 16'b0) ? 1 : 0; 
    		flags[2] <= (data_out[15] == 1) ? 1 : 0;
    		flags[1] <= (data_in1 == 16'b1111111111111110) ? 1 : 0; 
    		flags[0] <= 0; 
  		end

		5'b01111: // decrement
  		begin
    		data_out = data_in1 - 1;
    		flags <= 4'b0000;
    		flags[3] <= (data_out == 16'b0) ? 1 : 0; 
    		flags[2] <= (data_out[15] == 1) ? 1 : 0; 
    		flags[1] <= (data_in1 == 16'b0000000000000001) ? 1 : 0; 
    		flags[0] <= 0; 
  		end
      	
      	5'b10000: // mov
  		begin
    		data_out = data_in1;
    		flags <= flags;
  		end
      
        5'b10001: // mov
         begin
            data_out = data_in2;
            flags <= flags;
         end
      
      	5'b10011:// pow 
        	begin
			data_out <= pow1_function(data_in1, data_in2);
        	end
      
       5'b10100: // log2
            begin
              data_out <= log_function(data_in1, 16'b0000000000000010);
            end
      
      5'b10101: // log10
            begin
              data_out <= log_function(data_in1, 16'b0000000000001010);
            end
      
      5'b10110: //sqrt
        	begin
              data_out <= sqrt_function(data_in1);
            end
      
      5'b10111: //exp
        begin
          data_out <= exp_function(data_in1);
        end
      
    		
    endcase
  end
  

endmodule

