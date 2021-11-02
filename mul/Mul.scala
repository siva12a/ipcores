

package mul

import chisel3._
import chisel3.experimental._
import chisel3.util._
import chisel3.util.BitPat

import Control._




class MulBehav extends Module  {
//instruction ar channel
val io = IO(new Bundle {


val  PCLK              = Input(Clock())  // system control clock 
val  PRESETn           = Input(Bool())  // system control reset active low
val  OPCODE            = Input(UInt(6.W))   
val  OPA               = Input(UInt(64.W))    
val  OPB               = Input(UInt(64.W))   
val  OUT               = Output(UInt(64.W))

})


val alu_A_128    = RegInit(0.U(128.W))
val alu_B_128    = RegInit(0.U(128.W))

val alu_A  = RegInit(0.U(64.W))
val alu_B  = RegInit(0.U(64.W))

val alu_O = RegInit(0.U(64.W))


alu_A_128 := io.OPA.asUInt
alu_B_128 := io.OPB.asUInt
alu_A     := io.OPA
alu_B     := io.OPB


io.OUT := alu_O



alu_O := MuxLookup(io.OPCODE, 0.U, Seq(
      Control.ALU_MUL       -> (alu_A_128 * alu_B_128)(63,0).asSInt.asUInt,
      Control.ALU_MULH      -> (alu_A_128 * alu_B_128)(127,64).asSInt.asUInt,
      Control.ALU_MULHSU    -> (alu_A_128 * alu_B_128)(127,64).asSInt.asUInt,
      Control.ALU_MULHU     -> (alu_A_128.asUInt * alu_B_128.asUInt)(127,64).asSInt.asUInt,
      Control.ALU_DIV       -> (alu_A / alu_B).asSInt.asUInt,
      Control.ALU_DIVU      -> (alu_A.asUInt / alu_B.asUInt).asSInt.asUInt,
      Control.ALU_REM       -> (alu_A % alu_B).asSInt.asUInt,
      Control.ALU_REMU      -> (alu_A.asUInt % alu_B.asUInt).asSInt.asUInt,
      
      Control.ALU_MULW      -> (alu_A(31,0) * alu_B(31,0)).asSInt.asUInt,
      Control.ALU_DIVW      -> (alu_A(31,0) / alu_B(31,0)).asSInt.asUInt,
      Control.ALU_DIVUW     -> (alu_A(31,0).asUInt / alu_B(31,0).asUInt).asSInt.asUInt,
      Control.ALU_REMW      -> (alu_A(31,0) % alu_B(31,0)).asSInt.asUInt,
      Control.ALU_REMUW     -> (alu_A(31,0).asUInt % alu_B(31,0).asUInt).asSInt.asUInt
))




}
	
// Generate the Verilog code by invoking the Driver
object MulBehavMain extends App {
  println("Generating the top hardware")
  chisel3.Driver.execute(Array("--target-dir", "top"), () => new MulBehav())
}




