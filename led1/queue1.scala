

package led1
 
import chisel3._
import chisel3.util._
import chisel3.experimental._
 
class QueueModuleled1(width: Int, depth: Int)  extends Module {
  val io = IO(new Bundle {
    val i = Flipped(Decoupled(UInt(width.W))) // valid and bits are inputs
    val o = Decoupled(UInt(width.W)) // valid and bits are outputs
  })


  val qa = Queue(io.i,depth) // io.a is the input to the FIFO
   io.o.valid := qa.valid
   io.o.bits  := qa.bits
   qa.ready   := io.o.ready
   
   }
   



 
object queueMain1 extends App {
   chisel3.Driver.execute(Array("--target-dir", "top"), () => new QueueModuleled1(24,21))
}

