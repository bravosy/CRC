// 2016/2/13
// lsy
// serial crc8.

module CrcSerial(
		input				clk,
		input				rst_n,
		input				din,
		input				din_vld,
		input				clr,
		output	reg [7:0]	dout,
		output 	reg			dout_vld
);

//buffer input
reg data;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		data <= 1'b0;
	else if(clr == 1'b1)
		data <= 1'b0;
	else if(din_vld == 1'b1)
		data <= din;
	else
		data <= 1'b0;
end

//g(x) = x^8 + x^2 + x^1 + 1	100000111
reg [7:0] lsfr;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		lsfr <= 7'b0;
	else if(clr == 1'b1)
		lsfr <= 7'b0;
	else 
		begin
			lsfr[0] <= data  	^ lsfr[7];
			lsfr[1] <= lsfr[0]	^ lsfr[7] ^ data;
			lsfr[2] <= lsfr[1]	^ lsfr[7] ^ data;
			lsfr[3] <= lsfr[2];
			lsfr[4] <= lsfr[3];
			lsfr[5] <= lsfr[4];
			lsfr[6] <= lsfr[5];
			lsfr[7] <= lsfr[6];
		end
end

reg [1:0] state_pr, state_nx;
reg [4:0] cnt;
parameter IDLE = 2'b00, WORK = 2'b01, OUTPUT = 2'b11;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		state_pr <= IDLE;
	else
		state_pr <= state_nx;
end

always@(*)begin
	if(!rst_n)
		state_nx <= IDLE;
	else
		case(state_pr)
			IDLE:
				if(din_vld == 1'b1)
					state_nx = WORK;
				else
					state_nx = IDLE;
			WORK:
				if(cnt == 15)	// 
					state_nx = OUTPUT;
				else
					state_nx = WORK;
			OUTPUT:
				state_nx = IDLE;
		endcase
end

// 8 din + 8 padded 0 + 1delay = 17
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		cnt <= 0;
	else if(clr == 1'b1)
		cnt <= 0;
	else if(state_pr == WORK)
		cnt <= cnt + 1;
	else
		cnt <= 0;
end

always@(*) dout_vld = (state_pr == OUTPUT)? 1'b1 : 1'b0;
always@(*) dout 	= (state_pr == OUTPUT)? lsfr : 8'd0;
endmodule