

package ClockConv
 
import chisel3._
import chisel3.util._
import chisel3.experimental._
 
class FIFO(width: Int, depth: Int) extends RawModule {
  val io = IO(new Bundle {
    // write-domain
    val dataIn = Input(UInt(width.W))
    val writeEn = Input(Bool())
    val writeClk = Input(Clock())
    val full = Output(Bool())
    val writePtr = Output(UInt((depth + 1).W))
    // read-domain
    val dataOut = Output(UInt(width.W))
    val readEn = Input(Bool())
    val readClk = Input(Clock())
    val empty = Output(Bool())
    val readPtr = Output(UInt((depth + 1).W))
    // reset
    val systemRst = Input(Bool())
  })
 
  val ram = SyncReadMem(1 << depth, UInt(width.W))   // 2^depth
  val writeToReadPtr = Wire(UInt((depth + 1).W))  // to read clock domain
  val readToWritePtr = Wire(UInt((depth + 1).W))  // to write clock domain
 
  // write clock domain
  withClockAndReset(io.writeClk, io.systemRst) {
    val binaryWritePtr = RegInit(0.U((depth + 1).W))
    val binaryWritePtrNext = Wire(UInt((depth + 1).W))
    val grayWritePtr = RegInit(0.U((depth + 1).W))
    val grayWritePtrNext = Wire(UInt((depth + 1).W))
    val isFull = RegInit(false.B)
    val fullValue = Wire(Bool())
    val grayReadPtrDelay0 = RegNext(readToWritePtr)
    val grayReadPtrDelay1 = RegNext(grayReadPtrDelay0)
 
    io.writePtr := binaryWritePtr
    binaryWritePtrNext := binaryWritePtr + (io.writeEn && !isFull).asUInt
    binaryWritePtr := binaryWritePtrNext
    grayWritePtrNext := (binaryWritePtrNext >> 1) ^ binaryWritePtrNext
    grayWritePtr := grayWritePtrNext
    writeToReadPtr := grayWritePtr
    fullValue := (grayWritePtrNext === Cat(~grayReadPtrDelay1(depth, depth - 1), grayReadPtrDelay1(depth - 2, 0)))
    isFull := fullValue
 
    when(io.writeEn && !isFull) {
      ram.write(binaryWritePtr(depth - 1, 0), io.dataIn)
    }
 
    io.full := isFull    
  }
  // read clock domain
  withClockAndReset(io.readClk, io.systemRst) {
    val binaryReadPtr = RegInit(0.U((depth + 1).W))
    val binaryReadPtrNext = Wire(UInt((depth + 1).W))
    val grayReadPtr = RegInit(0.U((depth + 1).W))
    val grayReadPtrNext = Wire(UInt((depth + 1).W))
    val isEmpty = RegInit(true.B)
    val emptyValue = Wire(Bool())
    val grayWritePtrDelay0 = RegNext(writeToReadPtr)
    val grayWritePtrDelay1 = RegNext(grayWritePtrDelay0)
    io.readPtr := binaryReadPtr
    binaryReadPtrNext := binaryReadPtr + (io.readEn && !isEmpty).asUInt
    binaryReadPtr := binaryReadPtrNext
    grayReadPtrNext := (binaryReadPtrNext >> 1) ^ binaryReadPtrNext
    grayReadPtr := grayReadPtrNext
    readToWritePtr := grayReadPtr
    emptyValue := (grayReadPtrNext === grayWritePtrDelay1)
    isEmpty := emptyValue
 
    io.dataOut := ram.read(binaryReadPtr(depth - 1, 0), !isEmpty)
    io.empty := isEmpty
  }  
}
 
object FIFOGen extends App {
  chisel3.Driver.execute(args, () => new FIFO(10, 10))
}
