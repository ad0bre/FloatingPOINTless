module CPU_tb();
  reg clk;
  reg rst_b;
  
  wire [15:0] reg_R0_out_tb;
  wire [15:0] reg_R1_out_tb;
  wire [15:0] reg_R2_out_tb;
  
  integer passed = 0;
  integer total = 0;
  
  CPU #("Test1.mem") uut(.clk(clk), .rst_b(rst_b));
  
   assign reg_R0_out_tb = uut.rg.reg_R0_out;
   assign reg_R1_out_tb = uut.rg.reg_R1_out;
   assign reg_R2_out_tb = uut.rg.reg_R2_out;
  
  always #20 clk = ~clk;
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    $display("\nTEST1 - ADD WITH REGISTERS \n----------------------------------");
    rst_b = 1;
    clk = 0;
    #40 rst_b = 0;
    #40 rst_b = 1;
    
    // Step 1
    #200
    total++;
    if(reg_R1_out_tb == 'ha) begin
      passed++;
      $display("Step1 - PASSED");
    end
     else
       $display("Step1 - FAILED");
    
    // Step 2
    #200
    total++;
    if(reg_R2_out_tb == 'h6) begin
      passed++;
      $display("Step2 - PASSED");
    end
     else
       $display("Step2 - FAILED");
    
    // Step 3
    #200
    total++;
    if(reg_R1_out_tb == 'h10) begin
      passed++;
      $display("Step3 - PASSED");
    end
     else
       $display("Step3 - FAILED");
    
    // Step 4
    #200
    total++;
    if(reg_R1_out_tb == 'hffff) begin
      passed++;
      $display("Step4 - PASSED");
    end
     else
       $display("Step4 - FAILED");
    
    // Step 5
    #200
    total++;
    if(reg_R2_out_tb == 'h8001) begin
      passed++;
      $display("Step5 - PASSED");
    end
     else
       $display("Step5 - FAILED");
    
    
    // Statistics
    $display("----------------------------------");
    if(passed - total)
      $display("TEST1 FAILED");
    else
      $display("TEST1 PASSED");
    
    $display("%2d  /%2d test steps passsed\n", passed, total);
      
    
  end
 
endmodule
