import ALSU_pkg::*;
module ALSU_tb;

parameter INPUT_PRIORITY = "A";
parameter FULL_ADDER = "ON";
parameter clk_period = 10;

bit clk, rst, cin, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in;
opcode_e opcode;
bit signed [2:0] A, B;
logic [15:0] leds;
logic [5:0] out;

bit [15:0] leds_exp;
bit [5:0] out_exp;

int error_count;
int valid_count;

ALSU_class ALSU_obj = new();

ALSU alsu1(A, B, opcode, cin, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in, leds, out, clk, rst);

/////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////   Testbench Logic   /////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////

initial begin
    initialize();
    reset();
    ALSU_obj.opcode_arr_un.constraint_mode(0);
    repeat(1000) begin
        assert(ALSU_obj.randomize());
        rst = ALSU_obj.rst;
        cin = ALSU_obj.cin;
        red_op_A = ALSU_obj.red_op_A;
        red_op_B = ALSU_obj.red_op_B;
        bypass_A = ALSU_obj.bypass_A;
        bypass_B = ALSU_obj.bypass_B;
        direction = ALSU_obj.direction;
        serial_in = ALSU_obj.serial_in;
        opcode = ALSU_obj.opcode;
        A = ALSU_obj.A;
        B = ALSU_obj.B;

        if (!ALSU_obj.rst || !ALSU_obj.bypass_A || !ALSU_obj.bypass_B) begin
            ALSU_obj.cvr_grp.sample();
        end

        check_result(ALSU_obj);
    end

    // Todo : Complete Second Loop of different randomization conditions
    
    ALSU_obj.constraint_mode(0);
    ALSU_obj.opcode_arr_un.constraint_mode(1);
    
    red_op_A = 0;
    red_op_B = 0;
    bypass_A = 0;
    bypass_B = 0;
    rst = 0;
    
    repeat(1000) begin
        assert(ALSU_obj.randomize());
        rst = ALSU_obj.rst;
        cin = ALSU_obj.cin;
        red_op_A = ALSU_obj.red_op_A;
        red_op_B = ALSU_obj.red_op_B;
        bypass_A = ALSU_obj.bypass_A;
        bypass_B = ALSU_obj.bypass_B;
        direction = ALSU_obj.direction;
        serial_in = ALSU_obj.serial_in;
        opcode = ALSU_obj.opcode;
        A = ALSU_obj.A;
        B = ALSU_obj.B;

        if (!ALSU_obj.rst || !ALSU_obj.bypass_A || !ALSU_obj.bypass_B) begin
            ALSU_obj.cvr_grp.sample();
        end

        check_result(ALSU_obj);
    end

end

/////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////   Clock Generation   ////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////

initial begin
    clk = 0;
    forever begin
        #clk_period
        clk = ~clk;
    end
end

/////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////   Tasks & Functions   ///////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////

task reset();

    rst = 1;
    #clk_period
    rst = 0;
    
endtask 

task check_reset();
    @(negedge clk);
    if (rst && leds != 0 && out != 0) begin
        $display("Error: reset not working");
        error_count = error_count +1;
    end else begin
        valid_count = valid_count + 1;
    end

endtask 

task  initialize();
    
    rst = 0;
    cin = 0;
    red_op_A = 0;
    red_op_B = 0;
    bypass_A = 0;
    bypass_B = 0;
    direction = 0;
    serial_in = 0;
    opcode = 0;
    A = 0;
    B = 0;

endtask



