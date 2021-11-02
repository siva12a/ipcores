

package jtag

import chisel3._
import chisel3.util._
import chisel3.util.BitPat



object Address_jtag {


 val EN_ADDR                      = "h00".U(8.W)    // ENABLE AND STATUS REGISTER
 val TMSFF_ADDR                   = "h04".U(8.W)
 val TDOFF_ADDR                   = "h08".U(8.W)
 val TDIFF_ADDR                   = "h0c".U(8.W)
 val LEN_ADDR                     = "h10".U(8.W)
 val FF_CLR                      = "h14".U(8.W)
  val DIV_ADDR                   = "h20".U(8.W)

}

