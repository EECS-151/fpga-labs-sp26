module edge_detector #(
    parameter int WIDTH = 1
)(
    input wire clk,
    input wire [WIDTH-1:0] signal_in,
    output logic [WIDTH-1:0] edge_detect_pulse
);
    // TODO: implement a multi-bit edge detector that detects a rising edge of 'signal_in[x]'
    // and outputs a one-cycle pulse 'edge_detect_pulse[x]' at the next clock edge

    // Remove this line once you create your edge detector
    assign edge_detect_pulse = 0;
endmodule
