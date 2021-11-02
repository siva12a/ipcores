

package apbuart

import chisel3._
import chisel3.experimental._
import chisel3.util._
import chisel3.util.BitPat

import Address_apbuart._




class apbuart(depth: Int) extends Module  {

val io = IO(new Bundle {


val  PCLK              = Input(Clock())  // system control clock 
val  PRESETn            = Input(Bool())  // system control reset active low
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


 // uart portrs
val txd         = Output(UInt(1.W))  // serial transmitter port
val rxd         = Input(UInt(1.W))   // serial receiver port
val out1        = Output(Bool())     // general purpose out1
val out2        = Output(Bool())     // general purpose out2
val rtsn        = Output(Bool())    // ready to send output (active low)
val dtrn        = Output(Bool())    // data terminal ready  (active low)

val ctsn        = Input(Bool())        // clear to send Input(active low)
val dcdn        = Input(Bool())        // data carrier ready Input(active low)
val dsrn        = Input(Bool())        // data set ready Input(active low)
val rin         = Input(Bool())        // ring indicator Input(active low)



// baud out signals
val divisor   = Output(UInt(32.W))
val baudreg_tx   = Output(UInt(16.W))
val baudcount_tx = Output(UInt(16.W))
val baudcycle_tx = Output(UInt(4.W))


})


io.PREADY    := 1.U;
io.PSLVERR   := 0.U;

io.interrupt := false.B



// state machine state declaration /////////////////

//  pclk domain
withClockAndReset(io.PCLK, !io.PRESETn) {
//
//
val (s_IDLE :: s_TXDEQ :: s_TXRD ::  s_TXDATA :: Nil) = Enum(4)
val (s_IDLERX :: s_RXRD :: Nil) = Enum(2)
val txstate = RegInit(s_IDLE)
val rxstate = RegInit(s_IDLERX)
/// MODEM CONTROL REGISTER DEFINITIONS
val loop = RegInit(false.B)
val out1 = RegInit(false.B)
val out2 = RegInit(false.B)
val rtsn  = RegInit(false.B)
val dtrn  = RegInit(false.B)
/////////////////////////////////////

/*

val txfifo = Module(new FIFO(12,depth))
val rxfifo = Module(new FIFO(12,depth))

txfifo.io.systemRst := io.PRESETn
txfifo.io.writeClk  := io.PCLK
txfifo.io.readClk   := io.PCLK

rxfifo.io.systemRst := io.PRESETn
rxfifo.io.writeClk  := io.PCLK
rxfifo.io.readClk   := io.PCLK

val tx_ff_wdata  = RegInit(0.U(12.W))
val tx_ff_wen    = RegInit(false.B)
val tx_ff_rden   = RegInit(false.B)
val tx_ff_rdata  = txfifo.io.dataOut
val tx_ff_rdatar = RegInit(0.U(12.W))

txfifo.io.writeEn := tx_ff_wen
txfifo.io.dataIn  := tx_ff_wdata
txfifo.io.readEn  := tx_ff_rden


val rx_ff_wdata  = RegInit(0.U(12.W))
val rx_ff_wen    = RegInit(false.B)
val rx_ff_rden   = RegInit(false.B)

rxfifo.io.writeEn := rx_ff_wen
rxfifo.io.dataIn  := rx_ff_wdata
rxfifo.io.readEn  := rx_ff_rden

*/



val txfifo = Module(new QueueModule(12,16))
val rxfifo = Module(new QueueModule(12,16))


val tx_ff_wdata  = RegInit(0.U(12.W))
val tx_ff_wen    = RegInit(false.B)
val tx_ff_rden   = RegInit(false.B)
val tx_ff_rdata  = txfifo.io.o.bits
val tx_ff_rdatar = RegInit(0.U(12.W))

val rx_ff_wdata  = RegInit(0.U(12.W))
val rx_ff_wen    = RegInit(false.B)
val rx_ff_rden   = RegInit(false.B)


//txfifo.io.clock   :=  io.PCLK
//txfifo.io.reset   :=  !io.PRESETn

txfifo.io.i.valid :=  tx_ff_wen
txfifo.io.i.bits  :=  tx_ff_wdata
txfifo.io.o.ready :=  tx_ff_rden

//rxfifo.io.clock   :=  io.PCLK
//rxfifo.io.reset   :=  !io.PRESETn

rxfifo.io.i.valid :=  rx_ff_wen
rxfifo.io.i.bits  :=  rx_ff_wdata
rxfifo.io.o.ready :=  rx_ff_rden




val RDATA = RegInit(0.U(32.W))
io.PRDATA  := RDATA

val divisor      = RegInit(156.U(16.W))
val baudreg_tx   = RegInit(0.U(16.W))
val baudcount_tx = RegInit(0.U(16.W))
val baudcycle_tx = RegInit(0.U(4.W))

val baudreg_rx   = RegInit(0.U(16.W))
val baudcount_rx = RegInit(0.U(16.W))
val baudcycle_rx = RegInit(0.U(4.W))

io.divisor    := divisor
io.baudreg_tx    := baudreg_tx
io.baudcount_tx  := baudcount_tx
io.baudcycle_tx  := baudcycle_tx

val dlab          = RegInit(false.B)
val setbreak      = RegInit(false.B)
val stickparity   = RegInit(false.B)
val evenparselect = RegInit(false.B)
val parityenable  = RegInit(false.B)
val numstopbits   = RegInit(false.B)
val wordlengsel   = RegInit(3.U(2.W)) //default 8 bit

val rxdc = RegInit(false.B)
val rxdp = RegInit(false.B)
val rxbitcountr = RegInit(10.U(4.W))
val rxd_line    = RegInit(0.U(12.W))
val rxd = RegInit(true.B)  

val txd = RegInit(true.B)
io.txd       := Mux(loop,true.B,txd)
val trxbitcountr  = RegInit(10.U(4.W))
val txbitcountr = RegInit(10.U(4.W))
val rxparity   = RegInit(false.B)
val rxrawreg   = RegInit(0.U(12.W))


//////////////////////////// LINE CONTROL REGISTER //////////////////////////////////////////////////////////////
when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbuart.LCR)){
  dlab          := io.PWDATA(7)
  setbreak      := io.PWDATA(6)
  stickparity   := io.PWDATA(5)
  evenparselect := io.PWDATA(4)
  parityenable  := io.PWDATA(3)
  numstopbits   := io.PWDATA(2)
  wordlengsel   := io.PWDATA(1,0)
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


when (io.PSEL &&  !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbuart.LCR)){
  RDATA        := Cat(0.U(24.W),dlab,setbreak,stickparity,evenparselect,parityenable,numstopbits,wordlengsel)
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////  MODEM CONTROL REGISTER ///////////////////////////////////////////////////////////
when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbuart.MCR)){
  loop          := io.PWDATA(4)
  out2          := io.PWDATA(3)
  out1          := io.PWDATA(2)
  rtsn           := io.PWDATA(1)
  dtrn           := io.PWDATA(0)
}
when (io.PSEL &&  !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbuart.MCR)){
  RDATA        := Cat(0.U(27.W),loop,out2,out1,rtsn,dtrn)
}

