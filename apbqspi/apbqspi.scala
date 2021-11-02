

package apbqspi

import chisel3._
import chisel3.experimental._
import chisel3.util._
import chisel3.util.BitPat

import Address_apbqspi._




class apbqspi_ssp(depth: Int) extends Module  {

val io = IO(new Bundle {


val  PCLK              = Input(Clock())  // system control clock 
val  PRESETn           = Input(Bool())  // system control reset active low
val  PADDR             = Input(UInt(32.W))   
val  PPROT             = Input(Bool())
val  PSEL              = Input(Bool())
val  PENABLE           = Input(Bool())
val  PWRITE            = Input(Bool())
val  PWDATA            = Input(UInt(32.W))    
val  PSTRB             = Input(UInt(4.W))

val  PREADY            = Output(Bool())
val  PRDATA            = Output(Bits(32.W))  
val  PSLVERR           = Output(Bool())
 
val interrupt          = Output(Bool()) // interrupt request active high.


 // QSPI portrs



val io0_i = Input(Bool())
val io0_o = Output(Bool())
val io0_t = Output(Bool())

val io1_i = Input(Bool())
val io1_o = Output(Bool())
val io1_t = Output(Bool())

val io2_i = Input(Bool())
val io2_o = Output(Bool())
val io2_t = Output(Bool())

val io3_i = Input(Bool())
val io3_o = Output(Bool())
val io3_t = Output(Bool())

val spi_clk_i = Input(Bool())
val spi_clk_o = Output(Bool())
val spi_clk_t = Output(Bool())

val spi_ssel_i = Input(Bool())
val spi_ssel_o = Output(UInt(8.W)) 
val spi_ssel_t = Output(Bool()) 

})


io.spi_ssel_t := false.B
io.spi_clk_t := false.B



io.PREADY    := 1.U;
io.PSLVERR   := 0.U;

val interrupt_r = RegInit(false.B)
io.interrupt := interrupt_r



// state machine state declaration /////////////////

//  pclk domain
withClockAndReset(io.PCLK, !io.PRESETn) {
//
//
val qspien      = RegInit(false.B)
val trien       = RegInit(false.B)

val io0_or = RegInit(true.B)
val io1_or = RegInit(true.B)
val io2_or = RegInit(true.B)
val io3_or = RegInit(true.B)

val io0_tr = RegInit(false.B)
val io1_tr = RegInit(true.B)
val io2_tr = RegInit(true.B)
val io3_tr = RegInit(true.B)

io.io3_o := Mux(io3_tr,true.B,io3_or)
io.io2_o := Mux(io2_tr,true.B,io2_or)
io.io1_o := Mux(io1_tr,true.B,io1_or)
io.io0_o := Mux(io0_tr,true.B,io0_or)

io.io3_t := io3_tr
io.io2_t := io2_tr
io.io1_t := io1_tr
io.io0_t := io0_tr




val spi_clk_o = RegInit(false.B)

val spi_clk_t_r = RegInit(false.B)

val spi_ssel_o = RegInit(255.U(8.W)) 
val spi_ssel_t = RegInit(false.B) 

io.spi_clk_o := spi_clk_o
io.spi_ssel_o := spi_ssel_o


val rdata = RegInit(0.U(32.W))
io.PRDATA := rdata

val (s_IDLE :: s_TXDEQ :: s_TXDEQ1 ::  s_TXRD :: Nil) = Enum(4)
val (s_IDLERX :: s_RXRD :: Nil) = Enum(2)

val txstate = RegInit(s_IDLE)
val rxstate = RegInit(s_IDLERX)

///////////////////////////////////// FIFO definitions ////////////////
val txfifo_io3 = Module(new FIFO_qspi(5,3))
val txfifo_io2 = Module(new FIFO_qspi(5,3))
val txfifo_io1 = Module(new FIFO_qspi(5,3))
val txfifo_io0 = Module(new FIFO_qspi(17,3))  // this fifo is for qspi and spi


val rxfifo = Module(new RXFIFO(8,8))
rxfifo.io.systemRst := !io.PRESETn
rxfifo.io.writeClk  := io.PCLK
rxfifo.io.readClk   := io.PCLK


val tx_ff_rdata3  = txfifo_io3.io.dataOut
val tx_ff_rdata2  = txfifo_io2.io.dataOut
val tx_ff_rdata1  = txfifo_io1.io.dataOut
val tx_ff_rdata0  = txfifo_io0.io.dataOut


val tx_ff_rdatar3 = RegInit(0.U(5.W))
val tx_ff_rdatar2 = RegInit(0.U(5.W))
val tx_ff_rdatar1 = RegInit(0.U(5.W))
val tx_ff_rdatar0 = RegInit(0.U(17.W))





txfifo_io3.io.systemRst := !io.PRESETn
txfifo_io3.io.writeClk  := io.PCLK
txfifo_io3.io.readClk   := io.PCLK

txfifo_io2.io.systemRst := !io.PRESETn
txfifo_io2.io.writeClk  := io.PCLK
txfifo_io2.io.readClk   := io.PCLK

txfifo_io1.io.systemRst := !io.PRESETn
txfifo_io1.io.writeClk  := io.PCLK
txfifo_io1.io.readClk   := io.PCLK

txfifo_io0.io.systemRst := !io.PRESETn
txfifo_io0.io.writeClk  := io.PCLK
txfifo_io0.io.readClk   := io.PCLK

val tx_ff_wdata3  = RegInit(0.U(5.W))
val tx_ff_wdata2  = RegInit(0.U(5.W))
val tx_ff_wdata1  = RegInit(0.U(5.W))
val tx_ff_wdata0  = RegInit(0.U(17.W))


val tx_ff_wen     = RegInit(false.B)

txfifo_io3.io.writeEn := Mux(qspien,tx_ff_wen,false.B)
txfifo_io2.io.writeEn := Mux(qspien,tx_ff_wen,false.B)
txfifo_io1.io.writeEn := Mux(qspien,tx_ff_wen,false.B)
txfifo_io0.io.writeEn := tx_ff_wen

txfifo_io3.io.dataIn  := tx_ff_wdata3
txfifo_io2.io.dataIn  := tx_ff_wdata2
txfifo_io1.io.dataIn  := tx_ff_wdata1
txfifo_io0.io.dataIn  := tx_ff_wdata0


val tx_ff_rden   = RegInit(false.B)
txfifo_io3.io.readEn  := Mux(qspien,tx_ff_rden,false.B)
txfifo_io2.io.readEn  := Mux(qspien,tx_ff_rden,false.B)
txfifo_io1.io.readEn  := Mux(qspien,tx_ff_rden,false.B)
txfifo_io0.io.readEn  := tx_ff_rden




//val rx_ff_wdata  = RegInit(0.U(8.W))
val rx_ff_wen    = RegInit(false.B)
val rx_ff_rden   = RegInit(false.B)

rxfifo.io.writeEn := rx_ff_wen

rxfifo.io.readEn  := rx_ff_rden
///////////////////////////////////// FIFO definitions ////////////////

//////////////////////////// SOFTWARE RESET REGISTER //////////////////////////////////////////////////////////////
val sw_reset = RegInit(false.B)
when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbqspi.SRR)){
  sw_reset := io.PWDATA === (0x0000000A).asUInt
} .otherwise {
  sw_reset := false.B
}
when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbqspi.SRR)){
rdata := 0.U
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////// TRISTATE ENABLE REGISTER
when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbqspi.TRIEN)){
  io3_tr := io.PWDATA(3);
  io2_tr := io.PWDATA(2);
  io1_tr := io.PWDATA(1);
  io0_tr := io.PWDATA(0);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// SPI CONTROL REGISTER //////////////////////////////////////////////////////////////
val lsb_first   = RegInit(false.B)
val mstxinhibit = RegInit(true.B)
val manslvsel   = RegInit(true.B)
val rxffrst     = RegInit(false.B)
val txffrst     = RegInit(false.B)
val cpha        = RegInit(false.B)
val cpol        = RegInit(false.B)
val ismaster    = RegInit(false.B)
val spiena      = RegInit(true.B)
val loop        = RegInit(false.B)

val spiclk_reg  = RegInit(0.U(17.W))

when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbqspi.SPICR)){
 qspien         := io.PWDATA(10)
 lsb_first      := io.PWDATA(9)
 mstxinhibit    := io.PWDATA(8)
 manslvsel      := io.PWDATA(7)
 rxffrst        := io.PWDATA(6)
 txffrst        := io.PWDATA(5)
 cpha           := io.PWDATA(4)
 cpol           := io.PWDATA(3)
 ismaster       := io.PWDATA(2)
 spiena         := io.PWDATA(1)
 loop           := io.PWDATA(0)
} 
when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbqspi.SPICR)){
rdata := Cat(0.U((31-11).W),qspien,lsb_first,mstxinhibit,manslvsel,rxffrst,txffrst,cpha,cpol,ismaster,spiena,loop)
}






