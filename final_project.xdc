## Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

## Buttons
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN T17 [get_ports start]
set_property IOSTANDARD LVCMOS33 [get_ports start]

# switches
# set_property PACKAGE_PIN V17 [get_ports {box[0]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {box[0]}]
# set_property PACKAGE_PIN V16 [get_ports {box[1]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {box[1]}]
# set_property PACKAGE_PIN W16 [get_ports {box[2]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {box[2]}]
# set_property PACKAGE_PIN W17 [get_ports {box[3]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {box[3]}]
# set_property PACKAGE_PIN W15 [get_ports {box[4]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {box[4]}]
# set_property PACKAGE_PIN V15 [get_ports {box[5]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {box[5]}]
# set_property PACKAGE_PIN W14 [get_ports {box[6]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {box[6]}]
# set_property PACKAGE_PIN W13 [get_ports {box[7]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {box[7]}]
# set_property PACKAGE_PIN V2 [get_ports {box[8]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {box[8]}]
# set_property PACKAGE_PIN T3 [get_ports {sw[9]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {sw[9]}]
# set_property PACKAGE_PIN T2 [get_ports {sw[10]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {sw[10]}]
# set_property PACKAGE_PIN R3 [get_ports {sw[11]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {sw[11]}]
# set_property PACKAGE_PIN W2 [get_ports {sw[12]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {sw[12]}]
# set_property PACKAGE_PIN U1 [get_ports {sw[13]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {sw[13]}]
# set_property PACKAGE_PIN T1 [get_ports {sw[14]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {sw[14]}]
set_property PACKAGE_PIN R2 [get_ports {super}]
   set_property IOSTANDARD LVCMOS33 [get_ports {super}]

