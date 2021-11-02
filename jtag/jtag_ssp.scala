package jtag


import chisel3._
import chisel3.experimental._
import chisel3.util._
import chisel3.util.BitPat
import Address_jtag._


class jtag_ssp extends Module  {
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
val  PSTRB             = Input(UInt(1.W))
val  PREADY            = Output(Bool())
val  PRDATA            = Output(UInt(32.W))  
val  PSLVERR           = Output(Bool())

val  TMS           	= Output(Bool())
val  TCK           	= Output(Bool())
val  TDO           	= Output(Bool())
val  TDI           	= Input(Bool())


val JTAC            = Output(UInt(8.W))
val DIVI            = Output(UInt(8.W))



})

io.PREADY  := 0.U;
io.PSLVERR := 0.U;

withClockAndReset(io.PCLK, ~io.PRESETn) {
val tdo_or = RegInit(true.B)
val tms_or = RegInit(true.B)
val tck_or = RegInit(false.B)

io.TMS := tms_or
io.TCK := tck_or
io.TDO := tdo_or

val   tmsffrden   = RegInit(false.B)
val   tdoffrden   = RegInit(false.B)

val   tdodatar    = RegInit(0.U(64.W))
val   tmsdatar    = RegInit(0.U(64.W))

val  fifoinr    = RegInit(0.U(64.W))

val   fifoclr     = RegInit(false.B)


val divisor      = RegInit(2.U(8.W))
val divisorr     = RegInit(2.U(8.W))
val jtag_txcount = RegInit(0.U(8.W))

io.JTAC := jtag_txcount;
io.DIVI := divisorr




val apbrdata = RegInit(0.U(32.W))

val tmsfifo = Module(new QueueModule_jtag(64,1))
val tdofifo = Module(new QueueModule_jtag(64,1))
val tdififo = Module(new QueueModule_jtag(32,1))




io.PRDATA := apbrdata;


val tms_w = Cat(io.PWDATA(31),io.PWDATA(31),
		io.PWDATA(30),io.PWDATA(30),
		io.PWDATA(29),io.PWDATA(29),
		io.PWDATA(28),io.PWDATA(28),
		io.PWDATA(27),io.PWDATA(27),
		io.PWDATA(26),io.PWDATA(26),
		io.PWDATA(25),io.PWDATA(25),
		io.PWDATA(24),io.PWDATA(24),
		io.PWDATA(23),io.PWDATA(23),
		io.PWDATA(22),io.PWDATA(22),
		io.PWDATA(21),io.PWDATA(21),
		io.PWDATA(20),io.PWDATA(20),
		io.PWDATA(19),io.PWDATA(19),
		io.PWDATA(18),io.PWDATA(18),
		io.PWDATA(17),io.PWDATA(17),
		io.PWDATA(16),io.PWDATA(16),
		io.PWDATA(15),io.PWDATA(15),
		io.PWDATA(14),io.PWDATA(14),
		io.PWDATA(13),io.PWDATA(13),
		io.PWDATA(12),io.PWDATA(12),
		io.PWDATA(11),io.PWDATA(11),
		io.PWDATA(10),io.PWDATA(10),
		io.PWDATA(9),io.PWDATA(9),
		io.PWDATA(8),io.PWDATA(8),
		io.PWDATA(7),io.PWDATA(7),
		io.PWDATA(6),io.PWDATA(6),
		io.PWDATA(5),io.PWDATA(5),
		io.PWDATA(4),io.PWDATA(4),
		io.PWDATA(3),io.PWDATA(3),
		io.PWDATA(2),io.PWDATA(2),
		io.PWDATA(1),io.PWDATA(1),
		io.PWDATA(0),io.PWDATA(0))




val loop  = RegInit(false.B)
val start = RegInit(false.B)
val tmsfifowren = RegInit(false.B)
val tdofifowren = RegInit(false.B)
val tdififorden = RegInit(false.B)
val tdififowren = RegInit(false.B)

fifoinr  := tms_w
tmsfifo.io.i.bits  := fifoinr
tmsfifo.io.i.valid := tmsfifowren
tmsfifo.io.o.ready :=  tmsffrden || fifoclr


tdofifo.io.i.bits  := fifoinr
tdofifo.io.i.valid := tdofifowren
tdofifo.io.o.ready :=  tdoffrden || fifoclr


tdififo.io.o.ready := tdififorden
tdififo.io.i.valid := tdififowren




when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_jtag.EN_ADDR)) {
     start   := io.PWDATA(0)
     loop  		:= io.PWDATA(1)
    }
