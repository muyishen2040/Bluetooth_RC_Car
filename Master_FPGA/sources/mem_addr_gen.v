module mem_addr_gen(
   input [9:0] h_cnt,
   input [9:0] v_cnt,
   output reg [14:0] pixel_addr
   );
   
   //assign pixel_addr = (h_cnt>>1)+320*(v_cnt>>1);  //640*480 --> 320*240 
   
   always@(*) begin
        if(v_cnt>=60&&v_cnt<220) begin
            if(h_cnt>=60&&h_cnt<240) begin
                pixel_addr = (v_cnt-60)*180+(h_cnt-60);
            end
            else begin
                pixel_addr = 15'd0;
            end
        end    
        else begin
            pixel_addr = 1'd0;
        end
    end 
endmodule

module pixel_gen(
   input valid,
   input [9:0] h_cnt,
   input [9:0] v_cnt,
   output reg [11:0] pixel_bgnd
   );

    always@(*) begin
        if(!valid) pixel_bgnd = 12'h0;
        else pixel_bgnd = 12'hfd1;
    end

endmodule

module mem_addr_gen_WASD#(parameter v_start=280, v_end=330, h_start=100, h_end=150)(
   input [9:0] h_cnt,
   input [9:0] v_cnt,
   output reg [11:0] pixel_addr
   );
      
    always@(*) begin
        if(v_cnt>=v_start&&v_cnt<v_end) begin
            if(h_cnt>=h_start&&h_cnt<h_end) begin
                pixel_addr = (v_cnt-v_start)*(h_end-h_start)+(h_cnt-h_start);
            end
            else begin
                pixel_addr = 12'd0;
            end
        end    
        else begin
            pixel_addr = 12'd0;
        end
    end 
   
endmodule

module mem_addr_gen_WCMP#(parameter v_start=280, v_end=330, h_start=100, h_end=150)(
   input [9:0] h_cnt,
   input [9:0] v_cnt,
   output reg [11:0] pixel_addr
   );
    wire [9:0] n_h_cnt, n_v_cnt;
    //assign n_h_cnt = h_cnt>>1;
    //assign n_v_cnt = v_cnt>>1;  
    always@(*) begin
        if(v_cnt>=v_start&&v_cnt<v_end) begin
            if(h_cnt>=h_start&&h_cnt<h_end) begin
                pixel_addr = ((v_cnt-v_start)>>1)*((h_end-h_start)>>1)+((h_cnt-h_start)>>1);
            end
            else begin
                pixel_addr = 12'd0;
            end
        end    
        else begin
            pixel_addr = 12'd0;
        end
    end 
   
endmodule
