//`include "FIFO_sync.v"
`timescale 1ns / 10ps
module FourBankFIFO(
    input           clk         ,
    input           rst         ,
    input           wr_en_M0    ,
    input  [7:0]    data_in_M0  ,
    input           rd_en_M0    ,
    input  [1:0]    rd_id_M0    ,
    input           wr_en_M1    ,
    input  [7:0]    data_in_M1  ,
    input           rd_en_M1    ,
    input  [1:0]    rd_id_M1    ,
    output reg [7:0]   data_out_M0 ,
    output reg [7:0]   data_out_M1 ,
    output reg         valid_M0    ,
    output reg         valid_M1
);

reg RR = 1;
reg [1:0]LRU = 0;
reg M0, M1;

reg [7:0]data_in[0:3];
reg wr_en[0:3], rd_en[0:3];
wire [7:0]data_out[0:3];
wire full[0:3], empty[0:3];

integer j;

genvar i;
generate
    for(i=0;i<4;i=i+1)
    begin: BANK_GENERATE
        FIFO_sync_2 bank(
            .clk(clk),
            .rst(rst),
            .wr_en   (wr_en[i]),
            .rd_en   (rd_en[i]),
            .data_in(data_in[i]),
            .full    (full[i]),
            .empty   (empty[i]),
            .data_out(data_out[i])
        );
    end
endgenerate

always @(posedge clk)
begin
    if(rst)
    begin
        RR = 1;
        LRU = 0;
        valid_M0 = 0;
        valid_M1 = 0;

        for(j=0;j<4;j=j+1)
        begin
            wr_en[j] = 0;
            rd_en[j] = 0;
            data_in[j] = 0;
        end
    end
    else
    begin
        valid_M0 = 0;
        valid_M1 = 0;
        for(j = 0;j < 4;j = j + 1)
        begin
            wr_en[j] = 0;
            rd_en[j] = 0;
        end
        M0 = wr_en_M0 || rd_en_M0;
        M1 = wr_en_M1 || rd_en_M1;

        if(M0 && M1)
        begin
            RR = !RR;
        end
        else if(M0)
        begin
            RR = 0;
        end
        else if(M1)
        begin
            RR = 1;
        end
        else
        begin
            RR = RR;
        end

        if(RR == 0)
        begin
            if(rd_en_M0)
            begin
                if(!empty[rd_id_M0])
                begin
                    valid_M0 = 1;
                    rd_en[rd_id_M0] = 1;
                    data_out_M0 = data_out[rd_id_M0];
                end
            end
            if(wr_en_M0)
            begin
                if(!full[LRU])
                begin
                    wr_en[LRU] = 1;
                    data_in[LRU] = data_in_M0;
                    LRU = LRU + 1;
                end
            end
        end
        else
        begin
            if(rd_en_M1)
            begin
                if(!empty[rd_id_M1])
                begin
                    valid_M1 = 1;
                    rd_en[rd_id_M1] = 1;
                    data_out_M1 = data_out[rd_id_M1];
                end
            end
            if(wr_en_M1)
            begin
                if(!full[LRU])
                begin
                    wr_en[LRU] = 1;
                    data_in[LRU] = data_in_M1;
                    LRU = LRU + 1;
                end
            end
        end
    end
end



endmodule

module FIFO_sync_2(
    input             clk     ,
    input             rst     ,
    input             wr_en   ,
    input             rd_en   ,
    input       [7:0] data_in ,
    output   reg         full    ,
    output   reg         empty   ,
    output   reg   [7:0] data_out
);


reg write, read;
integer count = 0;
reg [7:0] memory [0:31];
reg [4:0] first, now;


always @(negedge clk)
begin
    if(rst)
    begin
        count = 0;
        first = 0;
        now = 0;
    end
    else
    begin
        if(empty)
        begin
            //data_out = 0;
        end
        if(write && read)
        begin
            memory[now] = data_in;
            now = now + 1;
            //data_out = memory[first];
            first = first + 1;
        end
        else if(write)
        begin
            memory[now] = data_in;
            count = count + 1;
            now = now + 1;
        end
        else if(read)
        begin
            // data_out = memory[first];
            count = count - 1;
            first = first + 1;
        end
    end
end

always @(*)
begin
    full = (count == 32);
    empty = (count == 0);
    write = (!full) & wr_en;
    read = (!empty) & rd_en;
    data_out = memory[first];
end

endmodule