/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// QSPI STATUS REGISTER //////////////////////////////////////////////////////////////
val slvmodsel   = RegInit(true.B)
val modefault   = RegInit(false.B)
when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbqspi.SPISR)){
rdata := Cat(0.U((31-6).W),slvmodsel,modefault,txfifo_io0.io.full,txfifo_io0.io.empty,rxfifo.io.full,rxfifo.io.empty)
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////// QSPI MODES //////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// mode 1
val qcph1_cpl1             = Cat(true.B, false.B,    true.B,       false.B,     true.B).asUInt

val qdata_struct_msb_3_io3 = Cat(false.B, io.PWDATA(7),io.PWDATA(7), io.PWDATA(3),io.PWDATA(3) );
val qdata_struct_msb_3_io2 = Cat(false.B, io.PWDATA(6),io.PWDATA(6), io.PWDATA(2),io.PWDATA(2) );
val qdata_struct_msb_3_io1 = Cat(false.B, io.PWDATA(5),io.PWDATA(5), io.PWDATA(1),io.PWDATA(1) );
val qdata_struct_msb_3_io0 = Cat(false.B, io.PWDATA(4),io.PWDATA(4), io.PWDATA(0),io.PWDATA(0) );

val qdata_struct_lsb_3_io3 = Cat(false.B, io.PWDATA(3),io.PWDATA(3), io.PWDATA(7),io.PWDATA(7) );
val qdata_struct_lsb_3_io2 = Cat(false.B, io.PWDATA(2),io.PWDATA(2), io.PWDATA(6),io.PWDATA(6) );
val qdata_struct_lsb_3_io1 = Cat(false.B, io.PWDATA(1),io.PWDATA(1), io.PWDATA(5),io.PWDATA(5) );
val qdata_struct_lsb_3_io0 = Cat(false.B, io.PWDATA(0),io.PWDATA(0), io.PWDATA(4),io.PWDATA(4) );

// mode 2 
val qcph1_cpl0         = Cat(false.B, true.B, false.B,  true.B, false.B).asUInt

val qdata_struct_msb_2_io3 = Cat(false.B, io.PWDATA(7),io.PWDATA(7), io.PWDATA(3),io.PWDATA(3) );
val qdata_struct_msb_2_io2 = Cat(false.B, io.PWDATA(6),io.PWDATA(6), io.PWDATA(2),io.PWDATA(2) );
val qdata_struct_msb_2_io1 = Cat(false.B, io.PWDATA(5),io.PWDATA(5), io.PWDATA(1),io.PWDATA(1) );
val qdata_struct_msb_2_io0 = Cat(false.B, io.PWDATA(4),io.PWDATA(4), io.PWDATA(0),io.PWDATA(0) );

val qdata_struct_lsb_2_io3 = Cat(false.B, io.PWDATA(3),io.PWDATA(3), io.PWDATA(7),io.PWDATA(7) );
val qdata_struct_lsb_2_io2 = Cat(false.B, io.PWDATA(2),io.PWDATA(2), io.PWDATA(6),io.PWDATA(6) );
val qdata_struct_lsb_2_io1 = Cat(false.B, io.PWDATA(1),io.PWDATA(1), io.PWDATA(5),io.PWDATA(5) );
val qdata_struct_lsb_2_io0 = Cat(false.B, io.PWDATA(0),io.PWDATA(0), io.PWDATA(4),io.PWDATA(4) );

// mode 1
val qcph0_cpl1         = Cat(true.B,false.B,true.B,false.B,true.B).asUInt

val qdata_struct_msb_1_io3 = Cat(io.PWDATA(7),io.PWDATA(7), io.PWDATA(3),io.PWDATA(3), false.B);
val qdata_struct_msb_1_io2 = Cat(io.PWDATA(6),io.PWDATA(6), io.PWDATA(2),io.PWDATA(2), false.B);
val qdata_struct_msb_1_io1 = Cat(io.PWDATA(5),io.PWDATA(5), io.PWDATA(1),io.PWDATA(1), false.B);
val qdata_struct_msb_1_io0 = Cat(io.PWDATA(4),io.PWDATA(4), io.PWDATA(0),io.PWDATA(0), false.B);

val qdata_struct_lsb_1_io3 = Cat(io.PWDATA(3),io.PWDATA(3), io.PWDATA(7),io.PWDATA(7), false.B);
val qdata_struct_lsb_1_io2 = Cat(io.PWDATA(2),io.PWDATA(2), io.PWDATA(6),io.PWDATA(6), false.B);
val qdata_struct_lsb_1_io1 = Cat(io.PWDATA(1),io.PWDATA(1), io.PWDATA(5),io.PWDATA(5), false.B);
val qdata_struct_lsb_1_io0 = Cat(io.PWDATA(0),io.PWDATA(0), io.PWDATA(4),io.PWDATA(4), false.B);


// mode 0
val qcph0_cpl0          = Cat(false.B,     true.B,       false.B,     true.B,      false.B).asUInt
		
val qdata_struct_msb_0_io3 = Cat(io.PWDATA(7),io.PWDATA(7), io.PWDATA(3),io.PWDATA(3), false.B);
val qdata_struct_msb_0_io2 = Cat(io.PWDATA(6),io.PWDATA(6), io.PWDATA(2),io.PWDATA(2), false.B);
val qdata_struct_msb_0_io1 = Cat(io.PWDATA(5),io.PWDATA(5), io.PWDATA(1),io.PWDATA(1), false.B);
val qdata_struct_msb_0_io0 = Cat(io.PWDATA(4),io.PWDATA(4), io.PWDATA(0),io.PWDATA(0), false.B);

val qdata_struct_lsb_0_io3 = Cat(io.PWDATA(3),io.PWDATA(3), io.PWDATA(7),io.PWDATA(7), false.B);
val qdata_struct_lsb_0_io2 = Cat(io.PWDATA(2),io.PWDATA(2), io.PWDATA(6),io.PWDATA(6), false.B);
val qdata_struct_lsb_0_io1 = Cat(io.PWDATA(1),io.PWDATA(1), io.PWDATA(5),io.PWDATA(5), false.B);
val qdata_struct_lsb_0_io0 = Cat(io.PWDATA(0),io.PWDATA(0), io.PWDATA(4),io.PWDATA(4), false.B);						  
						  
////////////////// SPI MODES ////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

val cph1_cpl1         = Cat(true.B, false.B,    true.B,       false.B,     true.B,      false.B,     true.B,      false.B,     true.B,     false.B,      true.B,      false.B,     true.B,      false.B,     true.B,      false.B,    true.B).asUInt
val data_struct_msb_3 = Cat(false.B,io.PWDATA(7),io.PWDATA(7),io.PWDATA(6),io.PWDATA(6),io.PWDATA(5),io.PWDATA(5),io.PWDATA(4),io.PWDATA(4),io.PWDATA(3),io.PWDATA(3),io.PWDATA(2),io.PWDATA(2),io.PWDATA(1),io.PWDATA(1),io.PWDATA(0),io.PWDATA(0))
val data_struct_lsb_3 = Cat(false.B,io.PWDATA(0),io.PWDATA(0),io.PWDATA(1),io.PWDATA(1),io.PWDATA(2),io.PWDATA(2),io.PWDATA(3),io.PWDATA(3),
                          io.PWDATA(4),io.PWDATA(4),io.PWDATA(5),io.PWDATA(5),io.PWDATA(6),io.PWDATA(6),io.PWDATA(7),io.PWDATA(7))
						  
val cph1_cpl0         = Cat(false.B,true.B,       false.B,		true.B,		false.B,		true.B,		false.B,	true.B,		false.B,      true.B,      false.B,    true.B,      false.B,     true.B,      false.B,      true.B,     false.B).asUInt						  
val data_struct_msb_2 = Cat(false.B,io.PWDATA(7),io.PWDATA(7),io.PWDATA(6),io.PWDATA(6),io.PWDATA(5),io.PWDATA(5),io.PWDATA(4),io.PWDATA(4),io.PWDATA(3),io.PWDATA(3),io.PWDATA(2),io.PWDATA(2),io.PWDATA(1),io.PWDATA(1),io.PWDATA(0),io.PWDATA(0))
val data_struct_lsb_2 = Cat(false.B,io.PWDATA(0),io.PWDATA(0),io.PWDATA(1),io.PWDATA(1),io.PWDATA(2),io.PWDATA(2),io.PWDATA(3),io.PWDATA(3),
                          io.PWDATA(4),io.PWDATA(4),io.PWDATA(5),io.PWDATA(5),io.PWDATA(6),io.PWDATA(6),io.PWDATA(7),io.PWDATA(7))						  
						  
val cph0_cpl1         = Cat(true.B,        false.B,      true.B,    false.B,    true.B,      false.B,     true.B,      false.B,     true.B,      false.B,     true.B,      false.B,     true.B,      false.B,    true.B,       false.B,     true.B).asUInt						  
val data_struct_msb_1 = Cat(io.PWDATA(7),io.PWDATA(7),io.PWDATA(6),io.PWDATA(6),io.PWDATA(5),io.PWDATA(5),io.PWDATA(4),io.PWDATA(4),io.PWDATA(3),io.PWDATA(3),io.PWDATA(2),io.PWDATA(2),io.PWDATA(1),io.PWDATA(1),io.PWDATA(0),io.PWDATA(0),false.B)
val data_struct_lsb_1 = Cat(io.PWDATA(0),io.PWDATA(0),io.PWDATA(1),io.PWDATA(1),io.PWDATA(2),io.PWDATA(2),io.PWDATA(3),io.PWDATA(3),
                          io.PWDATA(4),io.PWDATA(4),io.PWDATA(5),io.PWDATA(5),io.PWDATA(6),io.PWDATA(6),io.PWDATA(7),io.PWDATA(7),false.B)		

val cph0_cpl0          = Cat(false.B,     true.B,       false.B,     true.B,      false.B,    true.B,       false.B,      true.B       ,false.B,  true.B,      false.B,    true.B,       false.B,     true.B,     false.B,     true.B,     false.B).asUInt
val data_struct_msb_0 = Cat(io.PWDATA(7),io.PWDATA(7),io.PWDATA(6),io.PWDATA(6),io.PWDATA(5),io.PWDATA(5),io.PWDATA(4),io.PWDATA(4),io.PWDATA(3),io.PWDATA(3),io.PWDATA(2),io.PWDATA(2),io.PWDATA(1),io.PWDATA(1),io.PWDATA(0),io.PWDATA(0),false.B)
val data_struct_lsb_0 = Cat(io.PWDATA(0),io.PWDATA(0),io.PWDATA(1),io.PWDATA(1),io.PWDATA(2),io.PWDATA(2),io.PWDATA(3),io.PWDATA(3),
                          io.PWDATA(4),io.PWDATA(4),io.PWDATA(5),io.PWDATA(5),io.PWDATA(6),io.PWDATA(6),io.PWDATA(7),io.PWDATA(7),false.B)		
		

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


				// qspi clock sequence		  			  
val qspiclk_w  = MuxLookup(Cat(cpha,cpol).asUInt,0.U,Seq(
3.U -> qcph1_cpl1,
2.U -> qcph1_cpl0,
1.U -> qcph0_cpl1,
0.U -> qcph0_cpl0
))						  
                               // spi clock sequence
val sspiclk_w  = MuxLookup(Cat(cpha,cpol).asUInt,0.U,Seq(
3.U -> cph1_cpl1,
2.U -> cph1_cpl0,
1.U -> cph0_cpl1,
0.U -> cph0_cpl0
))
                               // if qspi then qspi clock sequence else spi clock sequence
val spiclk_w = Mux(qspien,Cat(qspiclk_w,0.U(12.W)),sspiclk_w);


						  
						  
when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbqspi.SPIDTR)){


tx_ff_wdata3 := MuxLookup(Cat(cpha,cpol).asUInt,0.U,Seq(
3.U -> Mux(lsb_first,qdata_struct_lsb_3_io3,qdata_struct_msb_3_io3),
2.U -> Mux(lsb_first,qdata_struct_lsb_2_io3,qdata_struct_msb_2_io3),
1.U -> Mux(lsb_first,qdata_struct_lsb_1_io3,qdata_struct_msb_1_io3),
0.U -> Mux(lsb_first,qdata_struct_lsb_0_io3,qdata_struct_msb_0_io3)
))

tx_ff_wdata2 := MuxLookup(Cat(cpha,cpol).asUInt,0.U,Seq(
3.U -> Mux(lsb_first,qdata_struct_lsb_3_io2,qdata_struct_msb_3_io2),
2.U -> Mux(lsb_first,qdata_struct_lsb_2_io2,qdata_struct_msb_2_io2),
1.U -> Mux(lsb_first,qdata_struct_lsb_1_io2,qdata_struct_msb_1_io2),
0.U -> Mux(lsb_first,qdata_struct_lsb_0_io2,qdata_struct_msb_0_io2)
))

tx_ff_wdata1 := MuxLookup(Cat(cpha,cpol).asUInt,0.U,Seq(
3.U -> Mux(lsb_first,qdata_struct_lsb_3_io1,qdata_struct_msb_3_io1),
2.U -> Mux(lsb_first,qdata_struct_lsb_2_io1,qdata_struct_msb_2_io1),
1.U -> Mux(lsb_first,qdata_struct_lsb_1_io1,qdata_struct_msb_1_io1),
0.U -> Mux(lsb_first,qdata_struct_lsb_0_io1,qdata_struct_msb_0_io1)
))



tx_ff_wdata0 := Mux(qspien,
			Cat(MuxLookup(Cat(cpha,cpol).asUInt,0.U,Seq(
3.U -> Mux(lsb_first,qdata_struct_lsb_3_io0,qdata_struct_msb_3_io0),
2.U -> Mux(lsb_first,qdata_struct_lsb_2_io0,qdata_struct_msb_2_io0),
1.U -> Mux(lsb_first,qdata_struct_lsb_1_io0,qdata_struct_msb_1_io0),
0.U -> Mux(lsb_first,qdata_struct_lsb_0_io0,qdata_struct_msb_0_io0))),0.U(12.W)),
MuxLookup(Cat(cpha,cpol).asUInt,0.U,Seq(
3.U -> Mux(lsb_first,data_struct_lsb_3,data_struct_msb_3),
2.U -> Mux(lsb_first,data_struct_lsb_2,data_struct_msb_2),
1.U -> Mux(lsb_first,data_struct_lsb_1,data_struct_msb_1),
0.U -> Mux(lsb_first,data_struct_lsb_0,data_struct_msb_0)
))
)


tx_ff_wen := true.B

} .otherwise {
tx_ff_wdata3 := 0.U
tx_ff_wdata2 := 0.U
tx_ff_wdata1 := 0.U
tx_ff_wdata0 := 0.U
tx_ff_wen    := false.B
}

