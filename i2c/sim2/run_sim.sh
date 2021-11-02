./do.sh
iverilog -s I2CBehav_tb -o design -c verilog.list
vvp design
gtkwave *.vcd
