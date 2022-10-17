
module descendSort #
(
parameter DEPTH = 8,
parameter WIDTH = 8

)(
input clock,
input rstn,
input valid,
input [WIDTH -1 :0] [DEPTH - 1:0] in_data,
input [WIDTH -1 :0] [DEPTH - 1:0] in_probab,
output  wire [WIDTH -1 :0] [DEPTH - 1:0] out_data,
output reg ready

);

localparam DEPTH_1 = DEPTH;

  parameter IDLE         = 3'b000;
  parameter START    = 3'b001;
  parameter SORT = 3'b010;
  parameter DONE  = 3'b011;
  parameter INCR_PTR      = 3'b100;
  
  reg [WIDTH -1 :0] [DEPTH - 1:0] in_data_1;
  
  reg [2:0]     sortState;
  reg [2:0]     inputPointer; //TODO
  reg [2:0]     checkPointer; //TODO
  reg [2:0]     counter_1; //TODO
  reg [2:0]     counter_2; //TODO
  reg [WIDTH -1 :0] in_data_2;
  assign out_data = in_data_1;
  
always @ (posedge clock or negedge rstn) begin

	if (~rstn) begin
		//out_data     <= 0;
		ready        <= 1'b0;
		sortState    <= IDLE;
		in_data_1    <= 0;
		inputPointer <= 0;
		checkPointer <= 1;
		counter_1    <= 3'b000;
		counter_2    <= 3'b000;
	end else begin
	
	case (sortState)
	IDLE : begin
		in_data_1 <= valid ? in_data : in_data_1;
		ready     <= valid ? 1'b0 : ready;
		sortState <= valid ? START : IDLE;
		inputPointer <= 0;
		checkPointer <= 0;
		counter_1    <= 3'b000;
		counter_2    <= 3'b000;
	end
	START : begin
		in_data_2 <= in_data_1[inputPointer];
		sortState <= (inputPointer == 3'b111 ) ? DONE : SORT;
		checkPointer <= (inputPointer == 3'b111 ) ? 3'b000 : inputPointer + 3'b001;
	end
	SORT : begin
		in_data_1[inputPointer] <= (in_data_1[inputPointer] < in_data_1[checkPointer]) ? in_data_1[checkPointer] : in_data_1[inputPointer];
		in_data_1[checkPointer] <= (in_data_1[inputPointer] < in_data_1[checkPointer]) ? in_data_1[inputPointer] : in_data_1[checkPointer];
		checkPointer            <= (checkPointer == 3'b111) ? 3'b000 : (checkPointer + 3'b001);
		sortState <= (checkPointer == 3'b111) ? INCR_PTR : SORT;
	end
	INCR_PTR : begin 
		inputPointer <= (inputPointer == 3'b111) ? 3'b000 : (inputPointer + 3'b001);
		sortState 	 <= (inputPointer == 3'b111) ? DONE : START;
	end
	DONE : begin
		//out_data <= in_data_1;
		ready <= 1'b1;
		sortState 	 <= IDLE;
	end
	endcase
	
	
	end



end









endmodule
