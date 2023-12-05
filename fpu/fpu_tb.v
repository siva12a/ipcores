// Verilog testbench created by ssp
// 2021-06-28 22:45:46

`timescale 1ns / 1ps

module fpusssp();

reg clock;
reg rst_n;


//Clock process
parameter PERIOD = 10;

//glbl Instantiate
//glbl glbl();
 always #5 clock = ~clock;  
//Unit Instantiate
reg en,enreq,enres;
reg [63:0] v1 , v2, v3;
reg [6:0] opcode;
reg [6:0] f7;
reg [2:0] rm;
wire [4:0] word_send;
reg [4:0] rs2;
wire [63:0] resp;

wire [31:0] rslt ;
wire rslt_rdy;
assign rslt = resp[31:0]; 
wire reqrdy, resrdy;
mkFBox_Core  uut(        .verbosity(4'h3),
		   .CLK(clock),
		   .RST_N(rst_n),

		   .EN_server_reset_request_put(enreq),
		   .RDY_server_reset_request_put(reqrdy),

		   .EN_server_reset_response_get(enres),
		   .RDY_server_reset_response_get(resrdy),

		   .req_opcode(opcode),
		   .req_f7(f7),
		   
		   .req_rm(rm),
		   .req_rs2(rs2),
		   .req_v1(v1),
		   .req_v2(v2),
		   .req_v3(v3),
		   .EN_req(en),

		   .valid(rslt_rdy),

		   .word_fst(resp),

		   .word_snd(word_send)
	     );



initial begin
		$dumpfile("fpusssp.vcd");
		$dumpvars(0, fpusssp);
		
        end
        
        
initial begin





end       
        
        
        
        
        
        
        
//Stimulus process
initial begin
//To be inserted
    clock <= 0;  
    rst_n <= 0;  
    en <= 0;
    v1 <= 0;
    v2 <= 0;
    v3 <= 0;
    rs2 <= 0;
    rm <= 1;
//    opcode <= 1;
    enreq  <= 0;
    enres  <= 0;
    f7 <= 7'h0;
    #105
    
    rst_n <= 1'b1;
    #100
    enreq <= 1'b0;
    #20
    enreq <= 1'b0;
    #100
    enres <= 1'b0;
    #20
    enres <= 1'b0;
    #10
    enreq <= 1'b0;
    #20
    enreq <= 1'b0;
    #100
    enres <= 1'b0;
    #20
    enres <= 1'b0;
    
    // add
    en <= 1;
    v2 <= 32'h42AA4000;
    v1 <= 32'h42AA4000;
    opcode <= 7'b1010011;
    f7 <= 0;
    #10 
    en <= 0;
    
    wait (rslt_rdy == 1'b1);

    // sub
    en <= 1;
    v2 <= 32'h42AA4000;
    v1 <= 32'h42AA4000;
    opcode <= 7'b1010011;
    f7 <= 4;
    #10 
    en <= 0;
    
    wait (rslt_rdy == 1'b1);   
    
    
    // mul
    en <= 1;
    v2 <= 32'h42AA4001;
    v1 <= 32'h42AA4001;
    opcode <= 7'b1010011;
    f7 <= 8;
    #10 
    en <= 0;
    
    wait (rslt_rdy == 1'b1);      
    
    
     // divide
    en <= 1;
    v2 <= 32'h42AA4001;
    v1 <= 32'h42AA4001;
    opcode <= 7'b1010011;
    f7 <= 7'hc;
    #10 
    en <= 0;
    
    wait (rslt_rdy == 1'b1);      
    
    
     // sqrt
    en <= 1;
    v2 <= 32'h42AA4001;
    v1 <= 32'h42AA4001;
    opcode <= 7'b1010011;
    f7 <= 7'h2c;
    #10 
    en <= 0;
    
    wait (rslt_rdy == 1'b1);     
    
       // min
    en <= 1;
    v2 <= 32'h42AA4000;
    v1 <= 32'h42AA4001;
    opcode <= 7'b1010011;
    f7 <= 7'h2c4;
    rm <= 3'b000;
    #10 
    en <= 0;
    
    wait (rslt_rdy == 1'b1);       
    
    
         // max
    en <= 1;
    v2 <= 32'h42AA4000;
    v1 <= 32'h42AA4001;
    opcode <= 7'b1010011;
    f7 <= 7'h24;
    rm <= 3'b001;
    #10 
    en <= 0;
    
    wait (rslt_rdy == 1'b1);  
    
          // less
    en <= 1;
    v2 <= 32'h42AA4000;
    v1 <= 32'h42AA4001;
    opcode <= 7'b1010011;
    f7 <= 7'h50;
    rm <= 3'b001;
    #10 
    en <= 0;
    
    wait (rslt_rdy == 1'b1);  
    
    
             // greater
    en <= 1;
    v2 <= 32'h42AA4000;
    v1 <= 32'h42AA4001;
    opcode <= 7'b1010011;
    f7 <= 7'h50;
    rm <= 3'b010;
    #10 
    en <= 0;
    
    wait (rslt_rdy == 1'b1);  
    
    
    
             // eq
    en <= 1;
    v2 <= 32'h42AA4000;
    v1 <= 32'h42AA4000;
    opcode <= 7'b1010011;
    f7 <= 7'h50;
    rm <= 3'b000;
    #10 
    en <= 0;
    
    wait (rslt_rdy == 1'b1);     
    
    #6000 $finish;
end










endmodule
