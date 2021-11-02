

package apbuart

import chisel3._
import chisel3.util._
import chisel3.util.BitPat



object Address_apbuart {


 val RBR                                    = "h00".U(8.W) 
 val THR                                    = "h00".U(8.W)
 val IER				     = "h04".U(8.W)
 val IIR             = "h08".U(8.W)
 val FCR             = "h08".U(8.W)

  val LCR               = "h0c".U(8.W)
   val MCR               = "h10".U(8.W)
    val LSR               = "h14".U(8.W)
     val MSR               = "h18".U(8.W)
      val SCR               = "h1c".U(8.W) 
       val DLL               = "h00".U(8.W) 
        val DLH               = "h04".U(8.W)     
 















}

