`define NM1 32'd466 //bB_freq
`define NM2 32'd523 //C_freq
`define NM3 32'd587 //D_freq
`define NM4 32'd622 //bE_freq
`define NM5 32'd698 //F_freq
`define NM6 32'd784 //G_freq
`define NM7 32'd880 //A_freq
`define NM0 32'd20000 //slience (over freq.)

`define _1 32'd261
`define _2 32'd293
`define _3 32'd329
`define _4 32'd370
`define _sharp4 32'd370
`define _natural4 32'd349
`define _5 32'd392
`define _6 32'd440
`define _7 32'd493
`define _0 32'd20000

module Music (
 input [7:0] ibeatNum, 
 output reg [31:0] tone
);

always @(*) begin
 case (ibeatNum)  // 1/4 beat
  8'd0 : tone = `_1 << 2; //3
  8'd1 : tone = `_7 << 1;
  8'd2 : tone = `_1 << 2;
  8'd3 : tone = `_7 << 1;
  8'd4 : tone = `_1 << 2; //1
  8'd5 : tone = `_1 << 2;
  8'd6 : tone = `_0;
  8'd7 : tone = `_0;
  
  8'd8 : tone = `_6; //2
  8'd9 : tone = `_4;
  8'd10 : tone = `_6;
  8'd11 : tone = `_4;
  8'd12 : tone = `_7; //6-
  8'd13 : tone = `_7;
  8'd14 : tone = `_1;
  8'd15 : tone = `_2; 
  8'd16 : tone = `_3;
  8'd17 : tone = `_3;
  8'd18 : tone = `_4;
  8'd19 : tone = `_4;
  8'd20 : tone = `_2;
  8'd21 : tone = `_2;
  8'd22 : tone = `_0;
  8'd23 : tone = `_0;

  8'd24 : tone = `_6;
  8'd25 : tone = `_4;
  8'd26 : tone = `_6;
  8'd27 : tone = `_4;
  8'd28 : tone = `_7;
  8'd29 : tone = `_7;
  8'd30 : tone = `_1 << 1;
  8'd31 : tone = `_2 << 1; 
  8'd32 : tone = `_3 << 1;
  8'd33 : tone = `_3 << 1;
  8'd34 : tone = `_3 << 1;
  8'd35 : tone = `_3 << 1;
  8'd36 : tone = `_4 << 1;
  8'd37 : tone = `_4 << 1;
  8'd38 : tone = `_0;
  8'd39 : tone = `_0;
  
  8'd40 : tone = `_5 << 1;
  8'd41 : tone = `_5 << 1;
  8'd42 : tone = `_4 << 1;
  8'd43 : tone = `_4 << 1;
  8'd44 : tone = `_natural4 << 1;
  8'd45 : tone = `_natural4 << 1;
  8'd46 : tone = `_3 << 1;
  8'd47 : tone = `_3 << 1;  
  8'd48 : tone = `_6;
  8'd49 : tone = `_sharp4;
  8'd50 : tone = `_6;
  8'd51 : tone = `_4;
  8'd52 : tone = `_7;
  8'd53 : tone = `_7;
  8'd54 : tone = `_1;
  8'd55 : tone = `_2;

  8'd56 : tone = `_3;
  8'd57 : tone = `_3;
  8'd58 : tone = `_4;
  8'd59 : tone = `_4;
  8'd60 : tone = `_2;
  8'd61 : tone = `_2;
  8'd62 : tone = `_0;
  8'd63 : tone = `_0;
  8'd64 : tone = `_0;
  8'd65 : tone = `_0;
  8'd66 : tone = `_0;
  8'd67 : tone = `_0;
  8'd68 : tone = `_0;
  8'd69 : tone = `_0;
  8'd70 : tone = `_0;
  8'd71 : tone = `_0;

  default : tone = `_0;
 endcase
end

endmodule