when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_jtag.DIV_ADDR)) {
     divisor   := io.PWDATA(7,0)
    }     
    
    val length_ind  = RegInit(0.U(8.W))
    val length_indr = RegInit(0.U(8.W))
 when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_jtag.LEN_ADDR)) {
     length_ind   := io.PWDATA(7,0)
    }    
    
    
when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_jtag.TMSFF_ADDR)) {
       
       tmsfifowren := true.B
     }  .otherwise {
       tmsfifowren := false.B
     }    
     
when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_jtag.TDOFF_ADDR)) {
		tdofifowren := true.B
     }  .otherwise {
     tdofifowren := false.B
     }   
// read operations


val complete = RegInit(false.B)

when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_jtag.EN_ADDR)) {
     apbrdata   := Cat(0.U((32-7).W),complete,tdififo.io.i.ready,tdififo.io.o.valid,tdofifo.io.i.ready,tdofifo.io.o.valid,tmsfifo.io.i.ready,tmsfifo.io.o.valid)
     }

when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_jtag.TDIFF_ADDR)) {
     apbrdata              := tdififo.io.o.bits
     tdififorden    := true.B
     } .otherwise {
     tdififorden    := fifoclr
     }

when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_jtag.FF_CLR)) {
     fifoclr   := io.PWDATA(0)
    } .otherwise {
     fifoclr   := false.B
    
    }
     
     
val tclk_r  = RegInit(0.U(64.W))    
val txclk0  = Cat(false.B,true.B)
val txclk1  = Cat(txclk0,txclk0,txclk0,txclk0,txclk0,txclk0,txclk0,txclk0)
val txclk   = Cat(txclk1,txclk1,txclk1,txclk1)

val tmsffnempty = tmsfifo.io.o.valid
val tdoffnempty = tdofifo.io.o.valid


// state machine state declaration /////////////////
val (sIDLE :: sSTART :: sTX :: s_TXRD  :: Nil) = Enum(4)
val state  = RegInit(sIDLE)


val rdtrue = (divisorr === (divisor - 1.U))
//                    for cpha 1                           for cpha 0
val cnt0   = jtag_txcount === 1.U
val cnt1   = jtag_txcount === 3.U
val cnt2   = jtag_txcount === 5.U
val cnt3   = jtag_txcount === 7.U
val cnt4   = jtag_txcount === 9.U
val cnt5   = jtag_txcount === 11.U
val cnt6   = jtag_txcount === 13.U
val cnt7   = jtag_txcount === 15.U
val cnt8   = jtag_txcount === 17.U
val cnt9   = jtag_txcount === 19.U
val cnt10  = jtag_txcount === 21.U
val cnt11  = jtag_txcount === 23.U
val cnt12  = jtag_txcount === 25.U
val cnt13  = jtag_txcount === 27.U
val cnt14  = jtag_txcount === 29.U
val cnt15  = jtag_txcount === 31.U
val cnt16  = jtag_txcount === 33.U
val cnt17  = jtag_txcount === 35.U
val cnt18  = jtag_txcount === 37.U
val cnt19  = jtag_txcount === 39.U
val cnt20  = jtag_txcount === 41.U
val cnt21  = jtag_txcount === 43.U
val cnt22  = jtag_txcount === 45.U
val cnt23  = jtag_txcount === 47.U
val cnt24  = jtag_txcount === 49.U
val cnt25  = jtag_txcount === 51.U
val cnt26  = jtag_txcount === 53.U
val cnt27  = jtag_txcount === 55.U
val cnt28  = jtag_txcount === 57.U
val cnt29  = jtag_txcount === 59.U
val cnt30  = jtag_txcount === 61.U
val cnt31  = jtag_txcount === 63.U


