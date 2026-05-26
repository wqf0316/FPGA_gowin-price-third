module led (
    input        clk,
    input        reset_,
    output  reg  led1,
    output  reg  led2,
    output  reg  led3,
    output  reg  led4
);

always @(posedge clk or negedge reset_) begin
    if (!reset_) begin
        led1 <= 1'b0;
        led2 <= 1'b0;
        led3 <= 1'b0;
        led4 <= 1'b0;
    end else begin
        led1 <= ~led1;
        led2 <= ~led2;
        led3 <= ~led3;
        led4 <= ~led4;
    end
end

endmodule
