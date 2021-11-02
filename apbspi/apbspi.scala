

package apbspi

import chisel3._
import chisel3.experimental._
import chisel3.util._
import chisel3.util.BitPat

import Address_apbspi._




class apbspi(depth: Int) extends Module  {

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


 // SPI portrs

val mosi_i = Input(Bool())
val mosi_o = Output(Bool())
val mosi_t = Output(Bool())


val miso_i = Input(Bool())
val miso_o = Output(Bool())
val miso_t = Output(Bool()) 



val spi_clk_o = Output(Bool())
val spi_clk_i = Input(Bool())
val spi_clk_t = Output(Bool())


val spi_ssel_o = Output(UInt(8.W)) 
val spi_ssel_i = Input(Bool())
val spi_ssel_t = Output(Bool()) 

})


io.spi_ssel_t := false.B
io.spi_clk_t := false.B
io.miso_t := true.B
io.mosi_t := false.B


io.PREADY    := 1.U;
io.PSLVERR   := 0.U;

val interrupt_r = RegInit(false.B)
io.interrupt := interrupt_r



// state machine state declaration /////////////////

//  pclk domain
withClockAndReset(io.PCLK, !io.PRESETn) {
//
//

val mosi_o = RegInit(false.B)
val mosi_t = RegInit(true.B)

val miso_o = RegInit(false.B)
val miso_t = RegInit(true.B)

io.mosi_o := mosi_o
io.miso_o := true.B



val spi_clk_o = RegInit(false.B)
val spi_clk_t = RegInit(false.B)

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
val txfifo = Module(new FIFO(17,4))
val rxfifo = Module(new FIFO(8,4))

val tx_ff_rdata  = txfifo.io.dataOut
val tx_ff_rdatar = RegInit(0.U(17.W))

val miso_rdata       = RegInit(0.U(8.W))
txfifo.io.systemRst := !io.PRESETn
txfifo.io.writeClk  := io.PCLK
txfifo.io.readClk   := io.PCLK

rxfifo.io.systemRst := !io.PRESETn
rxfifo.io.writeClk  := io.PCLK
rxfifo.io.readClk   := io.PCLK

val tx_ff_wdata  = RegInit(0.U(17.W))
val tx_ff_wen    = RegInit(false.B)
val tx_ff_rden   = RegInit(false.B)

txfifo.io.writeEn := tx_ff_wen
txfifo.io.dataIn  := tx_ff_wdata
txfifo.io.readEn  := tx_ff_rden


//val rx_ff_wdata  = RegInit(0.U(8.W))
val rx_ff_wen    = RegInit(false.B)
val rx_ff_rden   = RegInit(false.B)

rxfifo.io.writeEn := rx_ff_wen

rxfifo.io.readEn  := rx_ff_rden
///////////////////////////////////// FIFO definitions ////////////////

//////////////////////////// SOFTWARE RESET REGISTER //////////////////////////////////////////////////////////////
val sw_reset = RegInit(false.B)
when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbspi.SRR)){
  sw_reset := io.PWDATA === (0x0000000A).asUInt
} .otherwise {
  sw_reset := false.B
}
when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbspi.SRR)){
rdata := 0.U
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

when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbspi.SPICR)){
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
when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbspi.SPICR)){
rdata := Cat(0.U((31-10).W),lsb_first,mstxinhibit,manslvsel,rxffrst,txffrst,cpha,cpol,ismaster,spiena,loop)
}






/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// SPI STATUS REGISTER //////////////////////////////////////////////////////////////
val slvmodsel   = RegInit(true.B)
val modefault   = RegInit(false.B)
when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbspi.SPISR)){
rdata := Cat(0.U((31-6).W),slvmodsel,modefault,txfifo.io.full,txfifo.io.empty,rxfifo.io.full,rxfifo.io.empty)
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// SPI DATA TRANSMIT REGISTER //////////////////////////////////////////////////////////////
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
						  
						  
val spiclk_w  = MuxLookup(Cat(cpha,cpol).asUInt,0.U,Seq(
3.U -> cph1_cpl1,
2.U -> cph1_cpl0,
1.U -> cph0_cpl1,
0.U -> cph0_cpl0
))						  
						  
						  
when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbspi.SPIDTR)){

tx_ff_wdata := MuxLookup(Cat(cpha,cpol).asUInt,0.U,Seq(
3.U -> Mux(lsb_first,data_struct_lsb_3,data_struct_msb_3),
2.U -> Mux(lsb_first,data_struct_lsb_2,data_struct_msb_2),
1.U -> Mux(lsb_first,data_struct_lsb_1,data_struct_msb_1),
0.U -> Mux(lsb_first,data_struct_lsb_0,data_struct_msb_0)
))
tx_ff_wen := true.B

} .otherwise {
tx_ff_wdata := 0.U
tx_ff_wen := false.B
}

