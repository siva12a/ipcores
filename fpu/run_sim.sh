
iverilog -s fpusssp -o design -c verilog.list
vvp design
gtkwave *.vcd
