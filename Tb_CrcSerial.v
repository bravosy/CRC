`timescale 1ns/1ns
module Tb;

reg clk, rst_n, din, din_vld, clr;
wire [7:0] dout;
wire dout_vld;

parameter PERIOD = 10;

CrcSerial uut(
			.clk(clk),
			.rst_n(rst_n),
			.din(din),
			.din_vld(din_vld),
			.clr(clr),
			.dout(dout),
			.dout_vld(dout_vld)
);

initial begin
	rst_n 	= 0;
	clk   	= 0;
	din   	= 0;
	din_vld = 0;
	clr 	= 0;
	#(20 * PERIOD);
	rst_n	= 1;
end

always #(PERIOD/2) clk = ~clk;

reg [3:0] cnt;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt <= 4'd0;
	else if(cnt == 4'd15)
		cnt <= cnt;
	else
		cnt <= cnt + 1;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		din_vld <= 1'b0;
	else if( cnt >= 4 && cnt <= 11)
		din_vld <= 1'b1;
	else
		din_vld <= 1'b0;
end

reg [15:0] ram = 15'b0000_1010_1011_0000;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		din <= 1'b0;
	else
		din <= ram[15 - cnt];
end
endmodule 