io.out1  := out1
io.out2  := out2
io.rtsn   := rtsn 
io.dtrn   := dtrn 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////                SCRATCH REGISTER           ////////////////////////////////////////
val scratch = RegInit(0.U(32.W))
when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbuart.SCR)){
  scratch          := io.PWDATA
}
when (io.PSEL &&  !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbuart.SCR)){
  RDATA        := scratch
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////                                        DIVISOR REGISTER /////////////////////////////////////////////////
val divisor_lsb = RegInit(36.U(8.W))
val divisor_msb = RegInit(0.U(8.W))
when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbuart.DLL) && dlab) {
  divisor_lsb := io.PWDATA(7,0)
  divisor     := Cat(divisor_msb,io.PWDATA(7,0))
}
when (io.PSEL &&  !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbuart.DLL) && dlab){
  RDATA        := Cat(0.U(24.W),divisor_lsb)
}
when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbuart.DLH) && dlab) {
  divisor_msb := io.PWDATA(7,0);
  divisor     := Cat(io.PWDATA(7,0),divisor_lsb)
}
when (io.PSEL &&  !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbuart.DLH) && dlab){
   RDATA        := Cat(0.U(24.W),divisor_msb)
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////// STICKY PARITY AND ODD EVEN PARITY GENERATION ////////////////////////////
def parityGen(data: UInt,stickparity: Bool,evenparselect: Bool) : UInt = {
val sparity = stickparity && !data(4) && data(3) 
val dataparity  = MuxLookup(wordlengsel,false.B,Seq(
	0.U  ->  Mux(evenparselect,!data(4,0).xorR,data(4,0).xorR), 
	1.U  ->  Mux(evenparselect,!data(5,0).xorR,data(5,0).xorR),
	2.U  ->  Mux(evenparselect,!data(6,0).xorR,data(6,0).xorR),
	3.U  ->  Mux(evenparselect,!data(7,0).xorR,data(7,0).xorR)
))
val parity  = (sparity || dataparity)
return parity.asUInt
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// DATA PREPARATION //////////////////////////////////////////////////////////////



val txdata04 = Cat(io.PWDATA(0),io.PWDATA(1),io.PWDATA(2),io.PWDATA(3),io.PWDATA(4))
val txdata05 = Cat(io.PWDATA(0),io.PWDATA(1),io.PWDATA(2),io.PWDATA(3),io.PWDATA(4),io.PWDATA(5))
val txdata06 = Cat(io.PWDATA(0),io.PWDATA(1),io.PWDATA(2),io.PWDATA(3),io.PWDATA(4),io.PWDATA(5),io.PWDATA(6))
val txdata07 = Cat(io.PWDATA(0),io.PWDATA(1),io.PWDATA(2),io.PWDATA(3),io.PWDATA(4),io.PWDATA(5),io.PWDATA(6),io.PWDATA(7))

val txdata = MuxLookup(Cat(parityenable.asUInt,numstopbits.asUInt,wordlengsel), Cat(0.U(1.W),txdata07,1.U(1.W)).zext,Seq(
//one stop bits
	0.U  -> Cat(0.U(1.W),txdata04,1.U(1.W)).zext,
	1.U  -> Cat(0.U(1.W),txdata05,1.U(1.W)).zext,
	2.U  -> Cat(0.U(1.W),txdata06,1.U(1.W)).zext,
	3.U  -> Cat(0.U(1.W),txdata07,1.U(1.W)).zext,
	//two stop bits
	4.U  -> Cat(0.U(1.W),txdata04,3.U(2.W)).zext,
	5.U  -> Cat(0.U(1.W),txdata05,3.U(2.W)).zext,
	6.U  -> Cat(0.U(1.W),txdata06,3.U(2.W)).zext,
	7.U  -> Cat(0.U(1.W),txdata07,3.U(2.W)).zext,
	/////////////////////////////////////////////////////////////////////////
	//parity
	//one stop bits
	8.U  -> Cat(0.U(1.W),txdata04,parityGen(io.PWDATA,stickparity,evenparselect),1.U(1.W)).zext,
	9.U  -> Cat(0.U(1.W),txdata05,parityGen(io.PWDATA,stickparity,evenparselect),1.U(1.W)).zext,
	10.U -> Cat(0.U(1.W),txdata06,parityGen(io.PWDATA,stickparity,evenparselect),1.U(1.W)).zext,
	11.U -> Cat(0.U(1.W),txdata07,parityGen(io.PWDATA,stickparity,evenparselect),1.U(1.W)).zext,
	//parity
	//two stop bits
	12.U -> Cat(0.U(1.W),txdata04,parityGen(io.PWDATA,stickparity,evenparselect),3.U(2.W)).zext,
	13.U -> Cat(0.U(1.W),txdata05,parityGen(io.PWDATA,stickparity,evenparselect),3.U(2.W)).zext,
	14.U -> Cat(0.U(1.W),txdata06,parityGen(io.PWDATA,stickparity,evenparselect),3.U(2.W)).zext,
	15.U -> Cat(0.U(1.W),txdata07,parityGen(io.PWDATA,stickparity,evenparselect),3.U(2.W)).zext
/////////////////////////////////////////////////////////////////////////

))

////////////////////////////  TRANSMIT HOLDING REGISTER ////////////////////////////////////////////////////////////////////////
when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbuart.THR) && !dlab) {
	tx_ff_wdata := Mux(!txfifo.io.i.ready ,0.U,txdata.asUInt)
	tx_ff_wen   := Mux(!txfifo.io.i.ready ,false.B,true.B)    
}   .otherwise {
	tx_ff_wdata := 0.U
	tx_ff_wen := false.B 
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

trxbitcountr := MuxLookup(Cat(parityenable.asUInt,numstopbits.asUInt,wordlengsel),10.U,Seq(
	//one stop bits
	0.U  -> 7.U,                // 1 START 5 DATA 1STOP
	1.U  -> 8.U,			    // 1 START 6 DATA 1STOP	
	2.U  -> 9.U,                // 1 START 7 DATA 1STOP
	3.U  -> 10.U,               // 1 START 8 DATA 1STOP
	//two stop bits           
	4.U  -> 8.U,               // 1 START 5 DATA 2 STOP
	5.U  -> 9.U,               // 1 START 6 DATA 2 STOP
	6.U  -> 10.U,              // 1 START 7 DATA 2 STOP
	7.U  -> 11.U,              // 1 START 8 DATA 2 STOP
	/////////////////////////////////////////////////////////////////////////
	//parity
	//one stop bits
	8.U  -> 8.U,             // 1 START 5 DATA 1PARITY  1 STOP
	9.U  -> 9.U,             // 1 START 6 DATA 1PARITY  1 STOP
	10.U -> 10.U,            // 1 START 7 DATA 1PARITY  1 STOP
	11.U -> 11.U,            // 1 START 8 DATA 1PARITY  1 STOP
	//parity
	//two stop bits
	12.U -> 9.U,             // 1 START 5 DATA 1PARITY 2 STOP
	13.U -> 10.U,            // 1 START 6 DATA 1PARITY 2 STOP
	14.U -> 11.U,            // 1 START 7 DATA 1PARITY 2 STOP
	15.U -> 12.U             // 1 START 8 DATA 1PARITY 2 STOP
/////////////////////////////////////////////////////////////////////////
))


//
val txshiftout = RegInit(true.B)


val errrxff     = RegInit(false.B)
val txffempty   = RegInit(false.B)
val breaki      = RegInit(false.B)
val frameerr    = RegInit(false.B)
val parityerr   = RegInit(false.B)
val overrun     = RegInit(false.B)
val dataready   = RegInit(false.B)

txffempty := !txfifo.io.o.valid
val rxavail = rxfifo.io.o.valid
dataready := rxstate === s_IDLERX

txshiftout := Mux(txstate === s_IDLE,true.B,false.B)

// this is the calculated parity
val rxparitycalulated = parityGen(rx_ff_wdata,stickparity,evenparselect) 
// this is the received parity
val rxreceivedparity  = Mux(numstopbits,rxrawreg(2),rxrawreg(1))
val frameerrw         = Mux(numstopbits,!rxrawreg(2) || !rxrawreg(1),!rxrawreg(1))

when (io.PSEL && !io.PWRITE  && !io.PENABLE && (io.PADDR(7,0) === Address_apbuart.LSR) ) {
	RDATA := Cat(0.U(24.W),txshiftout,errrxff,rxavail,txffempty,breaki,parityerr,overrun,dataready)
	overrun       := false.B
	breaki        := false.B
	parityerr     := false.B
	frameerr      := false.B
	errrxff        := false.B
} .otherwise {
	overrun        := Mux(!overrun   && !rxfifo.io.i.ready && rx_ff_wen,true.B,overrun)
	breaki         := Mux(!breaki    && rx_ff_wen && rxrawreg === 0.U,true.B,breaki)
	parityerr      := Mux(!parityerr && rx_ff_wen && (rxparitycalulated =/= rxreceivedparity),true.B,parityerr)
        frameerr       := Mux(!frameerr  && rx_ff_wen && frameerrw,true.B,frameerr)
        errrxff        := Mux(!errrxff  && rx_ff_wen && ((!rxfifo.io.i.ready) ||  (rxrawreg === 0.U) ||   (rxparitycalulated =/= rxreceivedparity).toBool ||  frameerrw),true.B,errrxff)
}


// modem status register
val readmsr = RegInit(false.B)
val rinc = RegInit(false.B)
val rinp = RegInit(false.B)
rinc := io.rin
rinp := rinc
val teri = RegInit(false.B)

val ddcd = RegInit(false.B)
val ddsr = RegInit(false.B)
val dcts = RegInit(false.B)

val dcdn = RegInit(false.B)
val dsrn = RegInit(false.B)
val ctsn = RegInit(false.B)
val rin  = RegInit(false.B)

dcdn := io.dcdn
dsrn := io.dsrn
ctsn := io.ctsn

when(rinc && !rinp) {
teri := true.B
} .elsewhen (rinp && !rinc) {
teri := false.B
} .otherwise {
teri := teri
}

ddcd := Mux(dcdn =/= io.dcdn,true.B,ddcd)
ddsr := Mux(dsrn =/= io.dsrn,true.B,ddsr)
dcts := Mux(ctsn =/= io.ctsn,true.B,dcts)

when (io.PSEL && !io.PWRITE  && !io.PENABLE && (io.PADDR(7,0) === Address_apbuart.MSR) ) {
	RDATA   := Cat(0.U(24.W),!io.dcdn,!io.rin,!io.dsrn,!io.ctsn,ddcd,teri,ddsr,dcts)
	dcdn := io.dcdn
        dsrn := io.dsrn
        ctsn := io.ctsn
        rin  := io.rin
        
} 

///////////////////////////////////// UART TRANSMISSION /////////////////////////////////////////
when(dlab || setbreak) {
	txd           := Mux(setbreak,false.B,true.B)
	tx_ff_rden    := false.B
	txstate       := s_IDLE
	baudreg_tx    := divisor
	baudcount_tx  := 0.U
	baudcycle_tx  := 0.U
} .otherwise {//dlab  

switch(txstate) {

	is(s_IDLE) {
		tx_ff_rden    := Mux(!txfifo.io.o.valid,false.B,true.B)
		txstate       := Mux(!txfifo.io.o.valid,s_IDLE,s_TXRD)
		txd           := Mux(setbreak,false.B,true.B)
		baudreg_tx    := divisor
		baudcount_tx  := 0.U
		baudcycle_tx  := 0.U
		txbitcountr := trxbitcountr
		tx_ff_rdatar := 0.U
	} //S_IDLE
	is(s_TXRD) {
		tx_ff_rden   := false.B
	        tx_ff_rdatar := tx_ff_rdata
		txstate      := s_TXDEQ
		txd          := true.B
	} // s_TXRD
	is(s_TXDEQ) { 
		txstate    := s_TXDATA
		tx_ff_rden := false.B
		txd        := MuxLookup(trxbitcountr,false.B,Seq(
					7.U  ->  tx_ff_rdatar(6),
					8.U  ->  tx_ff_rdatar(7),
					9.U  ->  tx_ff_rdatar(8),
					10.U ->  tx_ff_rdatar(9),
					11.U ->  tx_ff_rdatar(10),
					12.U ->  tx_ff_rdatar(11)
					))
		baudcount_tx   := baudcount_tx + 1.U
		baudcycle_tx   :=  0.U
		txbitcountr := trxbitcountr
		
	} //s_TXDEQ
	is(s_TXDATA) {
		baudcount_tx  := Mux(baudcount_tx === (baudreg_tx - 1.U),0.U,baudcount_tx + 1.U)
		baudcycle_tx  := Mux(baudcount_tx === (baudreg_tx - 1.U),Mux(baudcycle_tx === 15.U,0.U,baudcycle_tx + 1.U),baudcycle_tx)
		
		when( (baudcycle_tx === 15.U) && (baudcount_tx === (baudreg_tx - 1.U)) ) {
			tx_ff_rdatar := tx_ff_rdatar << 1
		} .otherwise {
			tx_ff_rdatar := tx_ff_rdatar
		}
		
		when( (baudcycle_tx === 15.U) && (baudcount_tx === (baudreg_tx - 1.U)) && (txbitcountr === 1.U)) {
			txstate     := s_IDLE
			txd         := true.B
			txbitcountr := trxbitcountr
		} .otherwise {
			txstate    := s_TXDATA
			txbitcountr := Mux( (baudcycle_tx === 15.U) && (baudcount_tx === (baudreg_tx - 1.U)),txbitcountr - 1.U,txbitcountr)
			txd        := MuxLookup(trxbitcountr,false.B,Seq(
				7.U  ->  tx_ff_rdatar(6),
				8.U  ->  tx_ff_rdatar(7),
				9.U  ->  tx_ff_rdatar(8),
				10.U ->  tx_ff_rdatar(9),
				11.U ->  tx_ff_rdatar(10),
				12.U ->  tx_ff_rdatar(11)
				))
		}
	} //s_TXDATA
} //txstate

} //dlab  
///////////////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////// UART RECEPTION /////////////////////////////////////////
rxd  := Mux(loop,txd,io.rxd)
rxdc := rxd
rxdp := rxdc
val start_det = rxdp && !rxdc
switch(rxstate) {

is(s_IDLERX) { 
	rxstate       := Mux(start_det || !rxd,s_RXRD,s_IDLERX) //to avoid baud miss or condition
	baudreg_rx    := divisor
	baudcount_rx  := Mux(start_det,1.U,0.U)
	baudcycle_rx  := 0.U
	rxbitcountr   := trxbitcountr
	rx_ff_wdata   := 0.U
        rx_ff_wen     := false.B
        rxrawreg      := 0.U
     } //S_IDLE
is(s_RXRD) { 

	baudcount_rx  := Mux(baudcount_rx === (baudreg_rx - 1.U),0.U,baudcount_rx + 1.U)
	baudcycle_rx  := Mux(baudcount_rx === (baudreg_rx - 1.U),Mux(baudcycle_rx === 15.U,0.U,baudcycle_rx + 1.U),baudcycle_rx)
	rxbitcountr   := Mux( (baudcycle_rx === 15.U) && (baudcount_rx === (baudreg_rx - 1.U)),rxbitcountr - 1.U,rxbitcountr)
	
	when( (baudcycle_rx === 7.U) && (baudcount_rx === (baudreg_rx - 1.U)) && (rxbitcountr === trxbitcountr)) {
			rxstate        := Mux(rxd,s_IDLE,s_RXRD) // if in the middle start bit is high to ensure no false detection
		        rx_ff_wen      := false.B
		        rx_ff_wdata    := Cat(rx_ff_wdata(11,1),rxd)
			
		      
	} .elsewhen( (baudcycle_rx === 15.U) && (baudcount_rx === (baudreg_rx - 1.U)) &&   (rxbitcountr === 1.U)   ) {
			rxstate        := s_IDLE
			rx_ff_wen      := true.B
			rxrawreg       := rx_ff_wdata
			
			rx_ff_wdata    :=  MuxLookup(Cat(parityenable.asUInt,numstopbits.asUInt,wordlengsel),0.U,Seq(
	                           //one stop bits
	                           0.U  -> rx_ff_wdata(5,1).asUInt,            // 1 START 5 DATA 1STOP
	                           1.U  -> rx_ff_wdata(6,1).asUInt,               // 1 START 6 DATA 1STOP	
	                           2.U  -> rx_ff_wdata(7,1).asUInt,               // 1 START 7 DATA 1STOP
	                           3.U  -> rx_ff_wdata(8,1).asUInt,              // 1 START 8 DATA 1STOP
	                           //two stop bits           
	                           4.U  -> rx_ff_wdata(6,2).asUInt,                // 1 START 5 DATA 2 STOP
	                           5.U  -> rx_ff_wdata(7,2).asUInt,                // 1 START 6 DATA 2 STOP
	                           6.U  -> rx_ff_wdata(8,2).asUInt,               // 1 START 7 DATA 2 STOP
	                           7.U  -> rx_ff_wdata(9,2).asUInt,               // 1 START 8 DATA 2 STOP
	                           /////////////////////////////////////////////////////////////////////////
	                           //parity
	                           //one stop bits
	                           8.U  -> rx_ff_wdata(6,2).asUInt,              // 1 START 5 DATA 1PARITY  1 STOP
	                           9.U  -> rx_ff_wdata(7,2).asUInt,               // 1 START 6 DATA 1PARITY  1 STOP
	                           10.U -> rx_ff_wdata(8,2).asUInt,              // 1 START 7 DATA 1PARITY  1 STOP
	                           11.U -> rx_ff_wdata(9,2).asUInt,             // 1 START 8 DATA 1PARITY  1 STOP
	                           //parity
	                           //two stop bits
	                           12.U -> rx_ff_wdata(7,3).asUInt,                // 1 START 5 DATA 1PARITY 2 STOP
	                           13.U -> rx_ff_wdata(8,3).asUInt,               // 1 START 6 DATA 1PARITY 2 STOP
	                           14.U -> rx_ff_wdata(9,3).asUInt,               // 1 START 7 DATA 1PARITY 2 STOP
	                           15.U -> rx_ff_wdata(10,3).asUInt                // 1 START 8 DATA 1PARITY 2 STOP
                               /////////////////////////////////////////////////////////////////////////
))
  } .elsewhen( (baudcycle_rx === 7.U) && (baudcount_rx === (baudreg_rx - 1.U)) ) {
			rx_ff_wdata    := Cat(rx_ff_wdata(11,1),rxd)
			rxstate        := s_RXRD
			rx_ff_wen      := false.B
	} .elsewhen( (baudcycle_rx === 8.U) && (baudcount_rx === (baudreg_rx - 1.U)) &&   (rxbitcountr =/= 1.U)  )  {
	               rx_ff_wdata    := rx_ff_wdata << 1;
			rxstate        := s_RXRD
			rx_ff_wen      := false.B
	
	} .otherwise { 
			rx_ff_wen      := false.B	
			rxstate        := s_RXRD
	} 
} //s_RXRD


} //rxstate

//  WIRES FOR INTERRUPT
val intpend = RegInit(false.B)
val intid   = RegInit(0.U(3.W))
val receiver_line_intr = breaki || frameerr || parityerr || overrun
val modem_staus_intr = teri || dcdn || ddsr || dcts || !io.dcdn || !io.dsrn ||  !io.ctsn || !io.rin
val charatime_count = RegInit(0.U(2.W))
val charatimeout   = charatime_count === 3.U

 



// PRIOROTY INTERRUPT
when(receiver_line_intr)      {
	intid   := 3.U(3.W) 
} .elsewhen(!rxfifo.io.o.valid) {
	intid   := 2.U(3.W) 
} .elsewhen(!txfifo.io.o.valid)  { 
	intid   := 1.U(3.W)
} .elsewhen (charatimeout) {
	intid   := 6.U(3.W)
} .elsewhen(modem_staus_intr) {
	intid   := 0.U(3.W)
} .otherwise {
       intid   := 5.U(3.W)
}

//READ ONLY INTERRUPT IDENTIFICATION REGISTER
when (io.PSEL && !io.PWRITE  && !io.PENABLE && (io.PADDR(7,0) === Address_apbuart.IIR) ) {
	RDATA := Cat(0.U(24.W),3.U(2.W),0.U(2.W),intid,intpend)
	intpend := false.B
} .otherwise {
        intpend := receiver_line_intr || !rxfifo.io.o.valid || !txfifo.io.o.valid || modem_staus_intr
}



//read fifo
val rxffrev = Cat(rxfifo.io.o.bits(0),rxfifo.io.o.bits(1),rxfifo.io.o.bits(2),rxfifo.io.o.bits(3),rxfifo.io.o.bits(4),rxfifo.io.o.bits(5),rxfifo.io.o.bits(6),rxfifo.io.o.bits(7))

when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_apbuart.RBR) && !dlab) {
	RDATA           := Mux(!rxfifo.io.o.valid,0.U(32.W), Cat(0.U(24.W),rxffrev))
	rx_ff_rden      := Mux(!rxfifo.io.o.valid,false.B,true.B)
	// for every read the charatime_count is reset
	charatime_count := 0.U
} .otherwise {
	rx_ff_rden := false.B
	// the charatime_count increments every rd fifo enq till 4 times and then gives a interrupt
       charatime_count := Mux(rx_ff_wen,Mux(charatime_count === 3.U,3.U,charatime_count + 1.U),charatime_count)
}











///////////////////////////////////////////////////////////////////////////////////////////////////////////
} //pclk domain        

}
	
// Generate the Verilog code by invoking the Driver
object apbuartMain extends App {
  println("Generating the top hardware")
  chisel3.Driver.execute(Array("--target-dir", "top"), () => new apbuart(4))
}




