package ALSU_pkg;

    // Define an enum for opcode values
    typedef enum {
      OR, XOR, ADD, MULT, SHIFT, ROTATE, INVALID_6, INVALID_7 
    } opcode_e; 

    // Class for defining constraints and data types
    class ALSU_class;
    
        // Define constraints for inputs and outputs 


        // Implement the class functions
        function new();
          cg1 = new();
        endfunction
    
    endclass : ALSU_class  
    
endpackage : ALSU_pkg
