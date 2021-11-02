// Verilog testbench created by TD v4.6.18154
// 2021-06-28 22:45:46

`timescale 1ns / 1ps

module I2CBehav_tb();

reg clock;
reg rst_n;
reg uart1_rxd;
wire [2:0] gpo;
wire [1:0] pwm_o;
wire uart1_txd;
reg sda_i;
//Clock process
parameter PERIOD = 10;

//glbl Instantiate
//glbl glbl();
 always #5 clock = ~clock;  
//Unit Instantiate

reg [7:0] paddr,pwdata;
wire [7:0] prdata;
reg psel,pena,pwrite,sdai,scli;
wire sdat,sdao,sclt,sclo;
wire  [3:0] io_doOpcodeio;
wire txc,rxc,startsent,stopsent,rstartsent,nack;



wire [15:0] iiccount;
wire [5:0] txbitc;
wire [4:0] readl;
I2CBehav uut(
	.clock         (clock),
    .reset         (rst_n),
    .io_PCLK     (clock),
    .io_PRESETn    (rst_n),
    .io_PADDR      (paddr),
    .io_PPROT      (0),
    .io_PSEL       (psel),
    .io_PENABLE    (pena),
    .io_PWRITE     (pwrite),
    .io_PWDATA     (pwdata),
    .io_PSTRB      (0),
    .io_PREADY     (),
    .io_PRDATA     (prdata),
    .io_PSLVERR    (),
    .io_irq        (),
    .io_sda_t      (sdat),
    .io_sda_o      (sdao),
    .io_sda_i      (sdai),
    .io_scl_t      (sclt),
    .io_scl_o      (sclo),
    .io_scl_i      (scli),
    .io_doOpcodeio(io_doOpcodeio),
    .io_iiccount(iiccount),
    .io_txbitc(txbitc),
    .io_readl(readl),
     .io_txcio  (txc),
 .io_rxcio     (rxc),    
 .io_startsentio   (startsent),
.io_stopsentio     (stopsent),
 .io_rstartsentio  (rstartsent),
 .io_nackio       (nack)
    
    
    
    
    
);



initial begin
		$dumpfile("i2c.vcd");
		$dumpvars(0, I2CBehav_tb);
		
        end
//Stimulus process
initial begin
//To be inserted
    clock <= 0;  
    rst_n <= 0;  
    psel  <= 1'b0;
    pena  <= 1'b0;
    pwrite <= 1'b0;
    pwdata <= 8'hab;
    sdai  <= 1'b0;
    #105 rst_n <= 1;
    #100 paddr <= 8'h04;
         psel  <= 1'b1;
         pena  <= 1'b0;
         pwrite <= 1'b1;
         pwdata <= 8'h01;
    #160  pena   <= 1'b1;
    #10 psel   <= 1'b0;
     pena   <= 1'b0;
      pwrite   <= 1'b0;
    #100
    
     #100 paddr <= 8'h04;
         psel  <= 1'b1;
         pena  <= 1'b0;
         pwrite <= 1'b1;
         pwdata <= 8'h77;
    #10  pena   <= 1'b1;
    #10  psel   <= 1'b0;
     pena   <= 1'b0;
      pwrite   <= 1'b0;
      
    
       #100 paddr <= 8'h00;
         psel  <= 1'b1;
         pena  <= 1'b0;
         pwrite <= 1'b1;
         pwdata <= 8'h09;
    #10  pena   <= 1'b1;
    #10  psel   <= 1'b0;
     pena   <= 1'b0;
      pwrite   <= 1'b0;
      
      #10000
      
     #100 paddr <= 8'h05;
         psel  <= 1'b1;
         pena  <= 1'b0;
         pwrite <= 1'b0;
         pwdata <= 8'h01;
    #10  pena   <= 1'b1;
    #500  psel   <= 1'b0;
     pena   <= 1'b0;
      pwrite   <= 1'b0;
      
      
    #10000
    
    
   
 
    $finish;
end










endmodule
