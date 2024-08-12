module ALSU_sva;

    bit     [2:0]   A, B, opcode;
    bit             clk, rst;
    bit             cin, serial_in, direction;
    bit             bypass_A, bypass_B;
    bit             red_op_A, red_op_B;
    logic   [5:0]   out;
    logic   [15:0]  leds;

endmodule
