`timescale 1ns/1ps
`define CLK_PERIOD 8

module led_controller_tb();
    // 1 ns clock -> make CYCLES_PER_SECOND = 1_000_000_000 so 1 cycle = 1 ns
    logic clk = 0;
    always #(`CLK_PERIOD/2) clk = ~clk;

    logic rst;
    logic start;
    logic [2:0] led_out;
    logic trigger_next;
    
    // Testbench variables
    logic [26:0] pulse_cycles;
    logic seen_led;
    logic seen_led_fall;
    integer trigger_count;
    logic pulse_finished;
    integer tests_passed = 0;
    integer tests_failed = 0;

    led_controller DUT (
        .clk(clk),
        .rst(rst),
        .rgb(3'b101),
        .pulse_duration_cycles(pulse_cycles),
        .start(start),
        .trigger_next(trigger_next),
        .led_out(led_out)
    );

    initial begin
        `ifdef IVERILOG
            $dumpfile("led_controller_tb.fst");
            $dumpvars(0, led_controller_tb);
        `endif

        fork
            // Main test thread
            begin
                $display("Starting led_controller_tb");

                // initialise
                pulse_cycles = 26'd10;
                seen_led = 0;
                seen_led_fall = 0;
                trigger_count = 0;
                
                rst = 1;
                start = 0;
                @(posedge clk); #1;
                rst = 0;
                @(posedge clk); #1;

                start = 1;
                @(posedge clk); #1;
                start = 0;

                // sample for a reasonable window
                repeat (pulse_cycles + 10) begin
                    @(posedge clk); #1;
                    if (led_out == 3'b101) seen_led = 1;
                    if (seen_led && (led_out != 3'b101)) seen_led_fall = 1;
                    if (trigger_next) trigger_count = trigger_count + 1;
                end

                if (!seen_led) begin
                    $error("led_out never asserted after start");
                    tests_failed = tests_failed + 1;
                end else if (!seen_led_fall) begin
                    $error("led_out did not fall again within expected window");
                    tests_failed = tests_failed + 1;
                end else if (trigger_count != 1) begin
                    $error("trigger_next asserted %0d times (expected 1)", trigger_count);
                    tests_failed = tests_failed + 1;
                end else begin
                    $display("\n\nled_controller_tb PASSED - Initial test\n\n");
                    tests_passed = tests_passed + 1;
                end

                // Test 2: Decrease pulse_cycles halfway through
                $display("Test 2: Decreasing pulse_cycles halfway through pulse");
                pulse_cycles = 26'd10;
                rst = 1;
                start = 0;
                @(posedge clk); #1;
                rst = 0;
                @(posedge clk); #1;
                
                start = 1;
                @(posedge clk); #1;
                start = 0;
                
                // Wait halfway through the pulse
                repeat (5) @(posedge clk); #1;
                
                $display("  At cycle 5: led_out = %b, decreasing pulse_cycles to 2", led_out);
                pulse_cycles = 26'd2;  // Decrease pulse duration
                pulse_finished = 0;
                
                // Monitor to see if pulse finishes
                repeat (10) begin
                    @(posedge clk); #1;
                    if (led_out == 3'b000 && !pulse_finished) begin
                        pulse_finished = 1;
                        $display("  PASSED");
                    end
                end
                if (!pulse_finished) begin
                    $error("  FAILED: led_out did not finish (go to 000) after decreasing pulse_cycles");
                    tests_failed = tests_failed + 1;
                end else begin
                    tests_passed = tests_passed + 1;
                end
                
                $display("Test 2 complete\n");

                // Test 3: Assert rst halfway through
                $display("Test 3: Asserting rst halfway through pulse");
                pulse_cycles = 26'd10;
                rst = 1;
                start = 0;
                @(posedge clk); #1;
                rst = 0;
                @(posedge clk); #1;
                
                start = 1;
                @(posedge clk); #1;
                start = 0;
                
                // Wait halfway through the pulse
                repeat (5) @(posedge clk); #1;
                $display("  At cycle 5: led_out = %b, asserting rst", led_out);
                
                // Assert reset
                rst = 1;
                @(posedge clk); #1;
                
                // Check that led_out goes down
                if (led_out != 3'b000) begin
                    $error("  FAILED: led_out should be 000 after rst, but got %b", led_out);
                    tests_failed = tests_failed + 1;
                end else begin
                    $display("  PASSED: led_out correctly went to 000 after rst");
                    tests_passed = tests_passed + 1;
                end
                
                // Release reset and verify
                rst = 0;
                @(posedge clk); #1;
                if (led_out != 3'b000) begin
                    $error("  FAILED: led_out should remain 000 after rst release, but got %b", led_out);
                    tests_failed = tests_failed + 1;
                end else begin
                    $display("  PASSED: led_out correctly remains 000 after rst release");
                    tests_passed = tests_passed + 1;
                end
                $display("Test 3 complete\n");

                // Final summary
                $display("Tests Passed: %0d", tests_passed);
                $display("Tests Failed: %0d", tests_failed);
                if (tests_failed == 0) begin
                    $display("========================================");
                    $display("ALL TESTS PASSED!");
                    $display("========================================");
                end else begin
                    $display("========================================");
                    $error("SOME TESTS FAILED!");
                    $display("========================================");
                end

                `ifndef IVERILOG
                    $vcdplusoff;
                `endif
                $finish();
            end
            // Timeout thread
            begin
                repeat (10_000) @(posedge clk); #1;
                $error("Testbench timeout - simulation took too long");
                $fatal();
            end
        join
    end
endmodule
