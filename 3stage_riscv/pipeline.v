`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2021 14:00:03
// Design Name: 
// Module Name: pipeline
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

`define usefpu 0

module pipeline(
 input             clk,
 input             rstn,
 output  [31:0]    imem_addr,
 output            imem_rden,
 input   [31:0]    imem_rdata,
 
 
 output  [31:0]    dmem_addr,
 output            dmem_sel,
 output            dmem_enable,
 output            dmem_write,
 output  [3:0]     dmem_wstrb,
 input   [31:0]    dmem_rdata,
 output  [31:0]    dmem_wdata,
 
 input             ext_intr,
 input             tmr_intr
 
 
  );
  
  //////////////



parameter [31:0] START_PC = 32'h00000000;

parameter NOP = 32'b00000000000000000000000000010011;
    
    
parameter pc_4   =  3'b000;   // next pc = pc + 4
parameter pc_alu =  3'b001;   // next pc = from alu
parameter pc_c   =  3'b010;   // next pc = current pc
parameter pc_epc =  3'b011;   // next pc = exception pc
parameter pc_evec = 3'b100;
      // A_sel
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
parameter wb_frm_alu = 2'b00;
parameter wb_frm_mem = 2'b01;
parameter wb_frm_pc4 = 2'b10;
parameter wb_frm_csr = 2'b11;
 
 // CSR TYPE
 // CSR TYPE
parameter csr_is_no       = 3'b000;
parameter csr_is_wr       = 3'b001;
parameter csr_is_set      = 3'b010;
parameter csr_is_clr      = 3'b011;
parameter csr_is_ecall    = 3'b100;
parameter csr_is_ebreak   = 3'b101;
parameter csr_is_eret     = 3'b110;
        
        // OPERATION TYPE ADDED BY SSP
parameter op_is_add        = 5'b00000;
parameter op_is_sub        = 5'b00001;
parameter op_is_and        = 5'b00010;
parameter op_is_or         = 5'b00011;
parameter op_is_xor        = 5'b00100;
parameter op_is_slt        = 5'b00101;
parameter op_is_sll        = 5'b00110;
parameter op_is_sltu       = 5'b00111;
parameter op_is_srl        = 5'b01000;
parameter op_is_sra        = 5'b01001;
parameter op_is_a          = 5'b01010;
parameter op_is_b          = 5'b01011;

parameter op_is_no         = 5'b01111;

parameter op_is_mul          = 5'b11000;
parameter op_is_mulh         = 5'b11001;
parameter op_is_mulhsu       = 5'b11010;
parameter op_is_mulhu        = 5'b11011;

parameter op_is_div          = 5'b10000;
parameter op_is_divu         = 5'b10001;
parameter op_is_rem          = 5'b10010;
parameter op_is_remu         = 5'b10011;

parameter yes = 1'b1;
parameter no  = 1'b0;

 ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// MICRO OPCODES ARRAY //////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
parameter multicycle       = 1'b0;

 ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// MICRO OPCODES ARRAY //////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
 
 ////////////////////// decoding logic //////////////////////////////////////////////////////////////////////////////////////////////
 
 
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
 
 //////////////////////////////////////////////////////////////////////
  
  
    
   
   
// these are signals in decode stage
    reg [31:0] fetch_inst;
    reg [31:0] fetch_pc;
    wire [4:0] fetch_rs1_addr;
    wire [4:0] fetch_rs2_addr;
    wire [4:0] fetch_rs3_addr;
    wire [4:0] fetch_rd_addr;
    
    
      reg [31:0] fpu_rslt_r;
 // these are signals in execute writeback stage
    reg [31:0] exewb_inst;
    reg [31:0] exewb_pc  ;
    reg [31:0] exewb_alu_o;
    reg [4:0] exewb_rdaddr;
    