when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbqspi.SPIDTR)){
rdata := 0.U
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////// SPI DATA RECEIVE REGISTER //////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbqspi.SPIDRR)){
rx_ff_rden := true.B
rdata      := rxfifo.io.dataOut
} .otherwise {
rx_ff_rden := false.B
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////// TX/RX FIFO OCV REGISTER /////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbqspi.SPITXFFOCV)){
rdata      := txfifo_io0.io.writePtr
}

when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbqspi.SPIRXFFOCV)){
rdata      := rxfifo.io.writePtr
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////// INTERRUPT SETTINGS              ///////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
val gie = RegInit(false.B)  // global interrupt enable
when (io.PSEL && io.PWRITE && !io.PENABLE && io.PENABLE && (io.PADDR(7,0) === Address_apbqspi.DGIER)){
gie := io.PWDATA(31)
}
when (io.PSEL && !io.PWRITE  && !io.PENABLE && (io.PADDR(7,0) === Address_apbqspi.DGIER)){
rdata := Cat(gie,0.U(31.W))
}
///////////////////////////////////////////// INTERRUPT STATUS REGISTERS     /////////////////////////////////////////

val drr_emptyn_i        = RegInit(false.B)
val slv_sel_mod_i       = RegInit(false.B)
val txff_hempty_i       = RegInit(false.B) 
val rxff_ovrrun_i       = RegInit(false.B)
val rxff_full_i         = RegInit(false.B)
val txff_underrun_i     = RegInit(false.B)
val txff_empty_i        = RegInit(false.B)
val svl_modf_i          = RegInit(false.B)
val modf_i              = RegInit(false.B)

when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbqspi.IPISR)){
 drr_emptyn_i        := !drr_emptyn_i    && io.PWDATA(8) && !ismaster
 slv_sel_mod_i       := !slv_sel_mod_i   && io.PWDATA(7) && !ismaster
 txff_hempty_i       := !txff_hempty_i   && io.PWDATA(6) 
 rxff_ovrrun_i       := !rxff_ovrrun_i   && io.PWDATA(5)
 rxff_full_i         := !rxff_full_i     && io.PWDATA(4)
 txff_underrun_i     := !txff_underrun_i && io.PWDATA(3) && !ismaster && spiena
 txff_empty_i        := !txff_empty_i    && io.PWDATA(2)
 svl_modf_i          := !txff_empty_i    && io.PWDATA(1)
 modf_i              := !modf_i          && io.PWDATA(0)
} .otherwise {

drr_emptyn_i         := Mux(!ismaster && !txfifo_io0.io.empty,true.B,drr_emptyn_i)
slv_sel_mod_i        := Mux(!ismaster && !io.spi_ssel_i,true.B,slv_sel_mod_i)
txff_hempty_i        := Mux(txfifo_io0.io.writePtr === 4.U,true.B,txff_hempty_i)
rxff_ovrrun_i        := Mux(rx_ff_wen && rxfifo.io.full,true.B,rxff_ovrrun_i)
rxff_full_i          := Mux(rxfifo.io.full,true.B,rxff_ovrrun_i)
txff_underrun_i      := Mux(tx_ff_rden && !ismaster && spiena && txfifo_io0.io.empty,true.B,txff_underrun_i)
txff_empty_i         := Mux(txfifo_io0.io.empty,true.B,txff_empty_i)
svl_modf_i           := Mux(!ismaster && !spiena && !io.spi_ssel_i,true.B,svl_modf_i)
modf_i               := Mux(ismaster && !io.spi_ssel_i,true.B,modf_i)

}

