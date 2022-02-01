`timescale 1ns / 1ps

module motor_state(clk, rst, instruction, motor_ctrl, check);
    input clk;
    input rst;
    input [4:0] instruction;
    output reg [3:0] motor_ctrl;
    reg [30:0] cnt;
    reg [3:0] state, next_state;
    output reg [4:0] check;
    
    parameter IDLE = 3'b000, WAVE = 3'b001, CIRCLE = 3'b010, PIUPIU = 3'b011, CTRL = 3'b100;

    always @(*) begin
        if (rst == 1'b1) begin
            check = 5'b0;
        end 
        else begin
            case (state)
                IDLE: check = 5'b00000;
                WAVE: check = 5'b11010;
                CIRCLE: check = 5'b11001;
                PIUPIU: check = 5'b10000;
                default: check = instruction;
            endcase
        end
    end

    always @(posedge clk) begin
        if (rst == 1'b1) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin
        if (rst == 1'b1) begin
            next_state = IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    if (instruction == 5'b11010) begin
                        next_state = WAVE;
                    end
                    else if (instruction == 5'b11001) begin
                        next_state = CIRCLE;
                    end 
                    else if (instruction == 5'b10000) begin
                        next_state = PIUPIU; 
                    end
                    else if (instruction == 5'b00000) begin
                        next_state = IDLE;
                    end
                    else begin
                        next_state = CTRL;
                    end
                end
                WAVE: begin
                    if (instruction == 5'b00000) begin
                        next_state = WAVE;
                    end 
                    else if (instruction == 5'b11010) begin
                        next_state = WAVE;
                    end
                    else begin
                        next_state = IDLE; 
                    end
                end
                CIRCLE: begin
                    if (instruction == 5'b00000) begin
                        next_state = CIRCLE;
                    end
                    else if (instruction == 5'b11001) begin
                        next_state = CIRCLE;
                    end
                    else begin
                        next_state = IDLE;
                    end
                end
                PIUPIU: begin
                    if (instruction == 5'b00000) begin
                        next_state = PIUPIU;
                    end
                    else if (instruction == 5'b10000) begin
                        next_state = PIUPIU;
                    end
                    else begin
                        next_state = IDLE;
                    end
                end
                CTRL: begin
                    if (instruction == 5'b00000) begin
                        next_state = IDLE; 
                    end
                    else begin
                        next_state = CTRL; 
                    end
                end
                default: begin
                    next_state = IDLE;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (rst == 1'b1) begin
            cnt <= 31'b100_000_000;
        end
        else begin
            if (state == WAVE) begin
                if (cnt < 31'd400_000_000) begin
                    cnt <= cnt + 31'd1;
                end
                else begin
                    cnt <= 31'b0;
                end
            end
            else if (state == PIUPIU) begin
                if (cnt < 31'd200_000_000) begin
                    cnt <= cnt + 31'd1;
                end
                else begin
                    cnt <= 31'd0;
                end
            end
            else begin
                cnt <= 31'b100_000_000;
            end
        end
    end

    always @(*) begin
        if (rst == 1'b1) begin
            motor_ctrl = 4'b0;
        end 
        else begin
            case (state)
                WAVE: begin
                    if (cnt < 31'd200_000_000) begin
                        motor_ctrl = 4'b1010;
                    end
                    else begin
                        motor_ctrl = 4'b1001;
                    end
                end  
                CIRCLE: begin
                    motor_ctrl = 4'b1010;
                end
                PIUPIU: begin
                    if (cnt < 31'd100_000_000) begin
                        motor_ctrl = 4'b1010;
                    end
                    else begin
                        motor_ctrl = 4'b0101;
                    end
                end
                default: begin
                    motor_ctrl = instruction[3:0];
                end
            endcase
        end
    end
endmodule

module motor(clk, rst, turn_angle, instruction, motor, check, servo_pwm, check_duty, instruction_state);
    input clk;
    input rst;
    input [2:0] turn_angle;
    input [4:0] instruction;
    output reg [3:0] motor;
    output [3:0] check;
    output servo_pwm;
    output [6:0] check_duty;
    output [4:0] instruction_state;
    reg [1:0] left_right;
    wire [3:0] motor_ctrl;
    
    servo steer(
        .clk(clk),
        .reset(rst),
        .angle(turn_angle),
        .dir(left_right),
        .pwm(servo_pwm),
        .check_duty(check_duty)
        );
    
    motor_state ms(
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .motor_ctrl(motor_ctrl),
        .check(instruction_state)
        );
    
    assign check = motor;
    
    always@(*) begin
        case(motor_ctrl[3:2])
            2'b10: motor = 4'b1010;
            2'b01: motor = 4'b0101;
            default: motor = 4'b0000;
        endcase
    end
    
    always@(*) begin
        case(motor_ctrl[1:0])
            2'b10: left_right = 2'b10;
            2'b01: left_right = 2'b01;
            default: left_right = 2'b00;
        endcase
    end

endmodule

module servo(clk, reset, angle, dir, pwm, check_duty);
    input clk;
    input reset;
    input [2:0] angle;
    input [1:0] dir;
    output pwm;
    output [6:0] check_duty;
    
    reg [9:0] duty;
    
    servo_pwm s_p(
        .clk(clk), 
        .reset(reset), 
        .duty(duty), 
        .pmod_1(pwm)
        );
    
    assign check_duty = duty[6:0];

    always@(*)begin
        if (dir == 2'd1) begin
            case(angle)
                3'b001: duty = 10'd57;
                3'b010: duty = 10'd47;
                3'b100: duty = 10'd25;
                default: duty = 10'd74;
            endcase
        end
        else if (dir == 2'd2) begin
            case(angle)
                3'b001: duty = 10'd90;
                3'b010: duty = 10'd100;
                3'b100: duty = 10'd122;
                default: duty = 10'd74;
            endcase
        end
        else begin
            duty = 10'd74;
        end
    end
        
endmodule

module servo_pwm (
    input clk,
    input reset,
    input [9:0]duty,
	output pmod_1 //PWM
);
        
    PWM_gen pwm_0 ( 
        .clk(clk), 
        .reset(reset), 
        .freq(32'd50),
        .duty(duty), 
        .PWM(pmod_1)
        );

endmodule

//generte PWM by input frequency & duty
module PWM_gen (clk, reset, freq, duty, PWM);
    input clk;
    input reset;
	input [31:0] freq;
    input [9:0] duty;
    output reg PWM;

    wire [31:0] count_max = 32'd100_000_000 / freq;
    wire [31:0] count_duty = count_max * duty / 32'd1024;
    reg [31:0] count;
        
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 32'b0;
            PWM <= 1'b0;
        end else if (count < count_max) begin
            count <= count + 32'd1;
            if(count < count_duty)
                PWM <= 1'b1;
            else
                PWM <= 1'b0;
        end else begin
            count <= 32'b0;
            PWM <= 1'b0;
        end
    end
endmodule

