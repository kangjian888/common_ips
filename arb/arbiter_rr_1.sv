//this is the robin roll arbiter based on arbiter_fix_1, the base is updated based the last gnt result.
module arbiter_rr_1 #(
    parameter REQ_NUM = 2
) (
    input clk,
    input rst_n,
    input [REQ_NUM-1:0] req,
    input [REQ_NUM-1:0] base, //initial highest priority, onehot code. this value cannot be zero when rst_n is assert
    output [REQ_NUM-1:0] gnt

);

wire  [REQ_NUM-1:0] base_nxt;//next base value, right circule shift 1 bit with currtent grant values
wire [REQ_NUM-1:0] gnt_cur;
reg [REQ_NUM-1:0] base_cur;

assign base_nxt = {gnt_cur[0],gnt_cur[REQ_NUM-1:1]};
always_ff @(posedge clk or negedge rst_n ) begin : base_update_proc
    if (~rst_n) begin
        base_cur <=  base;
    end
    else begin
        base_cur <=  base_nxt;
    end
end

arbiter_fix_1 #(
    .REQ_NUM(REQ_NUM)
)
u_arbiter_fix_1 (
    .req(req),
    .base(base_cur),
    .gnt(gnt_cur)
);
assign gnt = gnt_cur;

endmodule