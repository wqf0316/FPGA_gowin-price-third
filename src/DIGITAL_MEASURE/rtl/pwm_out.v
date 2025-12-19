module pwm_out (
    input wire clk_50m,      // 50MHz时钟输入
    input wire rst_n,        // 低电平复位信号
    output reg pwm_out       // 输出方波信号
);

// 定义计数器最大值（50MHz / 10kHz = 5000）
parameter MAX_COUNT = 67770;
// 计算高电平时间（5000 * 34% = 1700）
parameter HIGH_TIME = 17000;

reg [19:0] count;  // 13位计数器（2^13=8192 > 5000）

always @(posedge clk_50m or negedge rst_n) begin
    if (~rst_n) begin
        count <= 0;
        pwm_out <= 0;
    end else begin
        if (count < MAX_COUNT - 1) begin
            count <= count + 1;
        end else begin
            count <= 0;
        end
        
        // 生成占空比34%的方波
        if (count < HIGH_TIME) begin
            pwm_out <= 1;
        end else begin
            pwm_out <= 0;
        end
    end
end

endmodule