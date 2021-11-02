

package riscv

import chisel3._
import chisel3.experimental._
import chisel3.util._
import chisel3.util.BitPat

import Address_apbtimer._




class apbtimer extends Module  {
//instruction ar channel
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
val  PRDATA            = Output(UInt(32.W))  
val  PSLVERR           = Output(Bool())
 
val interrupt                = Output(Bool()) // interrupt request active high.


 // timer ports
val generate           = Output(UInt(2.W)) 
val capture            = Input(UInt(2.W))     
val pwm                = Output(Bool())







})
/*

def renameSignals() {
    // write address channel
    io.bits.PCLK.setName("PCLK")
    io.PRESETn.setName("PRESETn")
    io.PADDR.setName("PADDR")
    io.PPROT.setName("PPROT")
    io.PSEL.setName("PSEL")
    io.PENABLE.setName("PENABLE")
    io.PWRITE.setName("PWRITE")
    io.PWDATA.setName("PWDATA")
    io.PSTRB.setName("PSTRB")
    io.PREADY.setName("PREADY")
    io.PRDATA.setName("PRDATA")
    io.PSLVERR.setName("PSLVERR")
    io.interrupt.setName("PCLK")
    io.generate.setName("PCLK")
    io.capture.setName("capture")
    io.pwm.setName("pwm")
            
}

io.renameSignals()

*/

io.PREADY  := 0.U;
io.PSLVERR := 0.U;





io.pwm :=  0.U;


// state machine state declaration /////////////////

//all clock crossing wires
//val audio_tx_complete_w_cdc            = Wire(Bool())
//val audio_sample_bit_w_aud             = Wire(UInt(6.W))



val (s_IDLE :: s_RUN :: Nil) = Enum(2)


//  pclk domain
withClockAndReset(io.PCLK, ~io.PRESETn) {
//
//


val tmr0state = RegInit(s_IDLE)
val tmr1state = RegInit(s_IDLE)
val casctmrstate = RegInit(s_IDLE)
val irqreg0 = RegInit(false.B)
val irqreg1 = RegInit(false.B)


val RDATA  = RegInit(0.U(32.W))
val CAPE0  = RegInit(false.B)
val CASC  = RegInit(false.B)
val ENALL = RegInit(false.B)
val PWMA0 = RegInit(false.B)
val T0INT = RegInit(false.B)
val ENT0  = RegInit(false.B)
val ENIT0 = RegInit(false.B)
val LOAD0 = RegInit(false.B)
val ARHT0 = RegInit(false.B)
val CAPT0 = RegInit(false.B)
val GENT0 = RegInit(false.B)
val UDT0  = RegInit(false.B)
val MDT0  = RegInit(false.B)


//val CASC  = RegInit(false.B)
//val ENALL = RegInit(false.B)
val CAPE1  = RegInit(false.B)
val PWMA1 = RegInit(false.B)
val T1INT = RegInit(false.B)
val ENT1  = RegInit(false.B)
val ENIT1 = RegInit(false.B)
val LOAD1 = RegInit(false.B)
val ARHT1 = RegInit(false.B)
val CAPT1 = RegInit(false.B)
val GENT1 = RegInit(false.B)
val UDT1  = RegInit(false.B)
val MDT1  = RegInit(false.B)


val TMR0  = RegInit(0.U(32.W))
val TMR1  = RegInit(0.U(32.W))

val TCR0  = RegInit(0.U(32.W))
val TCR1  = RegInit(0.U(32.W))


val LRTMR0  = RegInit(0.U(32.W))
val LRTMR1  = RegInit(0.U(32.W))

io.PRDATA := RDATA


//CONTROL STATUS TIMER MODULE 0 WRITE
when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_apbtimer.TCSR0)) {
     CAPE0  := io.PWDATA(12)
     CASC   := io.PWDATA(11)
     ENALL  := io.PWDATA(10)
     PWMA0  := io.PWDATA(9)
     T0INT  := io.PWDATA(8)
     ENT0   := io.PWDATA(7)
     ENIT0  := io.PWDATA(6)
     LOAD0  := io.PWDATA(5)
     ARHT0  := io.PWDATA(4)
     CAPT0  := io.PWDATA(3)
     GENT0  := io.PWDATA(2)
     UDT0   := io.PWDATA(1)
     MDT0   := io.PWDATA(0)    
     
} .otherwise {
     T0INT  := false.B
}

//CONTROL STATUS TIMER MODULE 0 READ
when (io.PSEL && !io.PWRITE && (io.PADDR(7,0) === Address_apbtimer.TCSR0)) {
     RDATA := Cat(0.U(20.W),CASC,ENALL,PWMA0,irqreg0,ENT0,ENIT0,LOAD0,ARHT0,CAPT0,GENT0,UDT0,MDT0)
}


