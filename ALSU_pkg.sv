package ALSU_pkg;
  parameter MAXPOS = 3'b011;
  parameter MAXNEG = 3'b111;
  parameter ZERO   = 3'b0;

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
      
      if (opcode == ROTATE || opcode == SHIFT) {
      
        disable AB_const;
      
      } else if (opcode == ADD || opcode == MULT) {
      
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

      unique {op_arr}

    }

  /////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////   CoverGroups   /////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////
  
    covergroup cvr_grp (@posedge clk);
      
      coverpoint A : A_cp {

        bins A_data_0 = {0};
        bins A_data_max = {MAXPOS};
        bins A_data_min = {MAXNEG};
        bins A_data_default = default;
        bins A_data_walkingones = {001, 010, 100};

      }
      
      coverpoint A iff(red_op_A) {
        
        bins A_walkingones[] = {001, 010, 100};

      }
      
      
      coverpoint B : B_cp {

        bins B_data_0 = {0};
        bins B_data_max = {MAXPOS};
        bins B_data_min = {MAXNEG};
        bins B_data_default = default;
        bins B_data_walkingones = {001, 010, 100};

      }

      coverpoint B iff(red_op_B && !red_op_A) {
        
        bins B_walkingones[] = {001, 010, 100};

      }

      coverpoint opcode : ALU_cp {

        bins Bins_shift[]   = {SHIFT, ROTATE};
        bins Bins_arith[]   = {ADD, MULT};
        bins Bins_bitwise[] = {OR, XOR};
        bins Bins_invalid = {INVALID_6, INVALID_7};
        bins Bins_trans = (OR => XOR => ADD => MULT => SHIFT => ROTATE);

      }

      coverpoint cin: cin_cp {

        bins cin_zero = {0};
        bins cin_one  = {1};

      }

      coverpoint serial_in: serial_cp {

        if (opcode == SHIFT) {
          bins shift_serial_in = {0, 1};
        }

      }
      
      coverpoint direction: direction_cp {

        if (opcode == SHIFT || opcode == ROTATE) {
          bins shift_rotate_direction = {0, 1};
        }

      }

      cross A_cp, B_cp {

        ///////////////////////////////

      } iff ( (opcode == OR || opcode == XOR) && (red_op_A) );


      cross A_cp, B_cp, cin_cp {
        
        bins AB_pos_pos = binsof(A_cp.A_data_max) * binsof(B_cp.B_data_max);
        bins AB_pos_neg = binsof(A_cp.A_data_max) * binsof(B_cp.B_data_min);
        bins AB_pos_zer = binsof(A_cp.A_data_max) * binsof(B_cp.B_data_0);

        bins AB_neg_pos = binsof(A_cp.A_data_min) * binsof(B_cp.B_data_max);
        bins AB_neg_neg = binsof(A_cp.A_data_min) * binsof(B_cp.B_data_min);
        bins AB_neg_zer = binsof(A_cp.A_data_min) * binsof(B_cp.B_data_0);
        
        bins AB_zer_pos = binsof(A_cp.A_data_0) * binsof(B_cp.B_data_max);
        bins AB_zer_neg = binsof(A_cp.A_data_0) * binsof(B_cp.B_data_min);
        bins AB_zer_zer = binsof(A_cp.A_data_0) * binsof(B_cp.B_data_0);

      } iff( (opcode == ADD) || (opcode == MULT) );




    endgroup



  /////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////
    
    function new();
      cvr_grp = new();
    endfunction
  
  endclass : ALSU_class  
    
endpackage : ALSU_pkg
