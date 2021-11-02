

package mul

import chisel3._
import chisel3.util._
import chisel3.util.BitPat



object Control {

  
 val  ALU_MUL        = 21.U(6.W)
 val  ALU_MULH       = 22.U(6.W)
 val  ALU_MULHSU     = 23.U(6.W)
 val  ALU_MULHU      = 24.U(6.W)
 val  ALU_DIV        = 25.U(6.W)
 val  ALU_DIVU       = 26.U(6.W)
 val  ALU_REM        = 27.U(6.W)
 val  ALU_REMU       = 28.U(6.W)
                    
 val ALU_MULW        = 29.U(6.W)
 val ALU_DIVW        = 30.U(6.W)
 val ALU_DIVUW       = 31.U(6.W)
 val ALU_REMW        = 32.U(6.W)
 val ALU_REMUW       = 33.U(6.W)
 
 
}
