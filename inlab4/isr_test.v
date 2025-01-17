module testbench;
  //Internal Wires
  reg [31:0] ans;
  //Module Wires
  reg clock;
  reg reset;
  reg [63:0] value;
  wire [31:0] result;
  wire done;
  wire [2:0] state;
  wire [6:0] counter;
  wire [31:0] guess_value;
  wire larger;

  ISR t1(.reset(reset), .value(value), .clock(clock), .result(result), .done(done));

always begin 
  #3.5;
  clock=~clock; 
end 

//--------------Test bench functions---------------
task exit_on_error;
  begin
    $display("@@@ Incorrect at time %4.0f", $time);
    $display("@@@ Time:%4.0f clock:%b value=%d  result:%d ans:%d", $time, clock, value, result, ans);
    $display("ENDING TESTBENCH : ERROR !");
    $finish;
  end
endtask

always@(posedge clock) begin
  #2
  if( done == 1 && ans != result  ) begin //CORRECT CASE
    exit_on_error( );
  end
end
//--------------------------------------------------

initial begin 

  $display("STARTING TESTBENCH!\n");
  $monitor("reset=%b value=%d result:%d ans:%d", reset, value, result, ans);

  //INIT STATE
  #10
  clock = 0;
  reset = 0;
  ans = 32'd0;
  value = ans*ans;
  // smallest number test
  $display("smallest number test");  
  @(negedge clock);
  reset = 1;
  @(negedge clock);
  reset = 0;
  @(posedge done);
  // largest number test
  $display("largest number test");  
  reset = 1;
  ans = 32'hFFFF_FFFF;
  value = ans*ans;
  @(negedge clock);
  reset = 1;
  @(negedge clock);
  reset = 0;
  @(posedge done);
  // random value test
  $display("random value test");
  ans = $random;
  value = ans*ans;
  reset = 1; 
  @(negedge clock);
  reset = 1;
  @(negedge clock);
  reset = 0;
  @(posedge done);
  // change inValue test
  $display("change inValue test");
  ans = $random;
  value = ans*ans;
  reset = 1; 
  @(negedge clock);
  reset = 1;
  @(negedge clock);
  reset = 0;
  @(negedge clock);
  @(negedge clock);
  value = (ans+1)*(ans+1);
  @(posedge done);
  // compute state reset test
  $display("compute state reset test");
  ans = $random;
  value = ans*ans;
  reset = 1; 
  @(negedge clock);
  reset = 0;
  @(negedge clock);
  @(negedge clock);
  @(negedge clock);
  @(negedge clock);
  @(negedge clock);
  @(negedge clock);
  reset = 1; 
  ans = 11;
  value = ans*ans;
  @(negedge clock);
  reset = 0;
  @(posedge done);

  $display("ENDING TESTBENCH : SUCCESS !\n");
  $finish;
	
end


endmodule 