when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbqspi.IPISR)){
rdata := Cat(0.U(23.W),drr_emptyn_i,slv_sel_mod_i,txff_hempty_i,rxff_ovrrun_i,rxff_full_i,txff_underrun_i,txff_empty_i,svl_modf_i,modf_i)
}

///////////////////////////////////////////// INTERRUPT ENABLE REGISTERS     /////////////////////////////////////////

val drr_emptyn_i_en        = RegInit(false.B)
val slv_sel_mod_i_en       = RegInit(false.B)
val txff_hempty_i_en       = RegInit(false.B) 
val rxff_ovrrun_i_en       = RegInit(false.B)
val rxff_full_i_en         = RegInit(false.B)
val txff_underrun_i_en     = RegInit(false.B)
val txff_empty_i_en        = RegInit(false.B)
val svl_modf_i_en          = RegInit(false.B)
val modf_i_en              = RegInit(false.B)

when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbqspi.IPIER)){
 drr_emptyn_i_en        :=   io.PWDATA(8)
 slv_sel_mod_i_en       :=   io.PWDATA(7) 
 txff_hempty_i_en       :=   io.PWDATA(6) 
 rxff_ovrrun_i_en       :=   io.PWDATA(5)
 rxff_full_i_en         :=   io.PWDATA(4)
 txff_underrun_i_en     :=   io.PWDATA(3) 
 txff_empty_i_en        :=   io.PWDATA(2)
 svl_modf_i_en          :=   io.PWDATA(1)
 modf_i_en              :=   io.PWDATA(0)
} 


