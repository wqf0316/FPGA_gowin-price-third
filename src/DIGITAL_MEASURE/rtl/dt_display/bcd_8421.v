module bcd_8421
(
    input   wire            sys_clk     ,   //系统时钟，频率50MHz
    input   wire            sys_rst_n   ,   //复位信号，低电平有效
    input   wire    [27:0]  data        ,   //输入需要转换的数据 (28位数据)

    output  reg     [3:0]   unit        ,   //个位BCD码
    output  reg     [3:0]   ten         ,   //十位BCD码
    output  reg     [3:0]   hun         ,   //百位BCD码
    output  reg     [3:0]   tho         ,   //千位BCD码
    output  reg     [3:0]   t_tho       ,   //万位BCD码
    output  reg     [3:0]   h_hun       ,   //十万位BCD码
    output  reg     [3:0]   million     ,   //百万位BCD码
    output  reg     [3:0]   t_million  		//千万位BCD码
);

//********************************************************************//
//******************** Parameter And Internal Signal *****************//
//********************************************************************//

//reg define
reg     [5:0]   cnt_shift   ;   //移位判断计数器 (修改为6位，支持28位数据)
reg     [59:0]  data_shift  ;   //移位判断数据寄存器 (48位，因为需要支持28位输入数据)
reg             shift_flag  ;   //移位判断标志信号

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//cnt_shift:从0到29循环计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_shift   <=  6'd0;
    else    if((cnt_shift == 6'd29) && (shift_flag == 1'b1)) //修改为28次移位
        cnt_shift   <=  6'd0;
    else    if(shift_flag == 1'b1)
        cnt_shift   <=  cnt_shift + 1'b1;
    else
        cnt_shift   <=  cnt_shift;

//data_shift：计数器为0时赋初值，计数器为1~28时进行移位判断操作
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_shift  <=  48'b0;
    else    if(cnt_shift == 6'd0)
        data_shift  <=  {32'b0, data};  //28位数据扩展至48位
    else    if((cnt_shift <= 28) && (shift_flag == 1'b0))
        begin
            // BCD调整逻辑 (对每一位数据进行BCD调整)

            data_shift[31:28]   <=  (data_shift[31:28] > 4) ? (data_shift[31:28] + 2'd3) : (data_shift[31:28]);
            data_shift[35:32]   <=  (data_shift[35:32] > 4) ? (data_shift[35:32] + 2'd3) : (data_shift[35:32]);
            data_shift[39:36]   <=  (data_shift[39:36] > 4) ? (data_shift[39:36] + 2'd3) : (data_shift[39:36]);
            data_shift[43:40]   <=  (data_shift[43:40] > 4) ? (data_shift[43:40] + 2'd3) : (data_shift[43:40]);
            data_shift[47:44]   <=  (data_shift[47:44] > 4) ? (data_shift[47:44] + 2'd3) : (data_shift[47:44]);
			data_shift[51:48]   <=  (data_shift[51:48] > 4) ? (data_shift[51:48] + 2'd3) : (data_shift[51:48]);
            data_shift[55:52]   <=  (data_shift[55:52] > 4) ? (data_shift[55:52] + 2'd3) : (data_shift[55:52]);
			data_shift[59:56]   <=  (data_shift[59:56] > 4) ? (data_shift[59:56] + 2'd3) : (data_shift[59:56]);
        end
    else    if((cnt_shift <= 28) && (shift_flag == 1'b1))
        data_shift  <=  data_shift << 1;
    else
        data_shift  <=  data_shift;

//shift_flag：移位判断标志信号，用于控制移位判断的先后顺序
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        shift_flag  <=  1'b0;
    else
        shift_flag  <=  ~shift_flag;

//当计数器等于28时，移位判断操作完成，对各个位数的BCD码进行赋值
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            unit        <=  4'b0;
            ten         <=  4'b0;
            hun         <=  4'b0;
            tho         <=  4'b0;
            t_tho       <=  4'b0;
            h_hun       <=  4'b0;
            million     <=  4'b0;
            t_million   <=  4'b0;
        end
    else    if(cnt_shift == 6'd29)
        begin
            unit            <=  data_shift[31:28];  //个位
            ten             <=  data_shift[35:32];	//十位
            hun             <=  data_shift[39:36];	//百位
            tho             <=  data_shift[43:40];	//千位
            t_tho           <=  data_shift[47:44];	//万位
            h_hun           <=  data_shift[51:48];	//十万位
            million         <=  data_shift[55:52];  // 百万位
            t_million       <=  data_shift[59:56];  // 千万位
        end


endmodule
