`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/26 10:24:56
// Design Name: 
// Module Name: UART_Master
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

module debounce(db, clk, in);
input clk, in;
output db;
reg [3:0]DFF;

always@(posedge clk) begin
    DFF[3:1] <= DFF[2:0];
    DFF[0] <= in;

end
assign db = &DFF;
endmodule

module one_pulse(op, clk, in);
input clk, in;
output reg op;
reg delay;

always@(posedge clk) begin
    delay <= in;
    op <= (!delay)&in;
end

endmodule

module clk_divider#(parameter N = 5, parameter MAX = 20)(dclk, clk, reset);
input clk, reset;
output reg dclk;

reg next_dclk;
reg [N-1:0] counter;
reg [N-1:0] next_counter;

always@(posedge clk) begin
    if(reset==1'b1) begin
        counter <= 0;
        dclk <= 1'b1;
    end
    else begin
        counter <= next_counter;
        dclk <= next_dclk;
    end
end

always@(*) begin
    if(counter==MAX-1) begin
        next_dclk = 1'b1;
        next_counter = 0;         
    end
    else begin
        next_dclk = 1'b0;
        next_counter = counter + 1;
    end
end

endmodule

module check_btn_push(clk, reset, btn_push, direction, up_btn, dn_btn, lf_btn, rt_btn);
input clk, reset;
input up_btn, dn_btn, lf_btn, rt_btn;
output btn_push;
output reg [3:0] direction;//UP = 1000, DN = 0100, LF = 0010, RT = 0001

assign btn_push = up_btn|dn_btn|lf_btn|rt_btn;

always@(*) begin
    case({up_btn, dn_btn, lf_btn, rt_btn})
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

endmodule

module Instruction_Encoder(out, is_music, in);
input [3:0] in;
output reg [7:0] out;
output is_music;
// 11010 Wave
// 11001 Circle
// 10000 PUIPUI

always@(*) begin
    if(in==4'b1111) begin
        out = 8'b11111111;
    end
    else begin
        if(in==4'b1000) out = {4'b0000,in};
        else if(in==4'b1001) out = {4'b0000,in};
        else if(in==4'b0001) out = {4'b0000,in};
        else if(in==4'b0101) out = {4'b0000,in};
        else if(in==4'b0100) out = {4'b0000,in};
        else if(in==4'b0110) out = {4'b0000,in};
        else if(in==4'b0010) out = {4'b0000,in};
        else if(in==4'b1010) out = {4'b0000,in};
        else if(in==4'b0000) out = 8'b00011010;
        else if(in==4'b0011) out = 8'b00011001;
        else if(in==4'b0111) out = 8'b00010000;
        else out = 8'b11111111;
    end
end

endmodule

module UART_Master(clk, UART_RX, UART_TX, PS2_DATA, PS2_CLK, an, seg, reset,
mode, vgaRed, vgaGreen, vgaBlue, hsync, vsync, pmod_1, pmod_2, pmod_4);
inout wire PS2_DATA;
inout wire PS2_CLK;
input clk, UART_RX;
input reset;
input mode;
output UART_TX;
output [3:0] an;
output [6:0] seg;
output [3:0] vgaRed;
output [3:0] vgaGreen;
output [3:0] vgaBlue;
output hsync;
output vsync;
output pmod_1, pmod_2, pmod_4;

wire db_rst;
wire op_rst;

wire btn_push;
wire [3:0] direction;
wire [3:0] wasd;
wire [7:0] instruction;
wire is_music;
wire music_start, op_music_start;
wire UART_clk;

one_pulse op1(.op(op_rst),
              .clk(clk),
              .in(reset)
              );

KBCtrl kbc(.direction(direction), 
            .key_push(btn_push),
            .music_start(music_start), 
            .wasd(wasd),
            .PS2_DATA(PS2_DATA),
            .PS2_CLK(PS2_CLK),
            .reset(op_rst),
            .clk(clk),
            .mode(mode)
            );
            
Instruction_Encoder ie1(.out(instruction),
                        .is_music(is_music),
                        .in(direction)
                        );
                    
clk_divider #( .N(14), .MAX(10420)) cd1 (.dclk(UART_clk),
                                         .clk(clk),
                                         .reset(op_rst)
                                         );
                                         
seven_segment ssg(.instruction(instruction),
                   .an( an),
                   .seg(seg)
                   );
                   
UART_TXD master_tx(.clk(clk), 
                   .UART_clk(UART_clk),
                   .reset(op_rst), 
                   .instruction(instruction),
                   .btn_push(btn_push), 
                   .UART_TX(UART_TX)
                   );

VGA_display vgad(.clk(clk), 
                 .rst(op_rst), 
                 .direction(wasd), 
                 .mode(mode), 
                 .vgaRed(vgaRed),
                 .vgaGreen(vgaGreen), 
                 .vgaBlue(vgaBlue), 
                 .hsync(hsync), 
                 .vsync(vsync)
                 );

Music_ctrl mc(
    .clk(clk),
    .reset(op_rst),
    .start(music_start),
    .pmod_1(pmod_1),
    .pmod_2(pmod_2), 
    .pmod_4(pmod_4)
    );
    
endmodule

module UART_TXD(clk, UART_clk, reset, instruction, btn_push, UART_TX);
input clk, UART_clk, reset, btn_push;
input [7:0] instruction;
output reg UART_TX;

reg next_UART_TX;
reg [7:0] SND_DATA, next_SND_DATA;

parameter WAIT = 1'b0, SEND = 1'b1; 
parameter MAX_SND_SIZE = 4'b1000;

reg state, next_state;

reg [3:0] count_bit, next_count_bit;

always@(posedge clk) begin
    if(reset==1'b1) begin
        state <= WAIT;
        SND_DATA <= 8'd0;
        count_bit <= 4'd0;
        UART_TX <= 1'b1;
    end
    else begin
        state <= next_state;
        SND_DATA <= next_SND_DATA;
        count_bit <= next_count_bit;
        UART_TX <= next_UART_TX;
    end
end

always@(*) begin
    case(state) 
        WAIT: begin
            if(btn_push==1'b1) begin
                next_state = SEND;
                next_UART_TX = 1'b1;
                next_SND_DATA = instruction;
                next_count_bit = 4'd0;
            end
            else begin
                next_state = WAIT;
                next_UART_TX = 1'b1;
                next_SND_DATA = instruction;
                next_count_bit = 4'd0;
            end
        end
        
        SEND: begin
            if(count_bit==4'd0) begin
                next_state = SEND;
                if(UART_clk==1'b1) begin
                    next_UART_TX = 1'b0;//Start Bit
                    next_count_bit = count_bit + 4'd1;
                end
                else begin
                    next_UART_TX = UART_TX;
                    next_count_bit = count_bit;
                end
                next_SND_DATA = SND_DATA;
            end
            else if(count_bit>4'd0&&count_bit<=MAX_SND_SIZE) begin
                next_state = SEND;
                if(UART_clk==1'b1) begin
                    next_UART_TX = SND_DATA[MAX_SND_SIZE-count_bit];//7th Bit to 0th Bit
                    next_count_bit = count_bit + 4'd1;
                end
                else begin
                    next_UART_TX = UART_TX;
                    next_count_bit = count_bit;
                end
                next_SND_DATA = SND_DATA;
            end
            else if(count_bit==MAX_SND_SIZE+4'd1) begin
                next_state = SEND;
                if(UART_clk==1'b1) begin
                    next_UART_TX = 1'b1;//END Bit
                    next_count_bit = count_bit + 4'd1;
                end
                else begin
                    next_UART_TX = UART_TX;
                    next_count_bit = count_bit;
                end
                next_SND_DATA = SND_DATA;
            end
            else begin
                if(UART_clk==1'b1)begin
                    next_state = WAIT;
                    next_UART_TX = 1'b1;
                    next_SND_DATA = instruction;
                    next_count_bit = 4'd0;
                end
                else begin
                    next_state = SEND;
                    next_UART_TX = UART_TX;
                    next_SND_DATA = SND_DATA;
                    next_count_bit = count_bit;
                end
            end
        end
    endcase
end

endmodule

module seven_segment(instruction, an, seg);
input [7:0] instruction;
output reg [3:0] an;
output reg [6:0] seg;

parameter UP = 8'b00001000, DN = 8'b00000100, LF = 8'b00000010, RT = 8'b00000001; 
parameter UL = 8'b00001010, UR = 8'b00001001, DL = 8'b00000110, DR = 8'b00000101;
always@(*) begin
    case(instruction)
        UP: seg = 7'b1011100;
        DN: seg = 7'b1100011;
        LF: seg = 7'b1000110;
        RT: seg = 7'b1110000;
        UL:  seg = 7'b1011110;
        UR: seg = 7'b1111100;
        DL: seg = 7'b1100111;
        DR: seg = 7'b1110011;
        default: seg = 7'b0111111;
    endcase
    an = 4'b0000;
end 

endmodule