module debouncer #(
    parameter int WIDTH              = 1,
    parameter int SAMPLE_CNT_MAX     = 62500,
    parameter int PULSE_CNT_MAX      = 200,
    parameter int WRAPPING_CNT_WIDTH = $clog2(SAMPLE_CNT_MAX),
    parameter int SAT_CNT_WIDTH      = $clog2(PULSE_CNT_MAX) + 1
) (
    input wire clk,
    input wire [WIDTH-1:0] glitchy_signal,
    output logic [WIDTH-1:0] debounced_signal
);
    // TODO: fill in neccesary logic to implement the wrapping counter and the saturating counters
    // Some initial code has been provided to you, but feel free to change it however you like
    // One wrapping counter is required, one saturating counter is needed for each bit of glitchy_signal
    // You need to think of the conditions for reseting, clock enable, etc. those registers
    // Refer to the block diagram in the spec

    // Remove this line once you have created your debouncer
    assign debounced_signal = '0;

    logic [SAT_CNT_WIDTH-1:0] saturating_counter [WIDTH-1:0];
endmodule
