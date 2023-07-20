// +FHDR----------------------------------------------------------------------------
// Copyright (c) 2023 Momenta.
// ALL RIGHTS RESERVED Worldwide
//         
// Author        : kevin.kang
// Email         : kevin.kang@momenta.ai
// Created On    : 2023/07/14 09:51
// Last Modified : 2023/07/14 09:51
// File Name     : fbeb_gen.sv
// Description   : this is full bandwidth elastic bufffer, the data width is 8, the fifo depth is 5.
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2023/07/14   kevin.kang     1.0                     Original
// -FHDR----------------------------------------------------------------------------
module fbeb_gen (
input clk,
input rst_n
input upstream_vld,
output upstream_rdy,
input [7:0] upstream_data,
output downstream_vld,
input downstream_rdy,
output reg [7:0] downstream_data
);
wire push;
wire pop;
assign push = upstream_vld && upstream_rdy;
assign pop = downstream_vld && downstream_rdy;


//tail and head pointer generation
reg [3:0] tail;
reg [3:0] head;
always_ff @( posedge clk or negedge rst_n ) begin : point_gen
    if(rst_n) begin
        head <= 'd0;
        tail <= 'd0;
    end
    else begin
        if(push) begin
            if(tail <= 3'd4) begin
                tail <= tail + 1'b1; 
            end
            else begin
                tail <= 'd0;
            end
        end
        if(pop) begin
            if(head <= 3'd4) begin
                head <= head + 1'b1;
            end
            else begin 
                head <= 'd0;
            end
        end
    end
end
wire [4:0] upstream_vld_demux;
alwasys_comb begin:vld_demux_logic
case(tail)
    3'b0:
        upstream_vld_demux[0] = upstream_vld;
        upstream_vld_demux[1] = 1'b0;
        upstream_vld_demux[2] = 1'b0;
        upstream_vld_demux[3] = 1'b0;
        upstream_vld_demux[4] = 1'b0;
    3'b1:
        upstream_vld_demux[0] = 1'b0;
        upstream_vld_demux[1] = upstream_vld;
        upstream_vld_demux[2] = 1'b0;
        upstream_vld_demux[3] = 1'b0;
        upstream_vld_demux[4] = 1'b0;
    3'b2:
        upstream_vld_demux[0] = 1'b0;
        upstream_vld_demux[1] = 1'b0;
        upstream_vld_demux[2] = upstream_vld;
        upstream_vld_demux[3] = 1'b0;
        upstream_vld_demux[4] = 1'b0;
    3'b3:
        upstream_vld_demux[0] = 1'b0;
        upstream_vld_demux[1] = 1'b0;
        upstream_vld_demux[2] = 1'b0;
        upstream_vld_demux[3] = upstream_vld;
        upstream_vld_demux[4] = 1'b0;
    3'b4:
        upstream_vld_demux[0] = 1'b0;
        upstream_vld_demux[1] = 1'b0;
        upstream_vld_demux[2] = 1'b0;
        upstream_vld_demux[3] = 1'b0;
        upstream_vld_demux[4] = upstream_vld;
endcase
end
wire [4:0] downstream_rdy_demux;
alwasys_comb begin:rdy_demux_logic
case(head)
    3'b0:
        downstream_rdy_demux[0] = downstream_rdy;
        downstream_rdy_demux[1] = 1'b0;
        downstream_rdy_demux[2] = 1'b0;
        downstream_rdy_demux[3] = 1'b0;
        downstream_rdy_demux[4] = 1'b0;
    3'b1:
        downstream_rdy_demux[0] = 1'b0;
        downstream_rdy_demux[1] = downstream_rdy;
        downstream_rdy_demux[2] = 1'b0;
        downstream_rdy_demux[3] = 1'b0;
        downstream_rdy_demux[4] = 1'b0;
    3'b2:
        downstream_rdy_demux[0] = 1'b0;
        downstream_rdy_demux[1] = 1'b0;
        downstream_rdy_demux[2] = downstream_rdy;
        downstream_rdy_demux[3] = 1'b0;
        downstream_rdy_demux[4] = 1'b0;
    3'b3:
        downstream_rdy_demux[0] = 1'b0;
        downstream_rdy_demux[1] = 1'b0;
        downstream_rdy_demux[2] = 1'b0;
        downstream_rdy_demux[3] = downstream_rdy;
        downstream_rdy_demux[4] = 1'b0;
    3'b4:
        downstream_rdy_demux[0] = 1'b0;
        downstream_rdy_demux[1] = 1'b0;
        downstream_rdy_demux[2] = 1'b0;
        downstream_rdy_demux[3] = 1'b0;
        downstream_rdy_demux[4] = downstream_rdy;
endcase
end
wire [4:0][7:0] downstream_data_src;
wire [4:0] upstream_rdy_src;
wire [4:0] downstream_vld_src;
 hbeb u_hbeb0(
    .DATA_WIDTH(8)
)
(
    .clk(clk),
    .rst_n(rst_n),
    .upstream_vld(upstream_vld_demux[0]),
    .upstream_rdy(upstream_rdy_src[0]),
    .upstream_data(upstream_data),
    .downstream_vld(downstream_vld_src[0]),
    .downstream_rdy(down_stream_rdy_demux[0]),
    .downstream_data(downstream_data_src[0])
);
 hbeb u_hbeb1(
    .DATA_WIDTH(8)
)
(
    .clk(clk),
    .rst_n(rst_n),
    .upstream_vld(upstream_vld_demux[1]),
    .upstream_rdy(upstream_rdy_src[1]),
    .upstream_data(upstream_data),
    .downstream_vld(downstream_vld_src[1]),
    .downstream_rdy(down_stream_rdy_demux[1]),
    .downstream_data(downstream_data_src[1])
);
 hbeb u_hbeb2(
    .DATA_WIDTH(8)
)
(
    .clk(clk),
    .rst_n(rst_n),
    .upstream_vld(upstream_vld_demux[2]),
    .upstream_rdy(upstream_rdy_src[2]),
    .upstream_data(upstream_data),
    .downstream_vld(downstream_vld_src[2]),
    .downstream_rdy(down_stream_rdy_demux[2]),
    .downstream_data(downstream_data_src[2])
);
 hbeb u_hbeb3(
    .DATA_WIDTH(8)
)
(
    .clk(clk),
    .rst_n(rst_n),
    .upstream_vld(upstream_vld_demux[3]),
    .upstream_rdy(upstream_rdy_src[3]),
    .upstream_data(upstream_data),
    .downstream_vld(downstream_vld_src[3]),
    .downstream_rdy(down_stream_rdy_demux[3]),
    .downstream_data(downstream_data_src[3])
);
 hbeb u_hbeb4(
    .DATA_WIDTH(8)
)
(
    .clk(clk),
    .rst_n(rst_n),
    .upstream_vld(upstream_vld_demux[4]),
    .upstream_rdy(upstream_rdy_src[4]),
    .upstream_data(upstream_data),
    .downstream_vld(downstream_vld_src[4]),
    .downstream_rdy(down_stream_rdy_demux[4]),
    .downstream_data(downstream_data_src[4])
);
assign downstream_data = downstream_data_src[head];
assign downstream_vld = |downstream_vld_src;
assign upstream_rdy = |upstream_rdy_src;
endmodule