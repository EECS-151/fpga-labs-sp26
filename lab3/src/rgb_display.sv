module rgb_display #(
    parameter int DEFAULT_PULSE_DURATION_CYCLES = 10_000_000
) (
    input wire clk,
    input wire [2:0] switches,
    input wire [3:0] buttons,
    output wire [2:0] rgb_leds [3:0]
);
    logic [26:0] pulse_duration_cycles = DEFAULT_PULSE_DURATION_CYCLES; // 100ms

    always_ff @(posedge clk) begin
        if (buttons[2] && pulse_duration_cycles < 27'd100_000_000) begin
            // TODO: Implement the logic to increase the pulse duration
        end else if (buttons[3] && pulse_duration_cycles > 27'd1_000_000) begin
            // TODO: Implement the logic to decrease the pulse duration
        end
    end

    // TODO: Implement the logic to control the rgb_leds
    // You will need to initialize one led_controller for each rgb_led
    // Think about how to do this with a generate block
    // Each led_controller should trigger the next one
    // Based on the spec, think about what peripheral inputs (buttons, switches) you need to use
    // What should the rst be connected to?
    
    // TODO: Remove this once you have implemented the rgb_display module
    assign rgb_leds = '{3'b000, 3'b000, 3'b000, 3'b000};
    
endmodule