val tdirdata0  = RegInit(false.B)
val tdirdata1  = RegInit(false.B)
val tdirdata2  = RegInit(false.B)
val tdirdata3  = RegInit(false.B)
val tdirdata4  = RegInit(false.B)
val tdirdata5  = RegInit(false.B)
val tdirdata6  = RegInit(false.B)
val tdirdata7  = RegInit(false.B)
val tdirdata8  = RegInit(false.B)
val tdirdata9  = RegInit(false.B)
val tdirdata10 = RegInit(false.B)
val tdirdata11 = RegInit(false.B)
val tdirdata12 = RegInit(false.B)
val tdirdata13 = RegInit(false.B)
val tdirdata14 = RegInit(false.B)
val tdirdata15 = RegInit(false.B)
val tdirdata16 = RegInit(false.B)
val tdirdata17 = RegInit(false.B)
val tdirdata18 = RegInit(false.B)
val tdirdata19 = RegInit(false.B)
val tdirdata20 = RegInit(false.B)
val tdirdata21 = RegInit(false.B)
val tdirdata22 = RegInit(false.B)
val tdirdata23 = RegInit(false.B)
val tdirdata24 = RegInit(false.B)
val tdirdata25 = RegInit(false.B)
val tdirdata26 = RegInit(false.B)
val tdirdata27 = RegInit(false.B)
val tdirdata28 = RegInit(false.B)
val tdirdata29 = RegInit(false.B)
val tdirdata30 = RegInit(false.B)
val tdirdata31 = RegInit(false.B)


val tdi_w = Mux(loop,tdo_or,io.TDI)

val tdirdata = Cat(tdirdata31,tdirdata30,tdirdata29,tdirdata28,
                   tdirdata27,tdirdata26,tdirdata25,tdirdata24,tdirdata23,tdirdata22,tdirdata21,tdirdata20,
                   tdirdata19,tdirdata18,tdirdata17,tdirdata16,tdirdata15,tdirdata14,tdirdata13,tdirdata12,
                   tdirdata11,tdirdata10,tdirdata9,tdirdata8,tdirdata7,tdirdata6,tdirdata5,tdirdata4,tdirdata3,tdirdata2,tdirdata1,tdirdata0).asUInt
                   
                   

tdififo.io.i.bits := tdirdata

tdirdata0  := Mux(rdtrue && cnt0 ,tdi_w,tdirdata0 )
tdirdata1  := Mux(rdtrue && cnt1 ,tdi_w,tdirdata1 )
tdirdata2  := Mux(rdtrue && cnt2 ,tdi_w,tdirdata2 )
tdirdata3  := Mux(rdtrue && cnt3 ,tdi_w,tdirdata3 )
tdirdata4  := Mux(rdtrue && cnt4 ,tdi_w,tdirdata4 )
tdirdata5  := Mux(rdtrue && cnt5 ,tdi_w,tdirdata5 )
tdirdata6  := Mux(rdtrue && cnt6 ,tdi_w,tdirdata6 )
tdirdata7  := Mux(rdtrue && cnt7 ,tdi_w,tdirdata7 )
tdirdata8  := Mux(rdtrue && cnt8 ,tdi_w,tdirdata8 )
tdirdata9  := Mux(rdtrue && cnt9 ,tdi_w,tdirdata9 )
tdirdata10 := Mux(rdtrue && cnt10,tdi_w,tdirdata10)
tdirdata11 := Mux(rdtrue && cnt11,tdi_w,tdirdata11)
tdirdata12 := Mux(rdtrue && cnt12,tdi_w,tdirdata12)
tdirdata13 := Mux(rdtrue && cnt13,tdi_w,tdirdata13)
tdirdata14 := Mux(rdtrue && cnt14,tdi_w,tdirdata14)
tdirdata15 := Mux(rdtrue && cnt15,tdi_w,tdirdata15)
tdirdata16 := Mux(rdtrue && cnt16,tdi_w,tdirdata16)
tdirdata17 := Mux(rdtrue && cnt17,tdi_w,tdirdata17)
tdirdata18 := Mux(rdtrue && cnt18,tdi_w,tdirdata18)
tdirdata19 := Mux(rdtrue && cnt19,tdi_w,tdirdata19)
tdirdata20 := Mux(rdtrue && cnt20,tdi_w,tdirdata20)
tdirdata21 := Mux(rdtrue && cnt21,tdi_w,tdirdata21)
tdirdata22 := Mux(rdtrue && cnt22,tdi_w,tdirdata22)
tdirdata23 := Mux(rdtrue && cnt23,tdi_w,tdirdata23)
tdirdata24 := Mux(rdtrue && cnt24,tdi_w,tdirdata24)
tdirdata25 := Mux(rdtrue && cnt25,tdi_w,tdirdata25)
tdirdata26 := Mux(rdtrue && cnt26,tdi_w,tdirdata26)
tdirdata27 := Mux(rdtrue && cnt27,tdi_w,tdirdata27)
tdirdata28 := Mux(rdtrue && cnt28,tdi_w,tdirdata28)
tdirdata29 := Mux(rdtrue && cnt29,tdi_w,tdirdata29)
tdirdata30 := Mux(rdtrue && cnt30,tdi_w,tdirdata30)
tdirdata31 := Mux(rdtrue && cnt31,tdi_w,tdirdata31)