task ALSU_gold(input ALSU_class ALSU_obj_g);

    if (ALSU_obj_g.rst) begin
        ALSU_obj_g.leds_exp = 0;
        ALSU_obj_g.out_exp  = 0;
    end else begin
        @(posedge clk);
        if (INPUT_PRIORITY == "A" && ALSU_obj_g.bypass_A) begin
            ALSU_obj_g.out_exp = ALSU_obj_g.A;
            ALSU_obj_g.leds_exp = 0;
        end else if (INPUT_PRIORITY == "A" && ALSU_obj_g.bypass_B) begin
            ALSU_obj_g.out_exp = ALSU_obj_g.B;
            ALSU_obj_g.leds_exp = 0;
        end else if (INPUT_PRIORITY == "B" && ALSU_obj_g.bypass_B) begin 
            ALSU_obj_g.out_exp = ALSU_obj_g.B;
            ALSU_obj_g.leds_exp = 0;
        end else if (INPUT_PRIORITY == "B" && ALSU_obj_g.bypass_A) begin 
            ALSU_obj_g.out_exp = ALSU_obj_g.A;
            ALSU_obj_g.leds_exp = 0;
        end else begin

            case (ALSU_obj_g.opcode)
                OR      :   if (INPUT_PRIORITY == "A") begin
                                if(ALSU_obj_g.red_op_A) begin
                                    ALSU_obj_g.out_exp = |ALSU_obj_g.A;
                                    ALSU_obj_g.leds_exp = 0;
                                end else if (ALSU_obj_g.red_op_B) begin
                                    ALSU_obj_g.out_exp = |ALSU_obj_g.B;
                                    ALSU_obj_g.leds_exp = 0;
                                end else begin
                                    ALSU_obj_g.out_exp = ALSU_obj_g.A | ALSU_obj_g.B;
                                    ALSU_obj_g.leds_exp = 0;
                                end
                            end else if (INPUT_PRIORITY == "B") begin
                                if(ALSU_obj_g.red_op_B) begin
                                    ALSU_obj_g.out_exp = |ALSU_obj_g.B;
                                    ALSU_obj_g.leds_exp = 0;
                                end else if (ALSU_obj_g.red_op_A) begin
                                    ALSU_obj_g.out_exp = |ALSU_obj_g.A;
                                    ALSU_obj_g.leds_exp = 0;
                                end else begin
                                    ALSU_obj_g.out_exp = ALSU_obj_g.A | ALSU_obj_g.B;
                                    ALSU_obj_g.leds_exp = 0;
                                end
                            end

                XOR     :   if (INPUT_PRIORITY == "A") begin
                                if(ALSU_obj_g.red_op_A) begin
                                    ALSU_obj_g.out_exp = ^ALSU_obj_g.A;
                                    ALSU_obj_g.leds_exp = 0;
                                end else if (ALSU_obj_g.red_op_B) begin
                                    ALSU_obj_g.out_exp = ^ALSU_obj_g.B;
                                    ALSU_obj_g.leds_exp = 0;
                                end else begin
                                    ALSU_obj_g.out_exp = ALSU_obj_g.A ^ ALSU_obj_g.B;
                                    ALSU_obj_g.leds_exp = 0;
                                end
                            end else if (INPUT_PRIORITY == "B") begin
                                if(ALSU_obj_g.red_op_B) begin
                                    ALSU_obj_g.out_exp = ^ALSU_obj_g.B;
                                    ALSU_obj_g.leds_exp = 0;
                                end else if (ALSU_obj_g.red_op_A) begin
                                    ALSU_obj_g.out_exp = ^ALSU_obj_g.A;
                                    ALSU_obj_g.leds_exp = 0;
                                end else begin
                                    ALSU_obj_g.out_exp = ALSU_obj_g.A ^ ALSU_obj_g.B;
                                    ALSU_obj_g.leds_exp = 0;
                                end
                            end

                ADD     :   if (FULL_ADDER == "ON") begin
                                ALSU_obj_g.out_exp = ALSU_obj_g.A + ALSU_obj_g.B + ALSU_obj_g.cin; 
                                ALSU_obj_g.leds_exp = 0;
                            end else if (FULL_ADDER == "OFF") begin
                                ALSU_obj_g.out_exp = ALSU_obj_g.A + ALSU_obj_g.B;  
                                ALSU_obj_g.leds_exp = 0;
                            end

                MULT    :   begin
                                ALSU_obj_g.out_exp = ALSU_obj_g.A * ALSU_obj_g.B ;
                                ALSU_obj_g.leds_exp = 0; 
                            end

                SHIFT   :   if (ALSU_obj_g.direction) begin

                                ALSU_obj_g.out_exp = ALSU_obj_g.out_exp << 1;
                                ALSU_obj_g.out_exp[0] = ALSU_obj_g.serial_in;
                                ALSU_obj_g.leds_exp = 0;

                            end else begin

                                ALSU_obj_g.out_exp = ALSU_obj_g.out_exp >> 1;
                                ALSU_obj_g.out_exp[5] = ALSU_obj_g.serial_in;
                                ALSU_obj_g.leds_exp = 0;

                            end

                ROTATE  :   if (ALSU_obj_g.direction) begin
                                ALSU_obj_g.out_exp = {ALSU_obj_g.out_exp[4:0], ALSU_obj_g.out_exp[5]};
                                ALSU_obj_g.leds_exp = 0;
                            end else begin
                                ALSU_obj_g.out_exp = {ALSU_obj_g.out_exp[0], ALSU_obj_g.out_exp[5:1]};
                                ALSU_obj_g.leds_exp = 0;
                            end

                default :   begin
                                ALSU_obj_g.leds_exp = ~ ALSU_obj_g.leds_exp ;
                                ALSU_obj_g.out_exp = 0 ;
                            end
            endcase
        end
    end

endtask



task check_result(input ALSU_class ALSU_obj_c);
    
    ALSU_gold(ALSU_obj_c);

    if(!rst) begin
        @(negedge clk);    
        if (ALSU_obj_c.leds_exp != leds) begin
            $display("Error: leds not correct");
            error_count = error_count + 1;
        end else begin
            valid_count = valid_count + 1;
        end

        if (ALSU_obj_c.out_exp != out) begin
            $display("Error: out not correct");
            error_count = error_count + 1;
        end else begin
            valid_count = valid_count + 1;
        end
    end

endtask

endmodule