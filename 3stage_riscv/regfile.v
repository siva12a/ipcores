`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2021 19:36:45
// Design Name: 
// Module Name: regfile
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

module regfile(
    input        clock,
    input        rstn,
    input [31:0] wdata,
    input [4:0] rdaddr,
    input [4:0] rs1_addr,
    input [4:0] rs2_addr,
    input wen,
    output [31:0] rs1data,
    output [31:0] rs2data
    
    );
     reg [31:0] regfile [31:0];
     
    assign rs1data = regfile[rs1_addr];
    assign rs2data = regfile[rs2_addr];
    
   
    
    always @(posedge clock or negedge rstn) begin
    if(!rstn) begin
    regfile[0]  <=  32'h0000_0000;
    regfile[1]  <=  32'h0000_0000;
    regfile[2]  <=  32'h0001_FFFF;
    regfile[3]  <=  32'h0000_0000;
    regfile[4]  <=  32'h0000_0000;
    regfile[5]  <=  32'h0000_0000;
    regfile[6]  <=  32'h0000_0000;
    regfile[7]  <=  32'h0000_0000;
    regfile[8]  <=  32'h0000_0000;
    regfile[9]  <=  32'h0000_0000;
    regfile[10] <=  32'h0000_0000;
    regfile[11] <=  32'h0000_0000;
    regfile[12] <=  32'h0000_0000;
    regfile[13] <=  32'h0000_0000;
    regfile[14] <=  32'h0000_0000;
    regfile[15] <=  32'h0000_0000;
    regfile[16] <=  32'h0000_0000;
    regfile[17] <=  32'h0000_0000;
    regfile[18] <=  32'h0000_0000;
    regfile[19] <=  32'h0000_0000;
    regfile[20] <=  32'h0000_0000;
    regfile[21] <=  32'h0000_0000;
    regfile[22] <=  32'h0000_0000;
    regfile[23] <=  32'h0000_0000;
    regfile[24] <=  32'h0000_0000;
    regfile[25] <=  32'h0000_0000;
    regfile[26] <=  32'h0000_0000;
    regfile[27] <=  32'h0000_0000;
    regfile[28] <=  32'h0000_0000;
    regfile[29] <=  32'h0000_0000;
    regfile[30] <=  32'h0000_0000;
    regfile[31] <=  32'h0000_0000;
    end else begin
    
    if(wen && rdaddr != 5'b00000) begin
    regfile[rdaddr] <= wdata;
    end
    
    
    end
    
    
    end
    
    
    
    
    
endmodule
