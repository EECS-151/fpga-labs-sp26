module led_controller (
    input wire clk,
    input wire rst,
    input wire [2:0] rgb,
    input wire [26:0] pulse_duration_cycles,
    input wire start,
    output wire trigger_next,
    output wire [2:0] led_out
);

    // TODO: Implement the logic to control the led_out
    // When start is asserted, the led_out should be the rgb color for the duration of the pulse_duration_cycles
    // When the pulse_duration_cycles is reached, the led_out should be 0 and trigger_next should be asserted
    // On rst, go into a blank state
    
    // TODO: Remove this once you have implemented the led_controller module
    assign led_out = '0;
endmodule
