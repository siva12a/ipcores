
// this is a  AXI2BRAM CONTROLLER 
//UNSUPPORTED FEATURES INCLUDE BURST AND WRAP
//ILLEGAL LOCATION SUPPORTED
package axibram

import chisel3._
import chisel3.util._
import chisel3.util.BitPat
import chisel3.experimental._


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

class BramChannel(width : Int) extends Bundle {
  val bram_wdata   = Output(Bits(width.W))
  val bram_addr    = Output(Bits(width.W))
  val bram_wea     = Output(Bits((width/8).W))
  val bram_ena     = Output(Bool())
  val bram_rdata   = Input(Bits(width.W))
  val bram_clk     = Output(Clock())
  val bram_rst     = Output(Bool())
    override def cloneType = { new BramChannel(width).asInstanceOf[this.type] }
}



class axi_m(width : Int) extends Bundle {
val ar = new ArChannel(width)
val aw = new Awchannel(width)
val w  = new WChannel(width)
val b  = new BChannel()
val r  = new RChannel(width)
  override def cloneType = { new axi_m(width).asInstanceOf[this.type] }
}


class AxiBram extends Module  {

  val io = IO(new Bundle {
    val axi_clk = Input(Clock())
    val axi_rst = Input(Bool())
    val m1 = new axi_m(32)
    val b1 = new BramChannel(32)
     
  })



 withClockAndReset(io.axi_clk, io.axi_rst) {
val (s_IDLE :: s_DECODE  ::  s_RESP :: Nil) = Enum(3)
val arstate = RegInit(s_IDLE)



val bram_wdata       =   RegInit(0.U(32.W))
val bram_addr        =   RegInit(0.U(32.W))
val bram_wea         =   RegInit(0.U(4.W))
val bram_ena         =   RegInit(false.B)
val bram_rdata       =   RegInit(0.U(32.W))

val legalSlave   = RegInit(false.B)
val rw           = RegInit(false.B)






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
io.m1.r.rdata    := bram_rdata
////////////////////////////////////////////
io.b1.bram_addr  := bram_addr
io.b1.bram_wdata := bram_wdata
io.b1.bram_wea   := bram_wea
io.b1.bram_ena   := bram_ena
bram_rdata       := io.b1.bram_rdata	
io.b1.bram_clk   := io.axi_clk
io.b1.bram_rst   := io.axi_rst




def addrlegal(a: UInt) : Bool = {

      val slavenum = (a <= "x10000".U && a >= "x00000".U)
    
      
      return slavenum
      
 } 




switch(arstate) {
	is(s_IDLE) {
	
	when(io.m1.ar.arvalid && axi_arready) {
        	rw	     := false.B
		axi_rid      := io.m1.ar.arid
		bram_addr    := io.m1.ar.araddr
		bram_wea     := 0.U
        	bram_wdata   := 0.U
        	axi_arready  := false.B		
		axi_wready   := false.B
		axi_awready  := false.B
		arstate      := s_DECODE
		legalSlave   := addrlegal(io.m1.ar.araddr.asUInt).toBool
		bram_ena     := addrlegal(io.m1.ar.araddr.asUInt).toBool
                bram_rdata  := 0.U
	        
        } .otherwise {  //no arvalid
		
		when(io.m1.aw.awvalid && axi_awready) {
		axi_bid         := io.m1.aw.awid
		rw              := true.B
		legalSlave      := addrlegal(io.m1.aw.awaddr).toBool
		bram_addr	 := io.m1.aw.awaddr
		axi_awready	 := false.B
		axi_arready     := false.B
              } 
		
		when(io.m1.w.wvalid && axi_wready) {
			axi_wready	:= false.B
			axi_arready	:= false.B
			bram_wdata	:= io.m1.w.wdata
			bram_wea	:= io.m1.w.wstrb
		} 
		
		
		when(axi_awready || axi_wready) {
			arstate := s_IDLE
		} .otherwise {
			arstate      := s_DECODE
			bram_ena     := legalSlave.toBool
                }
	
	} 
}
	
		
	
	is(s_DECODE) {
	arstate     := s_RESP
	axi_arready := false.B
	axi_awready := false.B
	axi_wready  := false.B
	bram_ena    := false.B

	bram_wea    := 0.U
	bram_wdata  := 0.U   
	bram_addr    := 0.U
	axi_rvalid := legalSlave && !rw
	axi_rresp  := Mux(rw,0.U,Mux(legalSlave,0.U,2.U))
	axi_bvalid := legalSlave && rw
	axi_bresp  := Mux(rw,Mux(legalSlave,0.U,2.U),0.U)
	arstate    := s_RESP
			
		
	} //s_DECODE
	

	
	is(s_RESP) {
			axi_rvalid := Mux(io.m1.r.rready && axi_rvalid,false.B,true.B)
			axi_bvalid := Mux(io.m1.b.bready && axi_bvalid,false.B,true.B)
			arstate    := Mux( (rw && io.m1.b.bready) || (!rw && io.m1.r.rready) , s_IDLE, s_RESP)
			axi_arready := true.B
			axi_awready := true.B
			axi_wready  := true.B	
		        bram_wea    := 0.U
	                bram_wdata  := 0.U   
	                bram_addr    := 0.U
		        bram_ena    := false.B
	
	}
	
	
	
				

} //arstate





	
	}
	
	
	
	
	
}	
	
	
	
	
  

	
// Generate the Verilog code by invoking the Driver
object AxiBramMain extends App {
  println("Generating the top hardware")
  chisel3.Driver.execute(Array("--target-dir", "top"), () => new AxiBram())
}


