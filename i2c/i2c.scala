package i2c
import chisel3._
import chisel3.experimental._
import chisel3.util._
import chisel3.util.BitPat
import Address_i2c._
class I2CBehav extends Module  {
//instruction ar channel
val io = IO(new Bundle {
val  PCLK              = Input(Clock())  // system control clock 
val  PRESETn           = Input(Bool())  // system control reset active low
val  PADDR             = Input(UInt(8.W))   
val  PPROT             = Input(Bool())
val  PSEL              = Input(Bool())
val  PENABLE           = Input(Bool())
val  PWRITE            = Input(Bool())
val  PWDATA            = Input(UInt(8.W))    
val  PSTRB             = Input(UInt(1.W))
val  PREADY            = Output(Bool())
val  PRDATA            = Output(UInt(8.W))  
val  PSLVERR           = Output(Bool())
val irq                = Output(Bool()) // interrupt request active high.
val sda_t              = Output(Bool())
val sda_o              = Output(Bool())
val sda_i              = Input(Bool())
val scl_t              = Output(Bool())
val scl_o              = Output(Bool())
val scl_i              = Input(Bool())
val doOpcodeio         = Output(UInt(4.W))  
val iiccount           = Output(UInt(16.W))
val txbitc             = Output(UInt(6.W))
val readl              = Output(UInt(5.W))
val txcio              = Output(Bool())
val rxcio              = Output(Bool())
val startsentio        = Output(Bool())
val stopsentio         = Output(Bool())
val rstartsentio       = Output(Bool())
val nackio             = Output(Bool())

})

io.PREADY  := 0.U;
io.PSLVERR := 0.U;

withClockAndReset(io.PCLK, ~io.PRESETn) {
val sda_or = RegInit(true.B)
val sda_tr = RegInit(true.B)
val scl_or = RegInit(true.B)
val scl_tr = RegInit(true.B)

// state machine state declaration /////////////////
val (sIDLE :: sSTART :: sRSTART :: sWDATA :: sRDATA :: sSTOP :: Nil) = Enum(6)
val state  = RegInit(sIDLE)
val stater = RegInit(sIDLE)
val   chpl           =  RegInit(240.U(8.W))
val   chph           =  RegInit(0.U(8.W))
val   chhpl          =  RegInit(120.U(8.W))
val   chhph          =  RegInit(0.U(8.W))
val   stop           = RegInit(false.B)
val   start          = RegInit(false.B)
val   rstart         = RegInit(false.B)
val   readlen        = RegInit(0.U(5.W))
val   readlenr       = RegInit(0.U(5.W))
val   stopsent       = RegInit(false.B)
val   startsent      = RegInit(false.B)
val   rstartsent     = RegInit(false.B)
val   txc            = RegInit(true.B)
val   rxc            = RegInit(false.B)
val   rxintr         = RegInit(false.B)
val   txintr         = RegInit(false.B)
val   nack           = RegInit(false.B)
val   gie            = RegInit(false.B)
val   txie           = RegInit(false.B)
val   rxie           = RegInit(false.B)
//val   txffwdata  = RegInit(0.U(8.W))
//val   txffwren   = RegInit(false.B)
val   txffrden   = RegInit(false.B)
val   txffclrr   = RegInit(false.B)
val   rxffwdata  = RegInit(0.U(8.W))
val   rxffwren   = RegInit(false.B)
val   rxffrden   = RegInit(false.B)
val txffclr = RegInit(false.B)
val apbrdata = RegInit(0.U(8.W))
val txfifo = Module(new QueueModule_i2c(8,16))
val rxfifo = Module(new QueueModule_i2c(8,16))


val txffwren = Mux((io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_i2c.TX_ADDR)),true.B,false.B)
val txffwdata = io.PWDATA


txfifo.io.i.valid :=  txffwren
txfifo.io.i.bits  :=  txffwdata
txfifo.io.o.ready :=  txffrden || txffclr

rxfifo.io.i.valid :=  rxffwren
rxfifo.io.i.bits  :=  rxffwdata
rxfifo.io.o.ready :=  rxffrden

io.PRDATA := apbrdata;
io.readl := readlenr

io.sda_t := sda_tr
io.sda_o := sda_or
io.scl_o := scl_or
io.scl_t := scl_tr



when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_i2c.CR_ADDR)) {
     start   := io.PWDATA(0)
     stop    := Mux(io.PWDATA(0),false.B,true.B)
     readlen := Mux(io.PWDATA(0) || io.PWDATA(7),io.PWDATA(6,2),0.U)
     rstart  := io.PWDATA(7)
     } .otherwise {
     start   := Mux(startsent && state === sIDLE,false.B,start)
     stop    := Mux(stopsent  && state === sIDLE,false.B,stop)
     rstart  := Mux(rstartsent && state === sIDLE,false.B,rstart)
     }