complete := state === sIDLE

switch(state) {
	is(sIDLE) { 
               
               state		:= Mux(start,sSTART,sIDLE)
               tdo_or		:= false.B
               tck_or		:= false.B
               tms_or		:= false.B
               tmsffrden	:= false.B
               tdoffrden	:= false.B
		divisorr      	:= 0.U
		jtag_txcount	:= 0.U(8.W)
		tclk_r        	:= 0.U(64.W)
		length_indr   	:= length_ind << 1;
		
		tdififowren    := false.B
	}
	is(sSTART) {
		state     	:= Mux(tdoffnempty && tmsffnempty,sTX,sSTART)
		tdo_or		:= false.B
               tck_or		:= false.B
               tms_or		:= false.B
	       tdodatar        := Mux(tdoffnempty && tmsffnempty,tdofifo.io.o.bits,0.U(64.W))
	       tmsdatar        := Mux(tdoffnempty && tmsffnempty,tmsfifo.io.o.bits,0.U(64.W))
	       tmsffrden	:= Mux(tdoffnempty && tmsffnempty,true.B,false.B)
               tdoffrden	:= Mux(tdoffnempty && tmsffnempty,true.B,false.B)
		tclk_r     	:= txclk
		jtag_txcount	:= 0.U(8.W)
		length_indr   	:= length_ind << 1;
		tdififowren    := false.B
	} 
	is(sTX) {
	    
	        state     	:= s_TXRD
	        
	        tdo_or         := tdodatar(0)
	        tdodatar       := tdodatar >> 1
	        
	        tms_or         := tmsdatar(0) 
	        tmsdatar       := tmsdatar >> 1
	        
	        tck_or         := tclk_r(31)
	        tclk_r        	:= tclk_r << 1
	        
	        jtag_txcount	:= 0.U(6.W)
		divisorr 	:= 1.U
		//length_indr   	:= length_ind
		tdififowren    := false.B
	
	}
	is(s_TXRD) {
	
	     jtag_txcount   	:= Mux(divisorr === (divisor - 1.U),Mux(jtag_txcount === length_indr,0.U,jtag_txcount + 1.U),jtag_txcount)
             state        	:= Mux( ( divisorr === (divisor - 1.U)) && (jtag_txcount === length_indr),sIDLE,s_TXRD)
	     divisorr      	:= Mux(divisorr === (divisor - 1.U),0.U,divisorr + 1.U)
	
	     tck_or		:= Mux(divisorr === 0.U,tclk_r(63),tck_or)
	     tclk_r		:= Mux(divisorr === 0.U,tclk_r << 1,tclk_r)
	     
	     
	     tms_or		:= Mux(divisorr === 0.U,tmsdatar(0),tms_or)
	     tmsdatar		:= Mux(divisorr === 0.U,tmsdatar >> 1,tmsdatar)
	     
	     tdo_or		:= Mux(divisorr === 0.U,tdodatar(0),tdo_or)
	     tdodatar		:= Mux(divisorr === 0.U,tdodatar >> 1,tdodatar)
	     
	      tdififowren    := Mux( ( divisorr === (divisor - 1.U)) && (jtag_txcount === length_indr),true.B,false.B)
	     
	
	}
	
	
	
	
	
	}
	}
	}
// Generate the Verilog code by invoking the Driver
object JTAGBehavMain extends App {
  println("Generating the top hardware")
  chisel3.Driver.execute(Array("--target-dir", "top"), () => new jtag_ssp())
}
