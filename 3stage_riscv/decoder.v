`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.05.2021 20:08:35
// Design Name: 
// Module Name: decoder
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

module decoder(
    input  [31:0] inst,
    output [2:0] pc_mux,
    output  [1:0]     a_mux,
    output  [1:0]      b_mux,
    output [2:0] immediate_type,
    output [6:0] alu_operand,
    output [2:0] branch_type,
    output [2:0] st_type,
    output [2:0] ld_type,
    output [1:0] wb_type,
    output [2:0]      csr_type,
    output       wb_en,
    output       nop_next,
    output       multicycleo,
    output       isFPU,
    output       fpu_wb_en,
    output       [2:0] roundmode,
    output       dynamicround,
    output       illegal_instruction);
    
//// ######################################


parameter [31:0] START_PC = 32'h0000_1000;
parameter [31:0] EVICT_PC = 32'h0000_1000;
parameter NOP = 32'b00000000000000000000000000010011;
    
    
    
parameter pc_4   =  3'b000;   // next pc = pc + 4
parameter pc_alu =  3'b001;   // next pc = from alu
parameter pc_c   =  3'b010;   // next pc = current pc
parameter pc_epc =  3'b011;   // next pc = exception pc
parameter pc_evec = 3'b100;
          
      // A_sel
    //  parameter A_XXX  = 0.U(1.W)
parameter a_is_pc     = 2'b00;
parameter a_is_rs1    = 2'b01;
parameter a_is_no     = 2'b00;
parameter a_is_frs1   = 2'b10;
  // B_sel
 // parameter B_XXX  = 0.U(1.W)
parameter b_is_imm    = 2'b00;
parameter b_is_rs2    = 2'b01;
parameter b_is_no     = 2'b00;
parameter b_is_frs2   = 2'b10;

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
parameter wb_frm_alu = 3'b000;
parameter wb_frm_mem = 3'b001;
parameter wb_frm_pc4 = 3'b010;
parameter wb_frm_csr = 3'b011;
parameter wb_frm_fpu = 3'b100;
 
 // CSR TYPE
parameter csr_is_no       = 3'b000;
parameter csr_is_wr       = 3'b001;
parameter csr_is_set      = 3'b010;
parameter csr_is_clr      = 3'b011;
parameter csr_is_ecall    = 3'b100;
parameter csr_is_ebreak   = 3'b101;
parameter csr_is_eret     = 3'b110;
        
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


parameter op_is_FMADD_S    = 7'h0; 
parameter op_is_FMSUB_S    = 7'h0; 
parameter op_is_FNMSUB_S   = 7'h0; 
parameter op_is_FNMADD_S   = 7'h0; 

parameter op_is_FADD_S      = 7'h0 ;
parameter op_is_FSUB_S      = 7'h4 ;
parameter op_is_FMUL_S      = 7'h8 ;
parameter op_is_FDIV_S      = 7'hC ;
parameter op_is_FSQRT_S     = 7'h2C;
parameter op_is_FCMP_S      = 7'h50;
parameter op_is_FLT_S      = 7'h50;
parameter op_is_FLE_S      = 7'h50;
parameter op_is_FMIN_S      = 7'h14;
parameter op_is_FMAX_S      = 7'h14;
parameter op_is_FSGNJ_S     = 7'h10;  


parameter op_is_FCVT_W_S    = 7'h60;
parameter op_is_FCVT_WU_S   = 7'h60;
parameter op_is_FCVT_S_W    = 7'h68;
parameter op_is_FCVT_S_WU   = 7'h68;
parameter op_is_FMV_X_W     = 7'h70;  
parameter op_is_FMV_W_X     = 7'h78;
parameter op_is_FCLASS_S    = 7'h70;

parameter yes = 1'b1;
parameter no  = 1'b0;

parameter multicycle       = 1'b0;
parameter drm = 1'b1; // dynamic rounding   
 parameter drmv = 3'b000;
 ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// MICRO OPCODES ARRAY //////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  
  
                    //             isFpu   is multicycle next      alu A     alu B      immed      ALU           branch       store     load       writeback    csr     fpureg  regwb   nop   illegal
                    //                                   pc       select    select     type      operation      type          type      type        type        type      wben   en   next   instruction
 parameter [39:0]   cs_0      = {drm,3'b000,no,multicycle,pc_4  , a_is_no,   b_is_no,  imm_is_no, op_is_no    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  no,  no,  no};
 parameter [39:0]   cs_NOP    = {drm,3'b000,no,multicycle,pc_4  , a_is_no,   b_is_no,  imm_is_no, op_is_no    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  no,  no,  no};
 parameter [39:0]   cs_LUI    = {drm,3'b000,no,multicycle,pc_4  , a_is_pc,   b_is_imm, imm_is_u,  op_is_b     , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_AUIPC  = {drm,3'b000,no,multicycle,pc_4  , a_is_pc,   b_is_imm, imm_is_u,  op_is_add   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_JAL    = {drm,3'b000,no,multicycle,pc_alu, a_is_pc,   b_is_imm, imm_is_j,  op_is_add   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_pc4,   csr_is_no, no,  yes, yes, no};
 parameter [39:0]   cs_JALR   = {drm,3'b000,no,multicycle,pc_alu, a_is_rs1,  b_is_imm, imm_is_i,  op_is_add   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_pc4,   csr_is_no, no,  yes, yes, no};
 parameter [39:0]   cs_BEQ    = {drm,3'b000,no,multicycle,pc_4  , a_is_pc,   b_is_imm, imm_is_b,  op_is_add   , br_is_eq ,  st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  no,  no,  no};
 parameter [39:0]   cs_BNE    = {drm,3'b000,no,multicycle,pc_4  , a_is_pc,   b_is_imm, imm_is_b,  op_is_add   , br_is_neq , st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  no,  no,  no};
 parameter [39:0]   cs_BLT    = {drm,3'b000,no,multicycle,pc_4  , a_is_pc,   b_is_imm, imm_is_b,  op_is_add   , br_is_lt ,  st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  no,  no,  no};
 parameter [39:0]   cs_BGE    = {drm,3'b000,no,multicycle,pc_4  , a_is_pc,   b_is_imm, imm_is_b,  op_is_add   , br_is_ge ,  st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  no,  no,  no};
 parameter [39:0]   cs_BLTU   = {drm,3'b000,no,multicycle,pc_4  , a_is_pc,   b_is_imm, imm_is_b,  op_is_add   , br_is_ltu,  st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  no,  no,  no};
 parameter [39:0]   cs_BGEU   = {drm,3'b000,no,multicycle,pc_4  , a_is_pc,   b_is_imm, imm_is_b,  op_is_add   , br_is_geu,  st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  no,  no,  no};
 parameter [39:0]   cs_LB     = {drm,3'b000,no,multicycle,pc_c  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_add   , br_is_no,   st_is_no,  ld_is_8 ,  wb_frm_mem, csr_is_no, no,  yes, yes, no};
 parameter [39:0]   cs_LH     = {drm,3'b000,no,multicycle,pc_c  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_add   , br_is_no,   st_is_no,  ld_is_16 , wb_frm_mem, csr_is_no, no,  yes, yes, no};
 parameter [39:0]   cs_LW     = {drm,3'b000,no,multicycle,pc_c  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_add   , br_is_no,   st_is_no,  ld_is_32 , wb_frm_mem, csr_is_no, no,  yes, yes, no};
 parameter [39:0]   cs_LBU    = {drm,3'b000,no,multicycle,pc_c  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_add   , br_is_no,   st_is_no,  ld_is_8u,  wb_frm_mem, csr_is_no, no,  yes, yes, no};
 parameter [39:0]   cs_LHU    = {drm,3'b000,no,multicycle,pc_c  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_add   , br_is_no,   st_is_no,  ld_is_16u, wb_frm_mem, csr_is_no, no,  yes, yes, no};
 parameter [39:0]   cs_SB     = {drm,3'b000,no,multicycle,pc_c  , a_is_rs1,  b_is_imm, imm_is_s,  op_is_add   , br_is_no,   st_is_8 ,  ld_is_no,  wb_frm_alu, csr_is_no, no,  no,  yes, no};
 parameter [39:0]   cs_SH     = {drm,3'b000,no,multicycle,pc_c  , a_is_rs1,  b_is_imm, imm_is_s,  op_is_add   , br_is_no,   st_is_16 , ld_is_no,  wb_frm_alu, csr_is_no, no,  no,  yes, no};
 parameter [39:0]   cs_SW     = {drm,3'b000,no,multicycle,pc_c  , a_is_rs1,  b_is_imm, imm_is_s,  op_is_add   , br_is_no,   st_is_32 , ld_is_no,  wb_frm_alu, csr_is_no, no,  no,  yes, no};
 parameter [39:0]   cs_ADDI   = {drm,3'b000,no,multicycle,pc_4  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_add   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_SLTI   = {drm,3'b000,no,multicycle,pc_4  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_slt   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_SLTIU  = {drm,3'b000,no,multicycle,pc_4  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_sltu  , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_XORI   = {drm,3'b000,no,multicycle,pc_4  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_xor   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_ORI    = {drm,3'b000,no,multicycle,pc_4  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_or    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_ANDI   = {drm,3'b000,no,multicycle,pc_4  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_and   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_SLLI   = {drm,3'b000,no,multicycle,pc_4  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_sll   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_SRLI   = {drm,3'b000,no,multicycle,pc_4  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_srl   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_SRAI   = {drm,3'b000,no,multicycle,pc_4  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_sra   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_ADD    = {drm,3'b000,no,multicycle,pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_add   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_SUB    = {drm,3'b000,no,multicycle,pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_sub   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_SLL    = {drm,3'b000,no,multicycle,pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_sll   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_SLT    = {drm,3'b000,no,multicycle,pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_slt   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_SLTU   = {drm,3'b000,no,multicycle,pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_sltu  , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_XOR    = {drm,3'b000,no,multicycle,pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_xor   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_SRL    = {drm,3'b000,no,multicycle,pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_srl   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_SRA    = {drm,3'b000,no,multicycle,pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_sra   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_OR     = {drm,3'b000,no,multicycle,pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_or    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_AND    = {drm,3'b000,no,multicycle,pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_and   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_FENCE  = {drm,3'b000,no,multicycle,pc_4  , a_is_no,   b_is_no,  imm_is_no, op_is_no    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  no,  no,  no};
 parameter [39:0]   cs_FENCEI = {drm,3'b000,no,multicycle,pc_4    , a_is_no,   b_is_no,  imm_is_no, op_is_no  , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  no,  no, no};
 
 parameter [39:0]   cs_CSRRW  = {drm,3'b000,no,multicycle,pc_4    , a_is_rs1,  b_is_no,  imm_is_no, op_is_a     , br_is_no,   st_is_no,  ld_is_no,  wb_frm_csr, csr_is_wr,  no, yes, no, no};
 parameter [39:0]   cs_CSRRS  = {drm,3'b000,no,multicycle,pc_4    , a_is_rs1,  b_is_no,  imm_is_no, op_is_a     , br_is_no,   st_is_no,  ld_is_no,  wb_frm_csr, csr_is_set, no, yes, no, no};
 parameter [39:0]   cs_CSRRC  = {drm,3'b000,no,multicycle,pc_4    , a_is_rs1,  b_is_no,  imm_is_no, op_is_a     , br_is_no,   st_is_no,  ld_is_no,  wb_frm_csr, csr_is_clr, no, yes, no, no};
 parameter [39:0]   cs_CSRRWI = {drm,3'b000,no,multicycle,pc_4    , a_is_no,   b_is_no,  imm_is_z,  op_is_no    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_csr, csr_is_wr,  no, yes, no, no};
 parameter [39:0]   cs_CSRRSI = {drm,3'b000,no,multicycle,pc_4    , a_is_no,   b_is_no,  imm_is_z,  op_is_no    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_csr, csr_is_set, no, yes, no, no};
 parameter [39:0]   cs_CSRRCI = {drm,3'b000,no,multicycle,pc_4    , a_is_no,   b_is_no,  imm_is_z,  op_is_no    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_csr, csr_is_clr, no, yes, no, no};
 
 parameter [39:0]   cs_ECALL  = {drm,3'b000,no,multicycle,pc_evec  , a_is_no,   b_is_no,  imm_is_no, op_is_no    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_csr, csr_is_ecall,  no, no,  yes,  no};
 parameter [39:0]   cs_EBREAK = {drm,3'b000,no,multicycle,pc_evec  , a_is_no,   b_is_no,  imm_is_no, op_is_no    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_csr, csr_is_ebreak, no, no,  yes,  no};
 parameter [39:0]   cs_ERET   = {drm,3'b000,no,multicycle,pc_epc, a_is_no,   b_is_no,  imm_is_no, op_is_no    , br_is_no,   st_is_no,  ld_is_no,  wb_frm_csr, csr_is_eret,     no, no,  yes, no};
 parameter [39:0]   cs_WFI    = {drm,3'b000,no,multicycle,pc_4  , a_is_no,   b_is_no,  imm_is_no, op_is_no    , br_is_no, st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,       no, no,  no, no};                                                                               
    
 parameter [39:0]   cs_MUL      = {drm,3'b000,no,!multicycle,pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_mul   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   no,  no, yes,  no};
 parameter [39:0]   cs_MULH     = {drm,3'b000,no,!multicycle,pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_mulh   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,  no,  no, yes,  no};
 parameter [39:0]   cs_MULHSU   = {drm,3'b000,no,!multicycle,pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_mulhsu   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,no,  no, yes,  no};
 parameter [39:0]   cs_MULHU    = {drm,3'b000,no,!multicycle,pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_mulhu   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no, no,  no, yes,  no};
 parameter [39:0]   cs_DIV      = {drm,3'b000,no,!multicycle,pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_div   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   no,  no, yes,  no};
 parameter [39:0]   cs_DIVU     = {drm,3'b000,no,!multicycle,pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_divu   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,  no,  no, yes,  no};
 parameter [39:0]   cs_REM      = {drm,3'b000,no,!multicycle,pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_rem   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,   no,  no, yes,  no};
 parameter [39:0]   cs_REMU     = {drm,3'b000,no,!multicycle,pc_4  , a_is_rs1,  b_is_rs2, imm_is_no, op_is_remu   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_alu, csr_is_no,  no,  no, yes,  no};
 
 //////// define FPU instructions
 
 
 parameter [39:0]   cs_FLW     = {!drm,3'b010,yes,multicycle,pc_c  , a_is_rs1,  b_is_imm, imm_is_i,  op_is_FMADD_S   , br_is_no,   st_is_no,  ld_is_32 , wb_frm_fpu, csr_is_no, yes,  no, yes, no};
 parameter [39:0]   cs_FSW     = {!drm,3'b010,yes,multicycle,pc_c  , a_is_rs1,  b_is_imm, imm_is_s,  op_is_FMADD_S   , br_is_no,   st_is_32 , ld_is_no,  wb_frm_fpu, csr_is_no, no,  no,  yes,  no};
  
 parameter [39:0]   cs_FMADD_S    = {drm,drmv,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FMADD_S   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no, yes,  no, no,  no};
 parameter [39:0]   cs_FMSUB_S    = {drm,drmv,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FMSUB_S   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no, yes,  no, no,  no};
 parameter [39:0]   cs_FNMSUB_S   = {drm,drmv,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FNMSUB_S  , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no, yes,  no, no,  no};
 parameter [39:0]   cs_FNMADD_S   = {drm,drmv,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FNMADD_S  , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no, yes,  no, no,  no};
  
 
 parameter [39:0]   cs_FADD_S    = {drm,drmv,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FADD_S   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no,  yes, no, no,  no};
 parameter [39:0]   cs_FSUB_S    = {drm,drmv,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FSUB_S   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no,  yes, no, no,  no};
 parameter [39:0]   cs_FMUL_S    = {drm,drmv,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FMUL_S   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no,  yes, no, no,  no};
 parameter [39:0]   cs_FDIV_S    = {drm,drmv,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FDIV_S   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no,  yes, no, no,  no};
 parameter [39:0]   cs_FSQRT_S   = {drm,drmv,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FSQRT_S   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no, yes,  no, no,  no};
// sign injection instructions uses rounding mode for instr identification
 parameter [39:0]   cs_FSGNJ_S    = {!drm,3'b000,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FSGNJ_S   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no, yes,   no, no,  no};
 parameter [39:0]   cs_FSGNJN_S   = {!drm,3'b001,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FSGNJ_S   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no, yes,   no, no,  no};
 parameter [39:0]   cs_FSGNJX_S   = {!drm,3'b010,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FSGNJ_S   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no, yes,   no, no,  no};
 
 parameter [39:0]   cs_FMIN_S    = {!drm,3'b000,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FMIN_S   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no, yes,  no, no,  no};
 parameter [39:0]   cs_FMAX_S    = {!drm,3'b001,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FMAX_S   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no, yes,  no, no,  no};

 parameter  [39:0]   cs_FCMP_S    = {!drm,3'b010,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FCMP_S   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no, yes,  no, no,  no};
  parameter [39:0]   cs_FLT_S    = {!drm,3'b001,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FCMP_S   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no, yes,  no, no,  no};
  parameter [39:0]   cs_FLE_S    = {!drm,3'b000,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FCMP_S   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no, yes,  no, no,  no};
 
 parameter [39:0]   cs_FCVT_W_S    = {drm,drmv,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FCVT_W_S   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no, no,  yes, no,  no};
 parameter [39:0]   cs_FCVT_WU_S   = {drm,drmv,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FCVT_WU_S   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no,no,  yes, no,  no};
 parameter [39:0]   cs_FCVT_S_W    = {drm,drmv,yes,!multicycle,pc_4  , a_is_rs1,  b_is_frs2, imm_is_no, op_is_FCVT_S_W   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no, yes,  no, no,  no};
 parameter [39:0]   cs_FCVT_S_WU   = {drm,drmv,yes,!multicycle,pc_4  , a_is_rs1,  b_is_frs2, imm_is_no, op_is_FCVT_S_WU   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no,yes,  no, no,  no};
 
 
 parameter [39:0]   cs_FMV_W_X    = {drm,drmv,yes,!multicycle,pc_4  , a_is_rs1,  b_is_frs2, imm_is_no, op_is_FMV_W_X   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no,   yes, no, no,  no};
 parameter [39:0]   cs_FMV_X_W    = {drm,drmv,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FMV_X_W   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no,  no, yes, no,  no};
 parameter [39:0]   cs_FCLASS_S   = {drm,drmv,yes,!multicycle,pc_4  , a_is_frs1,  b_is_frs2, imm_is_no, op_is_FCLASS_S   , br_is_no,   st_is_no,  ld_is_no,  wb_frm_fpu, csr_is_no, no, yes, no,  no};
        
 
//decoding logic


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
  parameter MD     = 7'b0000001;

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
  
  parameter EOPCODE = 7'b1110011;
  parameter ECALL   = 2'b00;
  parameter EBREAK  = 2'b01;
  parameter ERET    = 2'b10;
//  parameter WFI    = 7'b1110011;
 
 parameter STRB_8_00 = 4'b0001;
 parameter STRB_8_01 = 4'b0010;
 parameter STRB_8_10 = 4'b0100;
 parameter STRB_8_11 = 4'b1000;
 
 parameter STRB_16_00 = 4'b0011;
 parameter STRB_16_10 = 4'b1100;
 
 parameter STRB_32 = 4'b1111;
 
  // added by me on 22/07/2021
  parameter MULDIV = 7'b0110011;
  parameter MUL    = 3'b000;
  parameter MULH   = 3'b001;
  parameter MULHSU = 3'b010;
  parameter MULHU  = 3'b011;
  parameter DIV    = 3'b100;
  parameter DIVU   = 3'b101;
  parameter REM    = 3'b110;
  parameter REMU   = 3'b111;
    
 /// #############################
 //added by me on 25/07/2021
 // FPU instructuions
parameter FLW           = 7'b0000111;
parameter FSW           = 7'b0100111;
parameter FMADD_S       = 7'b1000011;
parameter FMSUB_S       = 7'b1000111;
parameter FNMSUB_S      = 7'b1001011;
parameter FNMADD_S      = 7'b1001111;
parameter FPUOP         = 7'b1010011;


parameter FADD_S        = 7'b0000000;
parameter FSUB_S        = 7'b0000100;
parameter FMUL_S        = 7'b0001000;
parameter FDIV_S        = 7'b0001100;
parameter FSQRT_S       = 7'b0101100;

 
parameter FSGNJ_S       = 7'b0010000;
parameter FSGNJN_S      = 7'b0010000;
parameter FSGNJX_S      = 7'b0010000;
parameter FMIN_S        = 7'b0010100;
parameter FMAX_S        = 7'b0010100;
parameter FCVT_W_S      = 7'b1100000;
parameter FCVT_WU_S     = 7'b1100000;
parameter FMV_X_W       = 7'b1110000;
parameter FEQ_S         = 7'b1010000;
parameter FLT_S         = 7'b1010000;
parameter FLE_S         = 7'b1010000;
parameter FCLASS_S      = 7'b1110000;
parameter FCVT_S_W      = 7'b1101000;
parameter FCVT_S_WU     = 7'b1101000;
parameter FMV_W_X       = 7'b1111000;

 

  reg [41:0] control_sig;
  
  wire [6:0]  func7;
  wire [2:0]  func3;
  wire [31:25] inst31_25;
  wire [11:0] inst31_20;
  assign func7     = inst[6:0];
  assign func3     = inst[14:12];
  assign inst31_25 = inst[31:25];
  assign inst31_20 = inst[31:20];
  
   assign dynamicround             = control_sig[41];
   assign roundmode                = control_sig[40:38];
   assign isFPU                    = control_sig[37];
   assign multicycleo              = control_sig[36];
   assign pc_mux                   = control_sig[35:33];      
   assign a_mux                    = control_sig[32:31];
   assign b_mux                    = control_sig[30:29];
   assign immediate_type           = control_sig[28:26];
   assign alu_operand              = control_sig[25:19];
   assign branch_type              = control_sig[18:16];
   assign st_type                  = control_sig[15:13];
   assign ld_type                  = control_sig[12:10];
   assign wb_type                  = control_sig[9:7];
   assign csr_type                 = control_sig[6:4];
   
   assign fpu_wb_en                = control_sig[3]; 
   assign wb_en                    = control_sig[2];
   assign nop_next                 = control_sig[1];
   assign illegal_instruction      = control_sig[0];
  
  
  
  
  
//  control_signal = (inst
 
 always @(inst) begin
 
 if (inst == 32'h00000013) begin
 
 control_sig <= cs_NOP ;
 
 end else begin
 
 
 case(func7) 
    
    LUI:   begin control_sig <= cs_LUI;  end
    AUIPC: begin control_sig <= cs_AUIPC; end
    JAL:   begin control_sig <= cs_JAL; end
    JALR[6:0]: begin 
           control_sig <= (func3 == JALR[9:7]) ? cs_JALR : cs_0;
    end
    
    
    
    BRANCH: begin 
        case(func3) 
            BEQ :     begin control_sig <= cs_BEQ ; end
            BNE :     begin control_sig <= cs_BNE ; end
            BLT :     begin control_sig <= cs_BLT ; end
            BGE :     begin control_sig <= cs_BGE ; end
            BLTU:     begin control_sig <= cs_BLTU; end
            BGEU:     begin control_sig <= cs_BGEU; end
            default : begin control_sig <= cs_0;    end
        endcase
    end
   LOAD: begin
         case(func3)
            LB      : begin control_sig <= cs_LB ; end
            LH      : begin control_sig <= cs_LH ; end
            LW      : begin control_sig <= cs_LW ; end
            LBU     : begin control_sig <= cs_LBU; end
            LHU     : begin control_sig <= cs_LHU; end
            default : begin control_sig <= cs_0  ; end
         endcase
    end
   STORE: begin
         case(func3)   
            SB       : begin control_sig <= cs_SB; end
            SH       : begin control_sig <= cs_SH; end
            SW       : begin control_sig <= cs_SW; end
            default  : begin control_sig <= cs_0;  end
         endcase
   end
   IMMEDIATE: begin
         case(func3) 
            ADDI     : begin control_sig <= cs_ADDI ; end
            SLTI     : begin control_sig <= cs_SLTI ; end
            SLTIU    : begin control_sig <= cs_SLTIU; end
            XORI     : begin control_sig <= cs_XORI ; end
            ORI      : begin control_sig <= cs_ORI  ; end
            ANDI     : begin control_sig <= cs_ANDI ; end
            SLLI     : begin control_sig <= (inst31_25 == 7'b0000000) ?  cs_SLLI : cs_0; end
            SRLI     : begin control_sig <= (inst31_25 == 7'b0000000) ?  cs_SRLI : (inst31_25 == 7'b0100000) ? cs_SRAI : cs_0; end
            // srli and srai have same func3 so inst31_25 is checked
            default  : begin control_sig <= cs_0    ; end
         endcase
   end
   REGOP: begin
            case(inst31_25) 
            7'b0000000: begin
                case(func3) 
                    ADD      : control_sig <= cs_ADD  ;
                    SLL      : control_sig <= cs_SLL  ;
                    SLT      : control_sig <= cs_SLT  ;
                    SLTU     : control_sig <= cs_SLTU ;
                    XOR      : control_sig <= cs_XOR  ;
                    SRL      : control_sig <= cs_SRL  ;
                    OR       : control_sig <= cs_OR   ;
                    AND      : control_sig <= cs_AND  ;
                    default  : control_sig <= cs_0    ;
                endcase
            end
            7'b0100000: begin
                case(func3)
                    SUB      : control_sig <= cs_SUB  ;
                    SRA      : control_sig <= cs_SRA  ;
                    default  : control_sig <= cs_0    ;
                endcase
            end
            7'b0000001:  begin
            	case(func3)
            		MUL   : control_sig <= cs_MUL  ;		
            		MULH   : control_sig <= cs_MULH  ;	
            		MULHSU   : control_sig <= cs_MULHSU  ;	
            		MULHU   : control_sig <= cs_MULHU  ;	
            	        DIV     : control_sig <= cs_DIV  ;	
            	        DIVU     : control_sig <= cs_DIVU  ;	
            	        REM     : control_sig <= cs_REM  ;	
            	        REMU     : control_sig <= cs_REMU  ;	
            	endcase
            end
            default: begin control_sig <= cs_0; end
            endcase
    end
    MEMOP: begin
        case(func3) 
            FENCE:  begin control_sig <= cs_FENCE;  end 
            FENCEI: begin control_sig <= cs_FENCEI; end
            default  : control_sig <= cs_0    ;    
        endcase
    end
    CSROP: begin
        case(func3)
            CSRRW  : begin control_sig <= cs_CSRRW  ; end
            CSRRS  : begin control_sig <= cs_CSRRS  ; end
            CSRRC  : begin control_sig <= cs_CSRRC  ; end
            CSRRWI : begin control_sig <= cs_CSRRWI ; end
            CSRRSI : begin control_sig <= cs_CSRRSI ; end
            CSRRCI : begin control_sig <= cs_CSRRCI ; end
            3'b000 : begin // exceptions
                case(inst31_20[1:0]) 
                    ERET   : begin control_sig <= cs_ERET; end
                    ECALL  : begin control_sig <= cs_ECALL; end
                    EBREAK : begin control_sig <= cs_EBREAK; end
                    default  : control_sig <= cs_0    ;  
                endcase
            
            end
             default  : control_sig <= cs_0    ;    
        endcase
    end
    FLW      : begin control_sig <= cs_FLW; end
    FSW      : begin control_sig <= cs_FSW; end
    FMADD_S  : begin control_sig <= cs_FMADD_S; end
    FMSUB_S  : begin control_sig <= cs_FMSUB_S; end
    FNMSUB_S  : begin control_sig <= cs_FNMSUB_S; end
    FNMADD_S : begin control_sig <= cs_FNMADD_S; end
    
    FPUOP : begin
    
    case (inst31_25)
    		FADD_S   : begin control_sig <= cs_FADD_S; end
    		FSUB_S   : begin control_sig <= cs_FSUB_S ; end
    		FMUL_S   : begin control_sig <= cs_FMUL_S ; end
    		FDIV_S   : begin control_sig <= cs_FDIV_S ; end
    		FSQRT_S  : begin control_sig <= cs_FSQRT_S ; end
    		FSGNJ_S  : begin control_sig <= cs_FSGNJ_S ; end
    		FMIN_S   : begin control_sig <= cs_FMIN_S ; end
    		FMAX_S   : begin control_sig <= cs_FMAX_S ; end
    		FCVT_W_S : begin control_sig <= cs_FCVT_W_S ; end 
    		FEQ_S    : begin control_sig <= cs_FCMP_S ; end 
    		FCVT_S_W : begin control_sig <= cs_FCVT_S_W ; end   
    		FMV_W_X  : begin control_sig <= cs_FMV_W_X ; end 		
    
    endcase
    
    
    
    end

     default  : control_sig <= cs_0    ;    
 endcase
 
 
 end
 end
 
 
 

 
 
 
    
endmodule