val intr0 = modf_i_en          && modf_i
val intr1 = svl_modf_i_en      && svl_modf_i
val intr2 = txff_empty_i_en    && txff_empty_i
val intr3 = txff_underrun_i_en && txff_underrun_i
val intr4 = rxff_full_i_en     && rxff_full_i
val intr5 = rxff_ovrrun_i_en   && rxff_ovrrun_i
val intr6 = txff_hempty_i_en   && txff_hempty_i
val intr7 = slv_sel_mod_i_en   && slv_sel_mod_i
val intr8 = drr_emptyn_i_en    && drr_emptyn_i

interrupt_r := (intr0 || intr1 || intr2 || intr3 || intr4 || intr5 || intr6 || intr7 || intr8) && gie

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// SPI SLAVE SELECT REGISTER //////////////////////////////////////////////////////////////
when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbqspi.SPISSR)){
spi_ssel_o := io.PWDATA(7,0)
spi_ssel_t := !io.PWDATA(7,0).andR
}

/////                                        DIVISOR REGISTER /////////////////////////////////////////////////
val divisor     = RegInit(2.U(8.W))
val divisorr    = RegInit(2.U(8.W))
val spi_txcount = RegInit(0.U(5.W))
val spi_txcountr = RegInit(16.U(5.W))


