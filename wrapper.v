module wrapper(input enable,reset,clk,output reg led,led256,led192);

reg [255:0] key;
reg [127:0] key1;
reg [191:0] key3;

reg [127:0]in;
wire [127:0] out,out2;
wire [127:0] outout,out256;
wire [127:0] out3,out192;

initial begin
        led=0;

end
always@(posedge clk)begin
    if(reset||!enable)
    begin
        led=0;
        led256=0;
        led192=0;
    end
    else begin
        
    
key=256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
key3=192'h000102030405060708090a0b0c0d0e0f1011121314151617;
key1=128'h000102030405060708090a0b0c0d0e0f;
in=128'h00112233445566778899aabbccddeeff;

//#10 $diplay("out2=%h",out2);
if(out2==in)
led=1;
if(outout==in)
led256=1;
if(out3==in)
led192=1;
end
end
InvCipher256 hi  ( clk,out256,outout,key);
cipher256 e5t6(clk,in,out256,key);
cipher hello ( clk,in ,out,key1);
InvCipher128 over (clk,out,out2, key1);
cipher192 hi2( clk,in,out192,key3);    
InvCipher192 boo(clk,out192,out3,key3);

endmodule