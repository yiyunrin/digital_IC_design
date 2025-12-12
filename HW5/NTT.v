module NTT(
    input         clk, 
    input         rst, 
    output        input_ready,
    input         input_valid,
    input  [22:0] input_data,
    output [7:0]  tf_addr,
    input  [22:0] tf_data,
    output reg       output_valid,
    output reg [22:0] output_data
);

reg [22:0] memory [0:255];
reg [7:0] m, len;
reg [8:0] cnt, start, j, output_cnt;


wire [8:0] end_start; 
wire [22:0] X, Y, A, B; 
wire bu_ok, read_ok, output_ok;

reg state_wait; 

BU bu(.X(X), .Y(Y), .TF(tf_data), .A(A), .B(B));

always @(posedge clk)
begin
    if(rst || output_ok)
    begin
        cnt <= 0;
        m <= 0;
        len <= 128;
        start <= 0;
        j <= 0;
        output_cnt <= 0;
        state_wait <= 0;
        output_valid <= 0;
    end
    else if(input_ready)
    begin
        memory[cnt] <= input_data;
        cnt <= cnt + 1;
    end
    else if(!bu_ok)
    begin
        if(start >= 256)
        begin
            start <= 0;
            len <= (len >> 1);
            m <= m + 1;
            j <= 0;
            state_wait <= 1;
        end
        else
        begin
            if(j > end_start) 
            begin
                start <= start + (len << 1);
                j <= start + (len << 1);
                
                if ((start + (len << 1)) < 256) 
                begin
                    m <= m + 1;
                    state_wait <= 1;
                end
            end
            else
            begin
                if (state_wait) 
                begin
                    state_wait <= 0;
                end
                else 
                begin
                    memory[j] <= A;
                    memory[j + len] <= B;
                    j <= j + 1;
                end
            end
        end
    end
    else
    begin
        output_valid <= 1;
        output_data <= memory[output_cnt];
        output_cnt <= output_cnt + 1;
    end
end

assign bu_ok = len < 1;
assign read_ok = cnt >= 256;
assign input_ready = input_valid && !read_ok;
assign tf_addr = m + 1;
assign end_start = start + len - 1;
assign X = memory[j];
assign Y = memory[j + len];
// assign output_valid = bu_ok && output_cnt < 256;
assign output_ok = output_cnt >= 256;

endmodule