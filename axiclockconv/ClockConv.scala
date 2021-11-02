
// this is a single master 3 slave crossbar implemented using state machine (no queue support)
package ClockConv

import chisel3._
import chisel3.util._
import chisel3.util.BitPat

class ArChannel(width : Int,id : Int) extends Bundle {
  val araddr   = Input(Bits(width.W))
  val arsize   = Input(Bits(3.W))
  val arlen    = Input(Bits(8.W))
  val arburst  = Input(Bits(2.W))
  val arid     = Input(Bits(id.W))
  val arready  = Output(Bool())
  val arvalid  = Input(Bool())
  override def cloneType = { new ArChannel(width,id).asInstanceOf[this.type] }
}


class RChannel(width : Int,id : Int) extends Bundle {
  val rdata   = Output(Bits(width.W))
  val rresp   = Output(Bits(2.W))
  val rid     = Output(Bits(id.W))
  val rready  = Input(Bool())
  val rvalid  = Output(Bool())
  val rlast   = Output(Bool())
    override def cloneType = { new RChannel(width,id).asInstanceOf[this.type] }
}


class Awchannel(width : Int,id : Int) extends Bundle {
  val awaddr   = Input(Bits(width.W))
  val awsize   = Input(Bits(3.W))
  val awlen    = Input(Bits(8.W))
  val awburst  = Input(Bits(2.W))
  val awid     = Input(Bits(id.W))
  val awready  = Output(Bool())
  val awvalid  = Input(Bool())
    override def cloneType = { new Awchannel(width,id).asInstanceOf[this.type] }
}

class WChannel(width : Int) extends Bundle {
  val wdata   = Input(Bits(width.W))
  val wstrb   = Input(Bits((width/8).W))
  val wlast   = Input(Bool())
  val wready  = Output(Bool())
  val wvalid  = Input(Bool())
    override def cloneType = { new WChannel(width).asInstanceOf[this.type] }
}

class BChannel(id : Int) extends Bundle {
  val bresp   = Output(Bits(2.W))
  val bid     = Output(Bits(id.W))
  val bready  = Input(Bool())
  val bvalid  = Output(Bool())
    override def cloneType = { new BChannel(id).asInstanceOf[this.type] }
}


class axi_m(addrw : Int,id : Int,dataw : Int) extends Bundle {
val ar = new ArChannel(addrw,id)
val aw = new Awchannel(addrw,id)
val w  = new WChannel(dataw)
val b  = new BChannel(id)
val r  = new RChannel(dataw,id)
  override def cloneType = { new axi_m(addrw,id,dataw).asInstanceOf[this.type] }
}


class ClockConv(addrw : Int,id : Int,dataw : Int) extends Module  {