when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbspi.SPIDTR)){
rdata := 0.U
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////// SPI DATA RECEIVE REGISTER //////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbspi.SPIDRR)){
rx_ff_rden := true.B
rdata      := rxfifo.io.dataOut
} .otherwise {
rx_ff_rden := false.B
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////// TX/RX FIFO OCV REGISTER /////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbspi.SPITXFFOCV)){
rdata      := txfifo.io.writePtr
}

when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbspi.SPIRXFFOCV)){
rdata      := rxfifo.io.writePtr
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////// INTERRUPT SETTINGS              ///////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
val gie = RegInit(false.B)  // global interrupt enable
when (io.PSEL && io.PWRITE && !io.PENABLE && io.PENABLE && (io.PADDR(7,0) === Address_apbspi.DGIER)){
gie := io.PWDATA(31)
}
when (io.PSEL && !io.PWRITE  && !io.PENABLE && (io.PADDR(7,0) === Address_apbspi.DGIER)){
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

when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbspi.IPISR)){
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

drr_emptyn_i         := Mux(!ismaster && !txfifo.io.empty,true.B,drr_emptyn_i)
slv_sel_mod_i        := Mux(!ismaster && !io.spi_ssel_i,true.B,slv_sel_mod_i)
txff_hempty_i        := Mux(txfifo.io.writePtr === 7.U,true.B,txff_hempty_i)
rxff_ovrrun_i        := Mux(rx_ff_wen && rxfifo.io.full,true.B,rxff_ovrrun_i)
rxff_full_i          := Mux(rxfifo.io.full,true.B,rxff_ovrrun_i)
txff_underrun_i      := Mux(tx_ff_rden && !ismaster && spiena && txfifo.io.empty,true.B,txff_underrun_i)
txff_empty_i         := Mux(txfifo.io.empty,true.B,txff_empty_i)
svl_modf_i           := Mux(!ismaster && !spiena && !io.spi_ssel_i,true.B,svl_modf_i)
modf_i               := Mux(ismaster && !io.spi_ssel_i,true.B,modf_i)

}

when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbspi.IPISR)){
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

when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbspi.IPIER)){
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
when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbspi.SPISSR)){
spi_ssel_o := io.PWDATA(7,0)
spi_ssel_t := !io.PWDATA(7,0).andR
}

/////                                        DIVISOR REGISTER /////////////////////////////////////////////////
val divisor     = RegInit(2.U(8.W))
val divisorr    = RegInit(2.U(8.W))
val spi_txcount = RegInit(0.U(5.W))


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

val rd0 = (cnt21  && lsb_first) || (cnt10f && !lsb_first)
val rd1 = (cnt43  && lsb_first) || (cnted && !lsb_first)
val rd2 = (cnt65  && lsb_first) || (cntcb && !lsb_first)
val rd3 = (cnt87  && lsb_first) || (cnta9 && !lsb_first)
val rd4 = (cnta9  && lsb_first) || (cnt87 && !lsb_first)
val rd5 = (cntcb  && lsb_first) || (cnt65 && !lsb_first)
val rd6 = (cnted  && lsb_first) || (cnt43 && !lsb_first)
val rd7 = (cnt10f && lsb_first) || (cnt21 && !lsb_first)

val read = (rd0 || rd1 || rd2 || rd3 || rd4 || rd5 || rd6 || rd7) && rdtrue
////////////////////////////////////////////////////////////////////////////////////////////////////


// LOOP BACK LOGIC ///

val miso_w = Mux(loop,mosi_o,io.miso_i)

val rdata0 = RegInit(false.B)
val rdata1 = RegInit(false.B)
val rdata2 = RegInit(false.B)
val rdata3 = RegInit(false.B)
val rdata4 = RegInit(false.B)
val rdata5 = RegInit(false.B)
val rdata6 = RegInit(false.B)
val rdata7 = RegInit(false.B)

