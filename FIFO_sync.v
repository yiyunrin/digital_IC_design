module FIFO_sync(
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


always @(posedge clk)
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
            data_out = 0;
        end
        if(write && read)
        begin
            memory[now] = data_in;
            now = now + 1;
            data_out = memory[first];
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
            data_out = memory[first];
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
end

endmodule