//CONTROL STATUS TIMER MODULE 1 WRITE
when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_apbtimer.TCSR1)) {
     CAPE1  := io.PWDATA(12)
     CASC   := io.PWDATA(11)
     ENALL  := io.PWDATA(10)
     PWMA1  := io.PWDATA(9)
     T1INT  := io.PWDATA(8)
     ENT1   := io.PWDATA(7)
     ENIT1  := io.PWDATA(6)
     LOAD1  := io.PWDATA(5)
     ARHT1  := io.PWDATA(4)
     CAPT1  := io.PWDATA(3)
     GENT1  := io.PWDATA(2)
     UDT1   := io.PWDATA(1)
     MDT1   := io.PWDATA(0)          
     
} .otherwise {

     T1INT  := false.B
}


//CONTROL STATUS TIMER MODULE 0 READ
when (io.PSEL && !io.PWRITE  && (io.PADDR(7,0) === Address_apbtimer.TCSR1)) {
	RDATA := Cat(0.U(20.W),CASC,ENALL,PWMA1,irqreg1,ENT1,ENIT1,LOAD1,ARHT1,CAPT1,GENT1,UDT1,MDT1)
}

//LOAD REGISTER TIMER MODULE 0 WRITE
when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_apbtimer.TLR0)) {
	LRTMR0 := io.PWDATA
}

//LOAD REGISTER TIMER MODULE 0 READ
when (io.PSEL && !io.PWRITE && (io.PADDR(7,0) === Address_apbtimer.TLR0)) {
	RDATA := LRTMR0
}

//LOAD REGISTER TIMER MODULE 0 WRITE
when (io.PSEL && io.PWRITE && io.PENABLE && (io.PADDR(7,0) === Address_apbtimer.TLR1)) {
	LRTMR1 := io.PWDATA
}

//LOAD REGISTER TIMER MODULE 0 READ
when (io.PSEL && !io.PWRITE  && (io.PADDR(7,0) === Address_apbtimer.TLR1)) {
	RDATA := LRTMR1
}

//READING COUNTER REGISTERS READ
when (io.PSEL && !io.PWRITE  && (io.PADDR(7,0) === Address_apbtimer.TCR0)) {
	RDATA := TCR0
}
when (io.PSEL && !io.PWRITE  && (io.PADDR(7,0) === Address_apbtimer.TCR1)) {
	RDATA := TCR1
}


val starttmr0 = (ENALL || ENT0)
val starttmr1 = (ENALL || ENT1)
val startcasc = starttmr0 

val generate0 = RegInit(false.B)
val generate1 = RegInit(false.B)

val capture0_c = RegInit(false.B)
val capture0_p = RegInit(false.B)

val capture1_c = RegInit(false.B)
val capture1_p = RegInit(false.B)

val rstdone0 = RegInit(false.B)
val rstdone1 = RegInit(false.B)
///////////////////////////////////////////
io.generate := Cat(generate1 && GENT1,generate0 && GENT0).asUInt
///////////////////////////////////////////
///////////////////////////////////////////////// CAPTURE LOGIC ///////////////////////////////////////////////////
capture0_c := io.capture(0)
capture0_p := capture0_c

capture1_c := io.capture(1)
capture1_p := capture1_c

val gotc0low    = !capture0_c && capture0_p //theses are all wires
val gotc0high   = capture0_c  && !capture0_p
val gotc1low    = !capture1_c && capture1_p
val gotc1high   = capture1_c  && !capture1_p
val gotcaptur0  = gotc0low || gotc0high 
val gotcaptur1  = gotc1low || gotc1high 
val capturevnt0 = ( ((CAPE0 && gotc0high) || (!CAPE0 && gotc0low)) ) && MDT0
val capturevnt1 = ( ((CAPE1 && gotc1high) || (!CAPE1 && gotc1low)) ) && MDT1

when(capturevnt0 && !rstdone0) {
	rstdone0 := true.B
}
when(capturevnt1 && !rstdone1) {
	rstdone1 := true.B
}

////////////////////// INTERRUPT  LOGIC //////////////////////////////////////////////////////////////////////////////////////
val cascoveflw = ( CASC  && ((UDT0 && (TMR0 === 0.U)  && (TMR1 === 0.U)) || ((!UDT0 && TMR1.andR && TMR0.andR))) )
val tmr0ovrflw = ( (UDT0  && (TMR0 === 0.U)) || (!UDT0 && TMR0.andR))	
val tmr1ovrflw = ( (UDT1  && (TMR1 === 0.U)) || (!UDT1 && TMR1.andR))	       
//val oveflw = cascoveflw || tmr0ovrflw || tmr1ovrflw

