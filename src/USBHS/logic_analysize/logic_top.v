module logic_top(
    input  wire        fx2_ifclk,
    input  wire        reset_n,
    input  wire [7:0]  rx_data,
    input  wire        rx_done,
    input  wire [7:0]  signal_in,

    output wire [7:0]  tx_data,
    output wire        tx_en
);
    //---------------- CMD解析 ----------------
    wire [7:0] cmd_start_stop;
    wire [7:0] cmd_trigger_enable;
    wire [7:0] cmd_trigger_position;
    wire [7:0] cmd_sample_depth;
    wire [7:0] cmd_trigger_channel;
    wire [7:0] cmd_trigger_mod;
    wire       cmd_valid;

    uart_cmd_logic uart_cmd_logic_inst (
        .fx2_ifclk(fx2_ifclk),
        .reset_n(reset_n),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .cmd_start_stop(cmd_start_stop),
        .cmd_trigger_enable(cmd_trigger_enable),
        .cmd_trigger_position(cmd_trigger_position),
        .cmd_sample_depth(cmd_sample_depth),
        .cmd_trigger_channel(cmd_trigger_channel),
        .cmd_trigger_mod(cmd_trigger_mod),
        .cmd_valid(cmd_valid)
    );

    //---------------- 采样模块 ----------------
    wire [12:0] wr_addr;
    wire [7:0]  wr_data;
    wire        wr_en;
    wire [15:0] sample_count;
    wire        sample_done;

    logic_sample logic_sample_inst (
        .fx2_ifclk(fx2_ifclk),
        .reset_n(reset_n),
        .signal_in(signal_in),
        .cmd_start_stop(cmd_start_stop),
        .cmd_trigger_enable(cmd_trigger_enable),
        .cmd_trigger_position(cmd_trigger_position),
        .cmd_sample_depth(cmd_sample_depth),
        .cmd_trigger_channel(cmd_trigger_channel),
        .cmd_trigger_mod(cmd_trigger_mod),
        .cmd_valid(cmd_valid),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .wr_en(wr_en),
        .sample_count(sample_count),
        .sample_done(sample_done)
    );

    //---------------- RAM ----------------
    wire [12:0] rd_addr;
    wire [7:0]  rd_data;
    wire        rd_en;

    Gowin_SDPB_logicram_1 Gowin_SDPB_logicram_1_inst (
        .dout(rd_data),
        .clka(fx2_ifclk),
        .cea(wr_en),
        .clkb(fx2_ifclk),
        .ceb(rd_en),
        .oce(1'b1),
        .reset(~reset_n),
        .ada(wr_addr),
        .din(wr_data),
        .adb(rd_addr)
    );

    //---------------- 发送模块 ----------------
    logic_sender   #(
        .CMT_delay(5000)
    ) logic_sender_inst (
        .fx2_ifclk(fx2_ifclk),
        .reset_n(reset_n),
        .start_send(sample_done),
        .data_len(sample_count),
        .rd_data(rd_data),
        .rd_addr(rd_addr),
        .rd_en(rd_en),
        .data_byte(tx_data),
        .byte_send_en(tx_en),
        .busy(),
        .tx_done()
    );
endmodule