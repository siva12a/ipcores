package led1
import chisel3._
import chisel3.experimental._
import chisel3.util._
import chisel3.util.BitPat
import Address_led1._
class LedBehav1 extends Module  {
//instruction ar channel
val io = IO(new Bundle {
val  PCLK              = Input(Clock())  // system control clock 
val  PRESETn           = Input(Bool())  // system control reset active low
val  PADDR             = Input(UInt(8.W))   
val  PPROT             = Input(Bool())
val  PSEL              = Input(Bool())
val  PENABLE           = Input(Bool())
val  PWRITE            = Input(Bool())
val  PWDATA            = Input(UInt(32.W))    
val  PSTRB             = Input(UInt(4.W))
val  PREADY            = Output(Bool())
val  PRDATA            = Output(UInt(32.W))  
val  PSLVERR           = Output(Bool())

val  LEDOUT            = Output(Bool())

})

io.PREADY  := 1.U;
io.PSLVERR := 0.U;

withClockAndReset(io.PCLK, ~io.PRESETn) {
val datar = RegInit(false.B)

val apbrdata = RegInit(0.U(32.W))
io.PRDATA := apbrdata
io.LEDOUT := datar

// state machine state declaration /////////////////
val (sIDLE :: sDATA :: sPACKET :: sTX :: Nil) = Enum(4)
val state  = RegInit(sIDLE)

val   toh          =  RegInit(12.U(8.W))
val   tol          =  RegInit(0.U(8.W))
val   t1h          =  RegInit(6.U(8.W))
val   t1l          =  RegInit(0.U(8.W))

val ledfifo = Module(new QueueModuleled1(24,21))

val   txffwdata  = RegInit(0.U(24.W))
val   txffwren   = RegInit(false.B)
val   txffrden   = RegInit(false.B)

ledfifo.io.i.valid :=  txffwren
ledfifo.io.i.bits  :=  txffwdata
ledfifo.io.o.ready :=  txffrden 

val packet = RegInit(0.U(600.W))


val dfifow = ledfifo.io.o.bits

val wire1h  = "hFFFF".U(16.W)
val wire1l  = "b000000000".U(9.W)
val wire1 = Cat(wire1h,wire1l)


val wire0h = "hFF".U(8.W)
val wire0l = Cat(0.U(1.W),"h0000".U(16.W))
val wire0 = Cat(wire0h,wire0l)

val gpacket7 = Mux(dfifow(23),wire1,wire0)
val gpacket6 = Mux(dfifow(22),wire1,wire0)
val gpacket5 = Mux(dfifow(21),wire1,wire0)
val gpacket4 = Mux(dfifow(20),wire1,wire0)
val gpacket3 = Mux(dfifow(19),wire1,wire0)
val gpacket2 = Mux(dfifow(18),wire1,wire0)
val gpacket1 = Mux(dfifow(17),wire1,wire0)
val gpacket0 = Mux(dfifow(16),wire1,wire0)

val gpacket = Cat(gpacket7,gpacket6,gpacket5,gpacket4,gpacket3,gpacket2,gpacket1,gpacket0)

val rpacket7 = Mux(dfifow(15),wire1,wire0)
val rpacket6 = Mux(dfifow(14),wire1,wire0)
val rpacket5 = Mux(dfifow(13),wire1,wire0)
val rpacket4 = Mux(dfifow(12),wire1,wire0)
val rpacket3 = Mux(dfifow(11),wire1,wire0)
val rpacket2 = Mux(dfifow(10),wire1,wire0)
val rpacket1 = Mux(dfifow(9),wire1,wire0)
val rpacket0 = Mux(dfifow(8),wire1,wire0)

val rpacket = Cat(rpacket7,rpacket6,rpacket5,rpacket4,rpacket3,rpacket2,rpacket1,rpacket0)

val bpacket7 = Mux(dfifow(7),wire1,wire0)
val bpacket6 = Mux(dfifow(6),wire1,wire0)
val bpacket5 = Mux(dfifow(5),wire1,wire0)
val bpacket4 = Mux(dfifow(4),wire1,wire0)
val bpacket3 = Mux(dfifow(3),wire1,wire0)
val bpacket2 = Mux(dfifow(2),wire1,wire0)
val bpacket1 = Mux(dfifow(1),wire1,wire0)
val bpacket0 = Mux(dfifow(0),wire1,wire0)

val bpacket = Cat(bpacket7,bpacket6,bpacket5,bpacket4,bpacket3,bpacket2,bpacket1,bpacket0)

val packetw = Cat(gpacket,rpacket,bpacket)




val count = RegInit(1.U(10.W))

when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_led1.TX_ADDR)) {
     txffwdata := io.PWDATA(23,0)
     txffwren  := true.B
     }  .otherwise {
     txffwdata := 0.U
     txffwren  := false.B
     }
     
 when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_led1.SR_ADDR)) {
     apbrdata := Cat(0.U(30.W),!ledfifo.io.o.valid,!ledfifo.io.i.ready)
     }


switch(state) {
	is(sIDLE) { 
	
	state := Mux(ledfifo.io.o.valid,sDATA,sIDLE)
	datar := false.B
	txffrden := false.B
               
	} //sidle
	
	is(sDATA) {
	
	txffrden := Mux(ledfifo.io.o.valid,true.B,false.B)
	datar    := false.B
	packet   := packetw
	state    := sPACKET
	
	
	} //sdata
	
	is(sPACKET) {
	
	txffrden := false.B
	datar    := false.B
	state     := sTX
	}
	
	
	is(sTX) {
	
	count := Mux(count === 600.U,1.U,count + 1.U)
	state := Mux(count === 600.U,sIDLE,sTX)
	datar := packet(599)
	
	packet := packet << 1
	
	
	
	
	
	
	}
	
	
	
	}
	}
	
	}
// Generate the Verilog code by invoking the Driver
object LedBehavMain1 extends App {

  println("Generating the top hardware")
  chisel3.Driver.execute(Array("--target-dir", "top"), () => new LedBehav1())
}
