module z1top (
    input CLK_125MHZ_FPGA,
    input [3:0] BUTTONS,
    input [1:0] SWITCHES,
    output [5:0] LEDS
);
    wire [5:0] adder_leds;
    wire [5:0] counter_leds;
    
    wire [14:0] adder_out;
    structural_adder user_adder (
        .a({12'b0,BUTTONS[1:0]}),
        .b({12'b0,BUTTONS[3:2]}),
        .sum(adder_out)
    );
    assign adder_leds[3:0] = adder_out[3:0]; // truncate upper bits
    
    // Self test of the structural adder
    wire [13:0] adder_operand1, adder_operand2;
    wire [14:0] structural_out, behavioral_out;
    wire test_fail;
    assign adder_leds[4] = ~test_fail;
    assign adder_leds[5] = ~test_fail;
    
    structural_adder structural_test_adder (
        .a(adder_operand1),
        .b(adder_operand2),
        .sum(structural_out)
    );
    
    behavioral_adder behavioral_test_adder (
        .a(adder_operand1),
        .b(adder_operand2),
        .sum(behavioral_out)
    );
    
    adder_tester tester (
        .adder_operand1(adder_operand1),
        .adder_operand2(adder_operand2),
        .structural_sum(structural_out),
        .behavioral_sum(behavioral_out),
        .clk(CLK_125MHZ_FPGA),
        .test_fail(test_fail)
    );
    
    assign counter_leds[5:4] = 0;
    
    counter ctr (
        .clk(CLK_125MHZ_FPGA),
        .ce(SWITCHES[0] & SWITCHES[1]),
        .LEDS(counter_leds[3:0])
    );

    assign LEDS = SWITCHES[1] ? counter_leds : adder_leds;
endmodule
