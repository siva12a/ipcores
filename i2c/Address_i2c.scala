

package i2c

import chisel3._
import chisel3.util._
import chisel3.util.BitPat



object Address_i2c {


 val CR_ADDR                  = "h00".U(8.W) 
 val SR_ADDR                   = "h04".U(8.W)
 val SR1_ADDR                  = "h08".U(8.W)
 val IER_ADDR               = "h0c".U(8.W)
 val TX_ADDR             = "h10".U(8.W)
 val RX_ADDR               = "h14".U(8.W)
 val CHPL_ADDR               = "h1c".U(8.W)
 val CHPH_ADDR                = "h20".U(8.W)
  val CHHPL_ADDR               = "h2c".U(8.W)
 val CHHPH_ADDR                = "h30".U(8.W)
 val TXFFCLR_ADDR              = "h3c".U(8.W)
 
 

}

