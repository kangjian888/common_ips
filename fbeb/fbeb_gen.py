import pandas as pd
import sys
import os
import re
from datetime import datetime
import getpass
import argparse
import math


def main():
        parser = argparse.ArgumentParser(description='command paramteres')
        parser.add_argument('--fifo_depth', '-d', type=int, help='fifo depth',default=8)
        parser.add_argument('--fifo_width', '-w', type=int, help='fifo width', default=8)
        args = parser.parse_args()
        print("Welcome to use hbeb generator") 
        print(args) 
        fifo_depth = args.fifo_depth
        fifo_width = args.fifo_width
        if(fifo_depth == 1):
            print("the minimum number of depth is 2, or you can generate peb or beb")
            sys.exit()
        else:
            fbeb_gen(fifo_depth,fifo_width)  


def fbeb_gen(fifo_depth,fifo_width):
    point_width = math.ceil(math.log2(fifo_depth))
    print(point_width)
    print("full bandwidth elastic buffer generate ...")
    output_file= "fbeb_gen.sv"
    fp = open(output_file,'w')
    print_line = []
    header(print_line,output_file,fifo_width,fifo_depth)
    print_line.append("module fbeb_gen (")
    print_line.append("input clk,")
    print_line.append("input rst_n")
    print_line.append("input upstream_vld,")
    print_line.append("output upstream_rdy,")
    print_line.append("input ["+str(fifo_width-1)+":0] upstream_data,")
    print_line.append("output downstream_vld,")
    print_line.append("input downstream_rdy,")
    print_line.append("output reg ["+str(fifo_width-1)+":0] downstream_data")
    print_line.append(");")
    print_line.append("wire push;")
    print_line.append("wire pop;")
    print_line.append("assign push = upstream_vld && upstream_rdy;")
    print_line.append("assign pop = downstream_vld && downstream_rdy;")
    print_line.append("\n")
    print_line.append("//tail and head pointer generation")
    print_line.append("reg ["+str(point_width)+":0] tail;")
    print_line.append("reg ["+str(point_width)+":0] head;")
    print_line.append("always_ff @( posedge clk or negedge rst_n ) begin : point_gen")
    print_line.append("    if(rst_n) begin")
    print_line.append("        head <= 'd0;")
    print_line.append("        tail <= 'd0;")
    print_line.append("    end")
    print_line.append("    else begin")
    print_line.append("        if(push) begin")
    print_line.append("            if(tail <= "+str(point_width)+"'d"+str(fifo_depth-1)+") begin")
    print_line.append("                tail <= tail + 1'b1; ")
    print_line.append("            end")
    print_line.append("            else begin")
    print_line.append("                tail <= 'd0;")
    print_line.append("            end")
    print_line.append("        end")
    print_line.append("        if(pop) begin")
    print_line.append("            if(head <= "+str(point_width)+"'d"+str(fifo_depth-1)+") begin")
    print_line.append("                head <= head + 1'b1;")
    print_line.append("            end")
    print_line.append("            else begin ")
    print_line.append("                head <= 'd0;")
    print_line.append("            end")
    print_line.append("        end")
    print_line.append("    end")
    print_line.append("end")
    print_line.append("wire ["+str(fifo_depth-1)+":0] upstream_vld_demux;")
    print_line.append("alwasys_comb begin:vld_demux_logic")
    print_line.append("case(tail)")
    for hbeb_num in range(0,fifo_depth):
         print_line.append("    "+str(point_width)+"'b"+str(hbeb_num)+":")
         for demux_num in range(0,fifo_depth):
            if(demux_num == hbeb_num):
                print_line.append("        upstream_vld_demux["+str(demux_num)+"] = upstream_vld;")
            else:
                 print_line.append("        upstream_vld_demux["+str(demux_num)+"] = 1'b0;")

    print_line.append("endcase")
    print_line.append("end")

    print_line.append("wire ["+str(fifo_depth-1)+":0] downstream_rdy_demux;")
    print_line.append("alwasys_comb begin:rdy_demux_logic")
    print_line.append("case(head)")
    for hbeb_num in range(0,fifo_depth):
         print_line.append("    "+str(point_width)+"'b"+str(hbeb_num)+":")
         for demux_num in range(0,fifo_depth):
            if(demux_num == hbeb_num):
                print_line.append("        downstream_rdy_demux["+str(demux_num)+"] = downstream_rdy;")
            else:
                 print_line.append("        downstream_rdy_demux["+str(demux_num)+"] = 1'b0;")

    print_line.append("endcase")
    print_line.append("end")    

    print_line.append("wire ["+str(fifo_depth-1)+":0]["+str(fifo_width-1)+":0] downstream_data_src;")

    print_line.append("wire ["+str(fifo_depth-1)+":0] upstream_rdy_src;")
    print_line.append("wire ["+str(fifo_depth-1)+":0] downstream_vld_src;")
    for hbeb_num in range(0,fifo_depth):
        print_line.append(" hbeb u_hbeb"+str(hbeb_num)+"(")
        print_line.append("    .DATA_WIDTH("+str(fifo_width)+")")
        print_line.append(")")
        print_line.append("(")
        print_line.append("    .clk(clk),")
        print_line.append("    .rst_n(rst_n),")
        print_line.append("    .upstream_vld(upstream_vld_demux["+str(hbeb_num)+"]),")
        print_line.append("    .upstream_rdy(upstream_rdy_src["+str(hbeb_num)+"]),")
        print_line.append("    .upstream_data(upstream_data),")
        print_line.append("    .downstream_vld(downstream_vld_src["+str(hbeb_num)+"]),")
        print_line.append("    .downstream_rdy(down_stream_rdy_demux["+str(hbeb_num)+"]),")
        print_line.append("    .downstream_data(downstream_data_src["+str(hbeb_num)+"])")
        print_line.append(");")

    print_line.append("assign downstream_data = downstream_data_src[head];")
    print_line.append("assign downstream_vld = |downstream_vld_src;")
    print_line.append("assign upstream_rdy = |upstream_rdy_src;")


