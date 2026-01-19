`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
    Akumulator.

  REQ_ACC:
    REQ_ACC_1:
      Moduł musi zatrzasnąć (zapisać) dane z magistrali wewnętrznej w narastającym zboczu sygnału zegarowego (clk), pod warunkiem, że sygnał zapisu (A_ce) jest w stanie wysokim.
    REQ_ACC_2:
      Zawartość akumulatora musi być stale dostępna na wyjściu Akumulatora (out).
    REQ_ACC_3:
      Po odebraniu sygnału reset (rst), zawartość akumulatora musi zostać wyzerowana w ciągu jednego cyklu zegarowego.
*/
//////////////////////////////////////////////////////////////////////////////////

module Akumulator#(
        parameter ALU_rozm_data = 8
    )(
        input wire clk,
        input wire rst,
        input wire [ALU_rozm_data-1:0] a,
        input wire A_ce,
        output logic [ALU_rozm_data-1:0] out
    );

    logic [ALU_rozm_data-1:0] akum;

    always @( posedge clk ) begin : always_A  //always_ff   always @( posedge clk ) begin
        if(rst) akum <= '0;
        else if(A_ce) akum <= a;
    end

    assign out = akum;

endmodule