## VGA Connector
set_property PACKAGE_PIN G19 [get_ports {vgaRed[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[0]}]
set_property PACKAGE_PIN H19 [get_ports {vgaRed[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[1]}]
set_property PACKAGE_PIN J19 [get_ports {vgaRed[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[2]}]
set_property PACKAGE_PIN N19 [get_ports {vgaRed[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[3]}]
set_property PACKAGE_PIN N18 [get_ports {vgaBlue[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[0]}]
set_property PACKAGE_PIN L18 [get_ports {vgaBlue[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[1]}]
set_property PACKAGE_PIN K18 [get_ports {vgaBlue[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[2]}]
set_property PACKAGE_PIN J18 [get_ports {vgaBlue[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[3]}]
set_property PACKAGE_PIN J17 [get_ports {vgaGreen[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[0]}]
set_property PACKAGE_PIN H17 [get_ports {vgaGreen[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[1]}]
set_property PACKAGE_PIN G17 [get_ports {vgaGreen[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[2]}]
set_property PACKAGE_PIN D17 [get_ports {vgaGreen[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[3]}]
set_property PACKAGE_PIN P19 [get_ports hsync]
set_property IOSTANDARD LVCMOS33 [get_ports hsync]
set_property PACKAGE_PIN R19 [get_ports vsync]
set_property IOSTANDARD LVCMOS33 [get_ports vsync]

# LEDs
set_property PACKAGE_PIN U16 [get_ports {box_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {box_out[0]}]
set_property PACKAGE_PIN E19 [get_ports {box_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {box_out[1]}]
set_property PACKAGE_PIN U19 [get_ports {box_out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {box_out[2]}]
set_property PACKAGE_PIN V19 [get_ports {box_out[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {box_out[3]}]
set_property PACKAGE_PIN W18 [get_ports {box_out[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {box_out[4]}]
set_property PACKAGE_PIN U15 [get_ports {box_out[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {box_out[5]}]
set_property PACKAGE_PIN U14 [get_ports {box_out[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {box_out[6]}]
set_property PACKAGE_PIN V14 [get_ports {box_out[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {box_out[7]}]
set_property PACKAGE_PIN V13 [get_ports {box_out[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {box_out[8]}]
# set_property PACKAGE_PIN V3 [get_ports {LED[9]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {LED[9]}]
# set_property PACKAGE_PIN W3 [get_ports {LED[10]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {LED[10]}]
# set_property PACKAGE_PIN U3 [get_ports {LED[11]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {LED[11]}]
# set_property PACKAGE_PIN P3 [get_ports {LED[12]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {LED[12]}]
# set_property PACKAGE_PIN N3 [get_ports {LED[13]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {LED[13]}]
# set_property PACKAGE_PIN P1 [get_ports {LED[14]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {LED[14]}]
# set_property PACKAGE_PIN L1 [get_ports {start_op}]
# set_property IOSTANDARD LVCMOS33 [get_ports {start_op}]

# real boxes
## Sch name = JA1
set_property PACKAGE_PIN J1 [get_ports {box[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {box[0]}]
set_property PULLUP TRUE [get_ports {box[0]}]
## Sch name = JA2
set_property PACKAGE_PIN L2 [get_ports {box[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {box[1]}]
set_property PULLUP TRUE [get_ports {box[1]}]
## Sch name = JA3
set_property PACKAGE_PIN J2 [get_ports {box[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {box[2]}]
set_property PULLUP TRUE [get_ports {box[2]}]
## Sch name = JA4
set_property PACKAGE_PIN G2 [get_ports {box[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {box[3]}]
set_property PULLUP TRUE [get_ports {box[3]}]
## Sch name = JA7
set_property PACKAGE_PIN H1 [get_ports {box[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {box[4]}]
set_property PULLUP TRUE [get_ports {box[4]}]
## Sch name = JA8
set_property PACKAGE_PIN K2 [get_ports {box[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {box[5]}]
set_property PULLUP TRUE [get_ports {box[5]}]
## Sch name = JA9
set_property PACKAGE_PIN H2 [get_ports {box[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {box[6]}]
set_property PULLUP TRUE [get_ports {box[6]}]
## Sch name = JA10
set_property PACKAGE_PIN G3 [get_ports {box[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {box[7]}]
set_property PULLUP TRUE [get_ports {box[7]}]

## Pmod Header JB
set_property PACKAGE_PIN A14 [get_ports {music[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {music[0]}]
set_property PACKAGE_PIN A16 [get_ports {music[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {music[1]}]
set_property PACKAGE_PIN B15 [get_ports {music[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {music[2]}]
set_property PACKAGE_PIN B16 [get_ports {music[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {music[3]}]
## Sch name = JB7
# set_property PACKAGE_PIN A15 [get_ports {JB[4]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {JB[4]}]
## Sch name = JB8
# set_property PACKAGE_PIN A17 [get_ports {JB[5]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {JB[5]}]
## Sch name = JB9
# set_property PACKAGE_PIN C15 [get_ports {JB[6]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {JB[6]}]
## Sch name = JB10
set_property PACKAGE_PIN C16 [get_ports {box[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {box[8]}]
set_property PULLUP TRUE [get_ports {box[8]}]
# set_property PACKAGE_PIN C16 [get_ports {JB[7]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {JB[7]}]

## Pmod Header JC
## Sch name = JC1
# set_property PACKAGE_PIN K17 [get_ports {box[8]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {box[8]}]
# set_property PULLUP TRUE [get_ports {box[8]}]
## Sch name = JC2
# set_property PACKAGE_PIN M18 [get_ports {box[8]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {box[8]}]
# set_property PULLUP TRUE [get_ports {box[8]}]
# set_property PACKAGE_PIN M18 [get_ports {JC[1]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {JC[1]}]
## Sch name = JC3
# set_property PACKAGE_PIN N17 [get_ports {JC[2]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {JC[2]}]
## Sch name = JC4
# set_property PACKAGE_PIN P18 [get_ports {JC[3]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {JC[3]}]
## Sch name = JC7
# set_property PACKAGE_PIN L17 [get_ports {JC[4]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {JC[4]}]
## Sch name = JC8
# set_property PACKAGE_PIN M19 [get_ports {JC[5]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {JC[5]}]
## Sch name = JC9
# set_property PACKAGE_PIN P17 [get_ports {JC[6]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {JC[6]}]
## Sch name = JC10
# set_property PACKAGE_PIN R18 [get_ports {JC[7]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {JC[7]}]

## Pmod Header JXADC
## Sch name = XA1_P
# set_property PACKAGE_PIN J3 [get_ports {JXADC[0]}]
#    set_property IOSTANDARD LVCMOS33 [get_ports {JXADC[0]}]

## Configuration options
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]