package ALSU_pkg;
  parameter MAXPOS = 3'b011;
  parameter MAXNEG = 3'b111;
  parameter ZERO   = 3'b0;
  parameter INPUT_PRIORITY = "A";
  parameter FULL_ADDER = "ON";

  typedef enum {
    OR, XOR, ADD, MULT, SHIFT, ROTATE, INVALID_6, INVALID_7 
  } opcode_e; 


  class ALSU_class;
    rand bit signed [2:0] A, B;
    rand opcode_e opcode;
    rand opcode_e op_arr [6];
    rand bit    cin, serial_in, direction,
                red_op_A, red_op_B,
                bypass_A, bypass_B;
    bit [5:0]   out;
    bit [15:0]  leds;
    bit clk, rst;

    /////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////   Constraints   /////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////
    
    constraint rst_deact {rst dist {0:=98, 1:=2}; }
    
    constraint AB_const { 
      
      if (opcode == ADD || opcode == MULT) {
      
        A dist {MAXPOS:/50, MAXNEG:/50, ZERO:/50};
        B dist {MAXPOS:/50, MAXNEG:/50, ZERO:/50};
      
      } else if ( (opcode == OR || opcode == XOR ) && red_op_A ) {
        
        $onehot(A);
        B == ZERO;
      
      } else if( (opcode == OR || opcode == XOR ) && red_op_B ) {
      
        $onehot(B);
        A == ZERO;
      
      }

    }

    constraint invalid_cases {
      opcode dist {OR:/20, XOR:/20, ADD:/20, MULT:/20, SHIFT:/20, ROTATE:/20, INVALID_6:/5, INVALID_7:/5};
    }
    
    constraint bypass {
      bypass_A dist {0:/10, 1:/90};
      bypass_B dist {0:/10, 1:/90};
    } 

    constraint unique_op_arr {

      foreach (op_arr[i]) {
          op_arr[i] inside {OR, XOR, ADD, MULT, SHIFT, ROTATE};
      }

      unique {op_arr};

    }

  /////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////   CoverGroups   /////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////
  
    covergroup cvr_grp @(posedge clk);
      
      // All Values of A
      A_cp : coverpoint A {

        bins A_data_0 = {0};
        bins A_data_max = {MAXPOS};
        bins A_data_min = {MAXNEG};
        bins A_data_default = default;
        
      }      
      
      // All Values of B
      B_cp : coverpoint B {

        bins B_data_0 = {0};
        bins B_data_max = {MAXPOS};
        bins B_data_min = {MAXNEG};
        bins B_data_default = default;
        bins B_data_walkingones = {001, 010, 100} iff (red_op_B && !red_op_A);

      }

      // For Cross Coverage of A and B during Reduction
      A_wo : coverpoint A {
        bins A_walkingones[] = {001, 010, 100};
        bins A_zer = {0};
      }

      B_wo : coverpoint B {        
        bins B_walkingones[] = {001, 010, 100};
        bins B_zer = {0};
      }

      cross A_wo, B_wo iff(opcode == OR || opcode == XOR);


      // Coverpoints for ALU Opcode Values
      ALU_cp : coverpoint opcode {

        bins Bins_shift[]   = {SHIFT, ROTATE};
        bins Bins_arith[]   = {ADD, MULT};
        bins Bins_bitwise[] = {OR, XOR};
        illegal_bins Bins_invalid = {INVALID_6, INVALID_7};
        bins Bins_trans = (OR => XOR => ADD => MULT => SHIFT => ROTATE);

      }

      // Coverpoints for cin while ALU is in Addition
      cin_cp : coverpoint cin {

        bins cin_zero = {0} iff (opcode == ADD);
        bins cin_one  = {1} iff (FULL_ADDER == "ON" && opcode == ADD);
        illegal_bins cin_one_ = {1} iff (FULL_ADDER == "OFF" && opcode == ADD);

      }

      // Coverpoints for serial while ALU is in Shift
      serial_cp : coverpoint serial_in {

        bins shift_serial_in = {0, 1} iff (opcode == SHIFT);

      }
      

      // Coverpoints for direction while ALU is in Shift or Rotate
      direction_cp : coverpoint direction {
  
        bins left_direction = {0} iff (opcode == SHIFT || opcode == ROTATE);
        bins right_direction = {1} iff (opcode == SHIFT || opcode == ROTATE);

      }


      // Cross Coverage for all permutations of A_B "Max, Min, Zero" while ALU is Arithmetic
      cross A, B iff( (opcode == ADD) || (opcode == MULT) );


      // Reduction operation is activated while the opcode is not OR or XOR
      red_A_cp : coverpoint red_op_A {

        illegal_bins red_A = {1} iff (opcode != OR && opcode != XOR); 
      
      }
      
      red_B_cp : coverpoint red_op_B {
      
        illegal_bins red_B = {1} iff (opcode != OR && opcode != XOR);
      
      }

      // Reduction operation is activated for both A & B simultaneously 
      cross red_A_cp, red_B_cp;

    endgroup



  /////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////
    
    function new();
      cvr_grp = new();
    endfunction
  
  endclass : ALSU_class  
    
endpackage : ALSU_pkg