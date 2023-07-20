//this is the arbiter applying fix priority, this is the called 
//req is the request signal from input source
//gnt is the grant signal of all request from input source, this is a onehot code, 1 means the corresponding input is granted
//base is the input to define which input is has the highest priority, this is a onehot code, 1 means the corresponding input has the highest priority
module arbiter_fix_1 #(
    parameter REQ_NUM = 2
) (
    input [REQ_NUM-1:0] req,
    input [REQ_NUM-1:0] base,
    output [REQ_NUM-1:0] gnt
);

wire [2*REQ_NUM-1:0] double_req;
wire [2*REQ_NUM-1:0] double_gnt;

assign double_req = {req,req};
assign double_gnt = (~(double_req - base)) & double_req;
assign gnt = double_gnt[2*REQ_NUM-1:REQ_NUM] | double_gnt[REQ_NUM-1:0];
    
endmodule
