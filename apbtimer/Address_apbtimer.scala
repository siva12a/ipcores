

package riscv

import chisel3._
import chisel3.util._
import chisel3.util.BitPat



object Address_apbtimer {


 val TCSR0                                    = "h00".U(8.W) 
 val TLR0                                     = "h04".U(8.W)
 val TCR0				       = "h08".U(8.W)
 val TCSR1             = "h10".U(8.W)
 val TLR1             = "h14".U(8.W)
 val TCR1               = "h18".U(8.W)
 
 val capture_edge = false.B

}