when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_i2c.SR_ADDR)) {
     apbrdata := Cat(rxc,!rxfifo.io.o.valid,!rxfifo.io.i.ready,txc,!txfifo.io.o.valid,!txfifo.io.i.ready,stopsent,startsent)
     }
when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_i2c.SR1_ADDR)) {
     apbrdata := Cat(0.U(5.W),rxintr,txintr,nack)
     }
when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_i2c.IER_ADDR)) {
     gie    := io.PWDATA(0)
     txie   := io.PWDATA(1)
     rxie   := io.PWDATA(2)
     }
when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_i2c.IER_ADDR)) {
     apbrdata := Cat(0.U(5.W),rxie,txie,gie)
     }     
/*     
when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_i2c.TX_ADDR)) {
     txffwdata := io.PWDATA
     txffwren  := true.B
     }  .otherwise {
     txffwdata := 0.U
     txffwren  := false.B
     }
*/

     
     
when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_i2c.TX_ADDR)) {
     apbrdata  := 0.U
     }    
when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_i2c.RX_ADDR)) {
     apbrdata := rxfifo.io.o.bits
     rxffrden  := true.B
     }  .otherwise {
     rxffrden  := false.B
     }   
when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_i2c.CHPL_ADDR)) {
     chpl  := io.PWDATA
     }       
when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_i2c.CHPH_ADDR)) {
     chph  := io.PWDATA
     }          
when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_i2c.CHHPL_ADDR)) {
     chhpl  := io.PWDATA
     }        
when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_i2c.CHHPH_ADDR)) {
     chhph  := io.PWDATA
     }        
when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_i2c.CHPL_ADDR)) {
     apbrdata := chpl  
     }       
when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_i2c.CHPH_ADDR)) {
     apbrdata := chph  
     }          
when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_i2c.CHHPL_ADDR)) {
     apbrdata := chhpl 
     }        
when (io.PSEL && !io.PWRITE && !io.PENABLE && (io.PADDR(7,0) === Address_i2c.CHHPH_ADDR)) {
     apbrdata := chhph  
     }      
when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_i2c.TXFFCLR_ADDR)) {
     txffclr  := true.B
     }   .otherwise {
         
         txffclr := Mux(txffclr && txfifo.io.o.valid,true.B,false.B)
     
     }
      


val doStart  =  start  &&  !startsent
val doStop   =  stop   &&  !stopsent
val doRstart =  rstart &&  !rstartsent

val wr       =  Mux((startsent || rstartsent) && (readlen === 0.U),true.B,false.B)

val doWData   = ( (startsent || rstartsent) && txfifo.io.o.valid  )
val doRData   = ( (startsent || rstartsent) && !txfifo.io.o.valid && !wr && !rxc)


val chp  = Cat(chph,chpl)

val chhp = Cat(chhph,chhpl)
chhp.suggestName("chhp")

val clkp = Cat(0.U(16.W),chp) + Cat(0.U(16.W),chp);
val clkp1p25x = clkp + Cat(0.U(24.W),chhp)
val clkp1p5x = clkp + Cat(0.U(16.W),chp);
val clkp0p75x = Cat(0.U(24.W),chp) + Cat(0.U(24.W),chhp)

val sta_setup  = chp
val sta_hold   = chp

val data_setup = chhp
val data_hold  = chp

val sto_setup  = chp
val sto_hold   = chp

val iiccount = RegInit(1.U(32.W))
val txbitc  = RegInit(0.U(6.W))
io.txbitc := txbitc
io.iiccount := iiccount

val sdtxdata  	= RegInit(0.U(38.W))
val sdtxtris  	= Cat(15.U(5.W),0.U(33.W))
val sdrxtris  	= Cat(0.U(5.W),1.U(1.W),"hFFFFFFFE".U(32.W))
val sdrxdata0 	= Cat(0.U(5.W),1.U(1.W),"hFFFFFFFE".U(32.W))
val sdrxdata1 	= Cat(31.U(5.W),1.U(1.W),"hFFFFFFFE".U(32.W))
val txffr   	= txfifo.io.o.bits
val txAck	= 15.U(4.W)
val txM7	= Cat(txffr(7),txffr(7),txffr(7),txffr(7))
val txM6	= Cat(txffr(6),txffr(6),txffr(6),txffr(6))
val txM5	= Cat(txffr(5),txffr(5),txffr(5),txffr(5))
val txM4	= Cat(txffr(4),txffr(4),txffr(4),txffr(4))
val txM3	= Cat(txffr(3),txffr(3),txffr(3),txffr(3))
val txM2	= Cat(txffr(2),txffr(2),txffr(2),txffr(2))
val txM1	= Cat(txffr(1),txffr(1),txffr(1),txffr(1))
val txM0	= Cat(txffr(0),txffr(0),txffr(0),txffr(0))

