module z1top(
  input [3:0] BUTTONS,
  input [7:0] SWITCHES,
  output [7:0] LEDS
);
  and(LEDS[0], BUTTONS[0], SWITCHES[0]);
  assign LEDS[7:1] = 0;
endmodule
