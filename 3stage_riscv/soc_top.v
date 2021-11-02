`timescale 1ns / 1ps


module soc_top(
    input clock,
    input rst_n,
    
   
    output    uart1_txd   ,
    input     uart1_rxd   ,
       
       
    output    uart0_txd   ,
    input     uart0_rxd   ,
    
   inout     scl_io   ,
   inout     sda_io   ,
  
  
  
 
  
    output         spi_clk,   
    input          spi_miso,   
    output         spi_mosi,   
    output [1:0]   spi_ssel,
    

   output  ledo,
   output [2:0]      gpo,
 
    
    
  output [1:0] pwm_o
    );
    
// wire clock;

/*
 pll u_pll (
 .refclk(clockin),
 .reset(rst_n),
 .clk0_out(clock)
 
 
 );
 */
 
 
 
 
 
 
 
 
 
 wire   [31:0]   imem_addr;   
 wire            imem_rden;   
 wire  [31:0]    imem_rdata;   
                                    
 
 wire  [31:0]    w_dmem_addr   ;
 wire            w_dmem_sel    ;
 wire            w_dmem_enable ;
 wire            w_dmem_write  ;
 wire  [3:0]     w_dmem_wstrb  ;
 wire  [31:0]    w_dmem_rdata  ;
 wire  [31:0]    w_dmem_wdata  ;
 
 wire [31:0] gpo_w;
 
 assign gpo = gpo_w[2:0];

 

 

wire spi_mosi_i      ;
wire spi_mosi_o      ;
wire spi_mosi_t      ;
wire spi_miso_i      ;
wire spi_miso_o      ;
wire spi_miso_t      ;
wire spi_clk_o   ;
wire spi_clk_i   ;
wire spi_clk_t   ;
wire [7:0] spi_ssel_o  ;
wire spi_ssel_i  ;
wire spi_ssel_t  ;
wire interrupt;
wire [4:0] peri_intr;
wire spi_intr;
wire uart1_intr;
wire uar2_intr;


wire   [31:0] m0_apb_addr  ;
wire          m0_apb_sel   ;
wire          m0_apb_write ;
wire          m0_apb_ena   ;
wire   [31:0] m0_apb_wdata ;
wire   [31:0] m0_apb_rdata ;
wire   [3:0]  m0_apb_pstb  ;
wire          m0_apb_rready;

wire   [31:0] m1_apb_addr  ;
wire          m1_apb_sel   ;
wire          m1_apb_write ;
wire          m1_apb_ena   ;
wire   [31:0] m1_apb_wdata ;
wire   [31:0] m1_apb_rdata ;
wire   [3:0]  m1_apb_pstb  ;
wire          m1_apb_rready;

wire   [31:0] m2_apb_addr  ;
wire          m2_apb_sel   ;
wire          m2_apb_write ;
wire          m2_apb_ena   ;
wire   [31:0] m2_apb_wdata ;
wire   [31:0] m2_apb_rdata ;
wire   [3:0]  m2_apb_pstb  ;
wire          m2_apb_rready;


wire  [31:0] m3_apb_addr  ;
wire         m3_apb_sel   ;
wire         m3_apb_write ;
wire         m3_apb_ena   ;
wire  [31:0] m3_apb_wdata ;
wire  [31:0] m3_apb_rdata ;
wire  [3:0]  m3_apb_pstb  ;
wire         m3_apb_rready;


wire  [31:0] m4_apb_addr  ;
wire         m4_apb_sel   ;
wire         m4_apb_write ;
wire         m4_apb_ena   ;
wire  [31:0] m4_apb_wdata ;
wire  [31:0] m4_apb_rdata ;
wire  [3:0]  m4_apb_pstb  ;
wire         m4_apb_rready;



wire   [31:0] m5_apb_addr  ;
wire          m5_apb_sel   ;
wire          m5_apb_write ;
wire          m5_apb_ena   ;
wire   [31:0] m5_apb_wdata ;
wire   [31:0] m5_apb_rdata ;
wire   [3:0]  m5_apb_pstb  ;
wire          m5_apb_rready;

wire   [31:0] m6_apb_addr  ;
wire          m6_apb_sel   ;
wire          m6_apb_write ;
wire          m6_apb_ena   ;
wire   [31:0] m6_apb_wdata ;
wire   [31:0] m6_apb_rdata ;
wire   [3:0]  m6_apb_pstb  ;
wire          m6_apb_rready;


wire   [31:0] m7_apb_addr  ;
wire          m7_apb_sel   ;
wire          m7_apb_write ;
wire          m7_apb_ena   ;
wire   [31:0] m7_apb_wdata ;
wire   [31:0] m7_apb_rdata ;
wire   [3:0]  m7_apb_pstb  ;
wire          m7_apb_rready;

wire   [31:0] m8_apb_addr  ;
wire          m8_apb_sel   ;
wire          m8_apb_write ;
wire          m8_apb_ena   ;
wire   [31:0] m8_apb_wdata ;
wire   [31:0] m8_apb_rdata ;
wire   [3:0]  m8_apb_pstb  ;
wire          m8_apb_rready;

wire   [31:0] m9_apb_addr  ;
wire          m9_apb_sel   ;
wire          m9_apb_write ;
wire          m9_apb_ena   ;
wire   [31:0] m9_apb_wdata ;
wire   [31:0] m9_apb_rdata ;
wire   [3:0]  m9_apb_pstb  ;
wire          m9_apb_rready;

wire   [31:0] m10_apb_addr  ;
wire          m10_apb_sel   ;
wire          m10_apb_write ;
wire          m10_apb_ena   ;
wire   [31:0] m10_apb_wdata ;
wire   [31:0] m10_apb_rdata ;
wire   [3:0]  m10_apb_pstb  ;
wire          m10_apb_rready;



 assign spi_miso_i  =  spi_miso    ;
 assign spi_mosi    =  spi_mosi_o    ;
 assign spi_clk     =  spi_clk_o     ;
 assign spi_ssel[0] =  spi_ssel_o[0] ;
 assign spi_ssel[1] =  spi_ssel_o[1] ;

    
pipeline u_pipeline  (
        .clk             (clock),
        .rstn            (rst_n),
        
        .imem_addr       (imem_addr),
        .imem_rden       (imem_rden),
        .imem_rdata      (imem_rdata),
                     
                     
        .dmem_addr       (w_dmem_addr),
        .dmem_sel        (w_dmem_sel),
        .dmem_enable     (w_dmem_enable),
        .dmem_write      (w_dmem_write),
        .dmem_wstrb      (w_dmem_wstrb),
        .dmem_rdata      (w_dmem_rdata),
        .dmem_wdata      (w_dmem_wdata),
                     
        .ext_intr        (interrupt),
        .tmr_intr        (1'b0)
    
 );   
    
   
    
    
 mtime u_mtime (   
  .clock                (clock),
  .rst_n                (rst_n),
  .apb_addr             (m5_apb_addr ),
  .apb_sel              (m5_apb_sel  ),
  .apb_write            (m5_apb_write),
  .apb_ena              (m5_apb_ena  ),
  .apb_wdata            (m5_apb_wdata),
  .apb_rdata            (m5_apb_rdata),
  .apb_pstb             (m5_apb_pstb ),
  .apb_rready           (),
  .tmr_intr_out         (tmr_intr)
  );  

 apbuart1 u_uart_0 (  
   .clock               (clock),
   .reset               (rst_n),
   .io_PCLK             (clock),
   .io_PRESETn          (rst_n),
   .io_PADDR            (m1_apb_addr),
   .io_PPROT            (1'b0),
   .io_PSEL             (m8_apb_sel),
   .io_PENABLE          (m8_apb_ena),
   .io_PWRITE           (m8_apb_write),
   .io_PWDATA           (m8_apb_wdata),
   .io_PSTRB            (m8_apb_pstb),
   .io_PREADY           (),
   .io_PRDATA           (m8_apb_rdata),
   .io_PSLVERR          (),
   .io_interrupt        (),
   .io_txd              (uart0_txd),
   .io_rxd              (uart0_rxd),
   .io_out1             (),
   .io_out2             (),
   .io_rtsn             (),
   .io_dtrn             (),
   .io_ctsn             (1'b0),
   .io_dcdn             (1'b0),
   .io_dsrn             (1'b0),
   .io_rin              (1'b0),
   .io_divisor          (),
   .io_baudreg_tx       (),
   .io_baudcount_tx     (),
   .io_baudcycle_tx     ()
 );
 
 
 
 wire uartshort;
  apbuart u_uart_1 (  
   .clock               (clock),
   .reset               (rst_n),
   .io_PCLK             (clock),
   .io_PRESETn          (rst_n),
   .io_PADDR            (m2_apb_addr),
   .io_PPROT            (1'b0),
   .io_PSEL             (m2_apb_sel),
   .io_PENABLE          (m2_apb_ena),
   .io_PWRITE           (m2_apb_write),
   .io_PWDATA           (m2_apb_wdata),
   .io_PSTRB            (m2_apb_pstb),
   .io_PREADY           (),
   .io_PRDATA           (m2_apb_rdata),
   .io_PSLVERR          (),
   .io_interrupt        (),
   .io_txd              (uart1_txd),
   .io_rxd              (uart1_rxd),
   .io_out1             (),
   .io_out2             (),
   .io_rtsn             (),
   .io_dtrn             (),
   .io_ctsn             (1'b0),
   .io_dcdn             (1'b0),
   .io_dsrn             (1'b0),
   .io_rin              (1'b0),
   .io_divisor          (),
   .io_baudreg_tx       (),
   .io_baudcount_tx     (),
   .io_baudcycle_tx     ()
 );
 
 
 
apbspi u_apbspi ( 
   .clock               (clock),
   .reset               (!rst_n),
   .io_PCLK             (clock),
   .io_PRESETn          (rst_n),
   .io_PADDR            (m3_apb_addr),
   .io_PPROT            (1'b0),
   .io_PSEL             (m3_apb_sel),
   .io_PENABLE          (m3_apb_ena),
   .io_PWRITE           (m3_apb_write),
   .io_PWDATA           (m3_apb_wdata),
   .io_PSTRB            (m3_apb_pstb),
   .io_PREADY           (),
   .io_PRDATA           (m3_apb_rdata),
   .io_PSLVERR          (),
   .io_interrupt        (spi_intr),
   .io_mosi_i           (1'b0     ),
   .io_mosi_o           (spi_mosi_o     ),
   .io_mosi_t           (     ),
   .io_miso_i           (spi_miso_i     ),
   .io_miso_o           (     ),
   .io_miso_t           (     ),
   .io_spi_clk_o        (spi_clk_o  ),
   .io_spi_clk_i        (1'b0  ),
   .io_spi_clk_t        (  ),
   .io_spi_ssel_o       (spi_ssel_o ),
   .io_spi_ssel_i       (1'b0 ),
   .io_spi_ssel_t       ( )
 );
 

 apb_crossbar u_apb_crossbar (
 .s_apb_addr   (w_dmem_addr),
 .s_apb_sel    (w_dmem_sel),
 .s_apb_write  (w_dmem_write),
 .s_apb_ena    (w_dmem_enable),
 .s_apb_wdata  (w_dmem_wdata),
 .s_apb_rdata  (w_dmem_rdata),
 .s_apb_pstb   (w_dmem_wstrb),
 .s_apb_rready (),
              
 .m0_apb_addr   (m0_apb_addr  ),
 .m0_apb_sel    (m0_apb_sel   ),
 .m0_apb_write  (m0_apb_write ),
 .m0_apb_ena    (m0_apb_ena   ),
 .m0_apb_wdata  (m0_apb_wdata ),
 .m0_apb_rdata  (m0_apb_rdata ),
 .m0_apb_pstb   (m0_apb_pstb  ),
 .m0_apb_rready (1'b1),
               
 .m1_apb_addr   (m1_apb_addr ),
 .m1_apb_sel    (m1_apb_sel  ),
 .m1_apb_write  (m1_apb_write),
 .m1_apb_ena    (m1_apb_ena  ),
 .m1_apb_wdata  (m1_apb_wdata),
 .m1_apb_rdata  (m1_apb_rdata),
 .m1_apb_pstb   (m1_apb_pstb ),
 .m1_apb_rready (1'b1),
               
 .m2_apb_addr   (m2_apb_addr ),
 .m2_apb_sel    (m2_apb_sel  ),
 .m2_apb_write  (m2_apb_write),
 .m2_apb_ena    (m2_apb_ena  ),
 .m2_apb_wdata  (m2_apb_wdata),
 .m2_apb_rdata  (m2_apb_rdata),
 .m2_apb_pstb   (m2_apb_pstb ),
 .m2_apb_rready (1'b1),
               
               
 .m3_apb_addr   (m3_apb_addr ),
 .m3_apb_sel    (m3_apb_sel  ),
 .m3_apb_write  (m3_apb_write),
 .m3_apb_ena    (m3_apb_ena  ),
 .m3_apb_wdata  (m3_apb_wdata),
 .m3_apb_rdata  (m3_apb_rdata),
 .m3_apb_pstb   (m3_apb_pstb ),
 .m3_apb_rready (1'b1),
               
               
 .m4_apb_addr   (m4_apb_addr ),
 .m4_apb_sel    (m4_apb_sel  ),
 .m4_apb_write  (m4_apb_write),
 .m4_apb_ena    (m4_apb_ena  ),
 .m4_apb_wdata  (m4_apb_wdata),
 .m4_apb_rdata  (m4_apb_rdata),
 .m4_apb_pstb   (m4_apb_pstb ),
 .m4_apb_rready (1'b1),
 
 .m5_apb_addr   (m5_apb_addr ),
 .m5_apb_sel    (m5_apb_sel  ),
 .m5_apb_write  (m5_apb_write),
 .m5_apb_ena    (m5_apb_ena  ),
 .m5_apb_wdata  (m5_apb_wdata),
 .m5_apb_rdata  (m5_apb_rdata),
 .m5_apb_pstb   (m5_apb_pstb ),
 .m5_apb_rready (1'b1),
 
  .m6_apb_addr   (m6_apb_addr ),
 .m6_apb_sel    (m6_apb_sel  ),
 .m6_apb_write  (m6_apb_write),
 .m6_apb_ena    (m6_apb_ena  ),
 .m6_apb_wdata  (m6_apb_wdata),
 .m6_apb_rdata  (m6_apb_rdata),
 .m6_apb_pstb   (m6_apb_pstb ),
 .m6_apb_rready (1'b1),
 
 .m7_apb_addr   (m7_apb_addr ),
 .m7_apb_sel    (m7_apb_sel  ),
 .m7_apb_write  (m7_apb_write),
 .m7_apb_ena    (m7_apb_ena  ),
 .m7_apb_wdata  (m7_apb_wdata),
 .m7_apb_rdata  (m7_apb_rdata),
 .m7_apb_pstb   (m7_apb_pstb ),
 .m7_apb_rready (1'b1),
 
 .m8_apb_addr   (m8_apb_addr ),
 .m8_apb_sel    (m8_apb_sel  ),
 .m8_apb_write  (m8_apb_write),
 .m8_apb_ena    (m8_apb_ena  ),
 .m8_apb_wdata  (m8_apb_wdata),
 .m8_apb_rdata  (32'h00000000),
 .m8_apb_pstb   (m8_apb_pstb ),
 .m8_apb_rready (1'b1),
 
 .m9_apb_addr   (m9_apb_addr ),
 .m9_apb_sel    (m9_apb_sel  ),
 .m9_apb_write  (m9_apb_write),
 .m9_apb_ena    (m9_apb_ena  ),
 .m9_apb_wdata  (m9_apb_wdata),
 .m9_apb_rdata  (m9_apb_rdata),
 .m9_apb_pstb   (m9_apb_pstb ),
 .m9_apb_rready (1'b1),
 
 .m10_apb_addr   (m10_apb_addr ),
 .m10_apb_sel    (m10_apb_sel  ),
 .m10_apb_write  (m10_apb_write),
 .m10_apb_ena    (m10_apb_ena  ),
 .m10_apb_wdata  (m10_apb_wdata),
 .m10_apb_rdata  (32'h00000000),
 .m10_apb_pstb   (m10_apb_pstb ),
 .m10_apb_rready (1'b1)
 

 
 );
 
 /*
 
  LedBehav u_LedBehav(
  .clock            (clock),
  .reset            (rst_n),
  .io_PCLK          (clock),
  .io_PRESETn       (rst_n),
  .io_PADDR         (m8_apb_addr[7:0]),
  .io_PPROT         (1'b0),
  .io_PSEL          (m8_apb_sel),
  .io_PENABLE       (m8_apb_ena),
  .io_PWRITE        (m8_apb_write),
  .io_PWDATA        (m8_apb_wdata),
  .io_PSTRB         (4'h0),
  .io_PREADY        (m8_apb_rready),
  .io_PRDATA        (m8_apb_rdata),
  .io_PSLVERR       (),
  .io_LEDOUT        (ledo)
  );
 
*/
 assign led = 1'b0;
 
 
 plic u_plic(
 .clock        (clock),
 .rst_n        (rst_n),
 .apb_addr     (m4_apb_addr ),
 .apb_sel      (m4_apb_sel  ),
 .apb_write    (m4_apb_write),
 .apb_ena      (m4_apb_ena  ),
 .apb_wdata    (m4_apb_wdata),
 .apb_rdata    (m4_apb_rdata),
 .apb_pstb     (m4_apb_pstb ),
 .apb_rready   ( ),
 .intr_in      (peri_intr),
 .intr_out     (interrupt)
 
 );
 

 
 wire gpio_intr;
 
 gpio_ssp u_gpio_ssp (
    .clock        (clock),
    .rst_n        (rst_n),
    .apb_addr     (m6_apb_addr ),
    .apb_sel      (m6_apb_sel  ),
    .apb_write    (m6_apb_write),
    .apb_ena      (m6_apb_ena  ),
    .apb_wdata    (m6_apb_wdata),
    .apb_rdata    (m6_apb_rdata),
    .apb_pstb     (m6_apb_pstb ),
    .apb_rready   (),
    .gpio_intr    (gpio_intr),
                 
    .gpi          (32'h0000_0000),
    .gpo          (gpo_w),
    .gpd          ()
  
 
 );
 
 
 assign uart1_intr = 1'b0;
 assign peri_intr = {1'b0,gpio_intr,spi_intr,uart1_intr,1'b0};

 
 wire [3:0] mem_w;
 wire [3:0] mem1_w;
 wire mem1_ena;
  
 assign mem_w = m0_apb_write && m0_apb_sel ? m0_apb_pstb : 4'b0000;
 assign mem1_w = m1_apb_write && m1_apb_sel ? m1_apb_pstb : 4'b0000;
 wire mem_ena = m0_apb_write && m0_apb_sel;
 
 assign mem1_ena = m1_apb_write && m1_apb_sel;
 
 
 

  wire [31:0] ram_idata;
ram_64KB u_ram_64KB (
//.rst_n(rst_n),
.doa(ram_idata),
.dob(m1_apb_rdata),
.dia(32'h00000000),
.dib(m1_apb_wdata),
.addra(imem_addr[15:2]),
.addrb(m1_apb_addr[15:2]),
.wea(4'h0),
.web(mem1_w),
.clka(clock),
.clkb(clock)

);  
  
    
  /*
  
 ram_1KB  u_ram_1KB(
 
 .clock(clock),
 .rst_n(rst_n),
 
 .addr_2(m0_apb_addr[9:2]),
 .dataw_2(m0_apb_wdata),
 .we_2(mem_ena),
 .ena_2(1'b1),
 .wmask_2(mem_w),
 .datar_2(m0_apb_rdata)


 );
 
  */
  
wire [31:0] rom_idata;
 rom u_rom( 
	.clock  (clock),
	.rstn   (rst_n),
	.addr1   (imem_addr[15:2]),
	.ena1    (1'b1),
	.rdata1  (rom_idata),
	
	.addr2  (m0_apb_addr[15:2]),
	.ena2   (m0_apb_sel),
	.rdata2 (m0_apb_rdata),
	.wdata2 (m0_apb_wdata),
	.wen2   (m0_apb_pstb)
	
	);
	
 assign imem_rdata = (imem_addr >=  32'h0000_0000) && (imem_addr <= 32'h0000_FFFF) ? rom_idata : ram_idata;
 
 
 
 pwm u_pwm (
 
    .clock      (clock), 
    .rstn       (rst_n),
    .apb_addr   (m9_apb_addr),
    .apb_sel    (m9_apb_sel),
    .apb_write  (m9_apb_write),
    .apb_ena    (m9_apb_ena),
    .apb_wdata  (m9_apb_wdata),
    .apb_rdata  (m9_apb_rdata),
    .apb_pstb   (m9_apb_pstb),
    .apb_rready (), 
    .pwm_o      (pwm_o)
 
 
 );
 
 
 
  
 wand scl,sda;
 
 assign scl = sclt ? 1'b1 : sclo;
 assign sda = sdat ? 1'b1 : sclo;
 
 assign scl_io = scl;
 assign sda_io = sda;
 
 wire [7:0] i2cread;
 wire [7:0] i2cwdata;
 
 assign m7_apb_rdata = {i2cread,i2cread,i2cread,i2cread};
 assign  i2cwdata    = (m7_apb_addr[1:0] == 2'b00) ? m7_apb_wdata[7:0] : 
                        (m7_apb_addr[1:0] == 2'b01) ? m7_apb_wdata[15:8] : 
                        (m7_apb_addr[1:0] == 2'b10) ? m7_apb_wdata[23:16] : 
                         m7_apb_wdata[31:24] ;
                        
 
 

 
 I2CBehav u_I2CBehav(
  .clock            (clock),
  .reset            (rst_n),
  .io_PCLK          (clock),
  .io_PRESETn       (rst_n),
  .io_PADDR         (m7_apb_addr[7:0]),
  .io_PPROT         (1'b0),
  .io_PSEL          (m7_apb_sel),
  .io_PENABLE       (m7_apb_ena),
  .io_PWRITE        (m7_apb_write),
  .io_PWDATA        (i2cwdata),
  .io_PSTRB         (1'b0),
  .io_PREADY        (m7_apb_rready),
  .io_PRDATA        (i2cread),
  .io_PSLVERR       (),
  .io_irq           (),
  .io_sda_t         (sdat),
  .io_sda_o         (sdao),
  .io_sda_i         (sda_io),
  .io_scl_t         (sclt),
  .io_scl_o         (sclo),
  .io_scl_i         (scl_io),
  .io_doOpcodeio    (),
  .io_iiccount      (),
  .io_txbitc        (),
  .io_readl         (),
  .io_txcio         (),
  .io_rxcio         (),
  .io_startsentio   (),
  .io_stopsentio    (),
  .io_rstartsentio  (),
  .io_nackio        ()
 );

 

  
 endmodule
