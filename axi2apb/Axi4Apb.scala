
// this is a AXI4APB BRIDGE implemented using state machine (no queue support)
package axi2apb

import chisel3._
import chisel3.util._
import chisel3.util.BitPat


class ArChannel(width : Int) extends Bundle {
  val araddr   = Input(Bits(width.W))
  val arsize   = Input(Bits(3.W))
  val arlen    = Input(Bits(8.W))
  val arburst  = Input(Bits(2.W))
  val arid     = Input(Bits(2.W))
  val arready  = Output(Bool())
  val arvalid  = Input(Bool())
  override def cloneType = { new ArChannel(width).asInstanceOf[this.type] }
}

class RChannel(width : Int) extends Bundle {
  val rdata   = Output(Bits(width.W))
  val rresp   = Output(Bits(2.W))
  val rid     = Output(Bits(2.W))
  val rready  = Input(Bool())
  val rvalid  = Output(Bool())
  val rlast   = Output(Bool())
    override def cloneType = { new RChannel(width).asInstanceOf[this.type] }
}


class Awchannel(width : Int) extends Bundle {
  val awaddr   = Input(Bits(width.W))
  val awsize   = Input(Bits(3.W))
  val awlen    = Input(Bits(8.W))
  val awburst  = Input(Bits(2.W))
  val awid     = Input(Bits(2.W))
  val awready  = Output(Bool())
  val awvalid  = Input(Bool())
    override def cloneType = { new Awchannel(width).asInstanceOf[this.type] }
}

class WChannel(width : Int) extends Bundle {
  val wdata   = Input(Bits(width.W))
  val wstrb   = Input(Bits((width/8).W))
  val wlast   = Input(Bool())
  val wready  = Output(Bool())
  val wvalid  = Input(Bool())
    override def cloneType = { new WChannel(width).asInstanceOf[this.type] }
}

class BChannel extends Bundle {
  val bresp   = Output(Bits(2.W))
  val bid     = Output(Bits(2.W))
  val bready  = Input(Bool())
  val bvalid  = Output(Bool())
//    override def cloneType = { new BChannel().asInstanceOf[this.type] }
}


class axi_m(width : Int) extends Bundle {
val ar = new ArChannel(width)
val aw = new Awchannel(width)
val w  = new WChannel(width)
val b  = new BChannel()
val r  = new RChannel(width)
  override def cloneType = { new axi_m(width).asInstanceOf[this.type] }
}



class ApbChannel(width : Int,numslaves : Int) extends Bundle {
  val psel    = Output(Bits(numslaves.W))
  val paddr   = Output(Bits(width.W))
  val pwrite  = Output(Bool())
  val pstrb   = Output(Bits((width/8).W))
  val pready  = Input(Bool())
  val penable = Output(Bool())
  val pwdata  = Output(Bits(width.W))
  val prdata  = Input(Bits(width.W))
  override def cloneType = { new ApbChannel(width,numslaves).asInstanceOf[this.type] }
  
}


class Axi4Apb() extends Module  {

