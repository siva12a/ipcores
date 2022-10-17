#./do.sh
iverilog -s descendSort_tb -o design -c verilog.list
vvp design
gtkwave *.vcd
