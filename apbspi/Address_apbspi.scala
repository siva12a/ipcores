

package apbspi

import chisel3._
import chisel3.util._
import chisel3.util.BitPat



object Address_apbspi {
 val SRR                = "h40".U(8.W) 
 val SPICR              = "h60".U(8.W)
 val SPISR		 = "h64".U(8.W)
 val SPIDTR             = "h68".U(8.W)
 val SPIDRR             = "h6C".U(8.W)
 val SPISSR             = "h70".U(8.W)
 val SPITXFFOCV         = "h74".U(8.W)
 val SPIRXFFOCV         = "h78".U(8.W)
 val DGIER              = "h1C".U(8.W)
 val IPISR              = "h20".U(8.W) 
 val IPIER              = "h28".U(8.W) 
 val DIVISOR           = "h2C".U(8.W) 
}
