//this module is full bandwidth elastic buffer
module fbeb#(
    parameter DEPTH = 8,
    parameter DATA_WIDTH = 8
)
(
    input clk,
    input rst_n,
    input upstream_vld,
    output upstream_rdy,
    input [DATA_WIDTH-1:0] upstream_data,
    output downstream_vld,
    input downstream_rdy,
    output reg [DATA_WIDTH-1:0] downstream_data
);
localparam POINT_WIDTH = $clog2(DEPTH);

wire push;
wire pop;

assign push = upstream_vld && upstream_rdy;
assign pop = downstream_vld && downstream_rdy;

//tail and head pointer generation
reg [POINT_WIDTH-1:0] tail;
reg [POINT_WIDTH-1:0] head;

always_ff @( posedge clk or negedge rst_n ) begin : point_gen
    if(~rst_n) begin
        head <= 'd0;
        tail <= 'd0;
    end
    else begin
        if(push) begin
            if(tail < DEPTH) begin
                tail <= tail + 1'b1; 
            end
            else begin
                tail <= 'd0;
            end
        end
        if(pop) begin
            if(head < DEPTH) begin
                head <= head + 1'b1;
            end
            else begin 
                head <= 'd0;
            end
        end
    end
end

wire [DEPTH-1:0] upstream_vld_demux;
genvar fifo_depth;
generate
    for (fifo_depth = 0; fifo_depth < DEPTH; fifo_depth = fifo_depth + 1) begin
        assign upstream_vld_demux[fifo_depth] = (tail == fifo_depth)? upstream_vld : 1'b0;
    end
endgenerate

wire [DEPTH-1:0] downstream_rdy_demux;
generate
    for (fifo_depth = 0; fifo_depth < DEPTH; fifo_depth = fifo_depth + 1) begin
        assign downstream_rdy_demux[fifo_depth] = (head == fifo_depth)? downstream_rdy : 1'b0;
    end
endgenerate

wire [DEPTH-1:0][DATA_WIDTH-1:0] downstream_data_src;
wire [DEPTH-1:0] upstream_rdy_src;
wire [DEPTH-1:0] downstream_vld_src;

generate
    for(fifo_depth = 0; fifo_depth < DEPTH; fifo_depth = fifo_depth + 1) begin
        hbeb #(
            .DATA_WIDTH(DEPTH))
        u_hbeb
    (
        .clk(clk),
        .rst_n(rst_n),
        .upstream_vld(upstream_vld_demux[fifo_depth]),
        .upstream_rdy(upstream_rdy_src[fifo_depth]),
        .upstream_data(upstream_data),
        .downstream_vld(downstream_vld_src[fifo_depth]),
        .downstream_rdy(downstream_rdy_demux[fifo_depth]),
        .downstream_data(downstream_data_src[fifo_depth])
    );
    end
endgenerate

assign downstream_data = downstream_data_src[head];
assign downstream_vld = |downstream_vld_src;
assign upstream_rdy = |upstream_rdy_src;


endmodule
