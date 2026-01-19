`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
    ALU.
    
    REQ_ALU:

    --
    albo inaczej:
    Moduł ALU musi wykonać operację matematyczną lub logiczną zgodnie z wartością podaną na 3-bitowym wejściu sterującym alu_op. Wybrany wynik musi zostać wystawiony na wyjście alu_out po ustaleniu się sygnałów wejściowych.

      REQ_ALU_01:
      (operacje - alu_op)
        Moduł musi wykonać operację dodawania (ADD) dwóch liczb 8-bitowych i udostępnić wynik na wyjściu.
        LD
        AND
        OR
        XOR
        ADD
        SUB
        INK
        NOT
        ADDC   - tutaj jeszcze flaga??...
        SUBC  - i tu toze
      REQ_ALU_02:
      (flagi)
        Jeśli wynik operacji jest równy zero, moduł musi ustawić flagę ZERO_FLAG na stan wysoki (1).
      REQ_ALU_03:
      (przepelnienie / OV) ?? to do flag
        W przypadku wystąpienia przeniesienia poza zakres 8 bitów, moduł musi ustawić flagę przeniesienia CARRY_FLAG.
*/
//////////////////////////////////////////////////////////////////////////////////

module ALU #(
    parameter ALU_rozm_data = 8
)(
    input wire [ALU_rozm_data-1:0] a,
    input wire [ALU_rozm_data-1:0] b,
    input wire [3:0] alu_op,

    output logic [ALU_rozm_data-1:0] out,

    input wire C_in,
    
    output wire P, Z, S,
    output wire C, OV
    );

    logic carry;

    always @(*) begin : blockName  //always_comb  always @(*) 
        carry = 0;
        case(alu_op)
        4'b0000: begin
            //0 - LD
            out = b;
        end
        4'b0001: begin
            //1 - AND
            out = a & b;
        end
        4'b0010: begin
            //2 - OR
            out = a | b;
        end
        4'b0011: begin
            //3 - XOR
            out = a ^ b;
        end
        4'b0100: begin
            //4 - ADD
            {carry, out} = a + b;
        end
        4'b0101: begin
            //5 - SUB
            {carry, out} = a - b;
        end
        4'b0110: begin
            //6 - INK
            out = a + 1'b1;
        end
        4'b0111: begin
            //7 - NOT
            out = ~a;
        end
        4'b1000: begin
            //8 - ADDC
            {carry, out} = a + b + C_in;
        end
        4'b1001: begin
            //9 - SUBC
            {carry, out} = a - b - C_in;
        end
    endcase    
    end

//flagi
assign P = ~^out;
assign Z = ~|out;//~(out[7] | out[6] | out[5] | out[4] | out[3] | out[2] | out[1] | out[0]);
assign S = out[7];

assign OV = (a[7] & b[7] & ~out[7]) | (~a[7] & ~b[7] & out[7]);
assign C = carry;// : 1'b1 ? 1'b0;

endmodule