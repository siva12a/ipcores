

package led

import chisel3._
import chisel3.util._
import chisel3.util.BitPat



object Address_led {


 val SR_ADDR             = "h04".U(8.W) 
 val TX_ADDR             = "h00".U(8.W)
 val T0H_ADDR            = "h08".U(8.W)
 val T0L_ADDR            = "h0C".U(8.W)
 val T1H_ADDR            = "h10".U(8.W)
 val T1L_ADDR            = "h14".U(8.W)
 val RSTLED_ADDR            = "h20".U(8.W)
 

}