#print the content into file
    for line in print_line:
        fp.write(line)
        fp.write('\n')
    fp.write('endmodule')
    fp.close()


# header{{{
def header(print_line, filename, fifo_width, fifo_depth):
    today = datetime.today()
    now = datetime.now()
    user = getpass.getuser()
    
    date1 = today.strftime("%Y/%m/%d")
    year = today.strftime("%Y")
    time = now.strftime("%H:%M")
    #print("date1 =", date1)
    #print("year =", year)
    #print("time =", time)
    #print(user)
    
    print_line.append("// +FHDR----------------------------------------------------------------------------")
    print_line.append("// Copyright (c) "+year+" Momenta.")
    print_line.append("// ALL RIGHTS RESERVED Worldwide")
    print_line.append("//         ")
    print_line.append("// Author        : "+user)
    print_line.append("// Email         : kevin.kang@momenta.ai")
    print_line.append("// Created On    : "+date1+" "+time)
    print_line.append("// Last Modified : "+date1+" "+time)
    print_line.append("// File Name     : "+filename)
    print_line.append("// Description   : this is full bandwidth elastic bufffer, the data width is "+str(fifo_width)+", the fifo depth is "+str(fifo_depth)+".")
    print_line.append("// ")
    print_line.append("// ---------------------------------------------------------------------------------")
    print_line.append("// Modification History:")
    print_line.append("// Date         By              Version                 Change Description")
    print_line.append("// ---------------------------------------------------------------------------------")
    print_line.append("// "+date1+"   "+user+"     1.0                     Original")
    print_line.append("// -FHDR----------------------------------------------------------------------------")

# }}} 
 #run main function       
if __name__ == "__main__":
    main()