  val io = IO(new Bundle {
  val m1 = new axi_m(32)
  val p1 = new ApbChannel(32,10)
 
  })

val (s_IDLE :: s_DECODE :: s_DESPATCH ::  s_RESP :: s_RESP1 :: Nil) = Enum(5)
val arstate = RegInit(s_IDLE)


val psel          =   RegInit(0.U(10.W))
val pwrite        =   RegInit(false.B)
val pstrb         =   RegInit(0.U(4.W))
val penable       =   RegInit(false.B)
val pwdata        =   RegInit(0.U(32.W))
val paddr         =   RegInit(0.U(32.W))




val axi_arready      =   RegInit(true.B)
val axi_araddr       =   RegInit(0.U(32.W))
val axi_arsize       =   RegInit(0.U(3.W))
val axi_arburst      =   RegInit(0.U(2.W))
val axi_arlen        =   RegInit(0.U(8.W))
val axi_arid         =   RegInit(0.U(2.W))

val axi_wready       =   RegInit(true.B)
val axi_wdata        =   RegInit(0.U(32.W))
val axi_wvalid       =   RegInit(false.B)
val axi_wlast        =   RegInit(false.B)
val axi_wstrb        =   RegInit(0.U(4.W))

val axi_awready      =   RegInit(true.B)
val axi_awvalid      =   RegInit(false.B)
val axi_awaddr       =   RegInit(0.U(32.W))
val axi_awburst      =   RegInit(0.U(2.W))
val axi_awsize       =   RegInit(0.U(3.W))
val axi_awlen        =   RegInit(0.U(8.W))
val axi_awid         =   RegInit(0.U(2.W))

val axi_bresp        = RegInit(0.U(2.W))
val axi_bid          = RegInit(0.U(2.W))
//val bready  = RegInit(false.B)
val axi_bvalid       = RegInit(false.B)



val axi_rdata   = RegInit(0.U(32.W))
val axi_rresp   = RegInit(0.U(2.W))
val axi_rid     = RegInit(0.U(2.W))
//val ready   = RegInit(false.B)
val axi_rvalid  = RegInit(false.B)
val axi_rlast   = RegInit(false.B)
val legalSlave   = RegInit(false.B)
val rw           = RegInit(false.B)
///////////////////////////////////////////////
io.m1.ar.arready := axi_arready
//////////////////////////////////////////////
/////////////////////////////////////////////			
//\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
///////////////////////////////////////////////
io.m1.aw.awready := axi_awready
//////////////////////////////////////////////
/////////////////////////////////////////////		
////////////////////////////////////////////
io.m1.w.wready   := axi_wready
////////////////////////////////////////////
io.m1.b.bvalid   := axi_bvalid
io.m1.b.bresp    := axi_bresp
io.m1.b.bid      := axi_bid
////////////////////////////////////////////
io.m1.r.rvalid   := axi_rvalid
io.m1.r.rresp    := axi_rresp
io.m1.r.rlast    := true.B
io.m1.r.rid      := axi_rid
io.m1.r.rdata    := axi_rdata
////////////////////////////////////////////
io.p1.psel    := psel
io.p1.pwrite  := pwrite
io.p1.penable := penable
io.p1.pstrb   := pstrb
io.p1.pwdata  := pwdata
io.p1.paddr   := paddr
	
// this is the address decoder /////////////
// simple but powerful :)
def addrlegal(a: UInt) : UInt = {

      val slavenum = Cat((a < "x1901_0000".U && a >= "x1900_0000".U),
     (a < "x1801_0000".U && a >= "x1800_0000".U),
     (a < "x1701_0000".U && a >= "x1700_0000".U),
     (a < "x1601_0000".U && a >= "x1600_0000".U),
     (a < "x1501_0000".U && a >= "x1500_0000".U),
     (a < "x1401_0000".U && a >= "x1400_0000".U),
     (a < "x1301_0000".U && a >= "x1300_0000".U),
     (a < "x1201_0000".U && a >= "x1200_0000".U),
     (a < "x1101_0000".U && a >= "x1100_0000".U),
     (a < "x1001_0000".U && a >= "x1000_0000".U)
      )
      
      return slavenum
      
 } 
	
switch(arstate) {
	is(s_IDLE) {
	
	when(io.m1.ar.arvalid && axi_arready) {
		penable    := false.B
		pwdata     := 0.U
		legalSlave := 	addrlegal(io.m1.ar.araddr).orR.toBool
		rw	   := false.B
		when(addrlegal(io.m1.ar.araddr.asUInt).orR.toBool) {
			psel        := addrlegal(io.m1.ar.araddr.asUInt)
                        paddr      := io.m1.ar.araddr
                        axi_rid    := io.m1.ar.arid
			pwrite      := false.B
			arstate     := s_DECODE
			rw          := false.B
		 	axi_arready := false.B	
			axi_wready  := false.B
			axi_awready := false.B		 	
		} .otherwise {
			psel	     := 0.U
                        paddr        := 0.U
                        axi_rid      := 0.U
		 	arstate      := s_RESP
		 	axi_arready  := false.B		
		 	axi_wready   := false.B
			axi_awready  := false.B	
		}
        } .otherwise {  //no arvalid
		
		when(io.m1.aw.awvalid) {
		legalSlave := 	addrlegal(io.m1.aw.awaddr.asUInt).orR.toBool
		when(addrlegal(io.m1.aw.awaddr.asUInt).orR.toBool) {
			axi_awaddr	:= io.m1.aw.awaddr
			axi_awready	:= false.B
			axi_arready     := false.B
			axi_bid         := io.m1.aw.awid
		} .otherwise {
			axi_awaddr	 := 0.U
			axi_awready     := true.B
			axi_arready     := true.B
			axi_bid         := 0.U
		}
		} 
		
		when(io.m1.w.wvalid && legalSlave.toBool) {
			axi_wready	:= false.B
			axi_arready	:= false.B
			axi_wdata	:= io.m1.w.wdata
			axi_wstrb	:= io.m1.w.wstrb
		} .otherwise {
			axi_wdata	:= 0.U
			axi_wstrb	:= 0.U		       
		}
		
		
		when(axi_awready || axi_wready) {
			arstate := s_IDLE
		} .otherwise {
			arstate  := Mux(legalSlave,s_DECODE,s_RESP)
			psel    :=  addrlegal(axi_awaddr.asUInt)
                        paddr   := axi_awaddr
			rw      := true.B
			pwrite  := true.B
			penable := false.B
			pwdata  := axi_wdata
			pstrb  := axi_wstrb
	      }
	
	} 
}
	
		
	
	is(s_DECODE) {
	arstate     := s_DESPATCH
	axi_arready := false.B
	axi_awready := false.B
	axi_wready  := false.B
	
	pwdata	    := Mux(rw,axi_wdata,0.U)
	pstrb	    := Mux(rw,axi_wstrb,0.U)
	pwrite	    := Mux(rw,true.B,false.B)
	penable     := true.B
			
		
	} //s_DECODE
	is(s_DESPATCH) {
		
	        when(io.p1.pready) {
			pwdata      := 0.U
			pstrb	    := 0.U
			pwrite      := false.B
			penable     := false.B	
			psel        := 0.U
			paddr       := 0.U
			arstate     := s_RESP
	        	axi_arready := false.B
		  	axi_awready := false.B
			axi_wready  := false.B	
			axi_rdata   := Mux(!rw && legalSlave,io.p1.prdata,0.U)	
		
					
	        } .otherwise {
		arstate     := s_DESPATCH
		axi_arready := false.B
		axi_awready := false.B
		axi_wready  := false.B
		axi_bid         := 0.U
		axi_rid         := 0.U
		pwdata	    := Mux(rw,axi_wdata,0.U)
		pstrb	    := Mux(rw,axi_wstrb,0.U)
		pwrite	    := Mux(rw,true.B,false.B)
		penable     := true.B
		    
	       }
	
	
	} //s_DESPATCH
	
	is(s_RESP) {
	
		 	axi_rvalid := legalSlave && !rw
		 	axi_rresp  := Mux(rw,0.U,Mux(legalSlave,0.U,2.U))
		 	axi_bvalid := legalSlave && rw
		 	axi_bresp  := Mux(rw,Mux(legalSlave,0.U,2.U),0.U)
			arstate    := s_RESP1
			axi_arready := false.B
			axi_awready := false.B
			axi_wready  := false.B	
			pwdata      := 0.U
			pstrb	    := 0.U
			pwrite      := false.B
			penable     := false.B	
			psel        := 0.U	
			paddr       := 0.U
	
	
	} //s_RESP
	
	is(s_RESP1) {
			axi_rvalid := Mux(io.m1.r.rready && axi_rvalid,false.B,true.B)
			axi_bvalid := Mux(io.m1.b.bready && axi_bvalid,false.B,true.B)
			arstate    := Mux( (rw && io.m1.b.bready) || (!rw && io.m1.r.rready) , s_IDLE, s_RESP1)
			axi_arready := true.B
			axi_awready := true.B
			axi_wready  := true.B	
			pwdata      := 0.U
			pstrb	    := 0.U
			pwrite      := false.B
			penable     := false.B	
			psel        := 0.U	
			paddr       := 0.U		
	
	
	
	
	}
	
	
	
				

} //arstate





	
	
	
	
	
	
	
}	
	
	
	
	
  


	
// Generate the Verilog code by invoking the Driver
object Axi4ApbMain extends App {
  println("Generating the top hardware")
  chisel3.Driver.execute(Array("--target-dir", "top"), () => new Axi4Apb())
}


