// Verilog testbench created by SSP
// 2022-10-17 22:45:46

`timescale 1ns / 1ps

module descendSort_tb();

reg clk;
reg rstb;

localparam DEPTH = 8;
localparam WIDTH = 8;


reg [WIDTH -1 :0] [DEPTH - 1:0] in_data;
reg [WIDTH -1 :0] [DEPTH - 1:0] in_probab;
wire [WIDTH -1 :0] [DEPTH - 1:0] out_data;


wire [WIDTH -1 :0] out_data0;
wire [WIDTH -1 :0] out_data1;
wire [WIDTH -1 :0] out_data2;
wire [WIDTH -1 :0] out_data3;
wire [WIDTH -1 :0] out_data4;
wire [WIDTH -1 :0] out_data5;
wire [WIDTH -1 :0] out_data6;
wire [WIDTH -1 :0] out_data7;

wire [WIDTH -1 :0] in_data0;
wire [WIDTH -1 :0] in_data1;
wire [WIDTH -1 :0] in_data2;
wire [WIDTH -1 :0] in_data3;
wire [WIDTH -1 :0] in_data4;
wire [WIDTH -1 :0] in_data5;
wire [WIDTH -1 :0] in_data6;
wire [WIDTH -1 :0] in_data7;



assign in_data0 = in_data[0];
assign in_data1 = in_data[1];
assign in_data2 = in_data[2];
assign in_data3 = in_data[3];
assign in_data4 = in_data[4];
assign in_data5 = in_data[5];
assign in_data6 = in_data[6];
assign in_data7 = in_data[7];

 assign out_data0  =  out_data[0];
 assign out_data1  =  out_data[1];
 assign out_data2  =  out_data[2];
 assign out_data3  =  out_data[3];
 assign out_data4  =  out_data[4];
 assign out_data5  =  out_data[5];
 assign out_data6  =  out_data[6];
 assign out_data7  =  out_data[7];








reg valid;
always #1 clk = ~clk;  

initial begin
		$dumpfile("descendSort.vcd");
		$dumpvars(0, descendSort_tb);
		
        end
//Stimulus process
initial begin
//To be inserted
    clk 	<= 0;  
    valid 	<= 1'b0;
    rstb 	<= 0;  
    in_data <= 0;
    #100 rstb <= 1;
    #10
    in_data[0] <= 10;
    in_data[1] <= 5;
    in_data[2] <= 2;
    in_data[3] <= 25;
    in_data[4] <= 6;
    in_data[5] <= 4;
    in_data[6] <= 3;
    in_data[7] <= 44;
    valid 	<= 1;
    #10
    valid 	<= 0;
    #200
    
    $finish;
end











descendSort u_descendSort (


.clock(clk),
.rstn(rstb),
.valid(valid),
.ready(ready),

.in_data(in_data),
.in_probab(in_probab),
.out_data(out_data)




);







endmodule
