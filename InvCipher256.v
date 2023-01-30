module InvCipher256 (
    input clk,
input [127:0]in,
output reg [127:0] out,
input [255:0]key
);
    integer i,j;
 reg [127:0] temp;
 reg [255:0] keyTemp ;
always @(posedge clk) begin
temp=in;
keyTemp=yarabInv256(key,6);
temp=addRoundKey(temp,keyTemp[255:128]);
for (i = 1;i<=6;i=i+1 ) begin
    temp=InvShiftRows(temp);
    temp=InvSubBytes(temp);
    keyTemp=yarabInv256(key,6-i);
    temp=addRoundKey(temp,keyTemp[127:0]);
    temp=InvMixCol(temp);
    temp=InvShiftRows(temp);
    temp=InvSubBytes(temp);
    keyTemp=yarabInv256(key,6-i);
    temp=addRoundKey(temp,keyTemp[255:128]);
    temp=InvMixCol(temp);
end
temp=InvShiftRows(temp);
    temp=InvSubBytes(temp);
    temp=addRoundKey(temp,key[127:0]);
    temp=InvMixCol(temp);
    temp=InvShiftRows(temp);
    temp=InvSubBytes(temp);
    temp=addRoundKey(temp,key[255:128]);
    out=temp;
end
function [255:0] yarabInv256;
input reg [255:0] in;
reg [255:0] temp;
input integer j;
integer stop,i;
begin

stop=(j+2)*8;
temp=in;
temp[255:224]=subbytes(RotWord(in[31:0]))^Rcon(1)^in[255:224];  
  	 temp[223:192]=temp[255:224]^in[223:192];
  		temp[191:160]=temp[223:192]^in[191:160];
  		temp[159:128]=temp[191:160]^in[159:128];
	  temp[127:96]=subbytes(temp[159:128])^in[127:96];
	  temp[95:64]=temp[127:96]^in[95:64];
	  temp[63:32]=temp[95:64]^in[63:32];
	  temp[31:0]=temp[63:32]^in[31:0];
	  for (i = 16;i<stop ;i=i+8 ) begin
		  temp[255:224]=subbytes(RotWord(temp[31:0]))^Rcon(i/8)^temp[255:224];  
  	 temp[223:192]=temp[255:224]^temp[223:192];
  		temp[191:160]=temp[223:192]^temp[191:160];
  		temp[159:128]=temp[191:160]^temp[159:128];
	  temp[127:96]=subbytes(temp[159:128])^temp[127:96];
	  temp[95:64]=temp[127:96]^temp[95:64];
	  temp[63:32]=temp[95:64]^temp[63:32];
	  temp[31:0]=temp[63:32]^temp[31:0];
	  end
	yarabInv256=temp;	
end
endfunction
function [127:0] InvShiftRows;
input [127:0] state;    
    InvShiftRows={
		state[127:120],state[23:16],state[47:40],state[71:64],
    state[95:88],state[119:112],state[15:8],state[39:32],
    state[63:56],state[87:80],state[111:104],state[7:0],
    state[31:24],state[55:48],state[79:72],state[103:96]
		};
endfunction
function [127:0] InvMixCol;
input[127:0] data_in;

begin
InvMixCol[31:0]=state_out(data_in[31:0]);
InvMixCol[63:32]=state_out(data_in[63:32]);
InvMixCol[95:64]=state_out(data_in[95:64]);
InvMixCol[127:96]=state_out(data_in[127:96]);
end
endfunction
function [31:0] state_out;
input [31:0] state_in;
begin
state_out[31:24]=oE(state_in[31:24])^oB(state_in[23:16])^oD(state_in[15:8])^Onine(state_in[7:0]);
state_out[23:16]=Onine(state_in[31:24])^oE(state_in[23:16])^oB(state_in[15:8])^oD(state_in[7:0]);
state_out[15:8]=oD(state_in[31:24])^Onine(state_in[23:16])^oE(state_in[15:8])^oB(state_in[7:0]);
state_out[7:0]=oB(state_in[31:24])^oD(state_in[23:16])^Onine(state_in[15:8])^oE(state_in[7:0]);
end
endfunction


function [7:0] multiplication;
input [7:0] x;
input [7:0] y;
begin
case(y)
8'h01:multiplication=x;

