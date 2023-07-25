module fpa #(
    parameter REQ_NUM = 4,
    parameter DATA_WIDTH = 8

) (
    input [REQ_NUM*DATA_WIDTH-1:0] data_in,
    input [REQ_NUM-1:0] req,
    input [REQ_NUM-1:0] prio,//this is the thermometer code, the bit left the highest priority equal 1, and the bit right the highest prioriry equal 0. The highest priority bit equal 1.  
    output [REQ_NUM-1:0] gnt,
    output [REQ_NUM-1:0] gnt_thermometer,
    output [DATA_WIDTH-1:0] data_out
);
    
localparam TREE_LEVEL = $clog2(REQ_NUM)+1;
logic [2**(TREE_LEVEL-1)-2:0]                        sel;//when rightside is larger  or equal leftside, rightside is choose and this bit is set 0, when rightside is smaller than leftside, leftside is choose and this bit is set to 1
logic [2**TREE_LEVEL-2:0][DATA_WIDTH-1:0]            mux_data;
logic [2**TREE_LEVEL-2:0][1:0]                       mux_pri;
logic [TREE_LEVEL-1:0][2**(TREE_LEVEL-1)-1:0]       local_gnt;
logic [TREE_LEVEL-1:0][2**(TREE_LEVEL-1)-1:0]       local_gnt_thermometer;
generate
    genvar level;
    genvar node_idx;
    for(level= 0;unsigned'(level) <= TREE_LEVEL-1; level = level + 1) begin
        for (node_idx = 0;unsigned'(node_idx) <= 2**level-1 ; node_idx = node_idx + 1) begin
            localparam int unsigned src_idx_left  = 2**(level+1)-2 + 1 + node_idx*2 + 1;//current node left src index, exact value
            localparam int unsigned src_idx_right = 2**(level+1)-2 + 1 + node_idx*2 ;//current node right src index, exact value
            localparam int unsigned dst_idx       = 2**level-2 + 1 + node_idx;//current node dst  index
            if(level == TREE_LEVEL -1)begin //the first level, the src and dst of the node is all the input {req][i],prio[i]}
                assign local_gnt[level][node_idx] = 1'b1; //the first level local gnt value is all assigned to 1 
                if(dst_idx >= REQ_NUM) begin
                    assign mux_pri[dst_idx] = 2'd0;
                    assign mux_data[dst_idx] = {DATA_WIDTH{1'b0}};
                end
                else begin
                    assign mux_pri[dst_idx] = {req[dst_idx], prio[dst_idx]};
                    assign mux_data[dst_idx] = data_in[(node_idx+1)*DATA_WIDTH-1:node_idx*DATA_WIDTH];//assign input data to the mux tree
                end  
            end
            else begin
                assign sel[dst_idx]     = (mux_pri[src_idx_left] > mux_pri[src_idx_right]) ? 1'b1 : 1'b0;
                assign mux_pri[dst_idx] = sel ? mux_pri[src_idx_left] : mux_pri[src_idx_right]; 
                assign mux_data[dst_idx] = sel ? mux_data[src_idx_left] : mux_data[src_idx_right];
                assign local_gnt[level][(node_idx+1)*(2**(TREE_LEVEL-level-1))-1:(node_idx+1)*(2**(TREE_LEVEL-level-1))-(2**(TREE_LEVEL-level-1)/2)] = local_gnt[level+1][(node_idx+1)*(2**(TREE_LEVEL-level-1))-1:(node_idx+1)*(2**(TREE_LEVEL-level-1))-(2**(TREE_LEVEL-level-1)/2)] & {(2**(TREE_LEVEL-level-1)/2){sel[dst_idx]}};
                assign local_gnt[level][(node_idx+1)*(2**(TREE_LEVEL-level-1))-(2**(TREE_LEVEL-level-1)/2)-1:(node_idx+1)*(2**(TREE_LEVEL-level-1))-(2**(TREE_LEVEL-level-1))] = local_gnt[level][(node_idx+1)*(2**(TREE_LEVEL-level-1))-(2**(TREE_LEVEL-level-1)/2)-1:(node_idx+1)*(2**(TREE_LEVEL-level-1))-(2**(TREE_LEVEL-level-1))] & ~{(2**(TREE_LEVEL-level-1)/2){sel[dst_idx]}};
                assign local_gnt_thermometer[level][(node_idx+1)*(2**(TREE_LEVEL-level-1))-1:(node_idx+1)*(2**(TREE_LEVEL-level-1))-(2**(TREE_LEVEL-level-1)/2)] = local_gnt[level+1][(node_idx+1)*(2**(TREE_LEVEL-level-1))-1:(node_idx+1)*(2**(TREE_LEVEL-level-1))-(2**(TREE_LEVEL-level-1)/2)] & {(2**(TREE_LEVEL-level-1)/2){sel[dst_idx]}};
                assign local_gnt_thermometer[level][(node_idx+1)*(2**(TREE_LEVEL-level-1))-(2**(TREE_LEVEL-level-1)/2)-1:(node_idx+1)*(2**(TREE_LEVEL-level-1))-(2**(TREE_LEVEL-level-1))] = local_gnt[level][(node_idx+1)*(2**(TREE_LEVEL-level-1))-(2**(TREE_LEVEL-level-1)/2)-1:(node_idx+1)*(2**(TREE_LEVEL-level-1))-(2**(TREE_LEVEL-level-1))] | {(2**(TREE_LEVEL-level-1)/2){sel[dst_idx]}};
            end
        end
    end
endgenerate
//connect local_gnt to gnt
assign gnt = local_gnt[0][REQ_NUM-1:0];
assign gnt_thermometer = local_gnt_thermometer[REQ_NUM-1:0];
//connect mux_data to data_out
assign data_out = mux_data[0];

endmodule