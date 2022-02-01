// *******************************
// lab_SPEAKER_TOP
//
// ********************************

module Music_ctrl (
	input clk,
	input reset,
	input start,
	output pmod_1,
	output pmod_2,
	output reg pmod_4
);
parameter BEAT_FREQ = 32'd8;	//one beat=0.125sec
parameter DUTY_BEST = 10'd512;	//duty cycle=50%
parameter MUSIC_LEN = 8'd71;

parameter IDLE = 1'b0, MUSIC = 1'b1;
reg state, next_state;

wire [31:0] freq;
wire [7:0] ibeatNum;
wire beatFreq;

assign pmod_2 = 1'd1;	//no gain(6dB)
//assign pmod_4 = 1'd1;	//turn-on

//Generate beat speed
always@(posedge clk) begin
    if(reset==1'b1) begin
        state <= IDLE;
    end
    else begin
        state <= next_state;    
    end
end

always@(*) begin
    case(state) 
        IDLE: begin
            pmod_4 = 1'b0;
            if(start==1'b1) next_state = MUSIC;
            else next_state = state;
        end
        MUSIC: begin
            pmod_4 = 1'b1;
            if(ibeatNum>=MUSIC_LEN) next_state = IDLE;
            else next_state = state;
        end
    endcase
end

PWM_gen btSpeedGen ( .clk(clk), 
					 .reset(reset),
					 .freq(BEAT_FREQ),
					 .duty(DUTY_BEST), 
					 .PWM(beatFreq)
                      );
	
PlayerCtrl playerCtrl_00 ( .clk(beatFreq),
						   .reset(reset),
						   .start(start),
						   .ibeat(ibeatNum)
                           );	
	
Music music00 ( .ibeatNum(ibeatNum),
				.tone(freq)
                );

PWM_gen toneGen ( .clk(clk), 
				  .reset(reset), 
				  .freq(freq),
				  .duty(DUTY_BEST), 
				  .PWM(pmod_1)
                  );
endmodule