  val io = IO(new Bundle {

    val m = new axi_m(addrw,id,dataw)
    val s =  Flipped(new axi_m(addrw,id,dataw))
    val  m_axi_clk      = Input(Clock())  // system control clock 
    val  s_axi_clk      = Input(Clock()) 
    val  m_axi_rstn     = Input(Bool()) 
     
  })


def afifow =  addrw + 3 + 8 + 2 + id 
def wstrbw = dataw/8
def wfifow = dataw + wstrbw + 1
def rdataw = dataw + 2 + id + 1
def bdataw = 2 + id 

//// CLOCK DOMAIN CROSSING FIFOS 
val cdc_axi_aw_fifo = Module(new FIFO(afifow,16))  //AW FIFO
val cdc_axi_ar_fifo = Module(new FIFO(afifow,16))  //AR FIFO
val cdc_axi_w_fifo  = Module(new FIFO(wfifow,16))  //W FIFO
val cdc_axi_r_fifo  = Module(new FIFO(rdataw,16))  //R FIFO
val cdc_axi_b_fifo  = Module(new FIFO(bdataw,16))  // B FIFO
////////////////////////////////////// AW CHANNEL ////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// m_axi_clk_domain
cdc_axi_aw_fifo.io.dataIn   := Cat(io.m.aw.awid,io.m.aw.awburst,io.m.aw.awlen,io.m.aw.awsize,io.m.aw.awaddr).asUInt
cdc_axi_aw_fifo.io.writeEn  := io.m.aw.awvalid && !cdc_axi_aw_fifo.io.full
cdc_axi_aw_fifo.io.writeClk := io.m_axi_clk
io.m.aw.awready             := !cdc_axi_aw_fifo.io.full

// s_axi_clk domain
io.s.aw.awaddr  := cdc_axi_aw_fifo.io.dataOut(addrw - 1,0);
io.s.aw.awsize  := cdc_axi_aw_fifo.io.dataOut(addrw + 2,addrw);
io.s.aw.awlen   := cdc_axi_aw_fifo.io.dataOut(addrw + 10,addrw + 3);
io.s.aw.awburst := cdc_axi_aw_fifo.io.dataOut(addrw + 12,addrw + 11);
io.s.aw.awid    := cdc_axi_aw_fifo.io.dataOut(addrw + id - 1 + 13 ,addrw + 13);
io.s.aw.awvalid := !cdc_axi_aw_fifo.io.empty
cdc_axi_aw_fifo.io.readEn    :=   !cdc_axi_aw_fifo.io.empty && io.s.aw.awready
cdc_axi_aw_fifo.io.readClk   :=   io.s_axi_clk
cdc_axi_aw_fifo.io.systemRst :=  !io.m_axi_rstn
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////// AR CHANNEL ///////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// m_axi_clk_domain
cdc_axi_ar_fifo.io.dataIn   := Cat(io.m.ar.arid,io.m.ar.arburst,io.m.ar.arlen,io.m.ar.arsize,io.m.ar.araddr).asUInt
cdc_axi_ar_fifo.io.writeEn  := io.m.ar.arvalid && !cdc_axi_ar_fifo.io.full
cdc_axi_ar_fifo.io.writeClk := io.m_axi_clk
io.m.ar.arready             := !cdc_axi_ar_fifo.io.full

// s_axi_clk domain
io.s.ar.araddr  := cdc_axi_ar_fifo.io.dataOut(addrw - 1,0);
io.s.ar.arsize  := cdc_axi_ar_fifo.io.dataOut(addrw + 2,addrw);
io.s.ar.arlen   := cdc_axi_ar_fifo.io.dataOut(addrw + 10,addrw + 3);
io.s.ar.arburst := cdc_axi_ar_fifo.io.dataOut(addrw + 12,addrw + 11);
io.s.ar.arid    := cdc_axi_ar_fifo.io.dataOut(addrw + id - 1 + 13 ,addrw + 13);
io.s.ar.arvalid := !cdc_axi_ar_fifo.io.empty
cdc_axi_ar_fifo.io.readEn    :=   !cdc_axi_ar_fifo.io.empty && io.s.ar.arready
cdc_axi_ar_fifo.io.readClk   :=   io.s_axi_clk
cdc_axi_ar_fifo.io.systemRst :=  !io.m_axi_rstn 
  
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
////////////////////////////////////// W CHANNEL ////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
cdc_axi_w_fifo.io.dataIn   := Cat(io.m.w.wlast,io.m.w.wstrb,io.m.w.wdata)
cdc_axi_w_fifo.io.writeEn  := io.m.w.wvalid && !cdc_axi_w_fifo.io.full 
cdc_axi_w_fifo.io.writeClk := io.m_axi_clk  
io.m.w.wready              := !cdc_axi_w_fifo.io.full  

io.s.w.wdata  := cdc_axi_w_fifo.io.dataOut(dataw - 1,0);
io.s.w.wstrb  := cdc_axi_w_fifo.io.dataOut(dataw + wstrbw - 1,dataw);
io.s.w.wlast  := cdc_axi_w_fifo.io.dataOut(wfifow - 1);
io.s.w.wvalid := !cdc_axi_w_fifo.io.empty

cdc_axi_w_fifo.io.readEn    :=   !cdc_axi_w_fifo.io.empty && io.s.w.wready
cdc_axi_w_fifo.io.readClk   :=   io.s_axi_clk
cdc_axi_w_fifo.io.systemRst :=   !io.m_axi_rstn 

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
////////////////////////////////////// R CHANNEL ////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
cdc_axi_r_fifo.io.dataIn     := Cat(io.s.r.rlast,io.s.r.rid,io.s.r.rresp,io.s.r.rdata)
cdc_axi_r_fifo.io.writeEn    := io.s.r.rvalid &&  !cdc_axi_r_fifo.io.full
cdc_axi_r_fifo.io.writeClk   := io.s_axi_clk    
io.s.r.rready := !cdc_axi_r_fifo.io.full

io.m.r.rdata  := cdc_axi_r_fifo.io.dataOut(dataw - 1,0);
io.m.r.rresp  := cdc_axi_r_fifo.io.dataOut(dataw + 1,dataw);
io.m.r.rid    := cdc_axi_r_fifo.io.dataOut(dataw + 2 + id - 1,dataw + 2);  
io.m.r.rlast  := cdc_axi_r_fifo.io.dataOut(rdataw - 1)

io.m.r.rvalid := !cdc_axi_r_fifo.io.empty

cdc_axi_r_fifo.io.readEn    :=  !cdc_axi_r_fifo.io.empty && io.m.r.rready
cdc_axi_r_fifo.io.readClk   :=  io.m_axi_clk
cdc_axi_r_fifo.io.systemRst :=  !io.m_axi_rstn 
  

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
////////////////////////////////////// B CHANNEL ////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
 cdc_axi_b_fifo.io.dataIn     := Cat(io.s.b.bresp,io.s.b.bid) 
 cdc_axi_b_fifo.io.writeEn    := io.s.b.bvalid &&  !cdc_axi_b_fifo.io.full
 cdc_axi_b_fifo.io.writeClk   := io.s_axi_clk 
 io.s.b.bready := !cdc_axi_b_fifo.io.full
 
 
 io.m.b.bid    :=  cdc_axi_b_fifo.io.dataOut(id - 1,0)
 io.m.b.bresp  :=  cdc_axi_b_fifo.io.dataOut(bdataw - 1,id) 
 io.m.b.bvalid := !cdc_axi_b_fifo.io.empty
 
  cdc_axi_b_fifo.io.readEn    :=  !cdc_axi_b_fifo.io.empty && io.m.b.bready
  cdc_axi_b_fifo.io.readClk   :=  io.m_axi_clk
  cdc_axi_b_fifo.io.systemRst :=  !io.m_axi_rstn 
  
}

	
// Generate the Verilog code by invoking the Driver
object ClockConvMain extends App {
  println("Generating the top hardware")
  chisel3.Driver.execute(Array("--target-dir", "top"), () => new ClockConv(32,2,32))
}