val rxm7,rxm6,rxm5,rxm4,rxm3,rxm2,rxm1,rxm0 = RegInit(false.B)
rxffwdata     := Cat(rxm7,rxm6,rxm5,rxm4,rxm3,rxm2,rxm1,rxm0)

txc := Mux(state === sIDLE,true.B,false.B)

//data out sda is arranged according to half period
val txdataw = Cat(0.U(1.W),txAck,txM0,txM1,txM2,txM3,txM4,txM5,txM6,txM7,0.U(1.W))
sdtxdata      := Mux(txffrden,txdataw,sdtxdata)

val txclkl  = 0.U(2.W)
val txclkh  = 3.U(2.W)
val txclk   = Cat(txclkl,txclkh,txclkl,txclkh,txclkl,txclkh,txclkl,txclkh,txclkl,txclkh,txclkl,txclkh,txclkl,txclkh,txclkl,txclkh,txclkl,txclkh,txclkl)

val doOpcode = Cat(doStart,doWData,doRData,doStop)
val doOpcoder = RegInit(0.U(4.W))
doOpcoder := doOpcode;
io.doOpcodeio := doOpcoder;

 io.txcio          := txc 
 io.rxcio          := rxc
 io.startsentio    := startsent
io.stopsentio      := stopsent
 io.rstartsentio   := rstartsent
 io.nackio         := nack


txintr := txfifo.io.i.ready && gie && txie
rxintr := rxfifo.io.i.ready && gie && rxie
val intrw = txintr || rxintr 
io.irq    := intrw

