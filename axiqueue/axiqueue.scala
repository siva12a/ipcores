

package axiqueue
 
import chisel3._
import chisel3.util._
import chisel3.experimental._
 
 
 class ArChannel(awidth : Int) extends Bundle {
  val araddr   = Input(Bits(awidth.W))
  val arsize   = Input(Bits(3.W))
  val arlen    = Input(Bits(8.W))
  val arburst  = Input(Bits(2.W))
  val arid     = Input(Bits(2.W))
 // val arready  = Output(Bool())
  //val arvalid  = Input(Bool())
  override def cloneType = { new ArChannel(awidth).asInstanceOf[this.type] }
}
 class RChannel(dwidth : Int) extends Bundle {
  val rdata   = Output(Bits(dwidth.W))
  val rresp   = Output(Bits(2.W))
  val rid     = Output(Bits(2.W))
  //val rready  = Input(Bool())
  //val rvalid  = Output(Bool())
  val rlast   = Output(Bool())
  override def cloneType = { new RChannel(dwidth).asInstanceOf[this.type] }
}


class Awchannel(awidth : Int) extends Bundle {
  val awaddr   = Input(Bits(awidth.W))
  val awsize   = Input(Bits(3.W))
  val awlen    = Input(Bits(8.W))
  val awburst  = Input(Bits(2.W))
  val awid     = Input(Bits(2.W))
//  val awready  = Output(Bool())
//  val awvalid  = Input(Bool())
    override def cloneType = { new Awchannel(awidth).asInstanceOf[this.type] }
}

class WChannel(dwidth : Int) extends Bundle {
  val wdata   = Input(Bits(dwidth.W))
  val wstrb   = Input(Bits((dwidth/8).W))
  val wlast   = Input(Bool())
//  val wready  = Output(Bool())
//  val wvalid  = Input(Bool())
    override def cloneType = { new WChannel(dwidth).asInstanceOf[this.type] }
}

class BChannel extends Bundle {
  val bresp   = Output(Bits(2.W))
  val bid     = Output(Bits(2.W))
//  val bready  = Input(Bool())
//  val bvalid  = Output(Bool())
   override def cloneType = { new BChannel().asInstanceOf[this.type] }
}

class LoadStoreQueue(dwidth: Int, awidth: Int, depth: Int)  extends Module {
  val io = IO(new Bundle {
  
    val lafromproc    = Flipped(Decoupled(new ArChannel(awidth)))
    val latoport      = Decoupled(Flipped (new ArChannel(awidth)))
    
    val ldfromport    = Flipped(Decoupled(Flipped(new RChannel(dwidth))))
    val ldtoproc      = Decoupled((new RChannel(awidth)))
    
    val stafromproc   = Flipped(Decoupled(new Awchannel(awidth)))
    val statoport     = Decoupled(Flipped (new Awchannel(awidth)))
    
    val stdfromproc   = Flipped(Decoupled(new WChannel(dwidth)))
    val stdtoport     = Decoupled(Flipped (new WChannel(dwidth)))
    
    
    val strfromport   = Flipped(Decoupled(Flipped(new BChannel())))
    val strtoproc      = Decoupled((new BChannel()))
    
    
    
    // Note : always think of Decoupled with valid output and ready input
  })

  val loadadrq = Queue(io.lafromproc,depth) // io.a is the input to the FIFO
   io.latoport.valid     := loadadrq.valid
   io.latoport.bits      := loadadrq.bits
   loadadrq.ready   := io.latoport.ready
   
  val loaddataq = Queue(io.ldfromport,depth) 
  io.ldtoproc.valid     := loaddataq.valid
  io.ldtoproc.bits      := loaddataq.bits
  loaddataq.ready := io.ldtoproc.ready

  
  val storeadrq = Queue(io.stafromproc,depth)
  io.statoport.valid  := storeadrq.valid
  io.statoport.bits  := storeadrq.bits
  storeadrq.ready    := io.statoport.ready
  
  val storedatq = Queue(io.stdfromproc,depth)
  io.stdtoport.valid := storedatq.valid
  io.stdtoport.bits  := storedatq.bits
  storedatq.ready    := io.stdtoport.ready
  
  val storerespq = Queue(io.strfromport,depth)
  io.strtoproc.valid := storerespq.valid
  io.strtoproc.bits  := storerespq.bits
  storerespq.ready    := io.strtoproc.ready
   
   
   
   
   
   
}
 
object LoadStoreQueueMain extends App {
   chisel3.Driver.execute(Array("--target-dir", "top"), () => new LoadStoreQueue(32,32,1))
}

