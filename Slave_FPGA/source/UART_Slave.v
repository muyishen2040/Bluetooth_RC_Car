`timescale 1ns / 1ps

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

module seven_segment(instruction, an, seg);
input [7:0] instruction;
output reg [3:0] an;
output reg [6:0] seg;

// Control state
parameter UP = 8'b00001000, DN = 8'b00000100, LF = 8'b00000010, RT = 8'b00000001; 
parameter UL = 8'b00001010, UR = 8'b00001001, DL = 8'b00000110, DR = 8'b00000101;
// Command state 
parameter WAVE = 8'b00011010, CIRCLE = 8'b00011001, PIUPIU = 8'b00010000, IDLE = 8'b00000000;

always@(*) begin
    case(instruction)
        // Command
        IDLE: seg = 7'b0100011;
        WAVE: seg = 7'b0000110;
        CIRCLE: seg = 7'b0011100;
        PIUPIU: seg = 7'b0001100;
        // Control
        UP: seg = 7'b1011100;
        DN: seg = 7'b1100011;
        LF: seg = 7'b1000110;
        RT: seg = 7'b1110000;
        UL: seg = 7'b1011110;
        UR: seg = 7'b1111100;
        DL: seg = 7'b1100111;
        DR: seg = 7'b1110011;
        default: seg = 7'b0111111;
    endcase
    an = 4'b0000;
end 

endmodule

module UART_Slave(clk, reset, turn_angle,  UART_RX, UART_TX, seg, an, motor, check_motor, check_duty, servo_pwm);
input clk, reset, UART_RX;
input [2:0] turn_angle;
output UART_TX;
output [3:0] an;
output [6:0] seg;
output [3:0] motor;
output [3:0] check_motor;
output [6:0] check_duty;
output servo_pwm;

wire [7:0] instruction;
wire [7:0] instruction_state;

wire db_rst, op_rst;
debounce db1(db_rst, clk, reset);
one_pulse op1(op_rst, clk, db_rst);

wire UART_clk;
clk_divider #(.N(10), .MAX(650)) cd1 (
    .dclk(UART_clk), 
    .clk(clk), 
    .reset(op_rst)
    );

//wire turn_clk;
//wire [1:0] hold_left_right;
//clk_divider #(.N(27), .MAX(100000000)) cd2 (turn_clk, clk, op_rst);

// module UART_RXD(clk, UART_clk, UART_RX, reset, instruction);
UART_RXD slave_rx(
    .clk(clk),
    .UART_clk(UART_clk), 
    .UART_RX(UART_RX), 
    .reset(op_rst), 
    .instruction(instruction)
    );

assign UART_TX = 1'b1;

assign instruction_state[7:5] = 3'b0;
seven_segment ss1(instruction_state, an, seg);

//Direction_Hold dh1(clk, op_rst, turn_clk, instruction, hold_left_right);
motor m1(
    .clk(clk), 
    .rst(op_rst), 
    .turn_angle(turn_angle), 
    .instruction(instruction[4:0]), 
    .motor(motor), 
    .check(check_motor), 
    .servo_pwm(servo_pwm), 
    .check_duty(check_duty), 
    .instruction_state(instruction_state[4:0])
    );

endmodule

module Direction_Hold(clk, reset, turn_clk, instruction, hold_left_right);
input clk, reset, turn_clk;
input [3:0] instruction;
output reg [1:0] hold_left_right;
reg [1:0] next_hold;

reg been_changed, next_been_changed;

always@(posedge clk) begin
    if(reset==1'b1) begin
        been_changed <= 1'b0;
        hold_left_right <= 2'b00;
    end
    else begin
        if(turn_clk==1'b1) begin
            hold_left_right <= next_hold;
            been_changed <= 1'b0;
        end
        else begin
            hold_left_right <= hold_left_right;
            been_changed <= next_been_changed;
        end
    end
end



always@(*) begin
    if(been_changed==1'b0) begin
        case(instruction[1:0])
            2'b10: begin 
                next_hold = 2'b10;
                next_been_changed = 1'b1;
            end
            2'b01: begin 
                next_hold = 2'b01;
                next_been_changed = 1'b1;
            end
            default: begin 
                next_hold = 2'b00;
                next_been_changed = 1'b0;
            end
        endcase
    end
    else begin
        next_been_changed = been_changed;
    end
end

endmodule

module UART_RXD(clk, UART_clk, UART_RX, reset, instruction);
input clk, UART_clk, UART_RX, reset;
output reg [7:0] instruction;
reg [7:0] next_instruction;

parameter WAIT = 2'b00, START = 2'b01, REC = 2'b10, STOP = 2'b11;
parameter CNT_HOLD_MAX = 10'd640;
reg [1:0] state, next_state;
reg [7:0] data, next_data;
reg [4:0] count, next_count;
reg [3:0] cnt_in, next_cnt_in;
reg [9:0] cnt_hold, next_cnt_hold;
reg hold_valid, next_hold_valid;

always@(posedge clk) begin
    if(reset==1'b1) begin
        state <= WAIT;
        data <= 8'd0;
        count <= 5'd0;
        cnt_in <= 4'd0;
        instruction <= 8'd0;
        cnt_hold <= 10'd0;
        hold_valid <= 1'b0;
    end
    else begin
        state <= next_state;
        data <= next_data;
        count <= next_count;
        cnt_in <= next_cnt_in;
        instruction <= next_instruction;
        cnt_hold <= next_cnt_hold;
        hold_valid <= next_hold_valid;
    end
end

always@(*) begin
    case(state) 
        WAIT: begin
            if(UART_RX==1'b0) begin
                next_state = START;
            end
            else begin
                next_state = WAIT;
            end
            next_data = 8'd0;
            next_count = 5'd0;
            next_cnt_in = 4'd0;
        end
        START: begin
            if(count==5'b01000) begin
                next_state = REC;
                next_data = 8'd0;
                next_count = 5'd0;
                next_cnt_in = 4'd0;
            end
            else begin
                next_state = START;
                next_data = 8'd0;
                if(UART_clk==1'b1) begin
                    next_count = count + 5'd1;
                end
                else begin
                    next_count = count;
                end
                next_cnt_in = 4'd0;
            end
        end
        REC: begin
                if(cnt_in==4'b1000) begin
                    next_state = STOP;
                    next_data = data;
                    next_count = 5'd0;
                    next_cnt_in = 4'd0;
                end
                else begin
                    if(count==5'b10000) begin
                        next_state = REC;
                        next_data = {data[6:0], UART_RX};
                        next_count = 5'd0;
                        next_cnt_in = cnt_in + 4'd1;
                    end
                    else begin
                        if(UART_clk==1'b1) begin
                            next_state = REC;
                            next_data = data;
                            next_count = count + 5'd1;
                            next_cnt_in = cnt_in;
                        end
                        else begin
                            next_state = REC;
                            next_data = data;
                            next_count = count;
                            next_cnt_in = cnt_in;
                        end
                    end
                end
        end
        STOP: begin
            if(count==5'd24) begin
                next_state = WAIT;
                next_data = 8'd0;
                next_count = 5'd0;
                next_cnt_in = 4'd0;
            end
            else begin
                next_state = STOP;
                next_data = data;
                next_cnt_in = cnt_in;
                if(UART_clk==1'b1) begin
                   next_count = count +5'd1;
                end
                else begin
                    next_count = count;
                end
            end
        end
    endcase
end
always@(*) begin
    if(state==STOP) begin
        next_cnt_hold = 10'd0;
        next_hold_valid = 1'b1;
        next_instruction = data;
    end
    else begin
        if(hold_valid==1'b1) begin
            if(cnt_hold==CNT_HOLD_MAX) begin
                next_cnt_hold = 10'd0;
                next_hold_valid=1'b0;
                next_instruction = 8'd0;
            end
            else begin 
                if(UART_clk==1'b1) begin
                    next_cnt_hold = cnt_hold + 10'd1;
                end
                else begin
                   next_cnt_hold = cnt_hold;
                end
                next_hold_valid = 1'b1;
                next_instruction = instruction;
            end
        end
        else begin
            next_cnt_hold = 10'd0;
            next_hold_valid = 1'b0;
            next_instruction = 8'd0;
        end
    end
end
endmodule