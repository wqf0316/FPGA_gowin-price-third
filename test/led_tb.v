`timescale 1ns/1ns  // 定义仿真时间单位：单位1ns，精度1ns

module tb_led;

    // 1. 定义信号
    // 输入给模块的信号定义为 reg (因为我们需要在 tb 里给它赋值)
    reg clk;
    reg reset_;

    // 从模块输出的信号定义为 wire (我们要观察它的值)
    wire led1;
    wire led2;
    wire led3;
    wire led4;

    // 2. 实例化待测模块 (Unit Under Test)
    led u_led (
        .clk    (clk),
        .reset_ (reset_),
        .led1   (led1),
        .led2   (led2),
        .led3   (led3),
        .led4   (led4)
    );

    // 3. 生成时钟信号
    // 初始为0，每隔 5ns 翻转一次，周期为 10ns (即 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 4. 生成波形文件 (关键！用于 GTKWave)
    initial begin
        $dumpfile("wave.vcd");      // 指定波形文件名
        $dumpvars(0, tb_led);       // 导出 tb_led 模块下的所有信号
    end

    // 5. 测试逻辑 (Stimulus)
    initial begin
        // 初始化：复位无效 (高电平)
        reset_ = 1;
        
        // 打印表头，方便在终端看
        $display("Time\t Reset\t LED1\t LED2\t LED3\t LED4");
        $monitor("%0t\t %b\t %b\t %b\t %b\t %b", $time, reset_, led1, led2, led3, led4);

        // --- 开始测试 ---
        
        // 阶段1：按下复位 (Active Low)
        #10 reset_ = 0;   
        $display("--- Reset Applied ---");

        // 保持复位一段时间
        #20;

        // 阶段2：释放复位，开始工作
        reset_ = 1;
        $display("--- Reset Released ---");

        // 阶段3：让它跑 100ns，观察 LED 翻转
        #100;

        // 结束仿真
        $finish;
    end

endmodule