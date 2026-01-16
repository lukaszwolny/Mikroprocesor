`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module alu_acc_flagi_tb;
    localparam W = 8;
    logic clk;
    logic rst;

    logic C_OV_en;
    logic C_OV_kasowanie;

    logic C_in;
    logic OV_in;
    logic P_in;
    logic Z_in;
    logic S_in;
    logic C_out;
    logic OV_out;
    logic P_out;
    logic Z_out;
    logic S_out;


    logic [7:0] a;
    logic [7:0] b;
    logic [7:0] out;
    logic [2:0] alu_op;
    

    logic A_ce;
    logic [7:0] A_wyj;
    assign a = A_wyj;
    
    flagi uut_flagi(
        .*
    );

    ALU #(.ALU_rozm_data(W)) uut_alu(
      .*,
      .P(P_in),
      .Z(Z_in),
      .S(S_in),
      .C(C_in),
      .OV(OV_in),
      .C_in(C_out)
    );

  
    Akumulator uut_akumulator(
      .*,
      .a(out),
      .out(A_wyj)
    );
    
    
    initial clk = 1;
    always #5 clk = ~clk;

    initial begin
        // Dump pliku do GTKWave
        $dumpfile("alu_acc_flagi_tb.vcd");
        $dumpvars(0, alu_acc_flagi_tb);

        // Inicjalizacja sygnałów
        rst = 0;
        A_ce = 0;
        
        b = 0;
        alu_op = 0;
        #10;
        rst = 1;
        #10;
        rst = 0;
        #10;
        
        alu_op = 4;
        #10;
        b = 5;
        alu_op = 4;
        #10;
        alu_op = 0;
       
        b = 0;
        #10;
        alu_op = 7;
        
        #10;//flaga parzystosci
        alu_op = 0;
        b = 8'b10101010;
        #10;//flaga parzystosci BEZ
        alu_op = 0;
        b = 8'b10101011;
        #10;//flaga znaku
        b = 8'b10000000;
        #10;//flaga znaku berz
        b = 8'b01100000;
        #10;//flaga zero bez
        b = 8'b10001100;
        #10;//flaga zero 
        b = 8'b00000000;

        #10;
        
        b = 8'hFF;
        #50;
        
        b = 4;
        alu_op = 4;
        #10;//OV
        
        b = 8'b00000001;
        alu_op = 4;
        #10;//carry
        
        b = 8'b00000001;
        alu_op = 4;
        #10;
        
        b = 8'b11000000;
        alu_op = 4;
        #10;//dodanie tego carry
        
        b = 4;
        
        #10;////////////////////
       
        alu_op = 4;
        
        b = 8'hFF;
        #50;//////////////
        
        b = 4;
        alu_op = 5;
        #10;
        
        b = 5;
        alu_op = 5;



        #20;
        $finish;
    end
    


endmodule