8'h02:multiplication=(x[7]==0)?x<<1:(x<<1)^8'h1B;

8'h03:multiplication=(x[7]==0)?(x<<1)^x:((x<<1)^8'h1B)^x;

//default 
endcase
end
endfunction


function [7:0] Onine;
input [7:0] x;

reg [7:0] result,result2,sum;
begin

result = multiplication(x,8'h02);
result2=multiplication(result,8'h02);


result = multiplication(result2,8'h02);
Onine=result^x;
end
endfunction

function [7:0] oB;
input [7:0] x;
begin
oB=Onine(x)^multiplication(x,8'h02);
end
endfunction

function [7:0] oD;
input [7:0] x;
reg [7:0] sum,res;
begin

res=multiplication(x,8'h02);
sum=multiplication(res,8'h02);
oD=Onine(x)^sum;
end

endfunction

function [7:0] oE;
input [7:0] x;
reg [7:0] sum,res;
begin

res=multiplication(x,8'h02);
//sum=Mu(res,8'h02);
oE=Onine(x)^multiplication(res,8'h02)^x^multiplication(x,8'h02);
end

endfunction


function [127:0] InvSubBytes;
    input [127:0] state_isb_in;

reg [127:0] state_isb_out_reg;
reg [127:0] state_isb_out_next;
begin
        state_isb_out_next = state_isb_in;       
        state_isb_out_next[7:0] = inv_sbox(state_isb_out_next[7:0]);      //0
        state_isb_out_next[15:8] = inv_sbox(state_isb_out_next[15:8]);    //1
        state_isb_out_next[23:16] = inv_sbox(state_isb_out_next[23:16]);  //2
        state_isb_out_next[31:24] = inv_sbox(state_isb_out_next[31:24]);  //3
        state_isb_out_next[39:32] = inv_sbox(state_isb_out_next[39:32]);  //4
        state_isb_out_next[47:40] = inv_sbox(state_isb_out_next[47:40]);  //5
        state_isb_out_next[55:48] = inv_sbox(state_isb_out_next[55:48]);  //6
        state_isb_out_next[63:56] = inv_sbox(state_isb_out_next[63:56]);  //7
        state_isb_out_next[71:64] = inv_sbox(state_isb_out_next[71:64]);  //8
        state_isb_out_next[79:72] = inv_sbox(state_isb_out_next[79:72]);  //9
        state_isb_out_next[87:80] = inv_sbox(state_isb_out_next[87:80]);  //10
        state_isb_out_next[95:88] = inv_sbox(state_isb_out_next[95:88]);  //11
        state_isb_out_next[103:96] = inv_sbox(state_isb_out_next[103:96]);    //12
        state_isb_out_next[111:104] = inv_sbox(state_isb_out_next[111:104]);  //13
        state_isb_out_next[119:112] = inv_sbox(state_isb_out_next[119:112]);  //14
        state_isb_out_next[127:120] = inv_sbox(state_isb_out_next[127:120]);  //15
   
     InvSubBytes = state_isb_out_next;
   end
	endfunction
function [7:0] inv_sbox;
    input[7:0] address;

    //This function implements the "s-box", it takes in one byte
    //and returns this corresponding substituted byte
    begin
      case (address)
        8'h0 : inv_sbox = 8'h52;
        8'h1 : inv_sbox = 8'h09;
        8'h2 : inv_sbox = 8'h6A;
        8'h3 : inv_sbox = 8'hD5;
        8'h4 : inv_sbox = 8'h30;
        8'h5 : inv_sbox = 8'h36;
        8'h6 : inv_sbox = 8'hA5;
        8'h7 : inv_sbox = 8'h38;
        8'h8 : inv_sbox = 8'hBF;
        8'h9 : inv_sbox = 8'h40;
        8'hA : inv_sbox = 8'hA3;
        8'hB : inv_sbox = 8'h9E;
        8'hC : inv_sbox = 8'h81;
        8'hD : inv_sbox = 8'hF3;
        8'hE : inv_sbox = 8'hD7;
        8'hF : inv_sbox = 8'hFB;
        8'h10 : inv_sbox = 8'h7C;
        8'h11 : inv_sbox = 8'hE3;
        8'h12 : inv_sbox = 8'h39;
        8'h13 : inv_sbox = 8'h82;
        8'h14 : inv_sbox = 8'h9B;
        8'h15 : inv_sbox = 8'h2F;
        8'h16 : inv_sbox = 8'hFF;
        8'h17 : inv_sbox = 8'h87;
        8'h18 : inv_sbox = 8'h34;
        8'h19 : inv_sbox = 8'h8E;
        8'h1A : inv_sbox = 8'h43;
        8'h1B : inv_sbox = 8'h44;
        8'h1C : inv_sbox = 8'hC4;
        8'h1D : inv_sbox = 8'hDE;
        8'h1E : inv_sbox = 8'hE9;
        8'h1F : inv_sbox = 8'hCB;
        8'h20 : inv_sbox = 8'h54;
        8'h21 : inv_sbox = 8'h7B;
        8'h22 : inv_sbox = 8'h94;
        8'h23 : inv_sbox = 8'h32;
        8'h24 : inv_sbox = 8'hA6;
        8'h25 : inv_sbox = 8'hC2;
        8'h26 : inv_sbox = 8'h23;
        8'h27 : inv_sbox = 8'h3D;
        8'h28 : inv_sbox = 8'hEE;
        8'h29 : inv_sbox = 8'h4C;
        8'h2A : inv_sbox = 8'h95;
        8'h2B : inv_sbox = 8'h0B;
        8'h2C : inv_sbox = 8'h42;
        8'h2D : inv_sbox = 8'hFA;
        8'h2E : inv_sbox = 8'hC3;
        8'h2F : inv_sbox = 8'h4E;
        8'h30 : inv_sbox = 8'h08;
        8'h31 : inv_sbox = 8'h2E;
        8'h32 : inv_sbox = 8'hA1;
        8'h33 : inv_sbox = 8'h66;
        8'h34 : inv_sbox = 8'h28;
        8'h35 : inv_sbox = 8'hD9;
        8'h36 : inv_sbox = 8'h24;
        8'h37 : inv_sbox = 8'hB2;
        8'h38 : inv_sbox = 8'h76;
        8'h39 : inv_sbox = 8'h5B;
        8'h3A : inv_sbox = 8'hA2;
        8'h3B : inv_sbox = 8'h49;
        8'h3C : inv_sbox = 8'h6D;
        8'h3D : inv_sbox = 8'h8B;
        8'h3E : inv_sbox = 8'hD1;
        8'h3F : inv_sbox = 8'h25;
        8'h40 : inv_sbox = 8'h72;
        8'h41 : inv_sbox = 8'hF8;
        8'h42 : inv_sbox = 8'hF6;
        8'h43 : inv_sbox = 8'h64;
        8'h44 : inv_sbox = 8'h86;
        8'h45 : inv_sbox = 8'h68;
        8'h46 : inv_sbox = 8'h98;
        8'h47 : inv_sbox = 8'h16;
        8'h48 : inv_sbox = 8'hD4;
        8'h49 : inv_sbox = 8'hA4;
        8'h4A : inv_sbox = 8'h5C;
        8'h4B : inv_sbox = 8'hCC;
        8'h4C : inv_sbox = 8'h5D;
        8'h4D : inv_sbox = 8'h65;
        8'h4E : inv_sbox = 8'hB6;
        8'h4F : inv_sbox = 8'h92;
        8'h50 : inv_sbox = 8'h6C;
        8'h51 : inv_sbox = 8'h70;
        8'h52 : inv_sbox = 8'h48;
        8'h53 : inv_sbox = 8'h50;
        8'h54 : inv_sbox = 8'hFD;
        8'h55 : inv_sbox = 8'hED;
        8'h56 : inv_sbox = 8'hB9;
        8'h57 : inv_sbox = 8'hDA;
        8'h58 : inv_sbox = 8'h5E;
        8'h59 : inv_sbox = 8'h15;
        8'h5A : inv_sbox = 8'h46;
        8'h5B : inv_sbox = 8'h57;
        8'h5C : inv_sbox = 8'hA7;
        8'h5D : inv_sbox = 8'h8D;
        8'h5E : inv_sbox = 8'h9D;
        8'h5F : inv_sbox = 8'h84;
        8'h60 : inv_sbox = 8'h90;
        8'h61 : inv_sbox = 8'hD8;
        8'h62 : inv_sbox = 8'hAB;
        8'h63 : inv_sbox = 8'h00;
        8'h64 : inv_sbox = 8'h8C;
        8'h65 : inv_sbox = 8'hBC;
        8'h66 : inv_sbox = 8'hD3;
        8'h67 : inv_sbox = 8'h0A;
        8'h68 : inv_sbox = 8'hF7;
        8'h69 : inv_sbox = 8'hE4;
        8'h6A : inv_sbox = 8'h58;
        8'h6B : inv_sbox = 8'h05;
        8'h6C : inv_sbox = 8'hB8;
        8'h6D : inv_sbox = 8'hB3;
        8'h6E : inv_sbox = 8'h45;
        8'h6F : inv_sbox = 8'h06;
        8'h70 : inv_sbox = 8'hD0;
        8'h71 : inv_sbox = 8'h2C;
        8'h72 : inv_sbox = 8'h1E;
        8'h73 : inv_sbox = 8'h8F;
        8'h74 : inv_sbox = 8'hCA;
        8'h75 : inv_sbox = 8'h3F;
        8'h76 : inv_sbox = 8'h0F;
        8'h77 : inv_sbox = 8'h02;
        8'h78 : inv_sbox = 8'hC1;
        8'h79 : inv_sbox = 8'hAF;
        8'h7A : inv_sbox = 8'hBD;
        8'h7B : inv_sbox = 8'h03;
        8'h7C : inv_sbox = 8'h01;
        8'h7D : inv_sbox = 8'h13;
        8'h7E : inv_sbox = 8'h8A;
        8'h7F : inv_sbox = 8'h6B;
        8'h80 : inv_sbox = 8'h3A;
        8'h81 : inv_sbox = 8'h91;
        8'h82 : inv_sbox = 8'h11;
        8'h83 : inv_sbox = 8'h41;
        8'h84 : inv_sbox = 8'h4F;
        8'h85 : inv_sbox = 8'h67;
        8'h86 : inv_sbox = 8'hDC;
        8'h87 : inv_sbox = 8'hEA;
        8'h88 : inv_sbox = 8'h97;
        8'h89 : inv_sbox = 8'hF2;
        8'h8A : inv_sbox = 8'hCF;
        8'h8B : inv_sbox = 8'hCE;
        8'h8C : inv_sbox = 8'hF0;
        8'h8D : inv_sbox = 8'hB4;
        8'h8E : inv_sbox = 8'hE6;
        8'h8F : inv_sbox = 8'h73;
        8'h90 : inv_sbox = 8'h96;
        8'h91 : inv_sbox = 8'hAC;
        8'h92 : inv_sbox = 8'h74;
        8'h93 : inv_sbox = 8'h22;
        8'h94 : inv_sbox = 8'hE7;
        8'h95 : inv_sbox = 8'hAD;
        8'h96 : inv_sbox = 8'h35;
        8'h97 : inv_sbox = 8'h85;
        8'h98 : inv_sbox = 8'hE2;
        8'h99 : inv_sbox = 8'hF9;
        8'h9A : inv_sbox = 8'h37;
        8'h9B : inv_sbox = 8'hE8;
        8'h9C : inv_sbox = 8'h1C;
        8'h9D : inv_sbox = 8'h75;
        8'h9E : inv_sbox = 8'hDF;
        8'h9F : inv_sbox = 8'h6E;
        8'hA0 : inv_sbox = 8'h47;
        8'hA1 : inv_sbox = 8'hF1;
        8'hA2 : inv_sbox = 8'h1A;
        8'hA3 : inv_sbox = 8'h71;
        8'hA4 : inv_sbox = 8'h1D;
        8'hA5 : inv_sbox = 8'h29;
        8'hA6 : inv_sbox = 8'hC5;
        8'hA7 : inv_sbox = 8'h89;
        8'hA8 : inv_sbox = 8'h6F;
        8'hA9 : inv_sbox = 8'hB7;
        8'hAA : inv_sbox = 8'h62;
        8'hAB : inv_sbox = 8'h0E;
        8'hAC : inv_sbox = 8'hAA;
        8'hAD : inv_sbox = 8'h18;
        8'hAE : inv_sbox = 8'hBE;
        8'hAF : inv_sbox = 8'h1B;
        8'hB0 : inv_sbox = 8'hFC;
        8'hB1 : inv_sbox = 8'h56;
        8'hB2 : inv_sbox = 8'h3E;
        8'hB3 : inv_sbox = 8'h4B;
        8'hB4 : inv_sbox = 8'hC6;
        8'hB5 : inv_sbox = 8'hD2;
        8'hB6 : inv_sbox = 8'h79;
        8'hB7 : inv_sbox = 8'h20;
        8'hB8 : inv_sbox = 8'h9A;
        8'hB9 : inv_sbox = 8'hDB;
        8'hBA : inv_sbox = 8'hC0;
        8'hBB : inv_sbox = 8'hFE;
        8'hBC : inv_sbox = 8'h78;
        8'hBD : inv_sbox = 8'hCD;
        8'hBE : inv_sbox = 8'h5A;
        8'hBF : inv_sbox = 8'hF4;
        8'hC0 : inv_sbox = 8'h1F;
        8'hC1 : inv_sbox = 8'hDD;
        8'hC2 : inv_sbox = 8'hA8;
        8'hC3 : inv_sbox = 8'h33;
        8'hC4 : inv_sbox = 8'h88;
        8'hC5 : inv_sbox = 8'h07;
        8'hC6 : inv_sbox = 8'hC7;
        8'hC7 : inv_sbox = 8'h31;
        8'hC8 : inv_sbox = 8'hB1;
        8'hC9 : inv_sbox = 8'h12;
        8'hCA : inv_sbox = 8'h10;
        8'hCB : inv_sbox = 8'h59;
        8'hCC : inv_sbox = 8'h27;
        8'hCD : inv_sbox = 8'h80;
        8'hCE : inv_sbox = 8'hEC;
        8'hCF : inv_sbox = 8'h5F;
        8'hD0 : inv_sbox = 8'h60;
        8'hD1 : inv_sbox = 8'h51;
        8'hD2 : inv_sbox = 8'h7F;
        8'hD3 : inv_sbox = 8'hA9;
        8'hD4 : inv_sbox = 8'h19;
        8'hD5 : inv_sbox = 8'hB5;
        8'hD6 : inv_sbox = 8'h4A;
        8'hD7 : inv_sbox = 8'h0D;
        8'hD8 : inv_sbox = 8'h2D;
        8'hD9 : inv_sbox = 8'hE5;
        8'hDA : inv_sbox = 8'h7A;
        8'hDB : inv_sbox = 8'h9F;
        8'hDC : inv_sbox = 8'h93;
        8'hDD : inv_sbox = 8'hC9;
        8'hDE : inv_sbox = 8'h9C;
        8'hDF : inv_sbox = 8'hEF;
        8'hE0 : inv_sbox = 8'hA0;
        8'hE1 : inv_sbox = 8'hE0;
        8'hE2 : inv_sbox = 8'h3B;
        8'hE3 : inv_sbox = 8'h4D;
        8'hE4 : inv_sbox = 8'hAE;
        8'hE5 : inv_sbox = 8'h2A;
        8'hE6 : inv_sbox = 8'hF5;
        8'hE7 : inv_sbox = 8'hB0;
        8'hE8 : inv_sbox = 8'hC8;
        8'hE9 : inv_sbox = 8'hEB;
        8'hEA : inv_sbox = 8'hBB;
        8'hEB : inv_sbox = 8'h3C;
        8'hEC : inv_sbox = 8'h83;
        8'hED : inv_sbox = 8'h53;
        8'hEE : inv_sbox = 8'h99;
        8'hEF : inv_sbox = 8'h61;
        8'hF0 : inv_sbox = 8'h17;
        8'hF1 : inv_sbox = 8'h2B;
        8'hF2 : inv_sbox = 8'h04;
        8'hF3 : inv_sbox = 8'h7E;
        8'hF4 : inv_sbox = 8'hBA;
        8'hF5 : inv_sbox = 8'h77;
        8'hF6 : inv_sbox = 8'hD6;
        8'hF7 : inv_sbox = 8'h26;
        8'hF8 : inv_sbox = 8'hE1;
        8'hF9 : inv_sbox = 8'h69;
        8'hFA : inv_sbox = 8'h14;
        8'hFB : inv_sbox = 8'h63;
        8'hFC : inv_sbox = 8'h55;
        8'hFD : inv_sbox = 8'h21;
        8'hFE : inv_sbox = 8'h0C;
        8'hFF : inv_sbox = 8'h7D;
        default : inv_sbox = 8'h0;
      endcase
    end
endfunction

function [127:0] Invyarab128;
input reg [127:0] in;
reg [127:0] temp;
input integer j;
integer i;
integer stop;
begin
stop=(j+2)*4;
temp=in;
    temp[127:96]=subbytes(RotWord(in[31:0]))^Rcon(1'd1)^in[127:96];  
  	 temp[95:64]=temp[127:96]^in[95:64];
  		temp[63:32]=temp[95:64]^in[63:32];
  		temp[31:0]=temp[63:32]^in[31:0];
	for ( i =8 ;i<stop ; i=i+4)  begin :askjjfn
	   temp[127:96]=subbytes(RotWord(temp[31:0]))^Rcon(i/4)^temp[127:96];  
	  temp[95:64]=temp[127:96]^temp[95:64];
	  temp[63:32]=temp[95:64]^temp[63:32];
	  temp[31:0]=temp[63:32]^temp[31:0];
	end
	Invyarab128=temp;
	end
endfunction
function [31:0] RotWord;
  input [31:0] x;
  begin
     RotWord={x[23:0],x[31:24]};


  end
endfunction
function [127:0]addRoundKey;
	input reg [127:0] k1;
	input reg [127:0] k2;
	addRoundKey[127:0]=k1[127:0]^k2[127:0];
endfunction

function [31:0] Rcon;
  input [3:0] i;
  begin
    case(i)
      1: Rcon=32'h01000000;
      2: Rcon=32'h02000000;
      3: Rcon=32'h04000000;
      4: Rcon=32'h08000000;
      5: Rcon=32'h10000000;
      6: Rcon=32'h20000000;
      7: Rcon=32'h40000000;
      8: Rcon=32'h80000000;
      9: Rcon=32'h1b000000;
      10: Rcon=32'h36000000;
  endcase
  end 
endfunction
function [7:0]c;
input[7:0] a;
    case (a)
      8'h00: c=8'h63;
	   8'h01: c=8'h7c;
	   8'h02: c=8'h77;
	   8'h03: c=8'h7b;
	   8'h04: c=8'hf2;
	   8'h05: c=8'h6b;
	   8'h06: c=8'h6f;
	   8'h07: c=8'hc5;
	   8'h08: c=8'h30;
	   8'h09: c=8'h01;
	   8'h0a: c=8'h67;
	   8'h0b: c=8'h2b;
	   8'h0c: c=8'hfe;
	   8'h0d: c=8'hd7;
	   8'h0e: c=8'hab;
	   8'h0f: c=8'h76;
	   8'h10: c=8'hca;
	   8'h11: c=8'h82;
	   8'h12: c=8'hc9;
	   8'h13: c=8'h7d;
	   8'h14: c=8'hfa;
	   8'h15: c=8'h59;
	   8'h16: c=8'h47;
	   8'h17: c=8'hf0;
	   8'h18: c=8'had;
	   8'h19: c=8'hd4;
	   8'h1a: c=8'ha2;
	   8'h1b: c=8'haf;
	   8'h1c: c=8'h9c;
	   8'h1d: c=8'ha4;
	   8'h1e: c=8'h72;
	   8'h1f: c=8'hc0;
	   8'h20: c=8'hb7;
	   8'h21: c=8'hfd;
	   8'h22: c=8'h93;
	   8'h23: c=8'h26;
	   8'h24: c=8'h36;
	   8'h25: c=8'h3f;
	   8'h26: c=8'hf7;
	   8'h27: c=8'hcc;
	   8'h28: c=8'h34;
	   8'h29: c=8'ha5;
	   8'h2a: c=8'he5;
	   8'h2b: c=8'hf1;
	   8'h2c: c=8'h71;
	   8'h2d: c=8'hd8;
	   8'h2e: c=8'h31;
	   8'h2f: c=8'h15;
	   8'h30: c=8'h04;
	   8'h31: c=8'hc7;
	   8'h32: c=8'h23;
	   8'h33: c=8'hc3;
	   8'h34: c=8'h18;
	   8'h35: c=8'h96;
	   8'h36: c=8'h05;
	   8'h37: c=8'h9a;
	   8'h38: c=8'h07;
	   8'h39: c=8'h12;
	   8'h3a: c=8'h80;
	   8'h3b: c=8'he2;
	   8'h3c: c=8'heb;
	   8'h3d: c=8'h27;
	   8'h3e: c=8'hb2;
	   8'h3f: c=8'h75;
	   8'h40: c=8'h09;
	   8'h41: c=8'h83;
	   8'h42: c=8'h2c;
	   8'h43: c=8'h1a;
	   8'h44: c=8'h1b;
	   8'h45: c=8'h6e;
	   8'h46: c=8'h5a;
	   8'h47: c=8'ha0;
	   8'h48: c=8'h52;
	   8'h49: c=8'h3b;
	   8'h4a: c=8'hd6;
	   8'h4b: c=8'hb3;
	   8'h4c: c=8'h29;
	   8'h4d: c=8'he3;
	   8'h4e: c=8'h2f;
	   8'h4f: c=8'h84;
	   8'h50: c=8'h53;
	   8'h51: c=8'hd1;
	   8'h52: c=8'h00;
	   8'h53: c=8'hed;
	   8'h54: c=8'h20;
	   8'h55: c=8'hfc;
	   8'h56: c=8'hb1;
	   8'h57: c=8'h5b;
	   8'h58: c=8'h6a;
	   8'h59: c=8'hcb;
	   8'h5a: c=8'hbe;
	   8'h5b: c=8'h39;
	   8'h5c: c=8'h4a;
	   8'h5d: c=8'h4c;
	   8'h5e: c=8'h58;
	   8'h5f: c=8'hcf;
	   8'h60: c=8'hd0;
	   8'h61: c=8'hef;
	   8'h62: c=8'haa;
	   8'h63: c=8'hfb;
	   8'h64: c=8'h43;
	   8'h65: c=8'h4d;
	   8'h66: c=8'h33;
	   8'h67: c=8'h85;
	   8'h68: c=8'h45;
	   8'h69: c=8'hf9;
	   8'h6a: c=8'h02;
	   8'h6b: c=8'h7f;
	   8'h6c: c=8'h50;
	   8'h6d: c=8'h3c;
	   8'h6e: c=8'h9f;
	   8'h6f: c=8'ha8;
	   8'h70: c=8'h51;
	   8'h71: c=8'ha3;
	   8'h72: c=8'h40;
	   8'h73: c=8'h8f;
	   8'h74: c=8'h92;
	   8'h75: c=8'h9d;
	   8'h76: c=8'h38;
	   8'h77: c=8'hf5;
	   8'h78: c=8'hbc;
	   8'h79: c=8'hb6;
	   8'h7a: c=8'hda;
	   8'h7b: c=8'h21;
	   8'h7c: c=8'h10;
	   8'h7d: c=8'hff;
	   8'h7e: c=8'hf3;
	   8'h7f: c=8'hd2;
	   8'h80: c=8'hcd;
	   8'h81: c=8'h0c;
	   8'h82: c=8'h13;
	   8'h83: c=8'hec;
	   8'h84: c=8'h5f;
	   8'h85: c=8'h97;
	   8'h86: c=8'h44;
	   8'h87: c=8'h17;
	   8'h88: c=8'hc4;
	   8'h89: c=8'ha7;
	   8'h8a: c=8'h7e;
	   8'h8b: c=8'h3d;
	   8'h8c: c=8'h64;
	   8'h8d: c=8'h5d;
	   8'h8e: c=8'h19;
	   8'h8f: c=8'h73;
	   8'h90: c=8'h60;
	   8'h91: c=8'h81;
	   8'h92: c=8'h4f;
	   8'h93: c=8'hdc;
	   8'h94: c=8'h22;
	   8'h95: c=8'h2a;
	   8'h96: c=8'h90;
	   8'h97: c=8'h88;
	   8'h98: c=8'h46;
	   8'h99: c=8'hee;
	   8'h9a: c=8'hb8;
	   8'h9b: c=8'h14;
	   8'h9c: c=8'hde;
	   8'h9d: c=8'h5e;
	   8'h9e: c=8'h0b;
	   8'h9f: c=8'hdb;
	   8'ha0: c=8'he0;
	   8'ha1: c=8'h32;
	   8'ha2: c=8'h3a;
	   8'ha3: c=8'h0a;
	   8'ha4: c=8'h49;
	   8'ha5: c=8'h06;
	   8'ha6: c=8'h24;
	   8'ha7: c=8'h5c;
	   8'ha8: c=8'hc2;
	   8'ha9: c=8'hd3;
	   8'haa: c=8'hac;
	   8'hab: c=8'h62;
	   8'hac: c=8'h91;
	   8'had: c=8'h95;
	   8'hae: c=8'he4;
	   8'haf: c=8'h79;
	   8'hb0: c=8'he7;
	   8'hb1: c=8'hc8;
	   8'hb2: c=8'h37;
	   8'hb3: c=8'h6d;
	   8'hb4: c=8'h8d;
	   8'hb5: c=8'hd5;
	   8'hb6: c=8'h4e;
	   8'hb7: c=8'ha9;
	   8'hb8: c=8'h6c;
	   8'hb9: c=8'h56;
	   8'hba: c=8'hf4;
	   8'hbb: c=8'hea;
	   8'hbc: c=8'h65;
	   8'hbd: c=8'h7a;
	   8'hbe: c=8'hae;
	   8'hbf: c=8'h08;
	   8'hc0: c=8'hba;
	   8'hc1: c=8'h78;
	   8'hc2: c=8'h25;
	   8'hc3: c=8'h2e;
	   8'hc4: c=8'h1c;
	   8'hc5: c=8'ha6;
	   8'hc6: c=8'hb4;
	   8'hc7: c=8'hc6;
	   8'hc8: c=8'he8;
	   8'hc9: c=8'hdd;
	   8'hca: c=8'h74;
	   8'hcb: c=8'h1f;
	   8'hcc: c=8'h4b;
	   8'hcd: c=8'hbd;
	   8'hce: c=8'h8b;
	   8'hcf: c=8'h8a;
	   8'hd0: c=8'h70;
	   8'hd1: c=8'h3e;
	   8'hd2: c=8'hb5;
	   8'hd3: c=8'h66;
	   8'hd4: c=8'h48;
	   8'hd5: c=8'h03;
	   8'hd6: c=8'hf6;
	   8'hd7: c=8'h0e;
	   8'hd8: c=8'h61;
	   8'hd9: c=8'h35;
	   8'hda: c=8'h57;
	   8'hdb: c=8'hb9;
	   8'hdc: c=8'h86;
	   8'hdd: c=8'hc1;
	   8'hde: c=8'h1d;
	   8'hdf: c=8'h9e;
	   8'he0: c=8'he1;
	   8'he1: c=8'hf8;
	   8'he2: c=8'h98;
	   8'he3: c=8'h11;
	   8'he4: c=8'h69;
	   8'he5: c=8'hd9;
	   8'he6: c=8'h8e;
	   8'he7: c=8'h94;
	   8'he8: c=8'h9b;
	   8'he9: c=8'h1e;
	   8'hea: c=8'h87;
	   8'heb: c=8'he9;
	   8'hec: c=8'hce;
	   8'hed: c=8'h55;
	   8'hee: c=8'h28;
	   8'hef: c=8'hdf;
	   8'hf0: c=8'h8c;
	   8'hf1: c=8'ha1;
	   8'hf2: c=8'h89;
	   8'hf3: c=8'h0d;
	   8'hf4: c=8'hbf;
	   8'hf5: c=8'he6;
	   8'hf6: c=8'h42;
	   8'hf7: c=8'h68;
	   8'hf8: c=8'h41;
	   8'hf9: c=8'h99;
	   8'hfa: c=8'h2d;
	   8'hfb: c=8'h0f;
	   8'hfc: c=8'hb0;
	   8'hfd: c=8'h54;
	   8'hfe: c=8'hbb;
	   8'hff: c=8'h16;
		default:c=8'h0;
	endcase
endfunction
function [31:0] subbytes;
  input [31:0] x;
  begin
    
     subbytes[7:0]=c(x[7:0]);
     subbytes[15:8]=c(x[15:8]);
     subbytes[23:16]=c(x[23:16]);
     subbytes[31:24]=c(x[31:24]);

  end
  
endfunction

endmodule