rxfifo.io.dataIn  := Cat(rdata7,rdata6,rdata5,rdata4,rdata3,rdata2,rdata1,rdata0).asUInt
when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbspi.DIVISOR)){
divisor := io.PWDATA(7,0)
}
when(mstxinhibit || sw_reset || !spiena) { 
	//miso_t         := Mux(ismaster,true.B,false.B)
	//mosi_t         := Mux(ismaster,false.B,true.B)
	//spi_clk_t      := Mux(ismaster,true.B,false.B)
	spi_clk_o      := cpol
	mosi_o         := false.B
	divisorr       := 0.U
    spiclk_reg     := spiclk_w
    spi_txcount    := 0.U
	txstate        := s_IDLE

	rx_ff_wen       := false.B
} .otherwise  {

	switch(txstate) {

		is(s_IDLE) {
			//miso_t         := Mux(ismaster,true.B,false.B)
			//mosi_t         := Mux(ismaster,false.B,true.B)
			mosi_o         := false.B
			//spi_clk_t      := Mux(ismaster,true.B,false.B)
			spi_clk_o      := cpol
            tx_ff_rden     := Mux(txfifo.io.empty,false.B,true.B)
            txstate        := Mux(txfifo.io.empty,s_IDLE,s_TXDEQ1)
            divisorr       := 0.U
            spiclk_reg     := spiclk_w
            spi_txcount    := 0.U
		
			rx_ff_wen       := false.B
		} //S_IDLE
		
		is(s_TXDEQ1) {
		
			tx_ff_rden     := false.B
	        tx_ff_rdatar   := tx_ff_rdata
		    txstate        := s_TXDEQ
		    //miso_t         := Mux(ismaster,true.B,false.B)
			//mosi_t         := Mux(ismaster,false.B,true.B)
			mosi_o         := false.B
			//spi_clk_t      := Mux(ismaster,true.B,false.B)
			spi_clk_o      := cpol
		    divisorr       := 0.U
            spiclk_reg     := spiclk_w
            spi_txcount    := 0.U
			
		    rx_ff_wen       := false.B
		}
		is(s_TXDEQ) {
			tx_ff_rden     := false.B
	        txstate        := s_TXRD
	        spi_clk_o      := spiclk_reg(16)
        	spiclk_reg     := spiclk_reg << 1
			//mosi_t         := false.B
        	mosi_o         := tx_ff_rdatar(16)
			tx_ff_rdatar   := tx_ff_rdatar << 1
			spi_txcount    := 0.U
			divisorr       := 1.U
		
			rx_ff_wen       := false.B
			
        } // s_TXDEQ
           is(s_TXRD) { 
             spi_clk_o     := Mux(divisorr === 0.U,spiclk_reg(16),spi_clk_o)
             spiclk_reg    := Mux(divisorr === 0.U,spiclk_reg << 1,spiclk_reg)
             //mosi_t      := false.B
             mosi_o        := Mux(divisorr === 0.U,tx_ff_rdatar(16),mosi_o)
             tx_ff_rdatar  := Mux(divisorr === 0.U,tx_ff_rdatar << 1,tx_ff_rdatar)
             spi_txcount   := Mux(divisorr === (divisor - 1.U),Mux(spi_txcount === 16.U,0.U,spi_txcount + 1.U),spi_txcount)
             txstate       := Mux( ( divisorr === (divisor - 1.U)) && (spi_txcount === 16.U),s_IDLE,s_TXRD)
             divisorr      := Mux(divisorr === (divisor - 1.U),0.U,divisorr + 1.U)
		
	      rdata7       := Mux(rdtrue && rd7,miso_w,rdata7)	 
	      rdata6       := Mux(rdtrue && rd6,miso_w,rdata6)
	      rdata5       := Mux(rdtrue && rd5,miso_w,rdata5)
	      rdata4       := Mux(rdtrue && rd4,miso_w,rdata4)
	      rdata3       := Mux(rdtrue && rd3,miso_w,rdata3)
	      rdata2       := Mux(rdtrue && rd2,miso_w,rdata2)
	      rdata1       := Mux(rdtrue && rd1,miso_w,rdata1)
	      rdata0       := Mux(rdtrue && rd0,miso_w,rdata0)
	      rx_ff_wen    := Mux( ( divisorr === (divisor - 1.U)) && (spi_txcount === 16.U),true.B,false.B)
			 
			 
			 
			 
			 
        } //s_TXRD
} //transmission
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
} //pclk domain        
}
	
// Generate the Verilog code by invoking the Driver
object apbspiMain extends App {
  println("Generating the top hardware")
  chisel3.Driver.execute(Array("--target-dir", "top"), () => new apbspi(8))
}




