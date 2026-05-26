module logic_sender #(
    parameter CMT_delay = 5000
)(
    input  wire        fx2_ifclk,
    input  wire        reset_n,
    input  wire        start_send,
    input  wire [15:0] data_len,

    // RAM B口访问接口
    input  wire [7:0]  rd_data,
    output reg  [15:0] rd_addr,
    output reg         rd_en,

    // 输出到 UART发送
    output reg  [7:0]  data_byte,
    output reg         byte_send_en,

    output reg         busy,
    output reg         tx_done
);
    localparam S_IDLE  = 3'd0,
               S_HEAD1 = 3'd1,
               S_HEAD2 = 3'd2,
               S_LENH  = 3'd3,
               S_LENL  = 3'd4,
               S_READ  = 3'd5,
               S_TAIL  = 3'd6,
               S_WAIT  = 3'd7;

    reg [2:0]  state;
    reg [15:0] cnt;
    reg [15:0] delay_cnt;
    reg [7:0]  rd_buf;

    wire delay_done = (delay_cnt >= CMT_delay-1);

    always @(posedge fx2_ifclk or negedge reset_n) begin
        if(!reset_n) begin
            state        <= S_IDLE;
            rd_en        <= 0;
            rd_addr      <= 0;
            data_byte    <= 0;
            byte_send_en <= 0;
            busy         <= 0;
            delay_cnt    <= 0;
            tx_done      <= 0;
            cnt          <= 0;
            rd_buf       <= 0;
        end else begin
            byte_send_en <= 0;
            rd_en        <= 0;
            case(state)
                S_IDLE: begin
                    busy    <= 0;
                    tx_done <= 0;
                    if(start_send) begin
                        rd_addr <= 0;
                        cnt     <= 0;
                        busy    <= 1;
                        state   <= S_HEAD1;
                    end
                end
                S_HEAD1: begin
                    data_byte    <= 8'hAA;
                    byte_send_en <= 1;
                    delay_cnt    <= 0;
                    state        <= S_WAIT;
                    cnt          <= 1;
                end
                S_HEAD2: begin
                    data_byte    <= 8'h55;
                    byte_send_en <= 1;
                    delay_cnt    <= 0;
                    state        <= S_WAIT;
                    cnt          <= 2;
                end
                S_LENH: begin
                    data_byte    <= data_len[15:8];
                    byte_send_en <= 1;
                    delay_cnt    <= 0;
                    state        <= S_WAIT;
                    cnt          <= 3;
                end
                S_LENL: begin
                    data_byte    <= data_len[7:0];
                    byte_send_en <= 1;
                    delay_cnt    <= 0;
                    rd_en        <= 1;  // 预启动读 pipeline
                    state        <= S_WAIT;
                    cnt          <= 4;
                    rd_buf       <= rd_data;
                end
                S_READ: begin
                    // pipeline 读下一样本
                    rd_en        <= 1;
                    rd_addr      <= rd_addr + 1'b1;
                    rd_buf       <= rd_data;  // 上一周期输出的数据缓存
                    data_byte    <= rd_buf;
                    byte_send_en <= 1;
                    delay_cnt    <= 0;
                    cnt          <= cnt + 1;
                    if(cnt >= data_len + 3) begin
                        state <= S_TAIL;
                    end else
                        state <= S_WAIT;
                end
                S_TAIL: begin
                    data_byte    <= 8'hF0;
                    byte_send_en <= 1;
                    delay_cnt    <= 0;
                    state        <= S_IDLE;
                    cnt          <= cnt + 1;
                end
                S_WAIT: begin
						byte_send_en <= 0;
                    if(delay_done) begin
                        delay_cnt <= 0;
                        case(cnt)
                            1: state <= S_HEAD2;
                            2: state <= S_LENH;
                            3: state <= S_LENL;
                            4: state <= S_READ;
                            default: begin
                                if(cnt <= data_len + 4)
                                    state <= S_READ;
                                else if(cnt == data_len + 4)
                                    state <= S_TAIL;
                                else
                                    state <= S_IDLE;
                            end
                        endcase
                    end else begin
                        delay_cnt <= delay_cnt + 1;
                    end
                end
            endcase
        end
    end
endmodule