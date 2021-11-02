`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2021 14:59:24
// Design Name: 
// Module Name: branch
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



module branch(
    input [31:0] rs1,
    input [31:0] rs2,
    input [2:0]  br_type,
    output       taken
    );
    ////////////////////////// ######################################
    
    
   


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
parameter op_is_add        = 4'b0000;
parameter op_is_sub        = 4'b0001;
parameter op_is_and        = 4'b0010;
parameter op_is_or         = 4'b0011;
parameter op_is_xor        = 4'b0100;
parameter op_is_slt        = 4'b0101;
parameter op_is_sll        = 4'b0110;
parameter op_is_sltu       = 4'b0111;
parameter op_is_srl        = 4'b1000;
parameter op_is_sra        = 4'b1001;
parameter op_is_a          = 4'b1010;
parameter op_is_b          = 4'b1011;
parameter op_is_no         = 4'b1111;

parameter yes = 1'b1;
parameter no  = 1'b0;

 ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// MICRO OPCODES ARRAY //////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  
                    //          next      alu A     alu B      immed      ALU           branch       store     load       writeback    csr       wb   nop   illegal
                    //           pc       select    select     type      operation      type          type      type        type        type     en   next   instruction
 parameter [27:0]   cs_0      = {pc_4  , a_is_no,   b_is_no,  imm_is_no, op_is_no    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   no,  no,  yes};
 parameter [27:0]   cs_LUI    = {pc_4  , a_is_pc,   b_is_imm, imm_is_u,  op_is_b     , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_AUIPC  = {pc_4  , a_is_pc,   b_is_imm, imm_is_u,  op_is_add   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_JAL    = {pc_alu, a_is_pc,   b_is_imm, imm_is_j,  op_is_add   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_pc4, csr_is_no,   yes, yes, no};
 parameter [27:0]   cs_JALR   = {pc_alu, a_is_rs1,  b_is_imm, imm_is_i,  op_is_add   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_pc4, csr_is_no,   yes, yes, no};
 parameter [27:0]   cs_BEQ    = {pc_4  , a_is_pc,   b_is_imm, imm_is_b,  op_is_add   , br_is_eq ,  st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   no,  no,  no};
 parameter [27:0]   cs_BNE    = {pc_4  , a_is_pc,   b_is_imm, imm_is_b,  op_is_add   , br_is_neq ,  st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   no,  no,  no};
 parameter [27:0]   cs_BLT    = {pc_4  , a_is_pc,   b_is_imm, imm_is_b,  op_is_add   , br_is_lt ,  st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   no,  no,  no};
 parameter [27:0]   cs_BGE    = {pc_4  , a_is_pc,   b_is_imm, imm_is_b,  op_is_add   , br_is_ge ,  st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   no,  no,  no};
 parameter [27:0]   cs_BLTU   = {pc_4  , a_is_pc,   b_is_imm, imm_is_b,  op_is_add   , br_is_ltu,  st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   no,  no,  no};
 parameter [27:0]   cs_BGEU   = {pc_4  , a_is_pc,   b_is_imm, imm_is_b,  op_is_add   , br_is_geu,  st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   no,  no,  no};
 parameter [27:0]   cs_LB     = {pc_c    , a_is_rs1,  b_is_imm, imm_is_i,  op_is_add   , br_is_no,   st_is_no,  ld_is_8 ,  wb_frm_mem, csr_is_no,   yes, yes, no};
 parameter [27:0]   cs_LH     = {pc_c    , a_is_rs1,  b_is_imm, imm_is_i,  op_is_add   , br_is_no,   st_is_no,  ld_is_16 , wb_frm_mem, csr_is_no,   yes, yes, no};
 parameter [27:0]   cs_LW     = {pc_c    , a_is_rs1,  b_is_imm, imm_is_i,  op_is_add   , br_is_no,   st_is_no,  ld_is_32 , wb_frm_mem, csr_is_no,   yes, yes, no};
 parameter [27:0]   cs_LBU    = {pc_c    , a_is_rs1,  b_is_imm, imm_is_i,  op_is_add   , br_is_no,   st_is_no,  ld_is_8u,  wb_frm_mem, csr_is_no,   yes, yes, no};
 parameter [27:0]   cs_LHU    = {pc_c    , a_is_rs1,  b_is_imm, imm_is_i,  op_is_add   , br_is_no,   st_is_no,  ld_is_16u, wb_frm_mem, csr_is_no,   yes, yes, no};
 parameter [27:0]   cs_SB     = {pc_4  , a_is_rs1,  b_is_imm, imm_is_s,  op_is_add   , br_is_no,   st_is_8 ,  ld_is_no,  wb_frm_alu, csr_is_no,   no,  no,  no};
 parameter [27:0]   cs_SH     = {pc_4  , a_is_rs1,  b_is_imm, imm_is_s,  op_is_add   , br_is_no,   st_is_16 , ld_is_no,  wb_frm_alu, csr_is_no,   no,  no,  no};
 parameter [27:0]   cs_SW     = {pc_4  , a_is_rs1,  b_is_imm, imm_is_s,  op_is_add   , br_is_no,   st_is_32 , ld_is_no,  wb_frm_alu, csr_is_no,   no,  no,  no};
 parameter [27:0]   cs_ADDI   = {pc_4  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_add   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_SLTI   = {pc_4  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_slt   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_SLTIU  = {pc_4  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_sltu  , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_XORI   = {pc_4  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_xor   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_ORI    = {pc_4  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_or    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_ANDI   = {pc_4  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_and   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_SLLI   = {pc_4  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_sll   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_SRLI   = {pc_4  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_srl   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_SRAI   = {pc_4  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_sra   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_ADD    = {pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_add   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_SUB    = {pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_sub   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_SLL    = {pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_sll   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_SLT    = {pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_slt   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_SLTU   = {pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_sltu  , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_XOR    = {pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_xor   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_SRL    = {pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_srl   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_SRA    = {pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_sra   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_OR     = {pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_or    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_AND    = {pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_and   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   yes, no,  no};
 parameter [27:0]   cs_FENCE  = {pc_4  , a_is_no,   b_is_no,  imm_is_no, op_is_no    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   no,  no,  no};
 parameter [27:0]   cs_FENCEI = {pc_c    , a_is_no,   b_is_no,  imm_is_no, op_is_no    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   no,  yes, no};
 parameter [27:0]   cs_CSRRW  = {pc_c    , a_is_rs1,  b_is_no,  imm_is_no, op_is_a     , br_is_no,   st_is_no,  ld_is_no,  wb_frm_csr, csr_is_wr,   yes, yes, no};
 parameter [27:0]   cs_CSRRS  = {pc_c    , a_is_rs1,  b_is_no,  imm_is_no, op_is_a     , br_is_no,   st_is_no,  ld_is_no,  wb_frm_csr, csr_is_set,  yes, yes, no};
 parameter [27:0]   cs_CSRRC  = {pc_c    , a_is_rs1,  b_is_no,  imm_is_no, op_is_a     , br_is_no,   st_is_no,  ld_is_no,  wb_frm_csr, csr_is_clr,  yes, yes, no};
 parameter [27:0]   cs_CSRRWI = {pc_c    , a_is_no,   b_is_no,  imm_is_z,  op_is_no    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_csr, csr_is_wr,   yes, yes, no};
 parameter [27:0]   cs_CSRRSI = {pc_c    , a_is_no,   b_is_no,  imm_is_z,  op_is_no    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_csr, csr_is_set,  yes, yes, no};
 parameter [27:0]   cs_CSRRCI = {pc_c    , a_is_no,   b_is_no,  imm_is_z,  op_is_no    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_csr, csr_is_clr,  yes, yes, no};
/// parameter [29:0]   cs_ECALL  = {pc_4  , a_is_no,   b_is_no,  imm_is_no, op_is_no    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_csr, csr_is_pol,  no,  no,  no};
 //parameter [29:0]   cs_EBREAK = {pc_4  , a_is_no,   b_is_no,  imm_is_no, op_is_no    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_csr, csr_is_pol,  no,  no,  no};
// parameter [29:0]   cs_ERET   = {pc_epc, a_is_no,   b_is_no,  imm_is_no, op_is_no    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_csr, csr_is_pol,  no,  yes, no};
// parameter [29:0]   cs_WFI    = {pc_4  , a_is_no,   b_is_no,  imm_is_no, op_is_no    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   no,  no,  no};                                                                                 
    
 
 
 ////////////////////// decoding logic //////////////////////////////////////////////////////////////////////////////////////////////
 
 
  parameter LUI    = 7'b0110111;
  parameter AUIPC  = 7'b0010111;  
  
  // jump instructions
  parameter JAL    = 7'b1101111;
  parameter JALR   = {3'b000,7'b1100111}; 
  
  
  //branch instructions
  parameter BRANCH = 7'b1100011;
  parameter BEQ    = 3'b000;
  parameter BNE    = 3'b001;
  parameter BLT    = 3'b100;
  parameter BGE    = 3'b101;
  parameter BLTU   = 3'b110;
  parameter BGEU   = 3'b111;
    
   // load instructions   
  parameter LOAD   = 7'b0000011;              
  parameter LB     = 3'b000;
  parameter LH     = 3'b001;
  parameter LW     = 3'b010;
  parameter LBU    = 3'b100;
  parameter LHU    = 3'b101;
  
  //store instructions
  parameter STORE  = 7'b0100011;
  parameter SB     = 3'b000;
  parameter SH     = 3'b001;  
  parameter SW     = 3'b010;  
  
  // immediate///////////////////////////////////
  parameter IMMEDIATE = 7'b0010011;
  parameter ADDI   = 3'b000;
  parameter SLTI   = 3'b010;
  parameter SLTIU  = 3'b011;
  parameter XORI   = 3'b100;
  parameter ORI    = 3'b110;
  parameter ANDI   = 3'b111;
  parameter SLLI   = 3'b001; // 7'b0000000, //additional check at inst 31:25
  parameter SRLI   = 3'b101; // 7'b0000000,
  parameter SRAI   = 3'b101; // 7'b0100000,
  //////////////////////////////////////////////////////////////////
  parameter REGOP = 7'b0110011;
  parameter ADD    = 3'b000;  //  7'b0000000,  //additional check at inst 31:25
  parameter SUB    = 3'b000;  //  7'b0100000,  //additional check at inst 31:25
  parameter SLL    = 3'b001;  //  7'b0000000,  //additional check at inst 31:25
  parameter SLT    = 3'b010;  //  7'b0000000,  //additional check at inst 31:25
  parameter SLTU   = 3'b011;  //  7'b0000000,  //additional check at inst 31:25
  parameter XOR    = 3'b100;  //  7'b0000000,  //additional check at inst 31:25
  parameter SRL    = 3'b101;  //  7'b0000000,  //additional check at inst 31:25
  parameter SRA    = 3'b101;  //  7'b0100000,  //additional check at inst 31:25
  parameter OR     = 3'b110;  //  7'b0000000,  //additional check at inst 31:25
  parameter AND    = 3'b111;  //  7'b0000000,  //additional check at inst 31:25

  parameter MEMOP    = 7'b0001111;
  parameter FENCE    = 3'b000;
  parameter FENCEI   = 3'b001;

  parameter CSROP  = 7'b1110011;
  parameter CSRRW  = 3'b001;
  parameter CSRRS  = 3'b010;
  parameter CSRRC  = 3'b011;
  parameter CSRRWI = 3'b101;
  parameter CSRRSI = 3'b110;
  parameter CSRRCI = 3'b111;
  // Change Level
  
 // parameter ECALL  = 7'b1110011;
//  parameter EBREAK = 7'b1110011;
//  parameter ERET   = 7'b1110011;
//  parameter WFI    = 7'b1110011;
 
 parameter STRB_8_00 = 4'b0001;
 parameter STRB_8_01 = 4'b0010;
 parameter STRB_8_10 = 4'b0100;
 parameter STRB_8_11 = 4'b1000;
 
 parameter STRB_16_00 = 4'b0011;
 parameter STRB_16_10 = 4'b1100;
 
 parameter STRB_32 = 4'b1111;
 
  
    
    
    
    
    
    
    
    
    
    
    /////////////////?????/////////////#########################
    
  wire  eq   = (rs1 == rs2);
  wire  neq  = !eq;
  wire  lt   = $signed(rs1) < $signed(rs2);
  wire  ge   = !lt;
  wire  ltu  = rs1 < rs2;
  wire  geu  = !ltu;
  
  wire  br_inst = (br_type != 3'b000);
  wire  cond;
  


  
  
  assign taken = cond & br_inst;
  
  assign cond = ((br_type == br_is_eq)   &  eq)  |
                 ((br_type == br_is_neq) &  neq) |
                 ((br_type == br_is_lt)  &  lt)  |
                 ((br_type == br_is_ge)  &  ge)  |
                 ((br_type == br_is_ltu) &  ltu) |
                 ((br_type == br_is_geu) &  geu) ;
                 
    
    
    
  
endmodule
