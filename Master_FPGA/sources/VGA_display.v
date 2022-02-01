module VGA_display(
   input clk,
   input rst,
   input [3:0] direction,
   input mode,
   output [3:0] vgaRed,
   output [3:0] vgaGreen,
   output [3:0] vgaBlue,
   output hsync,
   output vsync
    );

    wire [11:0] data;
    wire clk_25MHz;
    wire clk_22;
    wire [14:0] pixel_pto_addr; 
    wire [11:0] pixel_w_addr, pixel_a_addr, pixel_s_addr, pixel_d_addr;
    wire [11:0] pixel_on_addr, pixel_off_addr;
    wire [11:0] pixel_wave_addr, pixel_circle_addr, pixel_music_addr, pixel_pui_addr;
    
    wire [11:0] pixel_on, pixel_off;
    wire [11:0] pixel_pto, pixel_bgnd;
    wire [11:0] pixel_w, pixel_a, pixel_s, pixel_d;
    wire [11:0] pixel_wave, pixel_circle, pixel_music, pixel_pui;
    wire [11:0] pixel_out;
    wire valid;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480
    
    assign {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel_out:12'h0;
  
    //assign {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ?pixel_page1:12'h0;
    
     clock_divisor clk_wiz_0_inst(
      .clk(clk),
      .clk1(clk_25MHz),
      .clk22(clk_22)
    );

    mem_addr_gen mem_addr_gen_inst(
    .h_cnt(h_cnt),
    .v_cnt(v_cnt),
    .pixel_addr(pixel_pto_addr)
    );

    blk_mem_gen_0_inst blk_mem_gen_0_inst(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_pto_addr),
      .dina(data[11:0]),
      .douta(pixel_pto)
    ); 
    
    mem_addr_gen_WASD #(.v_start(280), .v_end(330), .h_start(100), .h_end(150)) magw (h_cnt, v_cnt, pixel_w_addr);
    mem_addr_gen_WASD #(.v_start(330), .v_end(380), .h_start(50), .h_end(100)) maga (h_cnt, v_cnt, pixel_a_addr);
    mem_addr_gen_WASD #(.v_start(330), .v_end(380), .h_start(100), .h_end(150)) mags (h_cnt, v_cnt, pixel_s_addr);
    mem_addr_gen_WASD #(.v_start(330), .v_end(380), .h_start(150), .h_end(200)) magd (h_cnt, v_cnt, pixel_d_addr);
    mem_addr_gen_WASD #(.v_start(80), .v_end(110), .h_start(430), .h_end(530)) magon (h_cnt, v_cnt, pixel_on_addr);
    mem_addr_gen_WASD #(.v_start(80), .v_end(110), .h_start(430), .h_end(530)) magoff (h_cnt, v_cnt, pixel_off_addr);
    
    mem_addr_gen_WCMP #(.v_start(150), .v_end(270), .h_start(320), .h_end(440)) magwave (h_cnt, v_cnt, pixel_wave_addr);
    mem_addr_gen_WCMP #(.v_start(150), .v_end(270), .h_start(460), .h_end(580)) magcircle (h_cnt, v_cnt, pixel_circle_addr);
    mem_addr_gen_WCMP #(.v_start(300), .v_end(420), .h_start(320), .h_end(440)) magmusic (h_cnt, v_cnt, pixel_music_addr);
    mem_addr_gen_WCMP #(.v_start(300), .v_end(420), .h_start(460), .h_end(580)) magpui (h_cnt, v_cnt, pixel_pui_addr);
    
    blk_mem_gen_w bmgw(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_w_addr),
      .dina(data[11:0]),
      .douta(pixel_w)
    ); 
    
    blk_mem_gen_a bmga(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_a_addr),
      .dina(data[11:0]),
      .douta(pixel_a)
    );
    
    blk_mem_gen_s bmgs(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_s_addr),
      .dina(data[11:0]),
      .douta(pixel_s)
    );  
    
    blk_mem_gen_d bmgd(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_d_addr),
      .dina(data[11:0]),
      .douta(pixel_d)
    ); 
    
    blk_mem_gen_on bmgon(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_on_addr),
      .dina(data[11:0]),
      .douta(pixel_on)
    ); 
    
    blk_mem_gen_off bmgoff(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_off_addr),
      .dina(data[11:0]),
      .douta(pixel_off)
    ); 
    
    blk_mem_gen_wave bmgwave(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_wave_addr),
      .dina(data[11:0]),
      .douta(pixel_wave)
    );
    
    blk_mem_gen_circle bmgcircle(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_circle_addr),
      .dina(data[11:0]),
      .douta(pixel_circle)
    );
    
    blk_mem_gen_music bmgmusic(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_music_addr),
      .dina(data[11:0]),
      .douta(pixel_music)
    );
    
    blk_mem_gen_pui bmgpui(
      .clka(clk_25MHz),
      .wea(0),
      .addra(pixel_pui_addr),
      .dina(data[11:0]),
      .douta(pixel_pui)
    );
    
    pixel_gen pg1(valid, h_cnt, v_cnt, pixel_bgnd);
    
    vga_controller   vga_inst(
      .pclk(clk_25MHz),
      .reset(rst),
      .hsync(hsync),
      .vsync(vsync),
      .valid(valid),
      .h_cnt(h_cnt),
      .v_cnt(v_cnt)
    );
     
     page_ctrl pgc(pixel_out, h_cnt, v_cnt, pixel_pto, pixel_bgnd, pixel_w, pixel_a, pixel_s, pixel_d, pixel_on, pixel_off,
      pixel_wave, pixel_circle, pixel_music, pixel_pui, direction, mode);
