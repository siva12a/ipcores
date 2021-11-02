`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.06.2021 17:27:02
// Design Name: 
// Module Name: csr
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


module csr(
    input          clock,
    input          rst_n,
    input [2:0]    csr_cmd,
    input [11:0]   csr_address,
    input [31:0]   csr_rs1_in,
    input [31:0]   z_immediate,
    input          w_a_mux,
    input [4:0]    rs_addr,
    input [4:0]    rd_addr,
    
    input          ext_intr_in,
    input          tmr_intr_in,
    
    input  [31:0]  pc,
    
    output  reg  [31:0]     csr_rd_out,
    input [31:0]   load_addr,
    input [31:0]   store_addr,
    input [31:0]   branch_addr,
    input          branch_taken,
    input          illegal_inst,
    input [2:0]    st_type,
    input [2:0]    ld_type,
    input [2:0]    br_type,
    input [31:0]   inst,
    
    output         csr_exp,
    output [31:0]  evict_pc,
    output [31:0]  exp_pc
    );
    
    
    

 
 // read only 
 localparam mvendorid    = 32'h0000_0000;
 localparam marchid      = 32'h0000_0000;
 localparam mimid        = 32'h0000_0000;
 localparam mhartid      = 32'h000c_0000;
 
 // read only 
 localparam mvendorid_addr    = 12'hF11;
 localparam marchid_addr     = 12'hF12;
 localparam mimid_addr       = 12'hF13;
 localparam mhartid_addr     = 12'hF14;    
 
 // read write 
  localparam misa         = 32'b01000000000000000000000100000000;
  
  // machine trap setup 
 localparam mstatus_addr     = 12'h300;
 localparam misa_addr        = 12'h301;
 localparam medeleg_addr     = 12'h302;
 localparam mideleg_addr     = 12'h303; 
 localparam mie_addr         = 12'h304; 
 localparam mtvec_addr       = 12'h305; 
 localparam mcounteren_addr  = 12'h306; 
 
   // machine trap handle
   
 localparam mscratch_addr    = 12'h340;
 localparam mepc_addr        = 12'h341;
 localparam mcause_addr      = 12'h342;
 localparam mtval_addr       = 12'h343; 
 localparam mip_addr         = 12'h344;   
 
 
 // machine timers counter
 localparam mcycle_addr     = 12'hB00;
 localparam minstret_addr   = 12'hB02;
 
 
 parameter csr_is_no       = 3'b000;
 parameter csr_is_wr       = 3'b001;
 parameter csr_is_set      = 3'b010;
 parameter csr_is_clr      = 3'b011;
 parameter csr_is_ecall    = 3'b100;
 parameter csr_is_ebreak   = 3'b101;
 parameter csr_is_eret     = 3'b110;
 
 parameter st_is_no      = 3'b000;
 parameter st_is_32      = 3'b001;
 parameter st_is_16      = 3'b010;
 parameter st_is_8       = 3'b011;
  
 
  // ld_type
 parameter ld_is_no      = 3'b000;
 parameter ld_is_32      = 3'b001;
 parameter ld_is_16      = 3'b010;
 parameter ld_is_8       = 3'b011;
 parameter ld_is_16u     = 3'b100;
 parameter ld_is_8u      = 3'b101;
 
 parameter br_is_no  = 3'b000;
 
 reg [1:0] mpp;
 reg [31:0] mtvec;
 reg [31:0] mtval;
 reg [31:0] mepc;
 wire [31:0] evict_pc_w;
 // machine timer interrupt pending, machine sw interrupt pending , machine external interrup pending
 wire  mtip , meip;
 reg   msip;
  // machine timer interrupt enable, machine sw interrupt enable , machine external interrup enable
 reg  mtie , msie, meie;
 // machine previous interrupt enable , machine current interrupt enable
 reg  mpie, mie;
 
 reg [63:0] mcycle;
 reg [63:0] minst;
 reg [31:0] mcause;
 reg [31:0] mscratch;
 
 
 
 
 
 wire interrupt;
 wire timer_intr;
 wire ext_intr;
 wire sw_intr;
 wire vectored_pc;
 wire [31:0] vec_tmr_pc;
 wire [31:0] vec_sw_pc;
 wire [31:0] vec_ext_pc;
 
 wire [31:0] csr_in;
 wire [31:0] csr_wdata;
 wire csr_write;
 wire csr_write_0;
 wire csr_wen;
 wire [31:0] csr_out;
 
 wire br_addr_invalid;
 wire ld_addr_invalid;
 wire sr_addr_invalid;
 wire csr_read_only;
 
 wire exception;
 wire exec_intr;
 wire [31:0] mtval_w;
 wire env_breakpoint;
 
  assign timer_intr  = mie & (mtip & mtie);
  assign sw_intr     = mie & (msip & msie);
  assign ext_intr    = mie & (meip & meie);
  assign interrupt   = ext_intr | timer_intr | sw_intr;
  assign vectored_pc = mtvec[1:0] == 2'b00;
  assign vec_tmr_pc  = vectored_pc ? {mtvec[31:2],2'b00} : ({mtvec[31:2],2'b00} + 32'h0000_0000) ; // TODO
  assign vec_sw_pc   = vectored_pc ? {mtvec[31:2],2'b00} : ({mtvec[31:2],2'b00} + 32'h0000_0000) ;
  assign vec_ext_pc  = vectored_pc ? {mtvec[31:2],2'b00} : ({mtvec[31:2],2'b00} + 32'h0000_0000) ;
 
  assign meip      = ext_intr_in;
  assign mtip      = tmr_intr_in;
 
   
  assign evict_pc_w  = timer_intr  ? vec_tmr_pc :
                       sw_intr     ? vec_sw_pc  :
                       ext_intr    ? vec_ext_pc : 32'h0000_0000;
 
  assign evict_pc = evict_pc_w;
 
  // csr input can be rs1 or z immediate , this is selected here
  assign csr_in = w_a_mux ? csr_rs1_in : z_immediate;
  
  // csr cannot be written if rs_addr is zero or z_immediate
  assign csr_write =  w_a_mux ? (rs_addr != 5'b00000) : (z_immediate == 32'h0000_0000) ;
  
  assign csr_write_0 =  (csr_cmd == csr_is_set) | (csr_cmd == csr_is_clr) | (csr_cmd == csr_is_wr);
                        
  
  assign csr_wen  = (csr_write & csr_write_0);
  
  assign csr_wdata = (csr_cmd == csr_is_no) ? 32'h0000_0000 :
                     (csr_cmd == csr_is_wr) ? csr_in :
                     (csr_cmd == csr_is_set) ? (csr_out | csr_in) :
                     (csr_cmd == csr_is_clr) ? (csr_out  & ~csr_in) : 32'h0000_0000 ;
  /////////////////////////////////////////////////////////////////////////

 // branch instruction and branch taken and branch address[1:0] is not 2'b00
  assign br_addr_invalid = ( (br_type != br_is_no) && branch_taken && (branch_addr[1:0] != 2'b00) );       
  
  assign ld_addr_invalid = ((ld_type == ld_is_no) & 1'b0) |
                           ((ld_type == ld_is_32 ) & (load_addr[1:0] != 2'b00))   |
                           (( (ld_type == ld_is_16) | (ld_type == ld_is_16u) ) & load_addr[0]);
                           
  assign st_addr_invalid = ((st_type == st_is_no) & 1'b0)  |
                           ((st_type == st_is_32) & (store_addr[1:0] != 2'b00)) |
                           ((st_type == st_is_16) & (store_addr[0]));        
 
  assign csr_read_only   = (csr_address[11:10] == 2'b11);                        
  
  // csr[2] denotes it is ecall ebreak  
  assign exception =   illegal_inst | br_addr_invalid | ld_addr_invalid | st_addr_invalid | (csr_read_only & csr_wen) | (csr_cmd == csr_is_ecall) | (csr_cmd == csr_is_ebreak);    
  
  assign mtval_w   =   illegal_inst    ?   inst :
                       br_addr_invalid ?   branch_addr   :
                       ld_addr_invalid ?   load_addr     :
                       st_addr_invalid ?   store_addr    : 32'h0000_0000;                     
                                        
  assign exec_intr = interrupt | exception;
  
  assign csr_exp   = exec_intr;
                                      
  assign exp_pc      = mepc;
  
  assign env_breakpoint = (csr_cmd == csr_is_ebreak);
  assign ecall = (csr_cmd == csr_is_ecall);
  
  always @(csr_address or rd_addr) begin
    if (rd_addr == 5'b00000) begin
        csr_rd_out <= 32'h0000_00000;
  end else begin
        case(csr_address)
        
        mvendorid_addr : begin csr_rd_out <= mvendorid ; end
        marchid_addr   : begin csr_rd_out <= marchid   ; end
        mimid_addr     : begin csr_rd_out <= mimid     ; end
        mhartid_addr   : begin csr_rd_out <= mhartid   ; end
        
        mstatus_addr    : begin csr_rd_out <= $unsigned({2'b11,2'b00,1'b0,mpie,3'b000,mie,3'b000}); end
        misa_addr       : begin csr_rd_out <= misa; end
        medeleg_addr    : begin csr_rd_out <= 32'h0000_0000; end
        mideleg_addr    : begin csr_rd_out <= 32'h0000_0000; end
        mie_addr        : begin csr_rd_out <= $unsigned({meie,3'b000,mtie,3'b000,msie,3'b000}); end
        mtvec_addr      : begin csr_rd_out <= mtvec; end
        mcounteren_addr : begin csr_rd_out <= 32'h0000_00000; end
        
        mscratch_addr   : begin csr_rd_out <= mscratch; end
        mepc_addr       : begin csr_rd_out <= mepc; end
        mcause_addr     : begin csr_rd_out <= interrupt ? {1'b1,19'b0,ext_intr,3'b000,timer_intr,3'b000,sw_intr,3'b000} :
                                              exception ? {1'b0,19'b0,ecall,4'b000,st_addr_invalid,1'b0,ld_addr_invalid,env_breakpoint,illegal_inst,2'b0} : 32'b0; end
        mtval_addr      : begin csr_rd_out <= mtval; end
        mip_addr        : begin csr_rd_out <= $unsigned({meip,3'b000,mtip,3'b000,msip,3'b000}); end
    endcase
   
  end
  end
                     
 always @(posedge clock or negedge rst_n) begin
    if (!rst_n) begin
    
        mpp    <= 2'b11; //always 11 to denote machine mode
        mtvec  <= 32'h0000_0000;
        mtval  <= 32'h0000_0000;
        mepc   <= 32'h0000_1000;
        mscratch <= 32'h0000_0000;
        msip   <= 1'b0;
        mpie   <= 1'b0;
        mie    <= 1'b1;
        mcause <= 32'h0000_0000;
        // interrupt enable bits
        mtie   <= 1'b1;
        msie   <= 1'b1;
        meie   <= 1'b1;
        
 end else begin
        
        if(exec_intr) begin
            // if exception or interrupt save current pc in mepc
            mepc    <= pc;
            mie     <= 1'b0;
            mpie    <= mie;
            mtval   <= mtval_w;
       end  else if (csr_cmd == csr_is_eret) begin
           
            mie     <= mpie;
            mpie    <= 1'b1;
            
       end else if (csr_wen) begin
       
          case (csr_address) 
          
          mstatus_addr    : begin 
                   mie  <= csr_wdata[3];
                   mpie <= csr_wdata[7];
          end
         // misa_addr       : begin end
          mie_addr        : begin 
                   mtie   <= csr_wdata[7];
                   msie   <= csr_wdata[3];
                   meie   <= csr_wdata[11];
          end
          mtvec_addr      : begin mtvec <= csr_wdata; end
          mcounteren_addr : begin end
          
          
          mscratch_addr   : begin mscratch <= csr_wdata; end
          mepc_addr       : begin mepc     <= {csr_wdata[31:1],2'b00}; end
          mcause_addr     : begin mcause   <= csr_wdata; end 
          mtval_addr      : begin mtval    <= csr_wdata; end
          mip_addr        : begin msip     <= csr_wdata[3]; end
          endcase    
       end
        
        
 
 end
 end
    
endmodule
