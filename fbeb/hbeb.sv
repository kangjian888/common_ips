//this module is half bandwidth elastic buffer
module hbeb #(
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

reg  full;

always_ff @( posedge clk or negedge rst_n ) begin : write_and_read
    if(~rst_n) begin
        full <= 2'd0;
        downstream_data <= {DATA_WIDTH{1'b0}};
    end
    else begin
        if(upstream_vld && full == 1'b0) begin
            full <= 1'b1;
            downstream_data <= upstream_data;
        end
        if(downstream_rdy && full == 1'b1) begin
            full <= 1'b0;
        end
    end
end

assign downstream_vld = full;
assign upstream_rdy = ~full;
endmodule