//////////////////////////////// logic for receiver ///////////////////////////////////////////////
val rdtrue = (divisorr === (divisor - 1.U))
//                    for cpha 1                           for cpha 0
val cnt21  = (cpha && (spi_txcount === 2.U)   ) || (!cpha &&   (spi_txcount === 1.U)   )
val cnt43  = (cpha && (spi_txcount === 4.U)   ) || (!cpha &&   (spi_txcount === 3.U)   )
val cnt65  = (cpha && (spi_txcount === 6.U)   ) || (!cpha &&   (spi_txcount === 5.U)   )
val cnt87  = (cpha && (spi_txcount === 8.U)   ) || (!cpha &&   (spi_txcount === 7.U)   )
val cnta9  = (cpha && (spi_txcount === 10.U)  ) || (!cpha &&   (spi_txcount === 9.U)   )
val cntcb  = (cpha && (spi_txcount === 12.U)  ) || (!cpha &&   (spi_txcount === 11.U)  )
val cnted  = (cpha && (spi_txcount === 14.U)  ) || (!cpha &&   (spi_txcount === 13.U)  )
val cnt10f = (cpha && (spi_txcount === 16.U)  ) || (!cpha &&   (spi_txcount === 15.U)  )




//val read = (rd0 || rd1 || rd2 || rd3 || rd4 || rd5 || rd6 || rd7) && rdtrue
////////////////////////////////////////////////////////////////////////////////////////////////////


