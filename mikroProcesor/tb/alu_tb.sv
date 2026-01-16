`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module alu_tb;
    localparam W = 8;

    logic [7:0] a;
    logic [7:0] b;

    logic [7:0] out;

    logic [2:0] alu_op;

    logic P;
    logic Z;
    logic S;
    logic C;
    logic OV;

  //input:
    logic C_in;



    
    ALU #(.ALU_rozm_data(W)) uut_alu(
      .*
        // .a(a),
        // .b(b),
        // .alu_op(alu_op),
        // .out(out),
        // .P(P),
        // .Z(Z),
        // .S(S)
    );
    


    initial begin
        // Dump pliku do GTKWave
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);

        // Inicjalizacja sygnałów
        C_in = 0;
        a = 0;
        b = 0;
        alu_op = 0;
        #10;
        a = 5;
        alu_op = 4;
        #10;
        b = 5;
        alu_op = 4;
        #10;
        alu_op = 0;
        a = 0;
        b = 0;
        #10;
        alu_op = 7;
        a = 8'b10101010;
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
        a = 8'hFF;
        b = 8'hFF;
        #50;
        a = 5;
        b = 4;
        alu_op = 4;
        #10;//OV
        a = 8'b01111111;
        b = 8'b00000001;
        alu_op = 4;
        #10;//carry
        a = 8'b01111111;
        b = 8'b00000001;
        alu_op = 4;
        #10;
        a = 8'b01111111;
        b = 8'b11000000;
        alu_op = 4;
        #10;//dodanie tego carry
        a = 8'b00000101;//wynikz z poprzedniego
        b = 4;
        C_in = 1;
        #10;////////////////////
        C_in  =0;
        alu_op = 4;
        a = 8'hFF;
        b = 8'hFF;
        #50;//////////////
        a = 5;
        b = 4;
        alu_op = 5;
        #10;
        a = 4;
        b = 5;
        alu_op = 5;

        #20;
        $finish;
    end
    


endmodule