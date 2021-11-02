

package fetchbuffer
 
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
  val awready  = Output(Bool())
  val awvalid  = Input(Bool())
    override def cloneType = { new Awchannel(awidth).asInstanceOf[this.type] }
}

class WChannel(dwidth : Int) extends Bundle {
  val wdata   = Input(Bits(dwidth.W))
  val wstrb   = Input(Bits((dwidth/8).W))
  val wlast   = Input(Bool())
  val wready  = Output(Bool())
  val wvalid  = Input(Bool())
    override def cloneType = { new WChannel(dwidth).asInstanceOf[this.type] }
}

class BChannel extends Bundle {
  val bresp   = Output(Bits(2.W))
  val bid     = Output(Bits(2.W))
  val bready  = Input(Bool())
  val bvalid  = Output(Bool())
//   override def cloneType = { new BChannel().asInstanceOf[this.type] }
}

class fetchBuffer(dwidth: Int, awidth: Int, depth: Int)  extends Module {
  val io = IO(new Bundle {
  
    val imemafromproc    = Flipped(Decoupled(new ArChannel(awidth)))
    val imematoport      = Decoupled(Flipped (new ArChannel(awidth)))
    
    val imemdfromport    = Flipped(Decoupled(Flipped(new RChannel(dwidth))))
    val imemdtoproc      = Decoupled((new RChannel(awidth)))
   
    
    // Note : always think of Decoupled with valid output and ready input
  })

  val imemadrq = Queue(io.imemafromproc,depth) // io.a is the input to the FIFO
   io.imematoport.valid     := imemadrq.valid
   io.imematoport.bits      := imemadrq.bits
   imemadrq.ready           := io.imematoport.ready
   
  val imemdataq = Queue(io.imemdfromport,depth) 
  io.imemdtoproc.valid     := imemdataq.valid
  io.imemdtoproc.bits      := imemdataq.bits
  imemdataq.ready          := io.imemdtoproc.ready


   
   
   
   
   
}
 
object FetchBufferMain extends App
 {
 chisel3.Driver.execute(Array("--target-dir", "top"), () => new fetchBuffer(32,32,8))
}

