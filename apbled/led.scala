package led
import chisel3._
import chisel3.experimental._
import chisel3.util._
import chisel3.util.BitPat
import Address_led._
class apbled extends Module  {
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
val datar    = RegInit(true.B)
val swreset  = RegInit(false.B)
val apbrdata = RegInit(0.U(32.W))
io.PRDATA    := apbrdata
io.LEDOUT    := Mux(swreset,false.B,datar);

// state machine state declaration /////////////////
val (sIDLE :: sDATA :: sPACKET :: sTX :: Nil) = Enum(4)
val state  = RegInit(sIDLE)



val ledfifo = Module(new QueueModuleled(24,4))

val   txffwdata  = RegInit(0.U(24.W))
val   txffwren   = RegInit(false.B)
val   txffrden   = RegInit(false.B)

ledfifo.io.i.valid :=  txffwren
ledfifo.io.i.bits  :=  txffwdata
ledfifo.io.o.ready :=  txffrden 

val packet = RegInit(0.U(24.W))
val dfifow = ledfifo.io.o.bits
val pixelcount = RegInit(0.U(5.W))

val t0h = RegInit(4.U(8.W))
val t0l = RegInit(4.U(8.W))
val t1h = RegInit(4.U(8.W))
val t1l = RegInit(4.U(8.W))

val seqcount = RegInit(0.U(8.W))
val count = RegInit(1.U(8.W))
val count0 = t0h + t0l;
val count1 = t1h + t1l;



when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_led.TX_ADDR)) {
     txffwdata := io.PWDATA(23,0)
     txffwren  := true.B
     }  .otherwise {
     txffwdata := 0.U
     txffwren  := false.B
     }
     
when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_led.T0H_ADDR)) {
	t0h := io.PWDATA(7,0)
}
     
when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_led.T0L_ADDR)) {
	t0l := io.PWDATA(7,0)
}

when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_led.T1H_ADDR)) {
	t1h := io.PWDATA(7,0)
}

when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_led.T1L_ADDR)) {
	t1l := io.PWDATA(7,0)
}    
          
     
 when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_led.SR_ADDR)) {
     apbrdata := Cat(0.U(30.W),!ledfifo.io.o.valid,!ledfifo.io.i.ready)
     }

when (io.PSEL && io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_led.RSTLED_ADDR)) {
     swreset := io.PWDATA(0)
     }
     
     
switch(state) {
	is(sIDLE) { 
	
	state    := Mux(ledfifo.io.o.valid,sDATA,sIDLE)
	datar    := false.B
	txffrden := false.B
               
	} //sidle
	
	is(sDATA) {
	
	txffrden := Mux(ledfifo.io.o.valid,true.B,false.B)
	datar    := false.B
	packet   := dfifow
	state    := sPACKET
	
	
	} //sdata
	
	is(sPACKET) {
	
	txffrden := false.B
	datar    := false.B
	state    := sTX
	seqcount    := Mux(packet(23),count1,count0)
	
	}
	
	
	is(sTX) {
	
	
	
	seqcount   := Mux(packet(23),count1,count0)
	packet     := Mux(count === seqcount,packet << 1,packet);
	count      := Mux(count === seqcount,1.U(8.W), count + 1.U)
	pixelcount := Mux(count === seqcount,Mux(pixelcount === 23.U,0.U,pixelcount + 1.U),pixelcount)
	state      := Mux(count === seqcount,Mux(pixelcount === 23.U,sIDLE,sTX),state)
	
	
	datar      := Mux(packet(23),
	              Mux(count <= t1h,true.B,false.B)  // 1 sequence
	              ,
	              Mux(count <= t0h,true.B,false.B)) // 0 sequence
	             
	             
	             
	             
	             
	
	//packet := packet << 1
	
	
	
	
	
	
	}
	
	
	
	}
	}
	
	}
// Generate the Verilog code by invoking the Driver
object ApbLedMain extends App {

  println("Generating the top hardware")
  chisel3.Driver.execute(Array("--target-dir", "top"), () => new apbled())
}