switch(state) {
	is(sIDLE) { 
               when(doRstart) {
		state		:= sRSTART
		            } .otherwise {
		state      := MuxLookup(doOpcode,sIDLE,Seq(  //will handle every condition 
		         //  doStart, doWdata , doRdata ,doStop
		                0.U  -> sIDLE,
		                1.U  -> sSTOP,
		                2.U  -> sRDATA,
		                3.U  -> sRDATA,
		                4.U  -> sWDATA,
		                5.U  -> sWDATA,
		                6.U  -> sWDATA,
		                7.U  -> sWDATA,
		                8.U  -> sSTART,
		                9.U  -> sSTART,
		                10.U -> sSTART,
		                11.U -> sSTART,
		                12.U -> sSTART,
		                13.U -> sSTART,
		                14.U -> sSTART,
		                15.U -> sSTART))             
		               }
		txffrden	:= Mux(doWData && txfifo.io.o.valid && !doStart,true.B,false.B)
		iiccount      	:= 1.U
		readlenr      	:= readlen
		txbitc        	:= 0.U
		rxffwren     	:= false.B
	}
	is(sSTART) {
		stater     	:= sSTART
		iiccount  	:= Mux(iiccount === clkp,1.U,iiccount + 1.U)
		state  	:= Mux(iiccount === clkp,sIDLE,sSTART)
		sda_or  	:= Mux(iiccount === chp,false.B,sda_or)
		sda_tr   	:= false.B
		scl_or    	:= Mux(iiccount === clkp,false.B,scl_or)
		scl_tr    	:= false.B
		startsent  	:= Mux(iiccount === clkp - 2.U,true.B,startsent)
		stopsent   	:= false.B
		rstartsent	:= false.B
		nack       	:= false.B
		txffrden 	:= false.B
		rxffwren     	:= false.B
		txbitc        	:= 0.U
	} 
	is(sRSTART) {
		stater		:= sRSTART
	        iiccount 	:= Mux(iiccount === clkp1p5x,1.U,iiccount + 1.U)
	        state      	:= Mux(iiccount === clkp1p5x,sIDLE,sRSTART)
	        sda_or     	:= Mux( (iiccount > (chp - 1.U)) && (iiccount < (clkp - 1.U)),true.B,false.B)
		sda_tr     	:= false.B
		scl_or     	:= Mux((iiccount > (clkp0p75x - 1.U)) && (iiccount < clkp1p25x),true.B,false.B)
		scl_tr    	:= false.B
		startsent  	:= false.B
		stopsent   	:= false.B
		rstartsent 	:= Mux(iiccount === clkp1p5x,true.B,false.B)
		nack       	:= false.B
		txffrden 	:= false.B
		rxffwren     	:= false.B
		txbitc        	:= 0.U
	}
	is(sSTOP) {
		stater		:= sSTOP
	        iiccount 	:= Mux(iiccount === clkp1p5x,1.U,iiccount + 1.U)
	        state      	:= Mux((iiccount === clkp1p5x) && (!txfifo.io.o.valid),sIDLE,sSTOP)
	        scl_or     	:= Mux((iiccount > chp) ,true.B,false.B)
		scl_tr     	:= Mux(iiccount === clkp1p5x,true.B,false.B)
		sda_or     	:= Mux(iiccount > clkp,true.B,false.B)
		sda_tr    	:= Mux(iiccount === clkp1p5x,true.B,false.B)
		startsent  	:= false.B
		stopsent   	:=  Mux((iiccount === clkp1p5x - 2.U),true.B,stopsent)
		rstartsent 	:= false.B
		//nack       	:= false.B
		txffrden 	:= false.B
		rxffwren     	:= false.B
		txbitc        	:= 0.U
	        txffrden 	:= Mux(txfifo.io.o.valid,true.B,false.B)
	       
	}
	is(sWDATA) {
		stater     	:= sIDLE
		iiccount   	:= Mux(iiccount  === chhp,1.U,iiccount + 1.U)
		txbitc		:= Mux(iiccount  === chhp,Mux(txbitc === 37.U,2.U,txbitc + 1.U),txbitc)
		state        	:= Mux((iiccount  === chhp) && (txbitc === 36.U),Mux(nack,sSTOP,Mux(!txfifo.io.o.valid,sIDLE,sWDATA)),sWDATA)
		sda_or        	:= sdtxdata(txbitc)
		sda_tr     	:= sdtxtris(txbitc)
		scl_or		:= txclk(txbitc)
		scl_tr    	:= false.B
		txffrden 	:= Mux((iiccount === chhp) && (txbitc === 36.U) && (txfifo.io.o.valid),true.B,false.B) 
	        nack          	:= Mux((iiccount === chhp) && (txbitc === 35.U) && io.sda_i,true.B,nack)
	        rxc            := false.B
	        rxffwren       := false.B
	      
	}
	is(sRDATA) {
		stater     	:= sRDATA
	        iiccount   	:= Mux(iiccount  === chhp,1.U,iiccount + 1.U)
	        txbitc		:= Mux(iiccount  === chhp,Mux(txbitc === 37.U,1.U,txbitc + 1.U),txbitc) 
	        state          := Mux((iiccount === chhp) && (txbitc === 37.U) && (readlenr === 0.U),sSTOP,sRDATA)  
	        readlenr      	:= Mux((iiccount === chhp) && (txbitc === 36.U),Mux((readlenr === 0.U),readlenr,readlenr - 1.U),readlenr)
		nack       	:= false.B
		txffrden 	:= false.B
		sda_or        	:= Mux((readlenr === 1.U),sdrxdata1(txbitc),sdrxdata0(txbitc))
		sda_tr     	:= sdrxtris(txbitc)
		scl_or		:= txclk(txbitc)
		scl_tr    	:= false.B
		rxc            := Mux((iiccount === chhp) && (txbitc === 37.U) && (readlenr === 0.U),true.B,false.B)  
		rxffwren       := Mux((iiccount === chhp) && (txbitc === 37.U) ,true.B,false.B)
		rxm0           := Mux(txbitc === 31.U,io.sda_i,rxm0)
		rxm1           := Mux(txbitc === 27.U,io.sda_i,rxm1)
		rxm2           := Mux(txbitc === 23.U,io.sda_i,rxm2)
		rxm3           := Mux(txbitc === 19.U,io.sda_i,rxm3)
		rxm4           := Mux(txbitc === 15.U,io.sda_i,rxm4)
		rxm5           := Mux(txbitc === 11.U,io.sda_i,rxm5)
		rxm6           := Mux(txbitc === 7.U,io.sda_i,rxm6)
		rxm7           := Mux(txbitc === 3.U,io.sda_i,rxm7)
	}
	}
	}
	}
// Generate the Verilog code by invoking the Driver
object I2CBehavMain extends App {
  println("Generating the top hardware")
  chisel3.Driver.execute(Array("--target-dir", "top"), () => new I2CBehav())
}
