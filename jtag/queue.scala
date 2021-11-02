

package jtag
 
import chisel3._
import chisel3.util._
import chisel3.experimental._
 
class QueueModule_jtag(width: Int, depth: Int)  extends Module {
  val io = IO(new Bundle {
    val i = Flipped(Decoupled(UInt(width.W))) // valid and bits are inputs
    val o = Decoupled(UInt(width.W)) // valid and bits are outputs
  })


  val qa = Queue(io.i,depth) // io.a is the input to the FIFO
   io.o.valid := qa.valid
   io.o.bits  := qa.bits
   qa.ready   := io.o.ready
   
   }
   



 
object queueMain extends App {
   chisel3.Driver.execute(Array("--target-dir", "top"), () => new QueueModule_jtag(32,2))
}

