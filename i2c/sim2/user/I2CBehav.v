module Queue( // @[:@3.2]
  input        clock, // @[:@4.4]
  input        reset, // @[:@5.4]
  output       io_enq_ready, // @[:@6.4]
  input        io_enq_valid, // @[:@6.4]
  input  [7:0] io_enq_bits, // @[:@6.4]
  input        io_deq_ready, // @[:@6.4]
  output       io_deq_valid, // @[:@6.4]
  output [7:0] io_deq_bits // @[:@6.4]
);
  reg [7:0] ram [0:15]; // @[Decoupled.scala 214:24:@8.4]
  reg [31:0] _RAND_0;
  wire [7:0] ram__T_63_data; // @[Decoupled.scala 214:24:@8.4]
  wire [3:0] ram__T_63_addr; // @[Decoupled.scala 214:24:@8.4]
  wire [7:0] ram__T_49_data; // @[Decoupled.scala 214:24:@8.4]
  wire [3:0] ram__T_49_addr; // @[Decoupled.scala 214:24:@8.4]
  wire  ram__T_49_mask; // @[Decoupled.scala 214:24:@8.4]
  wire  ram__T_49_en; // @[Decoupled.scala 214:24:@8.4]
  reg [3:0] value; // @[Counter.scala 26:33:@9.4]
  reg [31:0] _RAND_1;
  reg [3:0] value_1; // @[Counter.scala 26:33:@10.4]
  reg [31:0] _RAND_2;
  reg  maybe_full; // @[Decoupled.scala 217:35:@11.4]
  reg [31:0] _RAND_3;
  wire  _T_41; // @[Decoupled.scala 219:41:@12.4]
  wire  _T_43; // @[Decoupled.scala 220:36:@13.4]
  wire  empty; // @[Decoupled.scala 220:33:@14.4]
  wire  _T_44; // @[Decoupled.scala 221:32:@15.4]
  wire  do_enq; // @[Decoupled.scala 37:37:@16.4]
  wire  do_deq; // @[Decoupled.scala 37:37:@19.4]
  wire [4:0] _T_52; // @[Counter.scala 35:22:@26.6]
  wire [3:0] _T_53; // @[Counter.scala 35:22:@27.6]
  wire [3:0] _GEN_5; // @[Decoupled.scala 225:17:@22.4]
  wire [4:0] _T_56; // @[Counter.scala 35:22:@32.6]
  wire [3:0] _T_57; // @[Counter.scala 35:22:@33.6]
  wire [3:0] _GEN_6; // @[Decoupled.scala 229:17:@30.4]
  wire  _T_58; // @[Decoupled.scala 232:16:@36.4]
  wire  _GEN_7; // @[Decoupled.scala 232:28:@37.4]
  assign ram__T_63_addr = value_1;
  assign ram__T_63_data = ram[ram__T_63_addr]; // @[Decoupled.scala 214:24:@8.4]
  assign ram__T_49_data = io_enq_bits;
  assign ram__T_49_addr = value;
  assign ram__T_49_mask = 1'h1;
  assign ram__T_49_en = io_enq_ready & io_enq_valid;
  assign _T_41 = value == value_1; // @[Decoupled.scala 219:41:@12.4]
  assign _T_43 = maybe_full == 1'h0; // @[Decoupled.scala 220:36:@13.4]
  assign empty = _T_41 & _T_43; // @[Decoupled.scala 220:33:@14.4]
  assign _T_44 = _T_41 & maybe_full; // @[Decoupled.scala 221:32:@15.4]
  assign do_enq = io_enq_ready & io_enq_valid; // @[Decoupled.scala 37:37:@16.4]
  assign do_deq = io_deq_ready & io_deq_valid; // @[Decoupled.scala 37:37:@19.4]
  assign _T_52 = value + 4'h1; // @[Counter.scala 35:22:@26.6]
  assign _T_53 = _T_52[3:0]; // @[Counter.scala 35:22:@27.6]
  assign _GEN_5 = do_enq ? _T_53 : value; // @[Decoupled.scala 225:17:@22.4]
  assign _T_56 = value_1 + 4'h1; // @[Counter.scala 35:22:@32.6]
  assign _T_57 = _T_56[3:0]; // @[Counter.scala 35:22:@33.6]
  assign _GEN_6 = do_deq ? _T_57 : value_1; // @[Decoupled.scala 229:17:@30.4]
  assign _T_58 = do_enq != do_deq; // @[Decoupled.scala 232:16:@36.4]
  assign _GEN_7 = _T_58 ? do_enq : maybe_full; // @[Decoupled.scala 232:28:@37.4]
  assign io_enq_ready = _T_44 == 1'h0; // @[Decoupled.scala 237:16:@43.4]
  assign io_deq_valid = empty == 1'h0; // @[Decoupled.scala 236:16:@41.4]
  assign io_deq_bits = ram__T_63_data; // @[Decoupled.scala 238:15:@45.4]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE
  integer initvar;
  initial begin
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
  _RAND_0 = {1{`RANDOM}};
  `ifdef RANDOMIZE_MEM_INIT
  for (initvar = 0; initvar < 16; initvar = initvar+1)
    ram[initvar] = _RAND_0[7:0];
  `endif // RANDOMIZE_MEM_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  value = _RAND_1[3:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_2 = {1{`RANDOM}};
  value_1 = _RAND_2[3:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_3 = {1{`RANDOM}};
  maybe_full = _RAND_3[0:0];
  `endif // RANDOMIZE_REG_INIT
  end
`endif // RANDOMIZE
  always @(posedge clock) begin
    if(ram__T_49_en & ram__T_49_mask) begin
      ram[ram__T_49_addr] <= ram__T_49_data; // @[Decoupled.scala 214:24:@8.4]
    end
    if (reset) begin
      value <= 4'h0;
    end else begin
      if (do_enq) begin
        value <= _T_53;
      end
    end
    if (reset) begin
      value_1 <= 4'h0;
    end else begin
      if (do_deq) begin
        value_1 <= _T_57;
      end
    end
    if (reset) begin
      maybe_full <= 1'h0;
    end else begin
      if (_T_58) begin
        maybe_full <= do_enq;
      end
    end
  end
endmodule
module QueueModule( // @[:@53.2]
  input        clock, // @[:@54.4]
  input        reset, // @[:@55.4]
  output       io_i_ready, // @[:@56.4]
  input        io_i_valid, // @[:@56.4]
  input  [7:0] io_i_bits, // @[:@56.4]
  input        io_o_ready, // @[:@56.4]
  output       io_o_valid, // @[:@56.4]
  output [7:0] io_o_bits // @[:@56.4]
);
  wire  qa_clock; // @[Decoupled.scala 293:21:@58.4]
  wire  qa_reset; // @[Decoupled.scala 293:21:@58.4]
  wire  qa_io_enq_ready; // @[Decoupled.scala 293:21:@58.4]
  wire  qa_io_enq_valid; // @[Decoupled.scala 293:21:@58.4]
  wire [7:0] qa_io_enq_bits; // @[Decoupled.scala 293:21:@58.4]
  wire  qa_io_deq_ready; // @[Decoupled.scala 293:21:@58.4]
  wire  qa_io_deq_valid; // @[Decoupled.scala 293:21:@58.4]
  wire [7:0] qa_io_deq_bits; // @[Decoupled.scala 293:21:@58.4]
  Queue qa ( // @[Decoupled.scala 293:21:@58.4]
    .clock(qa_clock),
    .reset(qa_reset),
    .io_enq_ready(qa_io_enq_ready),
    .io_enq_valid(qa_io_enq_valid),
    .io_enq_bits(qa_io_enq_bits),
    .io_deq_ready(qa_io_deq_ready),
    .io_deq_valid(qa_io_deq_valid),
    .io_deq_bits(qa_io_deq_bits)
  );
  assign io_i_ready = qa_io_enq_ready; // @[Decoupled.scala 296:17:@63.4]
  assign io_o_valid = qa_io_deq_valid; // @[queue.scala 17:15:@64.4]
  assign io_o_bits = qa_io_deq_bits; // @[queue.scala 18:15:@65.4]
  assign qa_clock = clock; // @[:@59.4]
  assign qa_reset = reset; // @[:@60.4]
  assign qa_io_enq_valid = io_i_valid; // @[Decoupled.scala 294:22:@61.4]
  assign qa_io_enq_bits = io_i_bits; // @[Decoupled.scala 295:21:@62.4]
  assign qa_io_deq_ready = io_o_ready; // @[queue.scala 19:15:@66.4]
endmodule
module I2CBehav( // @[:@133.2]
  input         clock, // @[:@134.4]
  input         reset, // @[:@135.4]
  input         io_PCLK, // @[:@136.4]
  input         io_PRESETn, // @[:@136.4]
  input  [7:0]  io_PADDR, // @[:@136.4]
  input         io_PPROT, // @[:@136.4]
  input         io_PSEL, // @[:@136.4]
  input         io_PENABLE, // @[:@136.4]
  input         io_PWRITE, // @[:@136.4]
  input  [7:0]  io_PWDATA, // @[:@136.4]
  input         io_PSTRB, // @[:@136.4]
  output        io_PREADY, // @[:@136.4]
  output [7:0]  io_PRDATA, // @[:@136.4]
  output        io_PSLVERR, // @[:@136.4]
  output        io_irq, // @[:@136.4]
  output        io_sda_t, // @[:@136.4]
  output        io_sda_o, // @[:@136.4]
  input         io_sda_i, // @[:@136.4]
  output        io_scl_t, // @[:@136.4]
  output        io_scl_o, // @[:@136.4]
  input         io_scl_i, // @[:@136.4]
  output [3:0]  io_doOpcodeio, // @[:@136.4]
  output [15:0] io_iiccount, // @[:@136.4]
  output [5:0]  io_txbitc, // @[:@136.4]
  output [4:0]  io_readl, // @[:@136.4]
  output        io_txcio, // @[:@136.4]
  output        io_rxcio, // @[:@136.4]
  output        io_startsentio, // @[:@136.4]
  output        io_stopsentio, // @[:@136.4]
  output        io_rstartsentio, // @[:@136.4]
  output        io_nackio // @[:@136.4]
);
  wire  QueueModule_clock; // @[i2c.scala 84:20:@176.4]
  wire  QueueModule_reset; // @[i2c.scala 84:20:@176.4]
  wire  QueueModule_io_i_ready; // @[i2c.scala 84:20:@176.4]
  wire  QueueModule_io_i_valid; // @[i2c.scala 84:20:@176.4]
  wire [7:0] QueueModule_io_i_bits; // @[i2c.scala 84:20:@176.4]
  wire  QueueModule_io_o_ready; // @[i2c.scala 84:20:@176.4]
  wire  QueueModule_io_o_valid; // @[i2c.scala 84:20:@176.4]
  wire [7:0] QueueModule_io_o_bits; // @[i2c.scala 84:20:@176.4]
  wire  QueueModule_1_clock; // @[i2c.scala 85:20:@179.4]
  wire  QueueModule_1_reset; // @[i2c.scala 85:20:@179.4]
  wire  QueueModule_1_io_i_ready; // @[i2c.scala 85:20:@179.4]
  wire  QueueModule_1_io_i_valid; // @[i2c.scala 85:20:@179.4]
  wire [7:0] QueueModule_1_io_i_bits; // @[i2c.scala 85:20:@179.4]
  wire  QueueModule_1_io_o_ready; // @[i2c.scala 85:20:@179.4]
  wire  QueueModule_1_io_o_valid; // @[i2c.scala 85:20:@179.4]
  wire [7:0] QueueModule_1_io_o_bits; // @[i2c.scala 85:20:@179.4]
  wire  _T_65; // @[i2c.scala 45:28:@140.4]
  reg  _T_68; // @[i2c.scala 46:21:@141.4]
  reg [31:0] _RAND_0;
  reg  _T_71; // @[i2c.scala 47:21:@142.4]
  reg [31:0] _RAND_1;
  reg  _T_74; // @[i2c.scala 48:21:@143.4]
  reg [31:0] _RAND_2;
  reg  _T_77; // @[i2c.scala 49:21:@144.4]
  reg [31:0] _RAND_3;
  reg [2:0] _T_85; // @[i2c.scala 53:21:@145.4]
  reg [31:0] _RAND_4;
  reg [7:0] _T_90; // @[i2c.scala 55:32:@147.4]
  reg [31:0] _RAND_5;
  reg [7:0] _T_93; // @[i2c.scala 56:32:@148.4]
  reg [31:0] _RAND_6;
  reg [7:0] _T_96; // @[i2c.scala 57:32:@149.4]
  reg [31:0] _RAND_7;
  reg [7:0] _T_99; // @[i2c.scala 58:32:@150.4]
  reg [31:0] _RAND_8;
  reg  _T_102; // @[i2c.scala 59:31:@151.4]
  reg [31:0] _RAND_9;
  reg  _T_105; // @[i2c.scala 60:31:@152.4]
  reg [31:0] _RAND_10;
  reg  _T_108; // @[i2c.scala 61:31:@153.4]
  reg [31:0] _RAND_11;
  reg [4:0] _T_111; // @[i2c.scala 62:31:@154.4]
  reg [31:0] _RAND_12;
  reg [4:0] _T_114; // @[i2c.scala 63:31:@155.4]
  reg [31:0] _RAND_13;
  reg  _T_117; // @[i2c.scala 64:31:@156.4]
  reg [31:0] _RAND_14;
  reg  _T_120; // @[i2c.scala 65:31:@157.4]
  reg [31:0] _RAND_15;
  reg  _T_123; // @[i2c.scala 66:31:@158.4]
  reg [31:0] _RAND_16;
  reg  _T_126; // @[i2c.scala 67:31:@159.4]
  reg [31:0] _RAND_17;
  reg  _T_129; // @[i2c.scala 68:31:@160.4]
  reg [31:0] _RAND_18;
  reg  _T_132; // @[i2c.scala 69:31:@161.4]
  reg [31:0] _RAND_19;
  reg  _T_135; // @[i2c.scala 70:31:@162.4]
  reg [31:0] _RAND_20;
  reg  _T_138; // @[i2c.scala 71:31:@163.4]
  reg [31:0] _RAND_21;
  reg  _T_141; // @[i2c.scala 72:31:@164.4]
  reg [31:0] _RAND_22;
  reg  _T_144; // @[i2c.scala 73:31:@165.4]
  reg [31:0] _RAND_23;
  reg  _T_147; // @[i2c.scala 74:31:@166.4]
  reg [31:0] _RAND_24;
  reg [7:0] _T_150; // @[i2c.scala 75:27:@167.4]
  reg [31:0] _RAND_25;
  reg  _T_153; // @[i2c.scala 76:27:@168.4]
  reg [31:0] _RAND_26;
  reg  _T_156; // @[i2c.scala 77:27:@169.4]
  reg [31:0] _RAND_27;
  reg [7:0] _T_162; // @[i2c.scala 79:27:@171.4]
  reg [31:0] _RAND_28;
  reg  _T_165; // @[i2c.scala 80:27:@172.4]
  reg [31:0] _RAND_29;
  reg  _T_168; // @[i2c.scala 81:27:@173.4]
  reg [31:0] _RAND_30;
  reg  _T_171; // @[i2c.scala 82:22:@174.4]
  reg [31:0] _RAND_31;
  reg [7:0] _T_174; // @[i2c.scala 83:23:@175.4]
  reg [31:0] _RAND_32;
  wire  _T_176; // @[i2c.scala 107:15:@195.4]
  wire  _T_177; // @[i2c.scala 107:28:@196.4]
  wire  _T_190; // @[i2c.scala 107:60:@198.4]
  wire  _T_191; // @[i2c.scala 107:42:@199.4]
  wire  _T_192; // @[i2c.scala 108:26:@201.6]
  wire  _T_196; // @[i2c.scala 109:20:@204.6]
  wire  _T_198; // @[i2c.scala 110:46:@207.6]
  wire  _T_199; // @[i2c.scala 110:34:@208.6]
  wire [4:0] _T_200; // @[i2c.scala 110:59:@209.6]
  wire [4:0] _T_202; // @[i2c.scala 110:20:@210.6]
  wire  _T_204; // @[i2c.scala 113:40:@216.6]
  wire  _T_205; // @[i2c.scala 113:31:@217.6]
  wire  _T_207; // @[i2c.scala 113:20:@218.6]
  wire  _T_209; // @[i2c.scala 114:31:@221.6]
  wire  _T_211; // @[i2c.scala 114:20:@222.6]
  wire  _T_213; // @[i2c.scala 115:32:@225.6]
  wire  _T_215; // @[i2c.scala 115:20:@226.6]
  wire  _GEN_0; // @[i2c.scala 107:86:@200.4]
  wire  _GEN_1; // @[i2c.scala 107:86:@200.4]
  wire [4:0] _GEN_2; // @[i2c.scala 107:86:@200.4]
  wire  _GEN_3; // @[i2c.scala 107:86:@200.4]
  wire  _T_217; // @[i2c.scala 117:18:@229.4]
  wire  _T_218; // @[i2c.scala 117:15:@230.4]
  wire  _T_219; // @[i2c.scala 117:29:@231.4]
  wire  _T_221; // @[i2c.scala 117:61:@233.4]
  wire  _T_222; // @[i2c.scala 117:43:@234.4]
  wire  _T_224; // @[i2c.scala 118:26:@236.6]
  wire  _T_226; // @[i2c.scala 118:45:@237.6]
  wire  _T_228; // @[i2c.scala 118:68:@238.6]
  wire  _T_230; // @[i2c.scala 118:87:@239.6]
  wire [1:0] _T_231; // @[Cat.scala 30:58:@240.6]
  wire [1:0] _T_232; // @[Cat.scala 30:58:@241.6]
  wire [3:0] _T_233; // @[Cat.scala 30:58:@242.6]
  wire [1:0] _T_234; // @[Cat.scala 30:58:@243.6]
  wire [1:0] _T_235; // @[Cat.scala 30:58:@244.6]
  wire [3:0] _T_236; // @[Cat.scala 30:58:@245.6]
  wire [7:0] _T_237; // @[Cat.scala 30:58:@246.6]
  wire [7:0] _GEN_4; // @[i2c.scala 117:87:@235.4]
  wire  _T_243; // @[i2c.scala 120:61:@253.4]
  wire  _T_244; // @[i2c.scala 120:43:@254.4]
  wire [1:0] _T_246; // @[Cat.scala 30:58:@256.6]
  wire [5:0] _T_247; // @[Cat.scala 30:58:@257.6]
  wire [7:0] _T_248; // @[Cat.scala 30:58:@258.6]
  wire [7:0] _GEN_5; // @[i2c.scala 120:88:@255.4]
  wire  _T_252; // @[i2c.scala 123:60:@264.4]
  wire  _T_253; // @[i2c.scala 123:42:@265.4]
  wire  _T_255; // @[i2c.scala 125:25:@269.6]
  wire  _T_256; // @[i2c.scala 126:25:@271.6]
  wire  _GEN_6; // @[i2c.scala 123:87:@266.4]
  wire  _GEN_7; // @[i2c.scala 123:87:@266.4]
  wire  _GEN_8; // @[i2c.scala 123:87:@266.4]
  wire  _T_263; // @[i2c.scala 128:43:@279.4]
  wire [1:0] _T_265; // @[Cat.scala 30:58:@281.6]
  wire [5:0] _T_266; // @[Cat.scala 30:58:@282.6]
  wire [7:0] _T_267; // @[Cat.scala 30:58:@283.6]
  wire [7:0] _GEN_9; // @[i2c.scala 128:88:@280.4]
  wire  _T_271; // @[i2c.scala 131:60:@289.4]
  wire  _T_272; // @[i2c.scala 131:42:@290.4]
  wire [7:0] _GEN_10; // @[i2c.scala 131:86:@291.4]
  wire  _T_282; // @[i2c.scala 138:43:@304.4]
  wire [7:0] _GEN_12; // @[i2c.scala 138:87:@305.4]
  wire  _T_289; // @[i2c.scala 141:61:@312.4]
  wire  _T_290; // @[i2c.scala 141:43:@313.4]
  wire [7:0] _GEN_13; // @[i2c.scala 141:87:@314.4]
  wire  _T_296; // @[i2c.scala 147:60:@324.4]
  wire  _T_297; // @[i2c.scala 147:42:@325.4]
  wire [7:0] _GEN_15; // @[i2c.scala 147:88:@326.4]
  wire  _T_301; // @[i2c.scala 150:60:@332.4]
  wire  _T_302; // @[i2c.scala 150:42:@333.4]
  wire [7:0] _GEN_16; // @[i2c.scala 150:88:@334.4]
  wire  _T_306; // @[i2c.scala 153:60:@340.4]
  wire  _T_307; // @[i2c.scala 153:42:@341.4]
  wire [7:0] _GEN_17; // @[i2c.scala 153:89:@342.4]
  wire  _T_311; // @[i2c.scala 156:60:@348.4]
  wire  _T_312; // @[i2c.scala 156:42:@349.4]
  wire [7:0] _GEN_18; // @[i2c.scala 156:89:@350.4]
  wire  _T_319; // @[i2c.scala 159:43:@358.4]
  wire [7:0] _GEN_19; // @[i2c.scala 159:89:@359.4]
  wire  _T_326; // @[i2c.scala 162:43:@367.4]
  wire [7:0] _GEN_20; // @[i2c.scala 162:89:@368.4]
  wire  _T_333; // @[i2c.scala 165:43:@376.4]
  wire [7:0] _GEN_21; // @[i2c.scala 165:90:@377.4]
  wire  _T_340; // @[i2c.scala 168:43:@385.4]
  wire [7:0] _GEN_22; // @[i2c.scala 168:90:@386.4]
  wire  _T_344; // @[i2c.scala 171:60:@392.4]
  wire  _T_345; // @[i2c.scala 171:42:@393.4]
  wire  _T_347; // @[i2c.scala 175:33:@398.6]
  wire  _GEN_23; // @[i2c.scala 171:91:@394.4]
  wire  _T_352; // @[i2c.scala 181:28:@402.4]
  wire  _T_353; // @[i2c.scala 181:24:@403.4]
  wire  _T_355; // @[i2c.scala 182:28:@404.4]
  wire  _T_356; // @[i2c.scala 182:24:@405.4]
  wire  _T_358; // @[i2c.scala 183:28:@406.4]
  wire  _T_359; // @[i2c.scala 183:24:@407.4]
  wire  _T_360; // @[i2c.scala 185:32:@408.4]
  wire  _T_362; // @[i2c.scala 185:59:@409.4]
  wire  _T_363; // @[i2c.scala 185:47:@410.4]
  wire  _T_368; // @[i2c.scala 187:45:@413.4]
  wire  _T_372; // @[i2c.scala 188:45:@416.4]
  wire  _T_374; // @[i2c.scala 188:70:@417.4]
  wire  _T_375; // @[i2c.scala 188:67:@418.4]
  wire  _T_377; // @[i2c.scala 188:77:@419.4]
  wire  _T_378; // @[i2c.scala 188:74:@420.4]
  wire [15:0] _T_379; // @[Cat.scala 30:58:@421.4]
  wire [15:0] chhp; // @[Cat.scala 30:58:@422.4]
  wire [31:0] _T_381; // @[Cat.scala 30:58:@423.4]
  wire [32:0] _T_384; // @[i2c.scala 196:31:@425.4]
  wire [31:0] _T_385; // @[i2c.scala 196:31:@426.4]
  wire [39:0] _T_387; // @[Cat.scala 30:58:@427.4]
  wire [39:0] _GEN_163; // @[i2c.scala 197:22:@428.4]
  wire [40:0] _T_388; // @[i2c.scala 197:22:@428.4]
  wire [39:0] _T_389; // @[i2c.scala 197:22:@429.4]
  wire [32:0] _T_392; // @[i2c.scala 198:21:@431.4]
  wire [31:0] _T_393; // @[i2c.scala 198:21:@432.4]
  wire [39:0] _T_395; // @[Cat.scala 30:58:@433.4]
  wire [40:0] _T_398; // @[i2c.scala 199:36:@435.4]
  wire [39:0] _T_399; // @[i2c.scala 199:36:@436.4]
  reg [31:0] _T_402; // @[i2c.scala 210:23:@437.4]
  reg [31:0] _RAND_33;
  reg [5:0] _T_405; // @[i2c.scala 211:22:@438.4]
  reg [31:0] _RAND_34;
  reg [37:0] _T_408; // @[i2c.scala 215:26:@441.4]
  reg [63:0] _RAND_35;
  wire  _T_428; // @[i2c.scala 222:28:@449.4]
  wire [1:0] _T_432; // @[Cat.scala 30:58:@453.4]
  wire [3:0] _T_434; // @[Cat.scala 30:58:@455.4]
  wire  _T_435; // @[i2c.scala 223:28:@456.4]
  wire [1:0] _T_439; // @[Cat.scala 30:58:@460.4]
  wire [3:0] _T_441; // @[Cat.scala 30:58:@462.4]
  wire  _T_442; // @[i2c.scala 224:28:@463.4]
  wire [1:0] _T_446; // @[Cat.scala 30:58:@467.4]
  wire [3:0] _T_448; // @[Cat.scala 30:58:@469.4]
  wire  _T_449; // @[i2c.scala 225:28:@470.4]
  wire [1:0] _T_453; // @[Cat.scala 30:58:@474.4]
  wire [3:0] _T_455; // @[Cat.scala 30:58:@476.4]
  wire  _T_456; // @[i2c.scala 226:28:@477.4]
  wire [1:0] _T_460; // @[Cat.scala 30:58:@481.4]
  wire [3:0] _T_462; // @[Cat.scala 30:58:@483.4]
  wire  _T_463; // @[i2c.scala 227:28:@484.4]
  wire [1:0] _T_467; // @[Cat.scala 30:58:@488.4]
  wire [3:0] _T_469; // @[Cat.scala 30:58:@490.4]
  wire  _T_470; // @[i2c.scala 228:28:@491.4]
  wire [1:0] _T_474; // @[Cat.scala 30:58:@495.4]
  wire [3:0] _T_476; // @[Cat.scala 30:58:@497.4]
  wire  _T_477; // @[i2c.scala 229:28:@498.4]
  wire [1:0] _T_481; // @[Cat.scala 30:58:@502.4]
  wire [3:0] _T_483; // @[Cat.scala 30:58:@504.4]
  reg  _T_486; // @[i2c.scala 231:54:@505.4]
  reg [31:0] _RAND_36;
  reg  _T_489; // @[i2c.scala 231:54:@506.4]
  reg [31:0] _RAND_37;
  reg  _T_492; // @[i2c.scala 231:54:@507.4]
  reg [31:0] _RAND_38;
  reg  _T_495; // @[i2c.scala 231:54:@508.4]
  reg [31:0] _RAND_39;
  reg  _T_498; // @[i2c.scala 231:54:@509.4]
  reg [31:0] _RAND_40;
  reg  _T_501; // @[i2c.scala 231:54:@510.4]
  reg [31:0] _RAND_41;
  reg  _T_504; // @[i2c.scala 231:54:@511.4]
  reg [31:0] _RAND_42;
  reg  _T_507; // @[i2c.scala 231:54:@512.4]
  reg [31:0] _RAND_43;
  wire [1:0] _T_508; // @[Cat.scala 30:58:@513.4]
  wire [1:0] _T_509; // @[Cat.scala 30:58:@514.4]
  wire [3:0] _T_510; // @[Cat.scala 30:58:@515.4]
  wire [1:0] _T_511; // @[Cat.scala 30:58:@516.4]
  wire [1:0] _T_512; // @[Cat.scala 30:58:@517.4]
  wire [3:0] _T_513; // @[Cat.scala 30:58:@518.4]
  wire [7:0] _T_514; // @[Cat.scala 30:58:@519.4]
  wire [4:0] _T_521; // @[Cat.scala 30:58:@524.4]
  wire [7:0] _T_522; // @[Cat.scala 30:58:@525.4]
  wire [11:0] _T_523; // @[Cat.scala 30:58:@526.4]
  wire [16:0] _T_524; // @[Cat.scala 30:58:@527.4]
  wire [7:0] _T_525; // @[Cat.scala 30:58:@528.4]
  wire [11:0] _T_526; // @[Cat.scala 30:58:@529.4]
  wire [8:0] _T_528; // @[Cat.scala 30:58:@531.4]
  wire [20:0] _T_529; // @[Cat.scala 30:58:@532.4]
  wire [37:0] _T_530; // @[Cat.scala 30:58:@533.4]
  wire [37:0] _T_531; // @[i2c.scala 238:21:@534.4]
  wire [1:0] _T_552; // @[Cat.scala 30:58:@554.4]
  wire [1:0] _T_553; // @[Cat.scala 30:58:@555.4]
  wire [3:0] _T_554; // @[Cat.scala 30:58:@556.4]
  reg [3:0] _T_557; // @[i2c.scala 245:24:@557.4]
  reg [31:0] _RAND_44;
  wire  _T_558; // @[i2c.scala 257:29:@566.4]
  wire  _T_559; // @[i2c.scala 257:36:@567.4]
  wire  _T_560; // @[i2c.scala 258:29:@569.4]
  wire  _T_561; // @[i2c.scala 258:36:@570.4]
  wire  _T_563; // @[Conditional.scala 37:30:@574.4]
  wire  _T_580; // @[Mux.scala 46:19:@580.8]
  wire [2:0] _T_581; // @[Mux.scala 46:16:@581.8]
  wire  _T_582; // @[Mux.scala 46:19:@582.8]
  wire [2:0] _T_583; // @[Mux.scala 46:16:@583.8]
  wire  _T_584; // @[Mux.scala 46:19:@584.8]
  wire [2:0] _T_585; // @[Mux.scala 46:16:@585.8]
  wire  _T_586; // @[Mux.scala 46:19:@586.8]
  wire [2:0] _T_587; // @[Mux.scala 46:16:@587.8]
  wire  _T_588; // @[Mux.scala 46:19:@588.8]
  wire [2:0] _T_589; // @[Mux.scala 46:16:@589.8]
  wire  _T_590; // @[Mux.scala 46:19:@590.8]
  wire [2:0] _T_591; // @[Mux.scala 46:16:@591.8]
  wire  _T_592; // @[Mux.scala 46:19:@592.8]
  wire [2:0] _T_593; // @[Mux.scala 46:16:@593.8]
  wire  _T_594; // @[Mux.scala 46:19:@594.8]
  wire [2:0] _T_595; // @[Mux.scala 46:16:@595.8]
  wire  _T_596; // @[Mux.scala 46:19:@596.8]
  wire [2:0] _T_597; // @[Mux.scala 46:16:@597.8]
  wire  _T_598; // @[Mux.scala 46:19:@598.8]
  wire [2:0] _T_599; // @[Mux.scala 46:16:@599.8]
  wire  _T_600; // @[Mux.scala 46:19:@600.8]
  wire [2:0] _T_601; // @[Mux.scala 46:16:@601.8]
  wire  _T_602; // @[Mux.scala 46:19:@602.8]
  wire [2:0] _T_603; // @[Mux.scala 46:16:@603.8]
  wire  _T_604; // @[Mux.scala 46:19:@604.8]
  wire [2:0] _T_605; // @[Mux.scala 46:16:@605.8]
  wire  _T_606; // @[Mux.scala 46:19:@606.8]
  wire [2:0] _T_607; // @[Mux.scala 46:16:@607.8]
  wire  _T_608; // @[Mux.scala 46:19:@608.8]
  wire [2:0] _T_609; // @[Mux.scala 46:16:@609.8]
  wire  _T_610; // @[Mux.scala 46:19:@610.8]
  wire [2:0] _T_611; // @[Mux.scala 46:16:@611.8]
  wire [2:0] _GEN_24; // @[i2c.scala 264:31:@576.6]
  wire  _T_612; // @[i2c.scala 286:48:@614.6]
  wire  _T_614; // @[i2c.scala 286:72:@615.6]
  wire  _T_615; // @[i2c.scala 286:69:@616.6]
  wire  _T_622; // @[Conditional.scala 37:30:@625.6]
  wire  _T_623; // @[i2c.scala 294:49:@628.8]
  wire [32:0] _T_626; // @[i2c.scala 294:71:@629.8]
  wire [31:0] _T_627; // @[i2c.scala 294:71:@630.8]
  wire [31:0] _T_628; // @[i2c.scala 294:39:@631.8]
  wire [2:0] _T_630; // @[i2c.scala 295:31:@634.8]
  wire [31:0] _GEN_164; // @[i2c.scala 296:49:@636.8]
  wire  _T_631; // @[i2c.scala 296:49:@636.8]
  wire  _T_633; // @[i2c.scala 296:39:@637.8]
  wire  _T_637; // @[i2c.scala 298:39:@641.8]
  wire [32:0] _T_640; // @[i2c.scala 300:58:@644.8]
  wire [32:0] _T_641; // @[i2c.scala 300:58:@645.8]
  wire [31:0] _T_642; // @[i2c.scala 300:58:@646.8]
  wire  _T_643; // @[i2c.scala 300:49:@647.8]
  wire  _T_645; // @[i2c.scala 300:39:@648.8]
  wire  _T_652; // @[Conditional.scala 37:30:@658.8]
  wire  _T_653; // @[i2c.scala 310:49:@661.10]
  wire [31:0] _T_658; // @[i2c.scala 310:39:@664.10]
  wire [2:0] _T_660; // @[i2c.scala 311:39:@667.10]
  wire [16:0] _T_662; // @[i2c.scala 312:58:@669.10]
  wire [16:0] _T_663; // @[i2c.scala 312:58:@670.10]
  wire [15:0] _T_664; // @[i2c.scala 312:58:@671.10]
  wire [31:0] _GEN_165; // @[i2c.scala 312:51:@672.10]
  wire  _T_665; // @[i2c.scala 312:51:@672.10]
  wire [32:0] _T_667; // @[i2c.scala 312:87:@673.10]
  wire [32:0] _T_668; // @[i2c.scala 312:87:@674.10]
  wire [31:0] _T_669; // @[i2c.scala 312:87:@675.10]
  wire  _T_670; // @[i2c.scala 312:79:@676.10]
  wire  _T_671; // @[i2c.scala 312:66:@677.10]
  wire [40:0] _T_677; // @[i2c.scala 314:63:@681.10]
  wire [40:0] _T_678; // @[i2c.scala 314:63:@682.10]
  wire [39:0] _T_679; // @[i2c.scala 314:63:@683.10]
  wire [39:0] _GEN_166; // @[i2c.scala 314:50:@684.10]
  wire  _T_680; // @[i2c.scala 314:50:@684.10]
  wire  _T_681; // @[i2c.scala 314:84:@685.10]
  wire  _T_682; // @[i2c.scala 314:71:@686.10]
  wire  _T_697; // @[Conditional.scala 37:30:@701.10]
  wire  _T_707; // @[i2c.scala 327:64:@711.12]
  wire [2:0] _T_708; // @[i2c.scala 327:39:@712.12]
  wire  _T_709; // @[i2c.scala 328:50:@714.12]
  wire  _T_717; // @[i2c.scala 330:49:@720.12]
  wire [32:0] _T_727; // @[i2c.scala 333:64:@727.12]
  wire [32:0] _T_728; // @[i2c.scala 333:64:@728.12]
  wire [31:0] _T_729; // @[i2c.scala 333:64:@729.12]
  wire  _T_730; // @[i2c.scala 333:51:@730.12]
  wire  _T_732; // @[i2c.scala 333:40:@731.12]
  wire  _T_739; // @[i2c.scala 339:39:@737.12]
  wire  _T_740; // @[Conditional.scala 37:30:@741.12]
  wire [31:0] _GEN_169; // @[i2c.scala 344:50:@744.14]
  wire  _T_741; // @[i2c.scala 344:50:@744.14]
  wire [31:0] _T_746; // @[i2c.scala 344:39:@747.14]
  wire  _T_749; // @[i2c.scala 345:70:@750.14]
  wire [6:0] _T_752; // @[i2c.scala 345:90:@751.14]
  wire [5:0] _T_753; // @[i2c.scala 345:90:@752.14]
  wire [5:0] _T_754; // @[i2c.scala 345:62:@753.14]
  wire [5:0] _T_755; // @[i2c.scala 345:39:@754.14]
  wire  _T_758; // @[i2c.scala 346:72:@757.14]
  wire  _T_759; // @[i2c.scala 346:61:@758.14]
  wire [2:0] _T_762; // @[i2c.scala 346:100:@760.14]
  wire [2:0] _T_763; // @[i2c.scala 346:85:@761.14]
  wire [2:0] _T_764; // @[i2c.scala 346:39:@762.14]
  wire [37:0] _T_765; // @[i2c.scala 347:44:@764.14]
  wire  _T_766; // @[i2c.scala 347:44:@765.14]
  wire [37:0] _T_767; // @[i2c.scala 348:44:@767.14]
  wire  _T_768; // @[i2c.scala 348:44:@768.14]
  wire [37:0] _T_769; // @[i2c.scala 349:41:@770.14]
  wire  _T_770; // @[i2c.scala 349:41:@771.14]
  wire  _T_776; // @[i2c.scala 351:81:@777.14]
  wire  _T_782; // @[i2c.scala 352:71:@781.14]
  wire  _T_783; // @[i2c.scala 352:60:@782.14]
  wire  _T_784; // @[i2c.scala 352:81:@783.14]
  wire  _T_786; // @[i2c.scala 352:39:@784.14]
  wire  _T_789; // @[Conditional.scala 37:30:@790.14]
  wire [5:0] _T_803; // @[i2c.scala 360:62:@802.16]
  wire [5:0] _T_804; // @[i2c.scala 360:39:@803.16]
  wire  _T_808; // @[i2c.scala 361:59:@807.16]
  wire  _T_810; // @[i2c.scala 361:93:@808.16]
  wire  _T_811; // @[i2c.scala 361:80:@809.16]
  wire [2:0] _T_812; // @[i2c.scala 361:38:@810.16]
  wire [5:0] _T_820; // @[i2c.scala 362:122:@816.16]
  wire [5:0] _T_821; // @[i2c.scala 362:122:@817.16]
  wire [4:0] _T_822; // @[i2c.scala 362:122:@818.16]
  wire [4:0] _T_823; // @[i2c.scala 362:84:@819.16]
  wire [4:0] _T_824; // @[i2c.scala 362:39:@820.16]
  wire  _T_828; // @[i2c.scala 365:50:@824.16]
  wire [37:0] _T_829; // @[i2c.scala 365:68:@825.16]
  wire  _T_830; // @[i2c.scala 365:68:@826.16]
  wire [37:0] _T_831; // @[i2c.scala 365:86:@827.16]
  wire  _T_832; // @[i2c.scala 365:86:@828.16]
  wire  _T_833; // @[i2c.scala 365:39:@829.16]
  wire  _T_857; // @[i2c.scala 371:46:@850.16]
  wire  _T_858; // @[i2c.scala 371:38:@851.16]
  wire  _T_860; // @[i2c.scala 372:46:@853.16]
  wire  _T_861; // @[i2c.scala 372:38:@854.16]
  wire  _T_863; // @[i2c.scala 373:46:@856.16]
  wire  _T_864; // @[i2c.scala 373:38:@857.16]
  wire  _T_866; // @[i2c.scala 374:46:@859.16]
  wire  _T_867; // @[i2c.scala 374:38:@860.16]
  wire  _T_869; // @[i2c.scala 375:46:@862.16]
  wire  _T_870; // @[i2c.scala 375:38:@863.16]
  wire  _T_872; // @[i2c.scala 376:46:@865.16]
  wire  _T_873; // @[i2c.scala 376:38:@866.16]
  wire  _T_875; // @[i2c.scala 377:46:@868.16]
  wire  _T_876; // @[i2c.scala 377:38:@869.16]
  wire  _T_878; // @[i2c.scala 378:46:@871.16]
  wire  _T_879; // @[i2c.scala 378:38:@872.16]
  wire [31:0] _GEN_26; // @[Conditional.scala 39:67:@791.14]
  wire [5:0] _GEN_27; // @[Conditional.scala 39:67:@791.14]
  wire [2:0] _GEN_28; // @[Conditional.scala 39:67:@791.14]
  wire [4:0] _GEN_29; // @[Conditional.scala 39:67:@791.14]
  wire  _GEN_30; // @[Conditional.scala 39:67:@791.14]
  wire  _GEN_31; // @[Conditional.scala 39:67:@791.14]
  wire  _GEN_32; // @[Conditional.scala 39:67:@791.14]
  wire  _GEN_33; // @[Conditional.scala 39:67:@791.14]
  wire  _GEN_34; // @[Conditional.scala 39:67:@791.14]
  wire  _GEN_35; // @[Conditional.scala 39:67:@791.14]
  wire  _GEN_36; // @[Conditional.scala 39:67:@791.14]
  wire  _GEN_37; // @[Conditional.scala 39:67:@791.14]
  wire  _GEN_38; // @[Conditional.scala 39:67:@791.14]
  wire  _GEN_39; // @[Conditional.scala 39:67:@791.14]
  wire  _GEN_40; // @[Conditional.scala 39:67:@791.14]
  wire  _GEN_41; // @[Conditional.scala 39:67:@791.14]
  wire  _GEN_42; // @[Conditional.scala 39:67:@791.14]
  wire  _GEN_43; // @[Conditional.scala 39:67:@791.14]
  wire  _GEN_44; // @[Conditional.scala 39:67:@791.14]
  wire  _GEN_45; // @[Conditional.scala 39:67:@791.14]
  wire [31:0] _GEN_47; // @[Conditional.scala 39:67:@742.12]
  wire [5:0] _GEN_48; // @[Conditional.scala 39:67:@742.12]
  wire [2:0] _GEN_49; // @[Conditional.scala 39:67:@742.12]
  wire  _GEN_50; // @[Conditional.scala 39:67:@742.12]
  wire  _GEN_51; // @[Conditional.scala 39:67:@742.12]
  wire  _GEN_52; // @[Conditional.scala 39:67:@742.12]
  wire  _GEN_53; // @[Conditional.scala 39:67:@742.12]
  wire  _GEN_54; // @[Conditional.scala 39:67:@742.12]
  wire  _GEN_55; // @[Conditional.scala 39:67:@742.12]
  wire  _GEN_56; // @[Conditional.scala 39:67:@742.12]
  wire  _GEN_57; // @[Conditional.scala 39:67:@742.12]
  wire [4:0] _GEN_58; // @[Conditional.scala 39:67:@742.12]
  wire  _GEN_59; // @[Conditional.scala 39:67:@742.12]
  wire  _GEN_60; // @[Conditional.scala 39:67:@742.12]
  wire  _GEN_61; // @[Conditional.scala 39:67:@742.12]
  wire  _GEN_62; // @[Conditional.scala 39:67:@742.12]
  wire  _GEN_63; // @[Conditional.scala 39:67:@742.12]
  wire  _GEN_64; // @[Conditional.scala 39:67:@742.12]
  wire  _GEN_65; // @[Conditional.scala 39:67:@742.12]
  wire  _GEN_66; // @[Conditional.scala 39:67:@742.12]
  wire [31:0] _GEN_68; // @[Conditional.scala 39:67:@702.10]
  wire [2:0] _GEN_69; // @[Conditional.scala 39:67:@702.10]
  wire  _GEN_70; // @[Conditional.scala 39:67:@702.10]
  wire  _GEN_71; // @[Conditional.scala 39:67:@702.10]
  wire  _GEN_72; // @[Conditional.scala 39:67:@702.10]
  wire  _GEN_73; // @[Conditional.scala 39:67:@702.10]
  wire  _GEN_74; // @[Conditional.scala 39:67:@702.10]
  wire  _GEN_75; // @[Conditional.scala 39:67:@702.10]
  wire  _GEN_76; // @[Conditional.scala 39:67:@702.10]
  wire  _GEN_77; // @[Conditional.scala 39:67:@702.10]
  wire  _GEN_78; // @[Conditional.scala 39:67:@702.10]
  wire [5:0] _GEN_79; // @[Conditional.scala 39:67:@702.10]
  wire  _GEN_80; // @[Conditional.scala 39:67:@702.10]
  wire  _GEN_81; // @[Conditional.scala 39:67:@702.10]
  wire [4:0] _GEN_82; // @[Conditional.scala 39:67:@702.10]
  wire  _GEN_83; // @[Conditional.scala 39:67:@702.10]
  wire  _GEN_84; // @[Conditional.scala 39:67:@702.10]
  wire  _GEN_85; // @[Conditional.scala 39:67:@702.10]
  wire  _GEN_86; // @[Conditional.scala 39:67:@702.10]
  wire  _GEN_87; // @[Conditional.scala 39:67:@702.10]
  wire  _GEN_88; // @[Conditional.scala 39:67:@702.10]
  wire  _GEN_89; // @[Conditional.scala 39:67:@702.10]
  wire  _GEN_90; // @[Conditional.scala 39:67:@702.10]
  wire [31:0] _GEN_92; // @[Conditional.scala 39:67:@659.8]
  wire [2:0] _GEN_93; // @[Conditional.scala 39:67:@659.8]
  wire  _GEN_94; // @[Conditional.scala 39:67:@659.8]
  wire  _GEN_95; // @[Conditional.scala 39:67:@659.8]
  wire  _GEN_96; // @[Conditional.scala 39:67:@659.8]
  wire  _GEN_97; // @[Conditional.scala 39:67:@659.8]
  wire  _GEN_98; // @[Conditional.scala 39:67:@659.8]
  wire  _GEN_99; // @[Conditional.scala 39:67:@659.8]
  wire  _GEN_100; // @[Conditional.scala 39:67:@659.8]
  wire  _GEN_101; // @[Conditional.scala 39:67:@659.8]
  wire  _GEN_102; // @[Conditional.scala 39:67:@659.8]
  wire  _GEN_103; // @[Conditional.scala 39:67:@659.8]
  wire [5:0] _GEN_104; // @[Conditional.scala 39:67:@659.8]
  wire  _GEN_105; // @[Conditional.scala 39:67:@659.8]
  wire [4:0] _GEN_106; // @[Conditional.scala 39:67:@659.8]
  wire  _GEN_107; // @[Conditional.scala 39:67:@659.8]
  wire  _GEN_108; // @[Conditional.scala 39:67:@659.8]
  wire  _GEN_109; // @[Conditional.scala 39:67:@659.8]
  wire  _GEN_110; // @[Conditional.scala 39:67:@659.8]
  wire  _GEN_111; // @[Conditional.scala 39:67:@659.8]
  wire  _GEN_112; // @[Conditional.scala 39:67:@659.8]
  wire  _GEN_113; // @[Conditional.scala 39:67:@659.8]
  wire  _GEN_114; // @[Conditional.scala 39:67:@659.8]
  wire [31:0] _GEN_116; // @[Conditional.scala 39:67:@626.6]
  wire [2:0] _GEN_117; // @[Conditional.scala 39:67:@626.6]
  wire  _GEN_118; // @[Conditional.scala 39:67:@626.6]
  wire  _GEN_119; // @[Conditional.scala 39:67:@626.6]
  wire  _GEN_120; // @[Conditional.scala 39:67:@626.6]
  wire  _GEN_121; // @[Conditional.scala 39:67:@626.6]
  wire  _GEN_122; // @[Conditional.scala 39:67:@626.6]
  wire  _GEN_123; // @[Conditional.scala 39:67:@626.6]
  wire  _GEN_124; // @[Conditional.scala 39:67:@626.6]
  wire  _GEN_125; // @[Conditional.scala 39:67:@626.6]
  wire  _GEN_126; // @[Conditional.scala 39:67:@626.6]
  wire  _GEN_127; // @[Conditional.scala 39:67:@626.6]
  wire [5:0] _GEN_128; // @[Conditional.scala 39:67:@626.6]
  wire  _GEN_129; // @[Conditional.scala 39:67:@626.6]
  wire [4:0] _GEN_130; // @[Conditional.scala 39:67:@626.6]
  wire  _GEN_131; // @[Conditional.scala 39:67:@626.6]
  wire  _GEN_132; // @[Conditional.scala 39:67:@626.6]
  wire  _GEN_133; // @[Conditional.scala 39:67:@626.6]
  wire  _GEN_134; // @[Conditional.scala 39:67:@626.6]
  wire  _GEN_135; // @[Conditional.scala 39:67:@626.6]
  wire  _GEN_136; // @[Conditional.scala 39:67:@626.6]
  wire  _GEN_137; // @[Conditional.scala 39:67:@626.6]
  wire  _GEN_138; // @[Conditional.scala 39:67:@626.6]
  wire [2:0] _GEN_139; // @[Conditional.scala 40:58:@575.4]
  wire  _GEN_140; // @[Conditional.scala 40:58:@575.4]
  wire [31:0] _GEN_141; // @[Conditional.scala 40:58:@575.4]
  wire [4:0] _GEN_142; // @[Conditional.scala 40:58:@575.4]
  wire [5:0] _GEN_143; // @[Conditional.scala 40:58:@575.4]
  wire  _GEN_144; // @[Conditional.scala 40:58:@575.4]
  wire  _GEN_146; // @[Conditional.scala 40:58:@575.4]
  wire  _GEN_147; // @[Conditional.scala 40:58:@575.4]
  wire  _GEN_148; // @[Conditional.scala 40:58:@575.4]
  wire  _GEN_149; // @[Conditional.scala 40:58:@575.4]
  wire  _GEN_150; // @[Conditional.scala 40:58:@575.4]
  wire  _GEN_151; // @[Conditional.scala 40:58:@575.4]
  wire  _GEN_152; // @[Conditional.scala 40:58:@575.4]
  wire  _GEN_153; // @[Conditional.scala 40:58:@575.4]
  wire  _GEN_154; // @[Conditional.scala 40:58:@575.4]
  wire  _GEN_155; // @[Conditional.scala 40:58:@575.4]
  wire  _GEN_156; // @[Conditional.scala 40:58:@575.4]
  wire  _GEN_157; // @[Conditional.scala 40:58:@575.4]
  wire  _GEN_158; // @[Conditional.scala 40:58:@575.4]
  wire  _GEN_159; // @[Conditional.scala 40:58:@575.4]
  wire  _GEN_160; // @[Conditional.scala 40:58:@575.4]
  wire  _GEN_161; // @[Conditional.scala 40:58:@575.4]
  wire  _GEN_162; // @[Conditional.scala 40:58:@575.4]
  QueueModule QueueModule ( // @[i2c.scala 84:20:@176.4]
    .clock(QueueModule_clock),
    .reset(QueueModule_reset),
    .io_i_ready(QueueModule_io_i_ready),
    .io_i_valid(QueueModule_io_i_valid),
    .io_i_bits(QueueModule_io_i_bits),
    .io_o_ready(QueueModule_io_o_ready),
    .io_o_valid(QueueModule_io_o_valid),
    .io_o_bits(QueueModule_io_o_bits)
  );
  QueueModule QueueModule_1 ( // @[i2c.scala 85:20:@179.4]
    .clock(QueueModule_1_clock),
    .reset(QueueModule_1_reset),
    .io_i_ready(QueueModule_1_io_i_ready),
    .io_i_valid(QueueModule_1_io_i_valid),
    .io_i_bits(QueueModule_1_io_i_bits),
    .io_o_ready(QueueModule_1_io_o_ready),
    .io_o_valid(QueueModule_1_io_o_valid),
    .io_o_bits(QueueModule_1_io_o_bits)
  );
  assign _T_65 = ~ io_PRESETn; // @[i2c.scala 45:28:@140.4]
  assign _T_176 = io_PSEL & io_PWRITE; // @[i2c.scala 107:15:@195.4]
  assign _T_177 = _T_176 & io_PENABLE; // @[i2c.scala 107:28:@196.4]
  assign _T_190 = io_PADDR == 8'h0; // @[i2c.scala 107:60:@198.4]
  assign _T_191 = _T_177 & _T_190; // @[i2c.scala 107:42:@199.4]
  assign _T_192 = io_PWDATA[0]; // @[i2c.scala 108:26:@201.6]
  assign _T_196 = _T_192 ? 1'h0 : 1'h1; // @[i2c.scala 109:20:@204.6]
  assign _T_198 = io_PWDATA[7]; // @[i2c.scala 110:46:@207.6]
  assign _T_199 = _T_192 | _T_198; // @[i2c.scala 110:34:@208.6]
  assign _T_200 = io_PWDATA[6:2]; // @[i2c.scala 110:59:@209.6]
  assign _T_202 = _T_199 ? _T_200 : 5'h0; // @[i2c.scala 110:20:@210.6]
  assign _T_204 = _T_85 == 3'h0; // @[i2c.scala 113:40:@216.6]
  assign _T_205 = _T_120 & _T_204; // @[i2c.scala 113:31:@217.6]
  assign _T_207 = _T_205 ? 1'h0 : _T_105; // @[i2c.scala 113:20:@218.6]
  assign _T_209 = _T_117 & _T_204; // @[i2c.scala 114:31:@221.6]
  assign _T_211 = _T_209 ? 1'h0 : _T_102; // @[i2c.scala 114:20:@222.6]
  assign _T_213 = _T_123 & _T_204; // @[i2c.scala 115:32:@225.6]
  assign _T_215 = _T_213 ? 1'h0 : _T_108; // @[i2c.scala 115:20:@226.6]
  assign _GEN_0 = _T_191 ? _T_192 : _T_207; // @[i2c.scala 107:86:@200.4]
  assign _GEN_1 = _T_191 ? _T_196 : _T_211; // @[i2c.scala 107:86:@200.4]
  assign _GEN_2 = _T_191 ? _T_202 : _T_111; // @[i2c.scala 107:86:@200.4]
  assign _GEN_3 = _T_191 ? _T_198 : _T_215; // @[i2c.scala 107:86:@200.4]
  assign _T_217 = io_PWRITE == 1'h0; // @[i2c.scala 117:18:@229.4]
  assign _T_218 = io_PSEL & _T_217; // @[i2c.scala 117:15:@230.4]
  assign _T_219 = _T_218 & io_PENABLE; // @[i2c.scala 117:29:@231.4]
  assign _T_221 = io_PADDR == 8'h1; // @[i2c.scala 117:61:@233.4]
  assign _T_222 = _T_219 & _T_221; // @[i2c.scala 117:43:@234.4]
  assign _T_224 = QueueModule_1_io_o_valid == 1'h0; // @[i2c.scala 118:26:@236.6]
  assign _T_226 = QueueModule_1_io_i_ready == 1'h0; // @[i2c.scala 118:45:@237.6]
  assign _T_228 = QueueModule_io_o_valid == 1'h0; // @[i2c.scala 118:68:@238.6]
  assign _T_230 = QueueModule_io_i_ready == 1'h0; // @[i2c.scala 118:87:@239.6]
  assign _T_231 = {_T_117,_T_120}; // @[Cat.scala 30:58:@240.6]
  assign _T_232 = {_T_228,_T_230}; // @[Cat.scala 30:58:@241.6]
  assign _T_233 = {_T_232,_T_231}; // @[Cat.scala 30:58:@242.6]
  assign _T_234 = {_T_226,_T_126}; // @[Cat.scala 30:58:@243.6]
  assign _T_235 = {_T_129,_T_224}; // @[Cat.scala 30:58:@244.6]
  assign _T_236 = {_T_235,_T_234}; // @[Cat.scala 30:58:@245.6]
  assign _T_237 = {_T_236,_T_233}; // @[Cat.scala 30:58:@246.6]
  assign _GEN_4 = _T_222 ? _T_237 : _T_174; // @[i2c.scala 117:87:@235.4]
  assign _T_243 = io_PADDR == 8'h2; // @[i2c.scala 120:61:@253.4]
  assign _T_244 = _T_219 & _T_243; // @[i2c.scala 120:43:@254.4]
  assign _T_246 = {_T_135,_T_138}; // @[Cat.scala 30:58:@256.6]
  assign _T_247 = {5'h0,_T_132}; // @[Cat.scala 30:58:@257.6]
  assign _T_248 = {_T_247,_T_246}; // @[Cat.scala 30:58:@258.6]
  assign _GEN_5 = _T_244 ? _T_248 : _GEN_4; // @[i2c.scala 120:88:@255.4]
  assign _T_252 = io_PADDR == 8'h3; // @[i2c.scala 123:60:@264.4]
  assign _T_253 = _T_177 & _T_252; // @[i2c.scala 123:42:@265.4]
  assign _T_255 = io_PWDATA[1]; // @[i2c.scala 125:25:@269.6]
  assign _T_256 = io_PWDATA[2]; // @[i2c.scala 126:25:@271.6]
  assign _GEN_6 = _T_253 ? _T_192 : _T_141; // @[i2c.scala 123:87:@266.4]
  assign _GEN_7 = _T_253 ? _T_255 : _T_144; // @[i2c.scala 123:87:@266.4]
  assign _GEN_8 = _T_253 ? _T_256 : _T_147; // @[i2c.scala 123:87:@266.4]
  assign _T_263 = _T_219 & _T_252; // @[i2c.scala 128:43:@279.4]
  assign _T_265 = {_T_144,_T_141}; // @[Cat.scala 30:58:@281.6]
  assign _T_266 = {5'h0,_T_147}; // @[Cat.scala 30:58:@282.6]
  assign _T_267 = {_T_266,_T_265}; // @[Cat.scala 30:58:@283.6]
  assign _GEN_9 = _T_263 ? _T_267 : _GEN_5; // @[i2c.scala 128:88:@280.4]
  assign _T_271 = io_PADDR == 8'h4; // @[i2c.scala 131:60:@289.4]
  assign _T_272 = _T_177 & _T_271; // @[i2c.scala 131:42:@290.4]
  assign _GEN_10 = _T_272 ? io_PWDATA : 8'h0; // @[i2c.scala 131:86:@291.4]
  assign _T_282 = _T_219 & _T_271; // @[i2c.scala 138:43:@304.4]
  assign _GEN_12 = _T_282 ? 8'h0 : _GEN_9; // @[i2c.scala 138:87:@305.4]
  assign _T_289 = io_PADDR == 8'h5; // @[i2c.scala 141:61:@312.4]
  assign _T_290 = _T_219 & _T_289; // @[i2c.scala 141:43:@313.4]
  assign _GEN_13 = _T_290 ? QueueModule_1_io_o_bits : _GEN_12; // @[i2c.scala 141:87:@314.4]
  assign _T_296 = io_PADDR == 8'h6; // @[i2c.scala 147:60:@324.4]
  assign _T_297 = _T_177 & _T_296; // @[i2c.scala 147:42:@325.4]
  assign _GEN_15 = _T_297 ? io_PWDATA : _T_90; // @[i2c.scala 147:88:@326.4]
  assign _T_301 = io_PADDR == 8'h7; // @[i2c.scala 150:60:@332.4]
  assign _T_302 = _T_177 & _T_301; // @[i2c.scala 150:42:@333.4]
  assign _GEN_16 = _T_302 ? io_PWDATA : _T_93; // @[i2c.scala 150:88:@334.4]
  assign _T_306 = io_PADDR == 8'h8; // @[i2c.scala 153:60:@340.4]
  assign _T_307 = _T_177 & _T_306; // @[i2c.scala 153:42:@341.4]
  assign _GEN_17 = _T_307 ? io_PWDATA : _T_96; // @[i2c.scala 153:89:@342.4]
  assign _T_311 = io_PADDR == 8'h9; // @[i2c.scala 156:60:@348.4]
  assign _T_312 = _T_177 & _T_311; // @[i2c.scala 156:42:@349.4]
  assign _GEN_18 = _T_312 ? io_PWDATA : _T_99; // @[i2c.scala 156:89:@350.4]
  assign _T_319 = _T_219 & _T_296; // @[i2c.scala 159:43:@358.4]
  assign _GEN_19 = _T_319 ? _T_90 : _GEN_13; // @[i2c.scala 159:89:@359.4]
  assign _T_326 = _T_219 & _T_301; // @[i2c.scala 162:43:@367.4]
  assign _GEN_20 = _T_326 ? _T_93 : _GEN_19; // @[i2c.scala 162:89:@368.4]
  assign _T_333 = _T_219 & _T_306; // @[i2c.scala 165:43:@376.4]
  assign _GEN_21 = _T_333 ? _T_96 : _GEN_20; // @[i2c.scala 165:90:@377.4]
  assign _T_340 = _T_219 & _T_311; // @[i2c.scala 168:43:@385.4]
  assign _GEN_22 = _T_340 ? _T_99 : _GEN_21; // @[i2c.scala 168:90:@386.4]
  assign _T_344 = io_PADDR == 8'ha; // @[i2c.scala 171:60:@392.4]
  assign _T_345 = _T_177 & _T_344; // @[i2c.scala 171:42:@393.4]
  assign _T_347 = _T_171 & QueueModule_io_o_valid; // @[i2c.scala 175:33:@398.6]
  assign _GEN_23 = _T_345 ? 1'h1 : _T_347; // @[i2c.scala 171:91:@394.4]
  assign _T_352 = _T_120 == 1'h0; // @[i2c.scala 181:28:@402.4]
  assign _T_353 = _T_105 & _T_352; // @[i2c.scala 181:24:@403.4]
  assign _T_355 = _T_117 == 1'h0; // @[i2c.scala 182:28:@404.4]
  assign _T_356 = _T_102 & _T_355; // @[i2c.scala 182:24:@405.4]
  assign _T_358 = _T_123 == 1'h0; // @[i2c.scala 183:28:@406.4]
  assign _T_359 = _T_108 & _T_358; // @[i2c.scala 183:24:@407.4]
  assign _T_360 = _T_120 | _T_123; // @[i2c.scala 185:32:@408.4]
  assign _T_362 = _T_111 == 5'h0; // @[i2c.scala 185:59:@409.4]
  assign _T_363 = _T_360 & _T_362; // @[i2c.scala 185:47:@410.4]
  assign _T_368 = _T_360 & QueueModule_io_o_valid; // @[i2c.scala 187:45:@413.4]
  assign _T_372 = _T_360 & _T_228; // @[i2c.scala 188:45:@416.4]
  assign _T_374 = _T_363 == 1'h0; // @[i2c.scala 188:70:@417.4]
  assign _T_375 = _T_372 & _T_374; // @[i2c.scala 188:67:@418.4]
  assign _T_377 = _T_129 == 1'h0; // @[i2c.scala 188:77:@419.4]
  assign _T_378 = _T_375 & _T_377; // @[i2c.scala 188:74:@420.4]
  assign _T_379 = {_T_93,_T_90}; // @[Cat.scala 30:58:@421.4]
  assign chhp = {_T_99,_T_96}; // @[Cat.scala 30:58:@422.4]
  assign _T_381 = {16'h0,_T_379}; // @[Cat.scala 30:58:@423.4]
  assign _T_384 = _T_381 + _T_381; // @[i2c.scala 196:31:@425.4]
  assign _T_385 = _T_384[31:0]; // @[i2c.scala 196:31:@426.4]
  assign _T_387 = {24'h0,chhp}; // @[Cat.scala 30:58:@427.4]
  assign _GEN_163 = {{8'd0}, _T_385}; // @[i2c.scala 197:22:@428.4]
  assign _T_388 = _GEN_163 + _T_387; // @[i2c.scala 197:22:@428.4]
  assign _T_389 = _T_388[39:0]; // @[i2c.scala 197:22:@429.4]
  assign _T_392 = _T_385 + _T_381; // @[i2c.scala 198:21:@431.4]
  assign _T_393 = _T_392[31:0]; // @[i2c.scala 198:21:@432.4]
  assign _T_395 = {24'h0,_T_379}; // @[Cat.scala 30:58:@433.4]
  assign _T_398 = _T_395 + _T_387; // @[i2c.scala 199:36:@435.4]
  assign _T_399 = _T_398[39:0]; // @[i2c.scala 199:36:@436.4]
  assign _T_428 = QueueModule_io_o_bits[7]; // @[i2c.scala 222:28:@449.4]
  assign _T_432 = {_T_428,_T_428}; // @[Cat.scala 30:58:@453.4]
  assign _T_434 = {_T_432,_T_432}; // @[Cat.scala 30:58:@455.4]
  assign _T_435 = QueueModule_io_o_bits[6]; // @[i2c.scala 223:28:@456.4]
  assign _T_439 = {_T_435,_T_435}; // @[Cat.scala 30:58:@460.4]
  assign _T_441 = {_T_439,_T_439}; // @[Cat.scala 30:58:@462.4]
  assign _T_442 = QueueModule_io_o_bits[5]; // @[i2c.scala 224:28:@463.4]
  assign _T_446 = {_T_442,_T_442}; // @[Cat.scala 30:58:@467.4]
  assign _T_448 = {_T_446,_T_446}; // @[Cat.scala 30:58:@469.4]
  assign _T_449 = QueueModule_io_o_bits[4]; // @[i2c.scala 225:28:@470.4]
  assign _T_453 = {_T_449,_T_449}; // @[Cat.scala 30:58:@474.4]
  assign _T_455 = {_T_453,_T_453}; // @[Cat.scala 30:58:@476.4]
  assign _T_456 = QueueModule_io_o_bits[3]; // @[i2c.scala 226:28:@477.4]
  assign _T_460 = {_T_456,_T_456}; // @[Cat.scala 30:58:@481.4]
  assign _T_462 = {_T_460,_T_460}; // @[Cat.scala 30:58:@483.4]
  assign _T_463 = QueueModule_io_o_bits[2]; // @[i2c.scala 227:28:@484.4]
  assign _T_467 = {_T_463,_T_463}; // @[Cat.scala 30:58:@488.4]
  assign _T_469 = {_T_467,_T_467}; // @[Cat.scala 30:58:@490.4]
  assign _T_470 = QueueModule_io_o_bits[1]; // @[i2c.scala 228:28:@491.4]
  assign _T_474 = {_T_470,_T_470}; // @[Cat.scala 30:58:@495.4]
  assign _T_476 = {_T_474,_T_474}; // @[Cat.scala 30:58:@497.4]
  assign _T_477 = QueueModule_io_o_bits[0]; // @[i2c.scala 229:28:@498.4]
  assign _T_481 = {_T_477,_T_477}; // @[Cat.scala 30:58:@502.4]
  assign _T_483 = {_T_481,_T_481}; // @[Cat.scala 30:58:@504.4]
  assign _T_508 = {_T_504,_T_507}; // @[Cat.scala 30:58:@513.4]
  assign _T_509 = {_T_498,_T_501}; // @[Cat.scala 30:58:@514.4]
  assign _T_510 = {_T_509,_T_508}; // @[Cat.scala 30:58:@515.4]
  assign _T_511 = {_T_492,_T_495}; // @[Cat.scala 30:58:@516.4]
  assign _T_512 = {_T_486,_T_489}; // @[Cat.scala 30:58:@517.4]
  assign _T_513 = {_T_512,_T_511}; // @[Cat.scala 30:58:@518.4]
  assign _T_514 = {_T_513,_T_510}; // @[Cat.scala 30:58:@519.4]
  assign _T_521 = {_T_434,1'h0}; // @[Cat.scala 30:58:@524.4]
  assign _T_522 = {_T_455,_T_448}; // @[Cat.scala 30:58:@525.4]
  assign _T_523 = {_T_522,_T_441}; // @[Cat.scala 30:58:@526.4]
  assign _T_524 = {_T_523,_T_521}; // @[Cat.scala 30:58:@527.4]
  assign _T_525 = {_T_476,_T_469}; // @[Cat.scala 30:58:@528.4]
  assign _T_526 = {_T_525,_T_462}; // @[Cat.scala 30:58:@529.4]
  assign _T_528 = {5'hf,_T_483}; // @[Cat.scala 30:58:@531.4]
  assign _T_529 = {_T_528,_T_526}; // @[Cat.scala 30:58:@532.4]
  assign _T_530 = {_T_529,_T_524}; // @[Cat.scala 30:58:@533.4]
  assign _T_531 = _T_156 ? _T_530 : _T_408; // @[i2c.scala 238:21:@534.4]
  assign _T_552 = {_T_378,_T_356}; // @[Cat.scala 30:58:@554.4]
  assign _T_553 = {_T_353,_T_368}; // @[Cat.scala 30:58:@555.4]
  assign _T_554 = {_T_553,_T_552}; // @[Cat.scala 30:58:@556.4]
  assign _T_558 = QueueModule_io_i_ready & _T_141; // @[i2c.scala 257:29:@566.4]
  assign _T_559 = _T_558 & _T_144; // @[i2c.scala 257:36:@567.4]
  assign _T_560 = QueueModule_1_io_i_ready & _T_141; // @[i2c.scala 258:29:@569.4]
  assign _T_561 = _T_560 & _T_147; // @[i2c.scala 258:36:@570.4]
  assign _T_563 = 3'h0 == _T_85; // @[Conditional.scala 37:30:@574.4]
  assign _T_580 = 4'hf == _T_554; // @[Mux.scala 46:19:@580.8]
  assign _T_581 = _T_580 ? 3'h1 : 3'h0; // @[Mux.scala 46:16:@581.8]
  assign _T_582 = 4'he == _T_554; // @[Mux.scala 46:19:@582.8]
  assign _T_583 = _T_582 ? 3'h1 : _T_581; // @[Mux.scala 46:16:@583.8]
  assign _T_584 = 4'hd == _T_554; // @[Mux.scala 46:19:@584.8]
  assign _T_585 = _T_584 ? 3'h1 : _T_583; // @[Mux.scala 46:16:@585.8]
  assign _T_586 = 4'hc == _T_554; // @[Mux.scala 46:19:@586.8]
  assign _T_587 = _T_586 ? 3'h1 : _T_585; // @[Mux.scala 46:16:@587.8]
  assign _T_588 = 4'hb == _T_554; // @[Mux.scala 46:19:@588.8]
  assign _T_589 = _T_588 ? 3'h1 : _T_587; // @[Mux.scala 46:16:@589.8]
  assign _T_590 = 4'ha == _T_554; // @[Mux.scala 46:19:@590.8]
  assign _T_591 = _T_590 ? 3'h1 : _T_589; // @[Mux.scala 46:16:@591.8]
  assign _T_592 = 4'h9 == _T_554; // @[Mux.scala 46:19:@592.8]
  assign _T_593 = _T_592 ? 3'h1 : _T_591; // @[Mux.scala 46:16:@593.8]
  assign _T_594 = 4'h8 == _T_554; // @[Mux.scala 46:19:@594.8]
  assign _T_595 = _T_594 ? 3'h1 : _T_593; // @[Mux.scala 46:16:@595.8]
  assign _T_596 = 4'h7 == _T_554; // @[Mux.scala 46:19:@596.8]
  assign _T_597 = _T_596 ? 3'h3 : _T_595; // @[Mux.scala 46:16:@597.8]
  assign _T_598 = 4'h6 == _T_554; // @[Mux.scala 46:19:@598.8]
  assign _T_599 = _T_598 ? 3'h3 : _T_597; // @[Mux.scala 46:16:@599.8]
  assign _T_600 = 4'h5 == _T_554; // @[Mux.scala 46:19:@600.8]
  assign _T_601 = _T_600 ? 3'h3 : _T_599; // @[Mux.scala 46:16:@601.8]
  assign _T_602 = 4'h4 == _T_554; // @[Mux.scala 46:19:@602.8]
  assign _T_603 = _T_602 ? 3'h3 : _T_601; // @[Mux.scala 46:16:@603.8]
  assign _T_604 = 4'h3 == _T_554; // @[Mux.scala 46:19:@604.8]
  assign _T_605 = _T_604 ? 3'h4 : _T_603; // @[Mux.scala 46:16:@605.8]
  assign _T_606 = 4'h2 == _T_554; // @[Mux.scala 46:19:@606.8]
  assign _T_607 = _T_606 ? 3'h4 : _T_605; // @[Mux.scala 46:16:@607.8]
  assign _T_608 = 4'h1 == _T_554; // @[Mux.scala 46:19:@608.8]
  assign _T_609 = _T_608 ? 3'h5 : _T_607; // @[Mux.scala 46:16:@609.8]
  assign _T_610 = 4'h0 == _T_554; // @[Mux.scala 46:19:@610.8]
  assign _T_611 = _T_610 ? 3'h0 : _T_609; // @[Mux.scala 46:16:@611.8]
  assign _GEN_24 = _T_359 ? 3'h2 : _T_611; // @[i2c.scala 264:31:@576.6]
  assign _T_612 = _T_368 & QueueModule_io_o_valid; // @[i2c.scala 286:48:@614.6]
  assign _T_614 = _T_353 == 1'h0; // @[i2c.scala 286:72:@615.6]
  assign _T_615 = _T_612 & _T_614; // @[i2c.scala 286:69:@616.6]
  assign _T_622 = 3'h1 == _T_85; // @[Conditional.scala 37:30:@625.6]
  assign _T_623 = _T_402 == _T_385; // @[i2c.scala 294:49:@628.8]
  assign _T_626 = _T_402 + 32'h1; // @[i2c.scala 294:71:@629.8]
  assign _T_627 = _T_626[31:0]; // @[i2c.scala 294:71:@630.8]
  assign _T_628 = _T_623 ? 32'h1 : _T_627; // @[i2c.scala 294:39:@631.8]
  assign _T_630 = _T_623 ? 3'h0 : 3'h1; // @[i2c.scala 295:31:@634.8]
  assign _GEN_164 = {{16'd0}, _T_379}; // @[i2c.scala 296:49:@636.8]
  assign _T_631 = _T_402 == _GEN_164; // @[i2c.scala 296:49:@636.8]
  assign _T_633 = _T_631 ? 1'h0 : _T_68; // @[i2c.scala 296:39:@637.8]
  assign _T_637 = _T_623 ? 1'h0 : _T_74; // @[i2c.scala 298:39:@641.8]
  assign _T_640 = _T_385 - 32'h2; // @[i2c.scala 300:58:@644.8]
  assign _T_641 = $unsigned(_T_640); // @[i2c.scala 300:58:@645.8]
  assign _T_642 = _T_641[31:0]; // @[i2c.scala 300:58:@646.8]
  assign _T_643 = _T_402 == _T_642; // @[i2c.scala 300:49:@647.8]
  assign _T_645 = _T_643 ? 1'h1 : _T_120; // @[i2c.scala 300:39:@648.8]
  assign _T_652 = 3'h2 == _T_85; // @[Conditional.scala 37:30:@658.8]
  assign _T_653 = _T_402 == _T_393; // @[i2c.scala 310:49:@661.10]
  assign _T_658 = _T_653 ? 32'h1 : _T_627; // @[i2c.scala 310:39:@664.10]
  assign _T_660 = _T_653 ? 3'h0 : 3'h2; // @[i2c.scala 311:39:@667.10]
  assign _T_662 = _T_379 - 16'h1; // @[i2c.scala 312:58:@669.10]
  assign _T_663 = $unsigned(_T_662); // @[i2c.scala 312:58:@670.10]
  assign _T_664 = _T_663[15:0]; // @[i2c.scala 312:58:@671.10]
  assign _GEN_165 = {{16'd0}, _T_664}; // @[i2c.scala 312:51:@672.10]
  assign _T_665 = _T_402 > _GEN_165; // @[i2c.scala 312:51:@672.10]
  assign _T_667 = _T_385 - 32'h1; // @[i2c.scala 312:87:@673.10]
  assign _T_668 = $unsigned(_T_667); // @[i2c.scala 312:87:@674.10]
  assign _T_669 = _T_668[31:0]; // @[i2c.scala 312:87:@675.10]
  assign _T_670 = _T_402 < _T_669; // @[i2c.scala 312:79:@676.10]
  assign _T_671 = _T_665 & _T_670; // @[i2c.scala 312:66:@677.10]
  assign _T_677 = _T_399 - 40'h1; // @[i2c.scala 314:63:@681.10]
  assign _T_678 = $unsigned(_T_677); // @[i2c.scala 314:63:@682.10]
  assign _T_679 = _T_678[39:0]; // @[i2c.scala 314:63:@683.10]
  assign _GEN_166 = {{8'd0}, _T_402}; // @[i2c.scala 314:50:@684.10]
  assign _T_680 = _GEN_166 > _T_679; // @[i2c.scala 314:50:@684.10]
  assign _T_681 = _GEN_166 < _T_389; // @[i2c.scala 314:84:@685.10]
  assign _T_682 = _T_680 & _T_681; // @[i2c.scala 314:71:@686.10]
  assign _T_697 = 3'h5 == _T_85; // @[Conditional.scala 37:30:@701.10]
  assign _T_707 = _T_653 & _T_228; // @[i2c.scala 327:64:@711.12]
  assign _T_708 = _T_707 ? 3'h0 : 3'h5; // @[i2c.scala 327:39:@712.12]
  assign _T_709 = _T_402 > _GEN_164; // @[i2c.scala 328:50:@714.12]
  assign _T_717 = _T_402 > _T_385; // @[i2c.scala 330:49:@720.12]
  assign _T_727 = _T_393 - 32'h2; // @[i2c.scala 333:64:@727.12]
  assign _T_728 = $unsigned(_T_727); // @[i2c.scala 333:64:@728.12]
  assign _T_729 = _T_728[31:0]; // @[i2c.scala 333:64:@729.12]
  assign _T_730 = _T_402 == _T_729; // @[i2c.scala 333:51:@730.12]
  assign _T_732 = _T_730 ? 1'h1 : _T_117; // @[i2c.scala 333:40:@731.12]
  assign _T_739 = QueueModule_io_o_valid; // @[i2c.scala 339:39:@737.12]
  assign _T_740 = 3'h3 == _T_85; // @[Conditional.scala 37:30:@741.12]
  assign _GEN_169 = {{16'd0}, chhp}; // @[i2c.scala 344:50:@744.14]
  assign _T_741 = _T_402 == _GEN_169; // @[i2c.scala 344:50:@744.14]
  assign _T_746 = _T_741 ? 32'h1 : _T_627; // @[i2c.scala 344:39:@747.14]
  assign _T_749 = _T_405 == 6'h25; // @[i2c.scala 345:70:@750.14]
  assign _T_752 = _T_405 + 6'h1; // @[i2c.scala 345:90:@751.14]
  assign _T_753 = _T_752[5:0]; // @[i2c.scala 345:90:@752.14]
  assign _T_754 = _T_749 ? 6'h2 : _T_753; // @[i2c.scala 345:62:@753.14]
  assign _T_755 = _T_741 ? _T_754 : _T_405; // @[i2c.scala 345:39:@754.14]
  assign _T_758 = _T_405 == 6'h24; // @[i2c.scala 346:72:@757.14]
  assign _T_759 = _T_741 & _T_758; // @[i2c.scala 346:61:@758.14]
  assign _T_762 = _T_228 ? 3'h0 : 3'h3; // @[i2c.scala 346:100:@760.14]
  assign _T_763 = _T_138 ? 3'h5 : _T_762; // @[i2c.scala 346:85:@761.14]
  assign _T_764 = _T_759 ? _T_763 : 3'h3; // @[i2c.scala 346:39:@762.14]
  assign _T_765 = _T_408 >> _T_405; // @[i2c.scala 347:44:@764.14]
  assign _T_766 = _T_765[0]; // @[i2c.scala 347:44:@765.14]
  assign _T_767 = 38'h1e00000000 >> _T_405; // @[i2c.scala 348:44:@767.14]
  assign _T_768 = _T_767[0]; // @[i2c.scala 348:44:@768.14]
  assign _T_769 = 38'hccccccccc >> _T_405; // @[i2c.scala 349:41:@770.14]
  assign _T_770 = _T_769[0]; // @[i2c.scala 349:41:@771.14]
  assign _T_776 = _T_759 & QueueModule_io_o_valid; // @[i2c.scala 351:81:@777.14]
  assign _T_782 = _T_405 == 6'h23; // @[i2c.scala 352:71:@781.14]
  assign _T_783 = _T_741 & _T_782; // @[i2c.scala 352:60:@782.14]
  assign _T_784 = _T_783 & io_sda_i; // @[i2c.scala 352:81:@783.14]
  assign _T_786 = _T_784 ? 1'h1 : _T_138; // @[i2c.scala 352:39:@784.14]
  assign _T_789 = 3'h4 == _T_85; // @[Conditional.scala 37:30:@790.14]
  assign _T_803 = _T_749 ? 6'h1 : _T_753; // @[i2c.scala 360:62:@802.16]
  assign _T_804 = _T_741 ? _T_803 : _T_405; // @[i2c.scala 360:39:@803.16]
  assign _T_808 = _T_741 & _T_749; // @[i2c.scala 361:59:@807.16]
  assign _T_810 = _T_114 == 5'h0; // @[i2c.scala 361:93:@808.16]
  assign _T_811 = _T_808 & _T_810; // @[i2c.scala 361:80:@809.16]
  assign _T_812 = _T_811 ? 3'h5 : 3'h4; // @[i2c.scala 361:38:@810.16]
  assign _T_820 = _T_114 - 5'h1; // @[i2c.scala 362:122:@816.16]
  assign _T_821 = $unsigned(_T_820); // @[i2c.scala 362:122:@817.16]
  assign _T_822 = _T_821[4:0]; // @[i2c.scala 362:122:@818.16]
  assign _T_823 = _T_810 ? _T_114 : _T_822; // @[i2c.scala 362:84:@819.16]
  assign _T_824 = _T_759 ? _T_823 : _T_114; // @[i2c.scala 362:39:@820.16]
  assign _T_828 = _T_114 == 5'h1; // @[i2c.scala 365:50:@824.16]
  assign _T_829 = 38'h3ffffffffe >> _T_405; // @[i2c.scala 365:68:@825.16]
  assign _T_830 = _T_829[0]; // @[i2c.scala 365:68:@826.16]
  assign _T_831 = 38'h1fffffffe >> _T_405; // @[i2c.scala 365:86:@827.16]
  assign _T_832 = _T_831[0]; // @[i2c.scala 365:86:@828.16]
  assign _T_833 = _T_828 ? _T_830 : _T_832; // @[i2c.scala 365:39:@829.16]
  assign _T_857 = _T_405 == 6'h1f; // @[i2c.scala 371:46:@850.16]
  assign _T_858 = _T_857 ? io_sda_i : _T_486; // @[i2c.scala 371:38:@851.16]
  assign _T_860 = _T_405 == 6'h1b; // @[i2c.scala 372:46:@853.16]
  assign _T_861 = _T_860 ? io_sda_i : _T_489; // @[i2c.scala 372:38:@854.16]
  assign _T_863 = _T_405 == 6'h17; // @[i2c.scala 373:46:@856.16]
  assign _T_864 = _T_863 ? io_sda_i : _T_492; // @[i2c.scala 373:38:@857.16]
  assign _T_866 = _T_405 == 6'h13; // @[i2c.scala 374:46:@859.16]
  assign _T_867 = _T_866 ? io_sda_i : _T_495; // @[i2c.scala 374:38:@860.16]
  assign _T_869 = _T_405 == 6'hf; // @[i2c.scala 375:46:@862.16]
  assign _T_870 = _T_869 ? io_sda_i : _T_498; // @[i2c.scala 375:38:@863.16]
  assign _T_872 = _T_405 == 6'hb; // @[i2c.scala 376:46:@865.16]
  assign _T_873 = _T_872 ? io_sda_i : _T_501; // @[i2c.scala 376:38:@866.16]
  assign _T_875 = _T_405 == 6'h7; // @[i2c.scala 377:46:@868.16]
  assign _T_876 = _T_875 ? io_sda_i : _T_504; // @[i2c.scala 377:38:@869.16]
  assign _T_878 = _T_405 == 6'h3; // @[i2c.scala 378:46:@871.16]
  assign _T_879 = _T_878 ? io_sda_i : _T_507; // @[i2c.scala 378:38:@872.16]
  assign _GEN_26 = _T_789 ? _T_746 : _T_402; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_27 = _T_789 ? _T_804 : _T_405; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_28 = _T_789 ? _T_812 : _T_85; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_29 = _T_789 ? _T_824 : _T_114; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_30 = _T_789 ? 1'h0 : _T_138; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_31 = _T_789 ? 1'h0 : _T_156; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_32 = _T_789 ? _T_833 : _T_68; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_33 = _T_789 ? _T_832 : _T_71; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_34 = _T_789 ? _T_770 : _T_74; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_35 = _T_789 ? 1'h0 : _T_77; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_36 = _T_789 ? _T_811 : _T_129; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_37 = _T_789 ? _T_808 : _T_165; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_38 = _T_789 ? _T_858 : _T_486; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_39 = _T_789 ? _T_861 : _T_489; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_40 = _T_789 ? _T_864 : _T_492; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_41 = _T_789 ? _T_867 : _T_495; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_42 = _T_789 ? _T_870 : _T_498; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_43 = _T_789 ? _T_873 : _T_501; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_44 = _T_789 ? _T_876 : _T_504; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_45 = _T_789 ? _T_879 : _T_507; // @[Conditional.scala 39:67:@791.14]
  assign _GEN_47 = _T_740 ? _T_746 : _GEN_26; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_48 = _T_740 ? _T_755 : _GEN_27; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_49 = _T_740 ? _T_764 : _GEN_28; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_50 = _T_740 ? _T_766 : _GEN_32; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_51 = _T_740 ? _T_768 : _GEN_33; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_52 = _T_740 ? _T_770 : _GEN_34; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_53 = _T_740 ? 1'h0 : _GEN_35; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_54 = _T_740 ? _T_776 : _GEN_31; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_55 = _T_740 ? _T_786 : _GEN_30; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_56 = _T_740 ? 1'h0 : _GEN_36; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_57 = _T_740 ? 1'h0 : _GEN_37; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_58 = _T_740 ? _T_114 : _GEN_29; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_59 = _T_740 ? _T_486 : _GEN_38; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_60 = _T_740 ? _T_489 : _GEN_39; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_61 = _T_740 ? _T_492 : _GEN_40; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_62 = _T_740 ? _T_495 : _GEN_41; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_63 = _T_740 ? _T_498 : _GEN_42; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_64 = _T_740 ? _T_501 : _GEN_43; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_65 = _T_740 ? _T_504 : _GEN_44; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_66 = _T_740 ? _T_507 : _GEN_45; // @[Conditional.scala 39:67:@742.12]
  assign _GEN_68 = _T_697 ? _T_658 : _GEN_47; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_69 = _T_697 ? _T_708 : _GEN_49; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_70 = _T_697 ? _T_709 : _GEN_52; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_71 = _T_697 ? _T_653 : _GEN_53; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_72 = _T_697 ? _T_717 : _GEN_50; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_73 = _T_697 ? _T_653 : _GEN_51; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_74 = _T_697 ? 1'h0 : _T_120; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_75 = _T_697 ? _T_732 : _T_117; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_76 = _T_697 ? 1'h0 : _T_123; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_77 = _T_697 ? _T_739 : _GEN_54; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_78 = _T_697 ? 1'h0 : _GEN_57; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_79 = _T_697 ? 6'h0 : _GEN_48; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_80 = _T_697 ? _T_138 : _GEN_55; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_81 = _T_697 ? _T_129 : _GEN_56; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_82 = _T_697 ? _T_114 : _GEN_58; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_83 = _T_697 ? _T_486 : _GEN_59; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_84 = _T_697 ? _T_489 : _GEN_60; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_85 = _T_697 ? _T_492 : _GEN_61; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_86 = _T_697 ? _T_495 : _GEN_62; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_87 = _T_697 ? _T_498 : _GEN_63; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_88 = _T_697 ? _T_501 : _GEN_64; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_89 = _T_697 ? _T_504 : _GEN_65; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_90 = _T_697 ? _T_507 : _GEN_66; // @[Conditional.scala 39:67:@702.10]
  assign _GEN_92 = _T_652 ? _T_658 : _GEN_68; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_93 = _T_652 ? _T_660 : _GEN_69; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_94 = _T_652 ? _T_671 : _GEN_72; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_95 = _T_652 ? 1'h0 : _GEN_73; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_96 = _T_652 ? _T_682 : _GEN_70; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_97 = _T_652 ? 1'h0 : _GEN_71; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_98 = _T_652 ? 1'h0 : _GEN_74; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_99 = _T_652 ? 1'h0 : _GEN_75; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_100 = _T_652 ? _T_653 : _GEN_76; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_101 = _T_652 ? 1'h0 : _GEN_80; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_102 = _T_652 ? 1'h0 : _GEN_77; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_103 = _T_652 ? 1'h0 : _GEN_78; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_104 = _T_652 ? 6'h0 : _GEN_79; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_105 = _T_652 ? _T_129 : _GEN_81; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_106 = _T_652 ? _T_114 : _GEN_82; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_107 = _T_652 ? _T_486 : _GEN_83; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_108 = _T_652 ? _T_489 : _GEN_84; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_109 = _T_652 ? _T_492 : _GEN_85; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_110 = _T_652 ? _T_495 : _GEN_86; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_111 = _T_652 ? _T_498 : _GEN_87; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_112 = _T_652 ? _T_501 : _GEN_88; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_113 = _T_652 ? _T_504 : _GEN_89; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_114 = _T_652 ? _T_507 : _GEN_90; // @[Conditional.scala 39:67:@659.8]
  assign _GEN_116 = _T_622 ? _T_628 : _GEN_92; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_117 = _T_622 ? _T_630 : _GEN_93; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_118 = _T_622 ? _T_633 : _GEN_94; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_119 = _T_622 ? 1'h0 : _GEN_95; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_120 = _T_622 ? _T_637 : _GEN_96; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_121 = _T_622 ? 1'h0 : _GEN_97; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_122 = _T_622 ? _T_645 : _GEN_98; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_123 = _T_622 ? 1'h0 : _GEN_99; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_124 = _T_622 ? 1'h0 : _GEN_100; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_125 = _T_622 ? 1'h0 : _GEN_101; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_126 = _T_622 ? 1'h0 : _GEN_102; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_127 = _T_622 ? 1'h0 : _GEN_103; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_128 = _T_622 ? 6'h0 : _GEN_104; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_129 = _T_622 ? _T_129 : _GEN_105; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_130 = _T_622 ? _T_114 : _GEN_106; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_131 = _T_622 ? _T_486 : _GEN_107; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_132 = _T_622 ? _T_489 : _GEN_108; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_133 = _T_622 ? _T_492 : _GEN_109; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_134 = _T_622 ? _T_495 : _GEN_110; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_135 = _T_622 ? _T_498 : _GEN_111; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_136 = _T_622 ? _T_501 : _GEN_112; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_137 = _T_622 ? _T_504 : _GEN_113; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_138 = _T_622 ? _T_507 : _GEN_114; // @[Conditional.scala 39:67:@626.6]
  assign _GEN_139 = _T_563 ? _GEN_24 : _GEN_117; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_140 = _T_563 ? _T_615 : _GEN_126; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_141 = _T_563 ? 32'h1 : _GEN_116; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_142 = _T_563 ? _T_111 : _GEN_130; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_143 = _T_563 ? 6'h0 : _GEN_128; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_144 = _T_563 ? 1'h0 : _GEN_127; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_146 = _T_563 ? _T_68 : _GEN_118; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_147 = _T_563 ? _T_71 : _GEN_119; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_148 = _T_563 ? _T_74 : _GEN_120; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_149 = _T_563 ? _T_77 : _GEN_121; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_150 = _T_563 ? _T_120 : _GEN_122; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_151 = _T_563 ? _T_117 : _GEN_123; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_152 = _T_563 ? _T_123 : _GEN_124; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_153 = _T_563 ? _T_138 : _GEN_125; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_154 = _T_563 ? _T_129 : _GEN_129; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_155 = _T_563 ? _T_486 : _GEN_131; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_156 = _T_563 ? _T_489 : _GEN_132; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_157 = _T_563 ? _T_492 : _GEN_133; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_158 = _T_563 ? _T_495 : _GEN_134; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_159 = _T_563 ? _T_498 : _GEN_135; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_160 = _T_563 ? _T_501 : _GEN_136; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_161 = _T_563 ? _T_504 : _GEN_137; // @[Conditional.scala 40:58:@575.4]
  assign _GEN_162 = _T_563 ? _T_507 : _GEN_138; // @[Conditional.scala 40:58:@575.4]
  assign io_PREADY = 1'h0; // @[i2c.scala 42:12:@138.4]
  assign io_PRDATA = _T_174; // @[i2c.scala 97:11:@189.4]
  assign io_PSLVERR = 1'h0; // @[i2c.scala 43:12:@139.4]
  assign io_irq = _T_135 | _T_132; // @[i2c.scala 260:11:@573.4]
  assign io_sda_t = _T_71; // @[i2c.scala 100:10:@191.4]
  assign io_sda_o = _T_68; // @[i2c.scala 101:10:@192.4]
  assign io_scl_t = _T_77; // @[i2c.scala 103:10:@194.4]
  assign io_scl_o = _T_74; // @[i2c.scala 102:10:@193.4]
  assign io_doOpcodeio = _T_557; // @[i2c.scala 247:15:@559.4]
  assign io_iiccount = _T_402[15:0]; // @[i2c.scala 213:13:@440.4]
  assign io_txbitc = _T_405; // @[i2c.scala 212:11:@439.4]
  assign io_readl = _T_114; // @[i2c.scala 98:10:@190.4]
  assign io_txcio = _T_126; // @[i2c.scala 249:20:@560.4]
  assign io_rxcio = _T_129; // @[i2c.scala 250:20:@561.4]
  assign io_startsentio = _T_120; // @[i2c.scala 251:20:@562.4]
  assign io_stopsentio = _T_117; // @[i2c.scala 252:20:@563.4]
  assign io_rstartsentio = _T_123; // @[i2c.scala 253:20:@564.4]
  assign io_nackio = _T_138; // @[i2c.scala 254:20:@565.4]
  assign QueueModule_clock = io_PCLK; // @[:@177.4]
  assign QueueModule_reset = ~ io_PRESETn; // @[:@178.4]
  assign QueueModule_io_i_valid = _T_153; // @[i2c.scala 89:19:@182.4]
  assign QueueModule_io_i_bits = _T_150; // @[i2c.scala 90:19:@183.4]
  assign QueueModule_io_o_ready = _T_156 | _T_171; // @[i2c.scala 91:19:@185.4]
  assign QueueModule_1_clock = io_PCLK; // @[:@180.4]
  assign QueueModule_1_reset = ~ io_PRESETn; // @[:@181.4]
  assign QueueModule_1_io_i_valid = _T_165; // @[i2c.scala 93:19:@186.4]
  assign QueueModule_1_io_i_bits = _T_162; // @[i2c.scala 94:19:@187.4]
  assign QueueModule_1_io_o_ready = _T_168; // @[i2c.scala 95:19:@188.4]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE
  integer initvar;
  initial begin
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
  `ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  _T_68 = _RAND_0[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  _T_71 = _RAND_1[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_2 = {1{`RANDOM}};
  _T_74 = _RAND_2[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_3 = {1{`RANDOM}};
  _T_77 = _RAND_3[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_4 = {1{`RANDOM}};
  _T_85 = _RAND_4[2:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_5 = {1{`RANDOM}};
  _T_90 = _RAND_5[7:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_6 = {1{`RANDOM}};
  _T_93 = _RAND_6[7:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_7 = {1{`RANDOM}};
  _T_96 = _RAND_7[7:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_8 = {1{`RANDOM}};
  _T_99 = _RAND_8[7:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_9 = {1{`RANDOM}};
  _T_102 = _RAND_9[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_10 = {1{`RANDOM}};
  _T_105 = _RAND_10[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_11 = {1{`RANDOM}};
  _T_108 = _RAND_11[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_12 = {1{`RANDOM}};
  _T_111 = _RAND_12[4:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_13 = {1{`RANDOM}};
  _T_114 = _RAND_13[4:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_14 = {1{`RANDOM}};
  _T_117 = _RAND_14[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_15 = {1{`RANDOM}};
  _T_120 = _RAND_15[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_16 = {1{`RANDOM}};
  _T_123 = _RAND_16[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_17 = {1{`RANDOM}};
  _T_126 = _RAND_17[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_18 = {1{`RANDOM}};
  _T_129 = _RAND_18[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_19 = {1{`RANDOM}};
  _T_132 = _RAND_19[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_20 = {1{`RANDOM}};
  _T_135 = _RAND_20[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_21 = {1{`RANDOM}};
  _T_138 = _RAND_21[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_22 = {1{`RANDOM}};
  _T_141 = _RAND_22[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_23 = {1{`RANDOM}};
  _T_144 = _RAND_23[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_24 = {1{`RANDOM}};
  _T_147 = _RAND_24[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_25 = {1{`RANDOM}};
  _T_150 = _RAND_25[7:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_26 = {1{`RANDOM}};
  _T_153 = _RAND_26[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_27 = {1{`RANDOM}};
  _T_156 = _RAND_27[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_28 = {1{`RANDOM}};
  _T_162 = _RAND_28[7:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_29 = {1{`RANDOM}};
  _T_165 = _RAND_29[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_30 = {1{`RANDOM}};
  _T_168 = _RAND_30[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_31 = {1{`RANDOM}};
  _T_171 = _RAND_31[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_32 = {1{`RANDOM}};
  _T_174 = _RAND_32[7:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_33 = {1{`RANDOM}};
  _T_402 = _RAND_33[31:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_34 = {1{`RANDOM}};
  _T_405 = _RAND_34[5:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_35 = {2{`RANDOM}};
  _T_408 = _RAND_35[37:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_36 = {1{`RANDOM}};
  _T_486 = _RAND_36[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_37 = {1{`RANDOM}};
  _T_489 = _RAND_37[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_38 = {1{`RANDOM}};
  _T_492 = _RAND_38[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_39 = {1{`RANDOM}};
  _T_495 = _RAND_39[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_40 = {1{`RANDOM}};
  _T_498 = _RAND_40[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_41 = {1{`RANDOM}};
  _T_501 = _RAND_41[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_42 = {1{`RANDOM}};
  _T_504 = _RAND_42[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_43 = {1{`RANDOM}};
  _T_507 = _RAND_43[0:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_44 = {1{`RANDOM}};
  _T_557 = _RAND_44[3:0];
  `endif // RANDOMIZE_REG_INIT
  end
`endif // RANDOMIZE
  always @(posedge io_PCLK) begin
    if (_T_65) begin
      _T_68 <= 1'h1;
    end else begin
      if (!(_T_563)) begin
        if (_T_622) begin
          if (_T_631) begin
            _T_68 <= 1'h0;
          end
        end else begin
          if (_T_652) begin
            _T_68 <= _T_671;
          end else begin
            if (_T_697) begin
              _T_68 <= _T_717;
            end else begin
              if (_T_740) begin
                _T_68 <= _T_766;
              end else begin
                if (_T_789) begin
                  if (_T_828) begin
                    _T_68 <= _T_830;
                  end else begin
                    _T_68 <= _T_832;
                  end
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_71 <= 1'h1;
    end else begin
      if (!(_T_563)) begin
        if (_T_622) begin
          _T_71 <= 1'h0;
        end else begin
          if (_T_652) begin
            _T_71 <= 1'h0;
          end else begin
            if (_T_697) begin
              _T_71 <= _T_653;
            end else begin
              if (_T_740) begin
                _T_71 <= _T_768;
              end else begin
                if (_T_789) begin
                  _T_71 <= _T_832;
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_74 <= 1'h1;
    end else begin
      if (!(_T_563)) begin
        if (_T_622) begin
          if (_T_623) begin
            _T_74 <= 1'h0;
          end
        end else begin
          if (_T_652) begin
            _T_74 <= _T_682;
          end else begin
            if (_T_697) begin
              _T_74 <= _T_709;
            end else begin
              if (_T_740) begin
                _T_74 <= _T_770;
              end else begin
                if (_T_789) begin
                  _T_74 <= _T_770;
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_77 <= 1'h1;
    end else begin
      if (!(_T_563)) begin
        if (_T_622) begin
          _T_77 <= 1'h0;
        end else begin
          if (_T_652) begin
            _T_77 <= 1'h0;
          end else begin
            if (_T_697) begin
              _T_77 <= _T_653;
            end else begin
              if (_T_740) begin
                _T_77 <= 1'h0;
              end else begin
                if (_T_789) begin
                  _T_77 <= 1'h0;
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_85 <= 3'h0;
    end else begin
      if (_T_563) begin
        if (_T_359) begin
          _T_85 <= 3'h2;
        end else begin
          if (_T_610) begin
            _T_85 <= 3'h0;
          end else begin
            if (_T_608) begin
              _T_85 <= 3'h5;
            end else begin
              if (_T_606) begin
                _T_85 <= 3'h4;
              end else begin
                if (_T_604) begin
                  _T_85 <= 3'h4;
                end else begin
                  if (_T_602) begin
                    _T_85 <= 3'h3;
                  end else begin
                    if (_T_600) begin
                      _T_85 <= 3'h3;
                    end else begin
                      if (_T_598) begin
                        _T_85 <= 3'h3;
                      end else begin
                        if (_T_596) begin
                          _T_85 <= 3'h3;
                        end else begin
                          if (_T_594) begin
                            _T_85 <= 3'h1;
                          end else begin
                            if (_T_592) begin
                              _T_85 <= 3'h1;
                            end else begin
                              if (_T_590) begin
                                _T_85 <= 3'h1;
                              end else begin
                                if (_T_588) begin
                                  _T_85 <= 3'h1;
                                end else begin
                                  if (_T_586) begin
                                    _T_85 <= 3'h1;
                                  end else begin
                                    if (_T_584) begin
                                      _T_85 <= 3'h1;
                                    end else begin
                                      if (_T_582) begin
                                        _T_85 <= 3'h1;
                                      end else begin
                                        if (_T_580) begin
                                          _T_85 <= 3'h1;
                                        end else begin
                                          _T_85 <= 3'h0;
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end else begin
        if (_T_622) begin
          if (_T_623) begin
            _T_85 <= 3'h0;
          end else begin
            _T_85 <= 3'h1;
          end
        end else begin
          if (_T_652) begin
            if (_T_653) begin
              _T_85 <= 3'h0;
            end else begin
              _T_85 <= 3'h2;
            end
          end else begin
            if (_T_697) begin
              if (_T_707) begin
                _T_85 <= 3'h0;
              end else begin
                _T_85 <= 3'h5;
              end
            end else begin
              if (_T_740) begin
                if (_T_759) begin
                  if (_T_138) begin
                    _T_85 <= 3'h5;
                  end else begin
                    if (_T_228) begin
                      _T_85 <= 3'h0;
                    end else begin
                      _T_85 <= 3'h3;
                    end
                  end
                end else begin
                  _T_85 <= 3'h3;
                end
              end else begin
                if (_T_789) begin
                  if (_T_811) begin
                    _T_85 <= 3'h5;
                  end else begin
                    _T_85 <= 3'h4;
                  end
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_90 <= 8'hc;
    end else begin
      if (_T_297) begin
        _T_90 <= io_PWDATA;
      end
    end
    if (_T_65) begin
      _T_93 <= 8'h0;
    end else begin
      if (_T_302) begin
        _T_93 <= io_PWDATA;
      end
    end
    if (_T_65) begin
      _T_96 <= 8'h6;
    end else begin
      if (_T_307) begin
        _T_96 <= io_PWDATA;
      end
    end
    if (_T_65) begin
      _T_99 <= 8'h0;
    end else begin
      if (_T_312) begin
        _T_99 <= io_PWDATA;
      end
    end
    if (_T_65) begin
      _T_102 <= 1'h0;
    end else begin
      if (_T_191) begin
        if (_T_192) begin
          _T_102 <= 1'h0;
        end else begin
          _T_102 <= 1'h1;
        end
      end else begin
        if (_T_209) begin
          _T_102 <= 1'h0;
        end
      end
    end
    if (_T_65) begin
      _T_105 <= 1'h0;
    end else begin
      if (_T_191) begin
        _T_105 <= _T_192;
      end else begin
        if (_T_205) begin
          _T_105 <= 1'h0;
        end
      end
    end
    if (_T_65) begin
      _T_108 <= 1'h0;
    end else begin
      if (_T_191) begin
        _T_108 <= _T_198;
      end else begin
        if (_T_213) begin
          _T_108 <= 1'h0;
        end
      end
    end
    if (_T_65) begin
      _T_111 <= 5'h0;
    end else begin
      if (_T_191) begin
        if (_T_199) begin
          _T_111 <= _T_200;
        end else begin
          _T_111 <= 5'h0;
        end
      end
    end
    if (_T_65) begin
      _T_114 <= 5'h0;
    end else begin
      if (_T_563) begin
        _T_114 <= _T_111;
      end else begin
        if (!(_T_622)) begin
          if (!(_T_652)) begin
            if (!(_T_697)) begin
              if (!(_T_740)) begin
                if (_T_789) begin
                  if (_T_759) begin
                    if (!(_T_810)) begin
                      _T_114 <= _T_822;
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_117 <= 1'h0;
    end else begin
      if (!(_T_563)) begin
        if (_T_622) begin
          _T_117 <= 1'h0;
        end else begin
          if (_T_652) begin
            _T_117 <= 1'h0;
          end else begin
            if (_T_697) begin
              if (_T_730) begin
                _T_117 <= 1'h1;
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_120 <= 1'h0;
    end else begin
      if (!(_T_563)) begin
        if (_T_622) begin
          if (_T_643) begin
            _T_120 <= 1'h1;
          end
        end else begin
          if (_T_652) begin
            _T_120 <= 1'h0;
          end else begin
            if (_T_697) begin
              _T_120 <= 1'h0;
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_123 <= 1'h0;
    end else begin
      if (!(_T_563)) begin
        if (_T_622) begin
          _T_123 <= 1'h0;
        end else begin
          if (_T_652) begin
            _T_123 <= _T_653;
          end else begin
            if (_T_697) begin
              _T_123 <= 1'h0;
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_126 <= 1'h1;
    end else begin
      _T_126 <= _T_204;
    end
    if (_T_65) begin
      _T_129 <= 1'h0;
    end else begin
      if (!(_T_563)) begin
        if (!(_T_622)) begin
          if (!(_T_652)) begin
            if (!(_T_697)) begin
              if (_T_740) begin
                _T_129 <= 1'h0;
              end else begin
                if (_T_789) begin
                  _T_129 <= _T_811;
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_132 <= 1'h0;
    end else begin
      _T_132 <= _T_561;
    end
    if (_T_65) begin
      _T_135 <= 1'h0;
    end else begin
      _T_135 <= _T_559;
    end
    if (_T_65) begin
      _T_138 <= 1'h0;
    end else begin
      if (!(_T_563)) begin
        if (_T_622) begin
          _T_138 <= 1'h0;
        end else begin
          if (_T_652) begin
            _T_138 <= 1'h0;
          end else begin
            if (!(_T_697)) begin
              if (_T_740) begin
                if (_T_784) begin
                  _T_138 <= 1'h1;
                end
              end else begin
                if (_T_789) begin
                  _T_138 <= 1'h0;
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_141 <= 1'h0;
    end else begin
      if (_T_253) begin
        _T_141 <= _T_192;
      end
    end
    if (_T_65) begin
      _T_144 <= 1'h0;
    end else begin
      if (_T_253) begin
        _T_144 <= _T_255;
      end
    end
    if (_T_65) begin
      _T_147 <= 1'h0;
    end else begin
      if (_T_253) begin
        _T_147 <= _T_256;
      end
    end
    if (_T_65) begin
      _T_150 <= 8'h0;
    end else begin
      if (_T_272) begin
        _T_150 <= io_PWDATA;
      end else begin
        _T_150 <= 8'h0;
      end
    end
    if (_T_65) begin
      _T_153 <= 1'h0;
    end else begin
      _T_153 <= _T_272;
    end
    if (_T_65) begin
      _T_156 <= 1'h0;
    end else begin
      if (_T_563) begin
        _T_156 <= _T_615;
      end else begin
        if (_T_622) begin
          _T_156 <= 1'h0;
        end else begin
          if (_T_652) begin
            _T_156 <= 1'h0;
          end else begin
            if (_T_697) begin
              _T_156 <= _T_739;
            end else begin
              if (_T_740) begin
                _T_156 <= _T_776;
              end else begin
                if (_T_789) begin
                  _T_156 <= 1'h0;
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_162 <= 8'h0;
    end else begin
      _T_162 <= _T_514;
    end
    if (_T_65) begin
      _T_165 <= 1'h0;
    end else begin
      if (_T_563) begin
        _T_165 <= 1'h0;
      end else begin
        if (_T_622) begin
          _T_165 <= 1'h0;
        end else begin
          if (_T_652) begin
            _T_165 <= 1'h0;
          end else begin
            if (_T_697) begin
              _T_165 <= 1'h0;
            end else begin
              if (_T_740) begin
                _T_165 <= 1'h0;
              end else begin
                if (_T_789) begin
                  _T_165 <= _T_808;
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_168 <= 1'h0;
    end else begin
      _T_168 <= _T_290;
    end
    if (_T_65) begin
      _T_171 <= 1'h0;
    end else begin
      if (_T_345) begin
        _T_171 <= 1'h1;
      end else begin
        _T_171 <= _T_347;
      end
    end
    if (_T_65) begin
      _T_174 <= 8'h0;
    end else begin
      if (_T_340) begin
        _T_174 <= _T_99;
      end else begin
        if (_T_333) begin
          _T_174 <= _T_96;
        end else begin
          if (_T_326) begin
            _T_174 <= _T_93;
          end else begin
            if (_T_319) begin
              _T_174 <= _T_90;
            end else begin
              if (_T_290) begin
                _T_174 <= QueueModule_1_io_o_bits;
              end else begin
                if (_T_282) begin
                  _T_174 <= 8'h0;
                end else begin
                  if (_T_263) begin
                    _T_174 <= _T_267;
                  end else begin
                    if (_T_244) begin
                      _T_174 <= _T_248;
                    end else begin
                      if (_T_222) begin
                        _T_174 <= _T_237;
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_402 <= 32'h1;
    end else begin
      if (_T_563) begin
        _T_402 <= 32'h1;
      end else begin
        if (_T_622) begin
          if (_T_623) begin
            _T_402 <= 32'h1;
          end else begin
            _T_402 <= _T_627;
          end
        end else begin
          if (_T_652) begin
            if (_T_653) begin
              _T_402 <= 32'h1;
            end else begin
              _T_402 <= _T_627;
            end
          end else begin
            if (_T_697) begin
              if (_T_653) begin
                _T_402 <= 32'h1;
              end else begin
                _T_402 <= _T_627;
              end
            end else begin
              if (_T_740) begin
                if (_T_741) begin
                  _T_402 <= 32'h1;
                end else begin
                  _T_402 <= _T_627;
                end
              end else begin
                if (_T_789) begin
                  if (_T_741) begin
                    _T_402 <= 32'h1;
                  end else begin
                    _T_402 <= _T_627;
                  end
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_405 <= 6'h0;
    end else begin
      if (_T_563) begin
        _T_405 <= 6'h0;
      end else begin
        if (_T_622) begin
          _T_405 <= 6'h0;
        end else begin
          if (_T_652) begin
            _T_405 <= 6'h0;
          end else begin
            if (_T_697) begin
              _T_405 <= 6'h0;
            end else begin
              if (_T_740) begin
                if (_T_741) begin
                  if (_T_749) begin
                    _T_405 <= 6'h2;
                  end else begin
                    _T_405 <= _T_753;
                  end
                end
              end else begin
                if (_T_789) begin
                  if (_T_741) begin
                    if (_T_749) begin
                      _T_405 <= 6'h1;
                    end else begin
                      _T_405 <= _T_753;
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_408 <= 38'h0;
    end else begin
      if (_T_156) begin
        _T_408 <= _T_530;
      end
    end
    if (_T_65) begin
      _T_486 <= 1'h0;
    end else begin
      if (!(_T_563)) begin
        if (!(_T_622)) begin
          if (!(_T_652)) begin
            if (!(_T_697)) begin
              if (!(_T_740)) begin
                if (_T_789) begin
                  if (_T_857) begin
                    _T_486 <= io_sda_i;
                  end
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_489 <= 1'h0;
    end else begin
      if (!(_T_563)) begin
        if (!(_T_622)) begin
          if (!(_T_652)) begin
            if (!(_T_697)) begin
              if (!(_T_740)) begin
                if (_T_789) begin
                  if (_T_860) begin
                    _T_489 <= io_sda_i;
                  end
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_492 <= 1'h0;
    end else begin
      if (!(_T_563)) begin
        if (!(_T_622)) begin
          if (!(_T_652)) begin
            if (!(_T_697)) begin
              if (!(_T_740)) begin
                if (_T_789) begin
                  if (_T_863) begin
                    _T_492 <= io_sda_i;
                  end
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_495 <= 1'h0;
    end else begin
      if (!(_T_563)) begin
        if (!(_T_622)) begin
          if (!(_T_652)) begin
            if (!(_T_697)) begin
              if (!(_T_740)) begin
                if (_T_789) begin
                  if (_T_866) begin
                    _T_495 <= io_sda_i;
                  end
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_498 <= 1'h0;
    end else begin
      if (!(_T_563)) begin
        if (!(_T_622)) begin
          if (!(_T_652)) begin
            if (!(_T_697)) begin
              if (!(_T_740)) begin
                if (_T_789) begin
                  if (_T_869) begin
                    _T_498 <= io_sda_i;
                  end
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_501 <= 1'h0;
    end else begin
      if (!(_T_563)) begin
        if (!(_T_622)) begin
          if (!(_T_652)) begin
            if (!(_T_697)) begin
              if (!(_T_740)) begin
                if (_T_789) begin
                  if (_T_872) begin
                    _T_501 <= io_sda_i;
                  end
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_504 <= 1'h0;
    end else begin
      if (!(_T_563)) begin
        if (!(_T_622)) begin
          if (!(_T_652)) begin
            if (!(_T_697)) begin
              if (!(_T_740)) begin
                if (_T_789) begin
                  if (_T_875) begin
                    _T_504 <= io_sda_i;
                  end
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_507 <= 1'h0;
    end else begin
      if (!(_T_563)) begin
        if (!(_T_622)) begin
          if (!(_T_652)) begin
            if (!(_T_697)) begin
              if (!(_T_740)) begin
                if (_T_789) begin
                  if (_T_878) begin
                    _T_507 <= io_sda_i;
                  end
                end
              end
            end
          end
        end
      end
    end
    if (_T_65) begin
      _T_557 <= 4'h0;
    end else begin
      _T_557 <= _T_554;
    end
  end
endmodule
