`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: S SIVA PRASAD
// 
// Create Date: 29.05.2021 19:30:59
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: RISCV ALU CORE  
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////


module alu(
       input clock,
       input rst_n,
       input  [31:0] A,
       input  [31:0] B,
       output [31:0] OUT,
       output [31:0] SUM,
       input  [6:0]  op,
       
       // multiplier divider
       
       //output [31:0] mulrslt,
       //output [31:0] rem,
       //output [31:0] quo,
       
       output mulvalid,
       output divvalid,

       input  mulstart,
       input  divstart
       
    );
    ///////////////////////// ############################
    
  


parameter [31:0] START_PC = 32'h0000_1000;
parameter [31:0] EVICT_PC = 32'h0000_1000;
parameter NOP = 32'b00000000000000000000000000010011;
    
    
parameter pc_4   = 2'b00;   // next pc = pc + 4
parameter pc_alu = 2'b01;   // next pc = from alu
parameter pc_c   = 2'b10;   // next pc = current pc
parameter pc_epc = 2'b11;   // next pc = exception pc
      
      // A_sel
    //  parameter A_XXX  = 0.U(1.W)
parameter a_is_pc   = 1'b0;
parameter a_is_rs1  = 1'b1;
parameter a_is_no   = 1'b0;
  // B_sel
 // parameter B_XXX  = 0.U(1.W)
parameter b_is_imm   = 1'b0;
parameter b_is_rs2   = 1'b1;
parameter b_is_no    = 1'b0;

  // imm_sel
parameter imm_is_no = 3'b000;
parameter imm_is_i  = 3'b001;
parameter imm_is_s  = 3'b010;
parameter imm_is_u  = 3'b011;
parameter imm_is_j  = 3'b100;
parameter imm_is_b  = 3'b101;
parameter imm_is_z  = 3'b110;

  // br_type
parameter br_is_no  = 3'b000;
parameter br_is_ltu = 3'b001;
parameter br_is_lt  = 3'b010;
parameter br_is_eq  = 3'b011;
parameter br_is_geu = 3'b100;
parameter br_is_ge  = 3'b101;
parameter br_is_neq  = 3'b110;

  // st_type
parameter st_is_no  = 3'b000;
parameter st_is_32  = 3'b001;
parameter st_is_16  = 3'b010;
parameter st_is_8   = 3'b011;
 

 // ld_type
parameter ld_is_no  = 3'b000;
parameter ld_is_32  = 3'b001;
parameter ld_is_16  = 3'b010;
parameter ld_is_8   = 3'b011;
parameter ld_is_16u = 3'b100;
parameter ld_is_8u  = 3'b101;


        // wb_sel
parameter wb_frm_alu = 2'b00;
parameter wb_frm_mem = 2'b01;
parameter wb_frm_pc4 = 2'b10;
parameter wb_frm_csr = 2'b11;
 
 // CSR TYPE
parameter csr_is_no = 3'b000;
parameter csr_is_wr    = 3'b001;
parameter csr_is_set   = 3'b010;
parameter csr_is_clr   = 3'b011;
parameter csr_is_pol   = 3'b100;
        
        // OPERATION TYPE ADDED BY SSP
        // OPERATION TYPE ADDED BY SSP
parameter op_is_add        = 7'b0000000;
parameter op_is_sub        = 7'b0000001;
parameter op_is_and        = 7'b0000010;
parameter op_is_or         = 7'b0000011;
parameter op_is_xor        = 7'b0000100;
parameter op_is_slt        = 7'b0000101;
parameter op_is_sll        = 7'b0000110;
parameter op_is_sltu       = 7'b0000111;
parameter op_is_srl        = 7'b0001000;
parameter op_is_sra        = 7'b0001001;
parameter op_is_a          = 7'b0001010;
parameter op_is_b          = 7'b0001011;

parameter op_is_no           = 7'b0001111;

parameter op_is_mul          = 7'b0011000;
parameter op_is_mulh         = 7'b0011001;
parameter op_is_mulhsu       = 7'b0011010;
parameter op_is_mulhu        = 7'b0011011;

parameter op_is_div          = 7'b0010000;
parameter op_is_divu         = 7'b0010001;
parameter op_is_rem          = 7'b0010010;
parameter op_is_remu         = 7'b0010011;



parameter yes = 1'b1;
parameter no  = 1'b0;

 ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// MICRO OPCODES ARRAY //////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  
    
    ////////////////////// #################################

    wire [4:0] shamt;
    
    wire [31:0] add_rslt  ;
    wire [31:0] sub_rslt  ;
    wire [31:0] and_rslt  ;
    wire [31:0] or_rslt   ;
    wire [31:0] xor_rslt  ;
    wire [31:0] slt_rslt  ;
    wire [31:0] sll_rslt  ;
    wire [31:0] sltu_rslt ;
    wire [31:0] srl_rslt  ;
    wire [31:0] sra_rslt  ;
    wire [31:0] copya_rslt;
    wire [31:0] copyb_rslt;
    wire muldivop;
    
     
    assign add_rslt      = A + B;
    assign sub_rslt      = A - B;
    assign and_rslt      = A & B;
    assign or_rslt       = A | B;
    assign xor_rslt      = A ^ B;
    assign slt_rslt      = ($signed(A) < $signed(B)) ? 31'b1 : 32'b0;
    assign sll_rslt      = A << shamt;
    assign sltu_rslt     = ($unsigned(A) < $unsigned(B)) ? 31'b1 : 32'b0;
    assign srl_rslt      = A >> shamt;
    assign sra_rslt      = $signed(A) >>> shamt;
    assign copya_rslt    = A;
    assign copyb_rslt    = B;
    
    
    assign shamt = B[4:0];
    
    
    wire [31:0] OUT1,OUT2,MULOUT,DIVOUT;
    assign OUT  = (op[4:3] == 2'b10) || (op[4:3] == 2'b11) ? OUT2 : OUT1;
    assign OUT1 = (op == op_is_add   ) ?  add_rslt   : 
                 (op == op_is_sub   ) ?  sub_rslt   : 
                 (op == op_is_and   ) ?  and_rslt   : 
                 (op == op_is_or    ) ?  or_rslt    : 
                 (op == op_is_xor   ) ?  xor_rslt   : 
                 (op == op_is_slt   ) ?  slt_rslt   : 
                 (op == op_is_sll   ) ?  sll_rslt   : 
                 (op == op_is_sltu  ) ?  sltu_rslt  : 
                 (op == op_is_srl   ) ?  srl_rslt   : 
                 (op == op_is_sra   ) ?  sra_rslt   : 
                 (op == op_is_no    ) ?  32'b0      :
                 (op == op_is_b  ) ?  copyb_rslt      :
                 (op == op_is_a) ?  copya_rslt : 32'b0;
    assign SUM = (op[0] == 1'b1) ? (A + B) : (A - B);
          
wire AisSigned ;
wire BisSigned;


assign AisSigned   =   (op == op_is_mul) || (op == op_is_mulh) || (op == op_is_mulhsu) || (op == op_is_div) || (op_is_rem);
assign BisSigned   =   (op == op_is_mul) || (op == op_is_mulh) || (op == op_is_div) || (op_is_rem);

 wire [63:0] mulrslt; 
 wire [31:0] quo; 
 wire [31:0] rem; 
mkIntDiv_32 divunit(    
                  .CLK(clock),
		   .RST_N(rst_n),

		   .start_num_is_signed(AisSigned),
		   .start_den_is_signed(BisSigned),
		   .start_num(A),
		   .start_den(B),
		   .EN_start(divstart),

		   .result_valid(divvalid),

		   .result_quo(quo),

		   .result_rem(rem),
		   .RDY_result_rem()
    );
       
mkIntMul_32 mulunit(
                  .CLK(clock),
		   .RST_N(rst_n),

		   .put_args_x_is_signed(AisSigned),
		   .put_args_x(A),
		   .put_args_y_is_signed(BisSigned),
		   .put_args_y(B),
		   .EN_put_args(mulstart),

		   .result_valid(mulvalid),

		   .result_value(mulrslt)
		   );

assign OUT2 = mulvalid ? MULOUT : divvalid ? DIVOUT :  32'h00000000;   
assign MULOUT =  (op == op_is_mul)    ?   mulrslt[31:0] :
                 (op == op_is_mulh)   ?   mulrslt[63:32] :
                 (op == op_is_mulhsu) ?   mulrslt[63:32] :
                 (op == op_is_mulhu)  ?   mulrslt[63:32] : 32'h00000000;


assign DIVOUT = (op == op_is_div) || (op_is_divu) ? quo :
                (op == op_is_rem) || (op_is_remu) ? rem : 32'h00000000;




 

  
endmodule
