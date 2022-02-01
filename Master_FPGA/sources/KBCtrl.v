`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/05 23:25:08
// Design Name: 
// Module Name: KBCtrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module KBCtrl(direction, key_push, music_start, wasd, PS2_DATA, PS2_CLK, reset, clk, mode);
inout wire PS2_DATA;
inout wire PS2_CLK;
input wire reset;
input wire clk;
input mode;
output reg [3:0] direction;
output key_push;
output [3:0] wasd;
output music_start;

wire [511:0] key_down;
wire [8:0] last_change;
wire been_ready;

parameter [8:0] KEY_CODES [0:7] = {
		9'b0_0001_1101,	// up => 1D
		9'b0_0001_1011,	// down => 1B
		9'b0_0001_1100,	// left => 1C
		9'b0_0010_0011,    	// right => 23
		9'b0_0011_0011,  //H  dir = 0000
		9'b0_0011_1011,  //J   dir = 0011
		9'b0_0100_0010,  //K  dir = 0111
		9'b0_0100_1011   //L  dir = 1100
	};
/*
              9'b1_0111_0101,	// up => E075
		9'b1_0111_0010,	// down => E072
		9'b1_0110_1011,	// left => E06B
		9'b1_0111_0100	// right => E074
*/
KBDecoder key_de (
		.key_down(key_down),
		.last_change(last_change),
		.key_valid(been_ready),
		.PS2_DATA(PS2_DATA),
		.PS2_CLK(PS2_CLK),
		.rst(reset),
		.clk(clk)
	    );

wire up_key, dn_key, lf_key, rt_key;
wire H_key, J_key, K_key, L_key;

assign up_key = key_down[KEY_CODES[0]];
assign dn_key = key_down[KEY_CODES[1]];
assign lf_key = key_down[KEY_CODES[2]];
assign rt_key = key_down[KEY_CODES[3]];
assign H_key = key_down[KEY_CODES[4]];
assign J_key = key_down[KEY_CODES[5]];
assign K_key = key_down[KEY_CODES[6]];
assign L_key = key_down[KEY_CODES[7]];

assign key_push = (mode==1'b1)?(up_key | dn_key | lf_key | rt_key | H_key | J_key | K_key):(up_key | dn_key | lf_key | rt_key);
assign wasd = {up_key, dn_key, lf_key, rt_key};
assign music_start = L_key;

always@(*) begin
    if(H_key | J_key | K_key | L_key != 1'b0) begin
        if(H_key!=1'b0) begin
            direction = 4'b0000;
        end
        else begin
            if(J_key!=1'b0) begin
                direction = 4'b0011;
            end
            else begin
                if(K_key!=1'b0) begin
                    direction = 4'b0111;
                end
                else begin
                    direction = 4'b1100;
                end
            end
        end
    end
    else begin
        case({up_key, dn_key, lf_key, rt_key})
            4'b1000: direction = 4'b1000;
            4'b0100: direction = 4'b0100;
            4'b0010: direction = 4'b0010;
            4'b0001: direction = 4'b0001;
            4'b1010: direction = 4'b1010;
            4'b1001: direction = 4'b1001;
            4'b0110: direction = 4'b0110;
            4'b0101: direction = 4'b0101;
            default: direction = 4'b1111;
        endcase
    end
end

endmodule
