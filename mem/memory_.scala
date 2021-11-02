
package mem

import chisel3._
import chisel3.util._
import chisel3.util.BitPat
class memory_() extends Module  {

  val io           = IO(new Bundle {
  val sram_dout    = Output(Vec(4, UInt(8.W)))
  val sram_din     = Input(Vec(4, UInt(8.W)))
  val sram_addr    = Input(UInt(10.W))
  val sram_dmask   = Input(Vec(4, Bool()))
  val sram_en      = Input(Bool())  
  val sram_wen     = Input(Bool())    
  
  })

val dataOut   = Reg(Vec(4, UInt(8.W)))
val dataIn    = Reg(Vec(4, UInt(8.W)))
val mask      = Reg(Vec(4, Bool()))
val enable    = RegInit(false.B)
val wenable   = RegInit(false.B)
val addr      = Reg(UInt(10.W))


dataIn := io.sram_din


enable  := io.sram_en


mask    := io.sram_dmask



addr 	:= io.sram_addr
wenable := io.sram_wen


io.sram_dout := dataOut



// ... assign values ...

// Create a 32-bit wide memory that is byte-masked.
val mem = SyncReadMem(8192, Vec(4, UInt(8.W)))
// Create one masked write port and one read port.
when(enable) {
	when(wenable) {
             mem.write(addr, dataIn, mask)
             } .otherwise {
             dataOut := mem.read(addr, enable)
	     }
} 

}

	
// Generate the Verilog code by invoking the Driver
object Memorymain extends App {
  println("Generating the top hardware")
  chisel3.Driver.execute(Array("--target-dir", "top"), () => new memory_())
}