// LOOP BACK LOGIC ///

val io3w = Mux(loop,io3_or,Mux(io3_tr,io.io3_i,true.B))
val io2w = Mux(loop,io2_or,Mux(io2_tr,io.io2_i,true.B))
val io1w = Mux(loop,io1_or,Mux(io1_tr,io.io1_i,true.B))
val io0w = Mux(loop,io0_or,Mux(io0_tr,io.io0_i,true.B))

val iow  = Mux(loop,io0_or,io.io1_i)





val rdata0 = RegInit(false.B)
val rdata1 = RegInit(false.B)
val rdata2 = RegInit(false.B)
val rdata3 = RegInit(false.B)
val rdata4 = RegInit(false.B)
val rdata5 = RegInit(false.B)
val rdata6 = RegInit(false.B)
val rdata7 = RegInit(false.B)

rxfifo.io.dataIn  := Mux(lsb_first,Cat(rdata0,rdata1,rdata2,rdata3,rdata4,rdata5,rdata6,rdata7).asUInt,Cat(rdata7,rdata6,rdata5,rdata4,rdata3,rdata2,rdata1,rdata0).asUInt)
when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbqspi.DIVISOR)){
divisor := io.PWDATA(7,0)
}



when(mstxinhibit || sw_reset || !spiena) { 
	
	spi_clk_o      := cpol
	
	io3_or         := Mux(qspien,false.B,true.B)
       io2_or          := Mux(qspien,false.B,true.B)
	io1_or         := Mux(qspien,false.B,true.B)
	io0_or         := false.B

	
	divisorr       := 0.U
        spiclk_reg    := spiclk_w
        spi_txcount   := 0.U
	txstate        := s_IDLE
        tx_ff_rdatar0  := 0.U
	rx_ff_wen       := false.B
	spi_txcountr    := Mux(qspien,4.U,16.U)
} .otherwise  {

	switch(txstate) {

		is(s_IDLE) {
			
			
		        io3_or         := Mux(qspien,false.B,true.B)
		        io2_or         := Mux(qspien,false.B,true.B)
	                io1_or         := Mux(qspien,false.B,true.B)
	                io0_or         := false.B
			
			spi_clk_o      := cpol
            		tx_ff_rden     := Mux(txfifo_io0.io.empty,false.B,true.B)
            		txstate        := Mux(txfifo_io0.io.empty,s_IDLE,s_TXDEQ1)
            		divisorr       := 0.U
            		spiclk_reg     := spiclk_w
            		spi_txcount    := 0.U
            		spi_txcountr   := Mux(qspien,4.U,16.U)
		        rx_ff_wen     := false.B
		} //S_IDL
		
		is(s_TXDEQ1) {
		
		    tx_ff_rden     := false.B
	            tx_ff_rdatar3  := Mux(qspien,tx_ff_rdata3,0.U)
	            tx_ff_rdatar2  := Mux(qspien,tx_ff_rdata2,0.U)
	            tx_ff_rdatar1  := Mux(qspien,tx_ff_rdata1,0.U)
	            tx_ff_rdatar0  := tx_ff_rdata0
	            
	           
		    txstate        := s_TXDEQ
		    
		        io3_or         := Mux(qspien,false.B,true.B)
		        io2_or         := Mux(qspien,false.B,true.B)
	                io1_or         := Mux(qspien,false.B,true.B)
	               io0_or          := false.B
	
		    spi_clk_o      := cpol
		    divisorr       := 0.U
                   spiclk_reg     := spiclk_w
                   spi_txcount    := 0.U
                  
		   rx_ff_wen       := false.B
		}
		is(s_TXDEQ) {
		
		
		tx_ff_rden     := false.B
	        txstate        := s_TXRD
	        spi_clk_o      := Mux(qspien,spiclk_reg(4),spiclk_reg(16))
        	spiclk_reg     := spiclk_reg << 1
        	
		io0_or         := tx_ff_rdatar0(16)
		tx_ff_rdatar0  := tx_ff_rdatar0 << 1
		
		io1_or         := Mux(qspien,tx_ff_rdatar1(4),false.B)
		tx_ff_rdatar1  := tx_ff_rdatar1 << 1
		
		io2_or         := Mux(qspien,tx_ff_rdatar2(4),false.B)
		tx_ff_rdatar2  := tx_ff_rdatar2 << 1
		
		
		io3_or         := Mux(qspien,tx_ff_rdatar3(4),false.B)
		tx_ff_rdatar3  := tx_ff_rdatar3 << 1
		
		spi_txcount    := 0.U
		
		divisorr       := 1.U
		rx_ff_wen      := false.B
			
        } // s_TXDEQ
           is(s_TXRD) { 
           
             spi_clk_o     := Mux(divisorr === 0.U,spiclk_reg(16),spi_clk_o)
             spiclk_reg    := Mux(divisorr === 0.U,spiclk_reg << 1,spiclk_reg)
             
             
             io0_or         := Mux(divisorr === 0.U,tx_ff_rdatar0(16),io0_or)
             tx_ff_rdatar0  := Mux(divisorr === 0.U,tx_ff_rdatar0 << 1,tx_ff_rdatar0)
             
             io1_or         := Mux(divisorr === 0.U,Mux(qspien,tx_ff_rdatar1(4),false.B),io1_or)
             tx_ff_rdatar1  := Mux(divisorr === 0.U,tx_ff_rdatar1 << 1,tx_ff_rdatar1)
             
             io2_or         := Mux(divisorr === 0.U,Mux(qspien,tx_ff_rdatar2(4),false.B),io2_or)
             tx_ff_rdatar2  := Mux(divisorr === 0.U,tx_ff_rdatar2 << 1,tx_ff_rdatar2)
             
             io3_or         := Mux(divisorr === 0.U,Mux(qspien,tx_ff_rdatar3(4),false.B),io3_or)
             tx_ff_rdatar3  := Mux(divisorr === 0.U,tx_ff_rdatar3 << 1,tx_ff_rdatar3)
             
             
             
             spi_txcount   := Mux(divisorr === (divisor - 1.U),Mux(spi_txcount === spi_txcountr,0.U,spi_txcount + 1.U),spi_txcount)
             txstate       := Mux( ( divisorr === (divisor - 1.U)) && (spi_txcount === spi_txcountr),s_IDLE,s_TXRD)
             divisorr      := Mux(divisorr === (divisor - 1.U),0.U,divisorr + 1.U)
		
	      rdata7       := Mux(qspien,Mux(rdtrue && cnt21,io3w,rdata7),
	                      Mux(rdtrue && cnt21,iow,rdata7))
	      	 
	      rdata6       := Mux(qspien,Mux(rdtrue && cnt21,io2w,rdata6),
	                      Mux(rdtrue && cnt43,iow,rdata6))
	      
	      rdata5       := Mux(qspien,Mux(rdtrue && cnt21,io1w,rdata5),
	                      Mux(rdtrue && cnt65,iow,rdata5))
	      
	      rdata4       := Mux(qspien,Mux(rdtrue && cnt21,io0w,rdata4),
	                      Mux(rdtrue && cnt87,iow,rdata4))
	      
	      rdata3       := Mux(qspien,Mux(rdtrue && cnt43,io3w,rdata3),
	                      Mux(rdtrue && cnta9,iow,rdata3))
	      
	      rdata2       := Mux(qspien,Mux(rdtrue && cnt43,io2w,rdata2),
	                      Mux(rdtrue && cntcb,iow,rdata2))
	      
	      rdata1       := Mux(qspien,Mux(rdtrue && cnt43,io1w,rdata1),
	                      Mux(rdtrue && cnted,iow,rdata1))
	      
	      rdata0       := Mux(qspien,Mux(rdtrue && cnt43,io0w,rdata0),
	                      Mux(rdtrue && cnt10f,iow,rdata0))
	      
	      
	      
	      rx_ff_wen    := Mux( ( divisorr === (divisor - 1.U)) && (spi_txcount === spi_txcountr),true.B,false.B)
			 
			 
			 
			 
			 
        } //s_TXRD
} //transmission
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
} //pclk domain        
}
	
// Generate the Verilog code by invoking the Driver
object apbqspiMain extends App {
  println("Generating the top hardware")
  chisel3.Driver.execute(Array("--target-dir", "top"), () => new apbqspi_ssp(8))
}