endmodule

module page_ctrl(pixel_out, h_cnt, v_cnt, pixel_pto, pixel_bgnd, pixel_w, pixel_a, pixel_s, pixel_d, pixel_on, pixel_off,
pixel_wave, pixel_circle, pixel_music, pixel_pui, direction, mode);
input [9:0] h_cnt, v_cnt;
input [11:0] pixel_pto, pixel_bgnd, pixel_w, pixel_a, pixel_s, pixel_d,  pixel_on, pixel_off;
input [11:0] pixel_wave, pixel_circle, pixel_music, pixel_pui;
input [3:0] direction;
input mode;
output reg [11:0] pixel_out;

always@(*) begin
    if(v_cnt>=60&&v_cnt<220) begin
        if(v_cnt>=80&&v_cnt<110) begin
            if(h_cnt>=60&&h_cnt<240) begin
                pixel_out = pixel_pto;
            end
            else begin
                if(h_cnt>=430&&h_cnt<530) begin
                    if(mode==1'b0) pixel_out = pixel_off;
                    else pixel_out = pixel_on;
                end
                else begin
                    pixel_out = pixel_bgnd;
                end
            end    
        end
        else if(v_cnt>=150&&v_cnt<220) begin
            if(h_cnt>=60&&h_cnt<240) begin
                pixel_out = pixel_pto;
            end
            else if(h_cnt>=320&&h_cnt<440) begin
                pixel_out = pixel_wave;
            end
            else if(h_cnt>=460&&h_cnt<580) begin
                pixel_out = pixel_circle;
            end
            else begin
                pixel_out = pixel_bgnd;
            end
        end
        else begin
            if(h_cnt>=60&&h_cnt<240) begin
                pixel_out = pixel_pto;
            end
            else begin
                pixel_out = pixel_bgnd;
            end
        end
    end
    else if(v_cnt>=220&&v_cnt<270) begin
        if(h_cnt>=320&&h_cnt<440) begin
            pixel_out = pixel_wave;
        end
        else if(h_cnt>=460&&h_cnt<580) begin
            pixel_out = pixel_circle;
        end
        else begin
            pixel_out = pixel_bgnd;
        end
    end
    else if(v_cnt>=280&&v_cnt<330) begin
        if(v_cnt>=300&&v_cnt<330) begin
            if(h_cnt>=100&&h_cnt<150) begin
                if(direction[3]==1'b1)
                    pixel_out = 12'h888;
                else
                    pixel_out = pixel_w;
            end
            else if(h_cnt>=320&&h_cnt<440) begin
                pixel_out = pixel_music;
            end
            else if(h_cnt>=460&&h_cnt<580) begin
                pixel_out = pixel_pui;
            end
            else begin
                pixel_out = pixel_bgnd;
            end
        end
        else begin
            if(h_cnt>=100&&h_cnt<150) begin
                if(direction[3]==1'b1)
                    pixel_out = 12'h888;
                else
                    pixel_out = pixel_w;
            end
            else begin
                pixel_out = pixel_bgnd;
            end
        end
    end
    else if(v_cnt>=330&&v_cnt<380) begin
        if(h_cnt>=50&&h_cnt<100) begin
            if(direction[1]==1'b1)
                pixel_out = 12'h888;
            else
                pixel_out = pixel_a;
        end
        else if(h_cnt>=100&&h_cnt<150) begin
            if(direction[2]==1'b1)
                pixel_out = 12'h888;
            else
                pixel_out = pixel_s;
        end
        else if(h_cnt>=150&&h_cnt<200) begin
            if(direction[0]==1'b1)
                pixel_out = 12'h888;
            else
                pixel_out = pixel_d;
        end
        else if(h_cnt>=320&&h_cnt<440) begin
            pixel_out = pixel_music;
        end
        else if(h_cnt>=460&&h_cnt<580) begin
            pixel_out = pixel_pui;
        end
        else begin
            pixel_out = pixel_bgnd;
        end
    end
    else if(v_cnt>=380&&v_cnt<420) begin
        if(h_cnt>=320&&h_cnt<440) begin
            pixel_out = pixel_music;
        end
        else if(h_cnt>=460&&h_cnt<580) begin
            pixel_out = pixel_pui;
        end
        else begin
            pixel_out = pixel_bgnd;
        end
    end
    else 
        pixel_out = pixel_bgnd;
end

endmodule