val intr0evnt = tmr0ovrflw || capturevnt0  || cascoveflw
val intr1evnt = tmr1ovrflw || capturevnt1 


when(T0INT) {
	irqreg0 := false.B	
} .otherwise {
	when(intr0evnt) {
		irqreg0 := true.B
	}
}
when(T1INT) {
	irqreg1 := false.B	
} .otherwise {
	when(intr1evnt) {
		irqreg1 := true.B
	}
}
io.interrupt := ( (irqreg0 && ENIT0) || (irqreg1 && ENIT1) )
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

when(CASC) { //a single 64-bit timer
        generate1 := false.B
	switch(casctmrstate) {

	is(s_IDLE) {
		TMR0      := Mux(LOAD0,LRTMR0,TMR0)
		TMR1      := Mux(LOAD1,LRTMR1,TMR1)
		casctmrstate := Mux(startcasc,s_RUN,s_IDLE)
		generate0 := false.B

	} //IDLE

	is(s_RUN) {
	        TMR0      := Mux(startcasc,Mux(UDT0,TMR0 - 1.U,TMR0 + 1.U),TMR0)
	        TMR1      := Mux(startcasc,Mux(UDT0,Mux(TMR0 === 0.U,TMR1 - 1.U,TMR1),Mux(TMR0.andR,TMR1 + 1.U,TMR1)),TMR1)
	        casctmrstate := Mux(startcasc,s_RUN,s_IDLE)
	        generate0  := Mux( (UDT0 && (TMR0 === 0.U) && (TMR1 === 0.U)) || ((!UDT0 && TMR1.andR && TMR0.andR)) ,true.B,false.B)

	} //RUN
	} //tmr0state

        when(capturevnt0) {
		when(rstdone0) {
			TCR0 := Mux(ARHT0,TMR0,TCR0);
			TCR1 := Mux(ARHT0,TMR1,TCR1); // FOR 1 ALSO CR0 IS CHECKED
		} .otherwise {
			TCR0 := TMR0
			TCR1 := TMR1
		} //rstdone0
	} .otherwise {
		TCR0 := 0.U
		TCR1 := 0.U
	
	}





} .otherwise {  //individual timers counters

	switch(tmr0state) {

	is(s_IDLE) {
		TMR0      := Mux(LOAD0,LRTMR0,TMR0)
		tmr0state := Mux(starttmr0,s_RUN,s_IDLE)
		generate0 := false.B

	} //IDLE

	is(s_RUN) {
	        TMR0      := Mux(starttmr0,
 	       		 Mux(UDT0,Mux(TMR0 === 0.U,Mux(ARHT0,LRTMR0,TMR0),TMR0 - 1.U),Mux(TMR0.andR,Mux(ARHT0,LRTMR0,TMR0),TMR0 + 1.U))
	        		 ,TMR0)
	        tmr0state := Mux(starttmr0,s_RUN,s_IDLE)
	        generate0 := Mux( UDT0 && (TMR0 === 0.U) || (!UDT0 && TMR0.andR) ,true.B,false.B)

	} //RUN
	} //tmr0state
	switch(tmr1state) {

	is(s_IDLE) {
		TMR1      := Mux(LOAD1,LRTMR1,TMR1)
		tmr1state := Mux(starttmr1,s_RUN,s_IDLE)
		generate1 := false.B

	} //IDLE

	is(s_RUN) {
	        TMR1      := Mux(starttmr1,
 	       		 Mux(UDT1,Mux(TMR1 === 0.U,Mux(ARHT1,LRTMR1,TMR1),TMR1 - 1.U),Mux(TMR1.andR,Mux(ARHT1,LRTMR1,TMR1),TMR1 + 1.U))
	        		 ,TMR1)
	        tmr1state := Mux(starttmr1,s_RUN,s_IDLE)
	        generate1 := Mux( UDT1 && (TMR1 === 0.U) || (!UDT1 && TMR1.andR) ,true.B,false.B)

	} //RUN
	} //tmr0state
	when(capturevnt0) {
		when(rstdone0) {
			TCR0 := Mux(ARHT0,TMR0,TCR0);
		} .otherwise {
			TCR0 := TMR0
		} //rstdone0
	} .otherwise {
		TCR0 := 0.U
		
	
	}
	when(capturevnt1) {
		when(rstdone1) {
			TCR1 := Mux(ARHT1,TMR1,TCR1);
		} .otherwise {
			TCR1 := TMR1
		} //rstdone0
	}.otherwise {
		TCR1 := 0.U
		
	
	}	
} 






} //pclk domain         












    
    
    

}
	
// Generate the Verilog code by invoking the Driver
object apbtimerMain extends App {
  println("Generating the top hardware")
  chisel3.Driver.execute(Array("--target-dir", "top"), () => new apbtimer())
}




