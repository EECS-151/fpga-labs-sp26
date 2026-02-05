module counter #(
    parameter int CYCLES_PER_SECOND = 125_000_000
)(
    input wire clk,
    input wire [3:0] buttons,
    output wire [3:0] leds
);
    logic [3:0] counter = 4'd0;
    assign leds = counter;

    always_ff @(posedge clk) begin
        if (buttons[0])
            counter <= counter + 4'd1;
        else if (buttons[1])
            counter <= counter - 4'd1;
        else if (buttons[3])
            counter <= 4'd0;
    end
endmodule