////////////////////////////////
    wire rs1_fw;
    wire rs2_fw;  
    wire [31:0] rs1;
    wire [31:0] rs2;
    
     reg [6:0] r_alu_operand;
  
    
    
    reg [31:0] pc;
    wire [31:0] next_pc;
    wire [31:0] inst;
    wire [31:0] next_inst;
    
    
    wire [31:0] regfilein;
    
    
    wire  [2:0]  w_pc_mux;            
    wire   [1:0]      w_a_mux;             
    wire   [1:0]      w_b_mux;             
    wire  [2:0]  w_immediate_type;   
    wire  [6:0]  w_alu_operand;      
    wire  [2:0]  w_branch_type;  
         
    wire  [2:0]  w_st_type;           
    wire  [2:0]  w_ld_type;          
    wire  [1:0]  w_wb_type;           
    wire  [2:0]  w_csr_type;          
    wire         w_wb_en;             
    wire         w_nop_next;          
    wire         w_illegal_instruction;
    
   reg  [2:0]  r_st_type;           
   reg  [2:0]  r_ld_type;          
   reg  [1:0]  r_wb_type;           
   reg  [2:0]  r_csr_type;          
   reg         r_wb_en;             
 //   wire         w_nop_next;          
   reg         r_illegal_instruction; 
    
   wire branch_taken;
    
    wire [31:0] rs1data;
    wire [31:0] rs2data;
    
    wire [31:0] frs1data;
    wire [31:0] frs2data;
    wire [31:0] frs3data;

    reg  [31:0] rs2_r;
    
    
    wire  [31:0] w_immediate;
  
    wire  [31:0] w_alu_out;
    wire  [31:0] w_alu_sum;
    
    wire  w_csr_exp;
    reg   r_csr_exp;
    wire [31:0] w_csr_rd_out;
    reg [31:0] r_csr_rd_out;
    wire [31:0] evict_pc;
    wire [31:0] exp_pc;
    wire multicyclew;
    wire isFPU;
    reg isFPUr,isFPUrr;
    wire fpu_wb_en,dynamicround;
    reg  multicycler;
    wire [2:0] roundmode;
    
    parameter csrround = 3'b000;
 decoder u_decoder 
    (
        .inst                  (fetch_inst),
        .pc_mux                (w_pc_mux),
        .a_mux                 (w_a_mux),
        .b_mux                 (w_b_mux),
        .immediate_type        (w_immediate_type),
        .alu_operand           (w_alu_operand),
        .branch_type           (w_branch_type),
        .st_type               (w_st_type),
        .ld_type               (w_ld_type),
        .wb_type               (w_wb_type),
        .csr_type              (w_csr_type),
        .multicycleo           (multicyclew),
        .isFPU                 (isFPU),
        .fpu_wb_en             (fpu_wb_en),
        .roundmode             (roundmode),
        .wb_en                 (w_wb_en),
        .dynamicround          (dynamicround),
        .nop_next              (w_nop_next),
        .illegal_instruction   (w_illegal_instruction)
       
   );
  
  imm_gen u_imm_gen(
        .inst                  (fetch_inst),
        .imm_op                (w_immediate_type),
        .imm_out               (w_immediate)
    );  
    
 wire [31:0] w_a, w_b;
 wire mulvalid, divvalid, mulstart, divstart;
 assign mulstart = (w_alu_operand[4:3] == 2'b11);
 assign divstart = (w_alu_operand[4:3] == 2'b10);
  reg multicyclerr;
 wire [6:0] aluop;
 assign aluop = (multicycler || multicyclerr) ? r_alu_operand : w_alu_operand;
  
 alu  u_alu( 
          .clock                (clk),
          .rst_n                (rstn),
          .A                    (w_a),
          .B                    (w_b),
          .OUT                  (w_alu_out),
          .SUM                  (w_alu_sum),
          .op                   (aluop),
          
          .mulvalid             (mulvalid),
          .divvalid		 (divvalid),

          .mulstart             (mulstart),
          .divstart             (divstart)
          
       ); 
  
  wire [6:0] fpu_opcode;
  assign fpu_opcode = w_alu_operand;
  wire [2:0] fpuround = dynamicround ? roundmode : csrround;
  
  wire [63:0] fpu_rslt;
  wire fpu_rdy,fpustart,fpuloadsw;
  assign fpuloadsw_w = ((w_ld_type == ld_is_32) || (w_st_type == st_is_32)) ? 1'b1 : 1'b0;
  reg fpuloadsw_r;
  assign fpustart = (isFPU && !fpuloadsw_w) ? 1'b1 : 1'b0;
  
  
  
  wire [31:0] exfrmint ;
  assign exfrmint = (w_a_mux == a_is_frs1) ? frs1data : rs1data  ;
  
  /*
  `ifdef usefpu
  
 mkFBox_Core  fpu(        
            .verbosity(4'h3),
		   .CLK(clk),
		   .RST_N(rstn),

		   .EN_server_reset_request_put(1'b0),
		   .RDY_server_reset_request_put(),

		   .EN_server_reset_response_get(1'b0),
		   .RDY_server_reset_response_get(),

		   .req_opcode(fetch_inst[6:0]),
		   .req_f7(fetch_inst[31:25]),
		   
		   .req_rm(fpuround),
		   .req_rs2(fetch_inst[24:20]),
		   .req_v1({32'h0000_0000,exfrmint}),
		   .req_v2({32'h0000_0000,frs2data}),
		   .req_v3({32'h0000_0000,frs3data}),
		   .EN_req(fpustart),

		   .valid(fpu_rdy),

		   .word_fst(fpu_rslt),

		   .word_snd()
	     );  
	     
	     `else 
	      assign fpu_rslt = 0;
	     assign fpu_rdy = 1'b0;
	      `endif    
    */
   	     assign fpu_rslt = 0;
	     assign fpu_rdy = 1'b0; 
    
branch u_branch(
          .rs1                   (rs1),        
          .rs2                   (rs2),
          .br_type               (w_branch_type),
          .taken                 (branch_taken)
    );
  

 regfile u_regfile(
           .clock                 (clk),
           .rstn                  (rstn),
           .wdata                 (regfilein),
           .rdaddr                (exewb_rdaddr),
           .rs1_addr              (fetch_rs1_addr),
           .rs2_addr              (fetch_rs2_addr),
           .wen                   (r_wb_en),
           .rs1data               (rs1data),
           .rs2data               (rs2data)
 );
 wire [31:0] fpu_rslt32;
 assign fpu_rslt32 = fpuloadsw_r ? dmem_rdata : fpu_rslt[31:0];
   reg fpu_r_wb_en;
  wire fpuregwr;
 assign fpuregwr = ( ((fpu_rdy || fpu_r_wb_en) && multicycler) || (fpu_r_wb_en && !multicycler) ) ;
 regfile_fpu u_regfile_fpu(
           .clock                 (clk),
           .rstn                  (rstn),
           .wdata                 (fpu_rslt32),
           .rdaddr                (exewb_rdaddr),
           .rs1_addr              (fetch_rs1_addr),
           .rs2_addr              (fetch_rs2_addr),
           .rs3_addr              (fetch_rs3_addr),
           .wen                   (fpuregwr),
           .rs1data               (frs1data),
           .rs2data               (frs2data),
           .rs3data               (frs3data)
 );
 
 csr u_csr(
    .clock                        (clk),
    .rst_n                        (rstn),
    .csr_cmd                      (w_csr_type),
    .csr_address                  (fetch_inst[31:20]),
    .csr_rs1_in                   (rs1),
    .z_immediate                  (w_immediate),
    .w_a_mux                      (w_a_mux),
    .rs_addr                      (fetch_rs1_addr),
    .rd_addr                      (fetch_rd_addr),
                                 
    .ext_intr_in                  (ext_intr),
    .tmr_intr_in                  (1'b0),
                                 
    .pc                           (fetch_pc),
                                  
    .csr_rd_out                   (w_csr_rd_out),
    .load_addr                    (w_alu_out),
    .store_addr                   (w_alu_out),
    .branch_addr                  (w_alu_out),
    .branch_taken                 (branch_taken),
    .illegal_inst                 (w_illegal_instruction),
    .st_type                      (w_st_type),
    .ld_type                      (w_ld_type),
    .br_type                      (w_branch_type),
    .inst                         (fetch_inst),
                                  
    .csr_exp                      (),
    .evict_pc                     (evict_pc),
    .exp_pc                       (exp_pc)
    );
 

 
 assign w_csr_exp = 1'b0;
 assign imem_rden = rstn;
 assign imem_addr = !rstn ? START_PC : next_pc;   
 
 
 wire [31:0] next_pc_w;
  assign next_pc_w =  ( (w_pc_mux  == pc_evec) || w_csr_exp) ? evict_pc :
                      ( w_pc_mux  == pc_epc)    ? exp_pc :
                      ((w_pc_mux  == pc_alu)   || branch_taken) ?  (w_alu_out >> 1 << 1) :
                      ( w_pc_mux  == pc_c ) || (multicyclew || multicycler) ? pc  : 
                        pc + 32'h0000_0004;
                    
  assign next_pc = !rstn ? START_PC :   next_pc_w;
                            
  assign inst   = (multicyclew || multicycler) ? NOP :
                  ( w_nop_next || branch_taken || w_csr_exp) ? NOP : imem_rdata ;  
       
       
  assign fetch_rs1_addr = fetch_inst[19:15];
  assign fetch_rs2_addr = fetch_inst[24:20];
  assign fetch_rs3_addr = fetch_inst[31:27];
  assign fetch_rd_addr  = fetch_inst[11:7];     
  
 // reg [4:0] exewb_rdaddr;
  //assign exewb_rdaddr   = exewb_inst[11:7]; 
  
  assign rs1_fw = (r_wb_en && (fetch_rs1_addr != 5'b00000) && (fetch_rs1_addr == exewb_rdaddr) && (r_wb_type == wb_frm_alu));
  assign rs2_fw = (r_wb_en && (fetch_rs2_addr != 5'b00000) && (fetch_rs2_addr == exewb_rdaddr) && (r_wb_type == wb_frm_alu));
  
  assign rs1 = rs1_fw ? exewb_alu_o : rs1data;
  assign rs2 = rs2_fw ? exewb_alu_o : rs2data;
  
  assign w_a = (w_a_mux == a_is_rs1) ? rs1 : fetch_pc;
  assign w_b = (w_b_mux == b_is_rs2) ? rs2 : w_immediate;
  
  


 wire [31:0] dmem_rdata8_0;
 wire [31:0] dmem_rdata8_1;
 wire [31:0] dmem_rdata8_2;
 wire [31:0] dmem_rdata8_3;
 wire [31:0] dmem_rdata8;
 
 wire [31:0] dmem_rdata16;
 wire [31:0] dmem_rdata16_0;
 wire [31:0] dmem_rdata16_1;

 assign dmem_rdata8_0 = (r_ld_type == ld_is_8) ?  dmem_rdata[7] ? {24'hFFFFFF,dmem_rdata[7:0]} : {24'h000000,dmem_rdata[7:0]} :
                        (r_ld_type == ld_is_8u) ? {24'h000000,dmem_rdata[7:0]} : 32'h00000000;
  assign dmem_rdata8_1 = (r_ld_type == ld_is_8) ?  dmem_rdata[15] ? {24'hFFFFFF,dmem_rdata[15:8]} : {24'h000000,dmem_rdata[15:8]} :
                        (r_ld_type == ld_is_8u) ? {24'h000000,dmem_rdata[15:8]} : 32'h00000000;  
                                             
  assign dmem_rdata8_2 = (r_ld_type == ld_is_8) ?  dmem_rdata[23] ? {24'hFFFFFF,dmem_rdata[23:16]} : {24'h000000,dmem_rdata[23:16]} :
                        (r_ld_type == ld_is_8u) ? {24'h000000,dmem_rdata[23:16]} : 32'h00000000;
                        
  assign dmem_rdata8_3 = (r_ld_type == ld_is_8) ?  dmem_rdata[31] ? {24'hFFFFFF,dmem_rdata[31:24]} : {24'h000000,dmem_rdata[31:24]} :
                        (r_ld_type == ld_is_8u) ? {24'h000000,dmem_rdata[31:24]} : 32'h00000000;  
                        
                        
 assign dmem_rdata8 =   (exewb_alu_o[1:0] == 2'b00)  ? dmem_rdata8_0 :
                        (exewb_alu_o[1:0] == 2'b01)  ? dmem_rdata8_1 :
                        (exewb_alu_o[1:0] == 2'b10)  ? dmem_rdata8_2 :
                        (exewb_alu_o[1:0] == 2'b11)  ? dmem_rdata8_3 : 32'h0000_0000;
                        
  
  assign dmem_rdata16_0 = (r_ld_type == ld_is_16) ?  dmem_rdata[15] ? {16'hFFFF,dmem_rdata[15:0]} : {16'h0000,dmem_rdata[15:0]} :
                        (r_ld_type == ld_is_16u) ? {16'h0000,dmem_rdata[15:0]} : 32'h00000000;
 
   assign dmem_rdata16_1 = (r_ld_type == ld_is_16) ?  dmem_rdata[31] ? {16'hFFFF,dmem_rdata[31:24]} : {16'h0000,dmem_rdata[31:24]} :
                        (r_ld_type == ld_is_16u) ? {16'h0000,dmem_rdata[31:24]} : 32'h00000000;
                        
       assign dmem_rdata16 =   (w_alu_out[1] == 1'b1)  ? dmem_rdata16_1 : dmem_rdata16_0;
                                                 

wire [31:0] dmem_rdata_w;
 assign dmem_rdata_w =  (r_ld_type == ld_is_32) ?  dmem_rdata :
                        (r_ld_type == ld_is_16) ?  dmem_rdata16 : 
                        (r_ld_type == ld_is_8)   ? dmem_rdata8 : 
                        (r_ld_type == ld_is_16u)  ? dmem_rdata16 :
                        (r_ld_type == ld_is_8u) ?  dmem_rdata8 : 32'h00000000;
  
  
  wire [31:0] intwriteback;
   
  assign intwriteback = (multicyclerr || multicycler) ? (isFPUrr ? fpu_rslt_r : exewb_alu_o ) : exewb_alu_o;
  
 
  assign regfilein = (r_wb_type == wb_frm_alu ) ?  intwriteback :
                     (r_wb_type == wb_frm_pc4 ) ? (exewb_pc + 32'h0000_0004) :
                     (r_wb_type == wb_frm_mem ) ?  dmem_rdata_w :
                     (r_wb_type == wb_frm_csr ) ?  r_csr_rd_out : 32'b0;
                     
 
  
  
  assign dmem_addr =     ((r_ld_type != ld_is_no) || (r_st_type != st_is_no) ) ? exewb_alu_o
                       : ( ((w_ld_type != ld_is_no) || (w_st_type != st_is_no) ) && !w_csr_exp )  ? w_alu_out : 32'b0;
                       
                       
  assign dmem_sel  =     ((r_ld_type != ld_is_no) || (r_st_type != st_is_no) )  ? 1'b1
                       : ( ((w_ld_type != ld_is_no) || (w_st_type != st_is_no) ) && !w_csr_exp ) ? 1'b1 : 1'b0;
                       
                       
  assign dmem_enable =   (r_ld_type != ld_is_no) || (r_st_type != st_is_no);
  
  assign dmem_write  =  ( (w_st_type != st_is_no) && !w_csr_exp ) || (r_st_type != st_is_no) ? 1'b1 : 1'b0;

  
  assign dmem_wstrb  =    (r_st_type != st_is_no) ?  (exewb_alu_o[1:0] == 2'b00) && (r_st_type == st_is_8 ) ? STRB_8_00 :
                                                     (exewb_alu_o[1:0] == 2'b01) && (r_st_type == st_is_8 ) ? STRB_8_01 :
                                                     (exewb_alu_o[1:0] == 2'b10) && (r_st_type == st_is_8 ) ? STRB_8_10 :
                                                     (exewb_alu_o[1:0] == 2'b11) && (r_st_type == st_is_8 ) ? STRB_8_11 : 
                                                     (exewb_alu_o[1:0] == 2'b00) && (r_st_type == st_is_16) ? STRB_16_00 :
                                                     (exewb_alu_o[1:0] == 2'b10) && (r_st_type == st_is_16) ? STRB_16_10 :
                                                     (r_st_type == st_is_32) ? STRB_32 : 4'b0000 
                        :  (w_st_type != st_is_no) ?   (w_alu_out[1:0] == 2'b00) &&  (w_st_type == st_is_8 ) ? STRB_8_00 :
                                                     (w_alu_out[1:0] == 2'b01)  &&   (w_st_type == st_is_8 ) ? STRB_8_01 :
                                                     (w_alu_out[1:0] == 2'b10)  &&   (w_st_type == st_is_8 ) ? STRB_8_10 :
                                                     (w_alu_out[1:0] == 2'b11)  &&   (w_st_type == st_is_8 ) ? STRB_8_11 : 
                                                     (w_alu_out[1:0] == 2'b00)  &&   (w_st_type == st_is_16)  ? STRB_16_00 :
                                                     (w_alu_out[1:0] == 2'b10)  &&   (w_st_type == st_is_16)  ? STRB_16_10 :
                                                     (w_st_type == st_is_32) ? STRB_32 : 4'b0000 : 4'b0000 ;
  
  
  wire [31:0] stored;
  
  assign stored = isFPU ? frs2data : rs2;
  reg [31:0] storedr;
  
 
  assign dmem_wdata  =      (w_st_type != st_is_no) && !w_csr_exp ?   
                            (w_st_type == st_is_8 ) ? {stored[7:0],stored[7:0],stored[7:0],stored[7:0],stored[7:0],stored[7:0],stored[7:0],stored[7:0]}  :
                            (w_st_type == st_is_16) ? {stored[15:0],stored[15:0]} :
                            (w_st_type == st_is_32) ? stored    : 32'h0000_0000
                          : (r_st_type == st_is_8 ) ? {storedr[7:0],storedr[7:0],storedr[7:0],storedr[7:0],storedr[7:0],storedr[7:0],storedr[7:0],storedr[7:0]}  :
                            (r_st_type == st_is_16) ? {storedr[15:0],storedr[15:0]} :
                            (r_st_type == st_is_32) ? storedr    : 32'h0000_0000 ;
                         
                       
                         
  
  wire regfile_en ;
  
  
  assign regfile_en = w_wb_en && rstn;
  

  
       
  always @(posedge clk or negedge rstn) begin
  
  if(!rstn) begin
  
  fetch_inst            <= NOP;
  fetch_pc              <= 32'h0000_0000 ;
  exewb_inst            <= NOP;
  exewb_pc              <= 32'h0000_0000 ;
  exewb_alu_o           <= 32'b0;
  
  pc                    <= START_PC - 32'h0000_0004;
  //inst                  <= NOP;
  
  r_st_type              <= st_is_no;
  r_ld_type              <= ld_is_no;
  r_wb_type              <= wb_frm_alu;
  r_csr_type             <= csr_is_no;
  r_wb_en                <= no;
  fpu_r_wb_en            <= no;
  r_illegal_instruction  <= no;
  
 // rs2_r                   <= 32'b0;
  r_csr_rd_out            <= 32'b0;
  
  r_csr_exp               <= 1'b0;
  
 multicycler              <= 1'b0;
multicyclerr <= 1'b0;
exewb_rdaddr <= 5'b00000;
r_alu_operand <= 7'b0000000;
storedr <= 32'h00000000;
fpuloadsw_r <= 1'b0;
fpu_rslt_r <= 32'h00000000;
isFPUr <= 1'b0;
  end else begin
  
  
  pc           <= next_pc;
  //inst         <= next_inst;
  fpu_rslt_r <= fpu_rslt;
  
  multicycler  <= multicycler ? (mulvalid || divvalid || fpu_rdy) ? 1'b0 : 1'b1 : multicyclew;
  //isFPUr       <= multicycler ? (fpu_rdy) ? 1'b0 : 1'b1 : isFPU;
  //isFPUrr      <= isFPUr;
  
  isFPUr <= 1'b0;
  isFPUrr      <= 1'b0;
  multicyclerr <= multicycler;
  fetch_pc     <= pc;
  fetch_inst   <= inst;
  
 // if (!w_csr_exp) begin
        exewb_inst              <=   !w_csr_exp ? (multicycler || multicyclerr && (mulvalid || divvalid || fpu_rdy)) ? exewb_inst : fetch_inst : NOP;
        exewb_pc                <=   !w_csr_exp ? (multicycler || multicyclerr && (mulvalid || divvalid)) ? exewb_pc   :  fetch_pc   : 32'h0000_0000;
        exewb_alu_o             <=   !w_csr_exp ? w_alu_out  : 32'h0000_0000;
        r_st_type               <=   !w_csr_exp ? w_st_type  : st_is_no         ;
        r_ld_type               <=   !w_csr_exp ? w_ld_type  : ld_is_no         ;
        r_wb_type               <=   w_wb_type                                  ;
        r_csr_type              <=   w_csr_type                                 ;
        
       
        if(!w_csr_exp) begin 
        		if(multicycler || multicyclew) begin 
        			if (mulvalid || divvalid || fpu_rdy) begin
        				r_wb_en <= 1'b1;
        			end else begin
        				r_wb_en <= 1'b0;
        			end
        		end else begin
        			r_wb_en <= w_wb_en;
        		end
        end else begin
        	r_wb_en <= 1'b0;
        end
         
 
        			fpu_r_wb_en <= fpu_wb_en;
      
        
      
        
       
        r_illegal_instruction   <=   w_illegal_instruction;
     //   rs2_r                   <=   rs2;
        storedr                  <= stored;
        r_csr_rd_out            <=   w_csr_rd_out;
        exewb_rdaddr            <=   !w_csr_exp ? (multicycler || multicyclerr && (mulvalid || divvalid || fpu_rdy)) ? exewb_rdaddr : fetch_rd_addr : 5'b00000;
        
   
 // end
        r_alu_operand           <=   !w_csr_exp ? (multicycler || multicyclerr && (mulvalid || divvalid || fpu_rdy)) ? r_alu_operand   :  w_alu_operand   : 7'b0000000;
        
        fpuloadsw_r <= fpuloadsw_w;
  
  end
  
  
  
  
  
  end     
       
       
       
endmodule
