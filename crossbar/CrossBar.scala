
// this is a single master 3 slave crossbar implemented using state machine (no queue support)
package riscv

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


class CrossBar extends Module  {

  val io = IO(new Bundle {

    val m1 = new axi_m(32)
    val s1 =  Flipped(new axi_m(32))
    val s2 =  Flipped(new axi_m(32))
    val s3 =  Flipped(new axi_m(32))
     
  })

val (s_IDLE :: s_DECODE :: s_DESPATCH ::   Nil) = Enum(3)
val arstate = RegInit(s_IDLE)
val awstate = RegInit(s_IDLE)
val bstate  = RegInit(s_IDLE)
val rwstate = RegInit(s_IDLE)
val rstate  = RegInit(s_IDLE)

val s1_axi_arvalid   =   RegInit(false.B)
val s2_axi_arvalid   =   RegInit(false.B)
val s3_axi_arvalid   =   RegInit(false.B)
val axi_arready      =   RegInit(true.B)
val axi_araddr       =   RegInit(0.U(32.W))
val axi_arsize       =   RegInit(0.U(3.W))
val axi_arburst      =   RegInit(0.U(2.W))
val axi_arlen        =   RegInit(0.U(8.W))
val axi_arid         =   RegInit(0.U(2.W))


val s1_axi_wvalid    =   RegInit(false.B)
val s2_axi_wvalid    =   RegInit(false.B)
val s3_axi_wvalid    =   RegInit(false.B)
val axi_wready       =   RegInit(true.B)
val axi_wdata        =   RegInit(0.U(32.W))
val axi_wvalid       =   RegInit(false.B)
val axi_wlast        =   RegInit(false.B)
val axi_wstrb        =   RegInit(0.U(4.W))


val s1_axi_awvalid   =   RegInit(false.B)
val s2_axi_awvalid   =   RegInit(false.B)
val s3_axi_awvalid   =   RegInit(false.B)
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


///////////////////////////////////////////////
io.m1.ar.arready := axi_arready
//////////////////////////////////////////////
io.s1.ar.araddr  := axi_araddr
io.s1.ar.arsize  := axi_arsize
io.s1.ar.arlen   := axi_arlen
io.s1.ar.arburst := axi_arburst 
io.s1.ar.arid    := axi_arid
io.s1.ar.arvalid := s1_axi_arvalid                     
//////////////////////////////////////////////		
io.s2.ar.araddr  := axi_araddr
io.s2.ar.arsize  := axi_arsize
io.s2.ar.arlen   := axi_arlen
io.s2.ar.arburst := axi_arburst 
io.s2.ar.arid    := axi_arid
io.s2.ar.arvalid := s2_axi_arvalid   
/////////////////////////////////////////////
io.s3.ar.araddr  := axi_araddr
io.s3.ar.arsize  := axi_arsize
io.s3.ar.arlen   := axi_arlen
io.s3.ar.arburst := axi_arburst 
io.s3.ar.arid    := axi_arid
io.s3.ar.arvalid := s3_axi_arvalid   			
/////////////////////////////////////////////			
//\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
///////////////////////////////////////////////
io.m1.aw.awready := axi_awready
//////////////////////////////////////////////
io.s1.aw.awaddr  := axi_awaddr
io.s1.aw.awsize  := axi_awsize
io.s1.aw.awlen   := axi_awlen
io.s1.aw.awburst := axi_awburst 
io.s1.aw.awid    := axi_awid
io.s1.aw.awvalid := s1_axi_awvalid                     
//////////////////////////////////////////////		
io.s2.aw.awaddr  := axi_awaddr
io.s2.aw.awsize  := axi_awsize
io.s2.aw.awlen   := axi_awlen
io.s2.aw.awburst := axi_awburst 
io.s2.aw.awid    := axi_awid
io.s2.aw.awvalid := s2_axi_awvalid   
/////////////////////////////////////////////
io.s3.aw.awaddr  := axi_awaddr
io.s3.aw.awsize  := axi_awsize
io.s3.aw.awlen   := axi_awlen
io.s3.aw.awburst := axi_awburst 
io.s3.aw.awid    := axi_awid
io.s3.aw.awvalid := s3_axi_awvalid   			
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
io.s1.w.wdata    := axi_wdata
io.s1.w.wstrb    := axi_wstrb
io.s1.w.wlast    := true.B
io.s1.w.wvalid   := s1_axi_wvalid
/////////////////////////////////////////////			
io.s2.w.wdata    := axi_wdata
io.s2.w.wstrb    := axi_wstrb
io.s2.w.wlast    := true.B
io.s2.w.wvalid   := s2_axi_wvalid
/////////////////////////////////////////////
io.s3.w.wdata    := axi_wdata
io.s3.w.wstrb    := axi_wstrb
io.s3.w.wlast    := true.B
io.s3.w.wvalid   := s3_axi_wvalid
/////////////////////////////////////////////		
val s1_axi_bready  = RegInit(true.B)
val s2_axi_bready  = RegInit(true.B)
val s3_axi_bready  = RegInit(true.B)
/////////////////////////////////////////////
io.s1.b.bready   := s1_axi_bready
io.s2.b.bready   := s2_axi_bready
io.s3.b.bready   := s3_axi_bready
////////////////////////////////////////////
val s1_axi_rready  = RegInit(false.B)
val s2_axi_rready  = RegInit(false.B)
val s3_axi_rready  = RegInit(false.B)
////////////////////////////////////////////
io.s1.r.rready   := s1_axi_rready
io.s2.r.rready   := s2_axi_rready
io.s3.r.rready   := s3_axi_rready
////////////////////////////////////////////

	

switch(arstate) { 
	is(s_IDLE) {
	
		
		when(io.m1.ar.arvalid) {
	        	arstate := s_DECODE
	        	axi_arready := false.B
	        	axi_araddr  := io.m1.ar.araddr
	        	axi_arsize  := io.m1.ar.arsize
	        	axi_arlen   := io.m1.ar.arlen
	        	axi_arburst := io.m1.ar.arburst
	        	axi_arid    := io.m1.ar.arid
	        	
               } .otherwise {  //no arvalid
               	arstate := s_IDLE
               	axi_arready := true.B
               	axi_araddr  := 0.U
	        	axi_arsize  := 0.U
	        	axi_arlen   := 0.U
	        	axi_arburst := 0.U
	        	axi_arid    := 0.U
               	
               }
	} //s_IDLE	
	
	is(s_DECODE) {
		arstate := s_DESPATCH
		axi_arready := false.B
		when(axi_araddr < "x0ffe".U(32.W) ) {
	        	s1_axi_arvalid := true.B
	        	s2_axi_arvalid := false.B
	        	s3_axi_arvalid := false.B
               } .elsewhen(axi_araddr > "x0ffe".U(32.W) && axi_araddr < "x2000".U(32.W) ) {
	       	s1_axi_arvalid := false.B
	       	s2_axi_arvalid := true.B
	       	s3_axi_arvalid := false.B
	       } .otherwise {
	       	s1_axi_arvalid := false.B
	       	s2_axi_arvalid := false.B
	       	s3_axi_arvalid := true.B
	       }
	
	} //s_DECODE
	
	is(s_DESPATCH) {
		
		when( (s1_axi_arvalid && io.s1.ar.arready) || (s2_axi_arvalid && io.s2.ar.arready) || (s3_axi_arvalid && io.s3.ar.arready) ) {
			s1_axi_arvalid := false.B
	       	s2_axi_arvalid := false.B
	       	s3_axi_arvalid := false.B
	       	axi_arready    := true.B
	       	arstate        := s_IDLE
		} .otherwise {
			arstate := s_DESPATCH
			axi_arready := false.B
		}
	
	
	}

} //ar switch statement

switch(awstate) {
	is(s_IDLE) {
		when(io.m1.aw.awvalid) {
			//awstate     := s_DECODE
			axi_awready := false.B
	        	axi_awaddr  := io.m1.aw.awaddr
	        	axi_awsize  := io.m1.aw.awsize
	        	axi_awlen   := io.m1.aw.awlen
	        	axi_awburst := io.m1.aw.awburst
	        	axi_awid    := io.m1.aw.awid
		 } 
	        
		when(io.m1.w.wvalid) {
			//awstate     := s_DECODE
			axi_wready  := false.B
	        	axi_wdata   := io.m1.w.wdata
	        	axi_wstrb   := io.m1.w.wstrb
	        }    
	        when(axi_wready || axi_awready) {    //means data or address is waiting
	        	awstate     := s_IDLE
	        } .otherwise {
	        	awstate     := s_DECODE
	        }     
	        s1_axi_awvalid := false.B
	        s2_axi_awvalid := false.B
	        s3_axi_awvalid := false.B
	        s1_axi_wvalid  := false.B
	        s2_axi_wvalid  := false.B
	        s3_axi_wvalid  := false.B	        
	        
	        
	} //is_IDLE
	
	is(s_DECODE) {
		awstate     := s_DESPATCH
		axi_wready  := false.B
		axi_awready := false.B
		when(axi_awaddr < "x0ffe".U(32.W) ) {
	        	s1_axi_awvalid := true.B
	        	s2_axi_awvalid := false.B
	        	s3_axi_awvalid := false.B
	        	s1_axi_wvalid  := true.B
	        	s2_axi_wvalid  := false.B
	        	s3_axi_wvalid  := false.B	        	
               } .elsewhen(axi_awaddr > "x0ffe".U(32.W) && axi_araddr < "x2000".U(32.W) ) {
	       	s1_axi_awvalid := false.B
	       	s2_axi_awvalid := true.B
	       	s3_axi_awvalid := false.B
	        	s1_axi_wvalid  := false.B
	        	s2_axi_wvalid  := true.B
	        	s3_axi_wvalid  := false.B	       	
	       } .otherwise {
	       	s1_axi_awvalid := false.B
	       	s2_axi_awvalid := false.B
	       	s3_axi_awvalid := true.B
	        	s1_axi_wvalid  := false.B
	        	s2_axi_wvalid  := false.B
	        	s3_axi_wvalid  := true.B	       	
	       }
	
	} //s_DECODE
	is(s_DESPATCH) {
		
		when(s1_axi_awvalid && io.s1.aw.awready) {
		s1_axi_awvalid := false.B
		}
		when(s2_axi_awvalid && io.s2.aw.awready) {
		s2_axi_awvalid := false.B
		}
		when(s3_axi_awvalid && io.s3.aw.awready) {
		s3_axi_awvalid := false.B
		}
		when(s1_axi_wvalid && io.s1.w.wready)   {
		s1_axi_wvalid := false.B
		}
		when(s2_axi_wvalid && io.s2.w.wready)   {
		s2_axi_wvalid := false.B
		}
		when(s3_axi_wvalid && io.s3.w.wready)   {
		s3_axi_wvalid := false.B
		}		
		when(s1_axi_awvalid || s2_axi_awvalid || s3_axi_awvalid || s1_axi_wvalid || s2_axi_wvalid || s3_axi_wvalid) {
		awstate := s_DESPATCH
		axi_wready  := false.B
		axi_awready := false.B
		} .otherwise {
		awstate := s_IDLE
	        s1_axi_awvalid := false.B
	        s2_axi_awvalid := false.B
	        s3_axi_awvalid := false.B
	        s1_axi_wvalid  := false.B
	        s2_axi_wvalid  := false.B
	        s3_axi_wvalid  := false.B	
	        axi_wready     := true.B
		axi_awready    := true.B	
		}
	       
	}


} //awstate switch
    
switch(bstate) {
	is(s_IDLE) {
	        
		when(io.s1.b.bvalid || io.s2.b.bvalid || io.s3.b.bvalid) {
			axi_bvalid := true.B
			bstate     := s_DECODE
			s1_axi_bready := false.B
			s2_axi_bready := false.B
			s3_axi_bready := false.B
			
		}
		when(io.s1.b.bvalid) {
			axi_bresp := io.s1.b.bresp
			axi_bid   := io.s1.b.bid

		} .elsewhen(io.s2.b.bvalid) {
			axi_bresp := io.s2.b.bresp
			axi_bid   := io.s2.b.bid
			
		} .otherwise {
			axi_bresp := io.s3.b.bresp
			axi_bid   := io.s3.b.bid

		}
		
	
	} //s_IDLE
	is(s_DECODE) {
		when(io.m1.b.bready) {
			axi_bvalid := false.B
			bstate     := s_IDLE
			axi_bresp  := 0.U
			axi_bid    := 0.U
			
		} .otherwise {
			axi_bvalid := true.B
			bstate     := s_DECODE
		}
	        s1_axi_bready := false.B
	        s2_axi_bready := false.B
	        s3_axi_bready := false.B
		
	} //s_DECODE
	
	is(s_DESPATCH) { // not used state
			bstate     := s_IDLE
			axi_bvalid := false.B
			axi_bresp  := 0.U
			axi_bid    := 0.U
			s1_axi_bready := true.B
			s2_axi_bready := true.B
			s3_axi_bready := true.B			
	
	}


} //bstate

switch(rstate) {
	is(s_IDLE) {
	        
		when(io.s1.r.rvalid || io.s2.r.rvalid || io.s3.r.rvalid) {
			axi_rvalid := true.B
			rstate     := s_DECODE
		}
		when(io.s1.r.rvalid) {
			axi_rresp := io.s1.r.rresp
			axi_rid   := io.s1.r.rid
			axi_rlast := io.s1.r.rlast
			axi_rdata := io.s1.r.rdata
			s1_axi_rready := true.B
			s2_axi_rready := false.B
			s3_axi_rready := false.B

		} .elsewhen(io.s2.r.rvalid) {
			axi_rresp := io.s2.r.rresp
			axi_rid   := io.s2.r.rid
			axi_rlast := io.s2.r.rlast
			axi_rdata := io.s2.r.rdata
			s1_axi_rready := false.B
			s2_axi_rready := true.B
			s3_axi_rready := false.B			

		} .otherwise {
			axi_rresp := io.s3.r.rresp
			axi_rid   := io.s3.r.rid
			axi_rlast := io.s3.r.rlast	
			axi_rdata := io.s3.r.rdata
			s1_axi_rready := false.B
			s2_axi_rready := false.B
			s3_axi_rready := true.B			
		
		}
		
	
	} //s_IDLE
	is(s_DECODE) {
		when(io.m1.r.rready) {
			axi_rvalid := false.B
			rstate     := s_IDLE
			axi_rresp  := 0.U
			axi_rid    := 0.U
			axi_rlast  := false.B
			axi_rdata  := 0.U
			
		} .otherwise {
			axi_rvalid := true.B
			rstate     := s_DECODE
		}
	        s1_axi_rready := false.B
		s2_axi_rready := false.B
		s3_axi_rready := false.B	
		
		
	} //s_DECODE
	
	is(s_DESPATCH) {  // not used state
			rstate     := s_IDLE
			axi_rvalid := false.B
			axi_rresp  := 0.U
			axi_rid    := 0.U
			axi_rlast  := false.B
	}


} //rstate
  
  
}

	
// Generate the Verilog code by invoking the Driver
object CrossBarMain extends App {
  println("Generating the top hardware")
  chisel3.Driver.execute(Array("--target-dir", "top"), () => new CrossBar())
}


