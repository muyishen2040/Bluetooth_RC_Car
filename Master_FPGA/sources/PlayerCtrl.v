module PlayerCtrl (
	input clk,
	input reset,
	input start,
	output reg [7:0] ibeat
);
parameter BEATLEAGTH = 72;

always @(posedge clk, posedge reset) begin
	if (reset||start)
		ibeat <= 0;
	else begin
	   if (ibeat < BEATLEAGTH) 
		  ibeat <= ibeat + 1;
	   else 
		  ibeat <= 0;
    end
end

endmodule