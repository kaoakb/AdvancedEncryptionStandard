module wrapper_tb();
reg enable,reset,clk;
 wire led,led256,led192;
 
 initial begin
 reset=1;
 enable=0;
 clk=0;
 
 end
 always begin
 #10 reset=0;
 #10 enable=1;
 #5 reset=1;
 end
 always #10 clk=~clk;
 wrapper error (enable,reset,clk, led,led256,led192);
 
 endmodule 