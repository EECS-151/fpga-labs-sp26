`default_nettype none
`define CLOCK_FREQ 100_000_000
module z1top (
    input wire CLK_100_P,
    input wire CLK_100_N,
    input wire [3:0] BUTTONS,
    input wire [7:0] SWITCHES,
    output wire [7:0] LEDS,
    output wire [2:0] RGB_LED0,
    output wire [2:0] RGB_LED1,
    output wire [2:0] RGB_LED2,
    output wire [2:0] RGB_LED3
);

    wire CLK_100;
    IBUFDS ibufds_clk (
        .I(CLK_100_P),
        .IB(CLK_100_N),
        .O(CLK_100)
    );

    // Button parser test circuit
    // Sample the button signal every 500us
    localparam integer B_SAMPLE_CNT_MAX = $rtoi(0.0005 * `CLOCK_FREQ);
    // The button is considered 'pressed' after 100ms of continuous pressing
    localparam integer B_PULSE_CNT_MAX = $rtoi(0.100 / 0.0005);

    wire [3:0] buttons_pressed;
    button_parser #(
        .WIDTH(4),
        .SAMPLE_CNT_MAX(B_SAMPLE_CNT_MAX),
        .PULSE_CNT_MAX(B_PULSE_CNT_MAX)
    ) bp (
        .clk(CLK_100),
        .in(BUTTONS),
        .out(buttons_pressed)
    );

    counter count (
        .clk(CLK_100 & ~SWITCHES[7]),
        .buttons(buttons_pressed),
        .leds(LEDS[3:0])
    );

    logic [2:0] RGB_LEDS [3:0];
    rgb_display #(
        .DEFAULT_PULSE_DURATION_CYCLES(10_000_000)
    ) rd (
        .clk(CLK_100 & SWITCHES[7]),
        .switches(SWITCHES[2:0]),
        .buttons(buttons_pressed[3:0]),
        .rgb_leds(RGB_LEDS)
    );

    assign RGB_LED0 = RGB_LEDS[0];
    assign RGB_LED1 = RGB_LEDS[1];
    assign RGB_LED2 = RGB_LEDS[2];
    assign RGB_LED3 = RGB_LEDS[3];
endmodule
