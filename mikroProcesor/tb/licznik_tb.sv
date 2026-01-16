`timescale 1ns / 1ps

module licznik_tb;
    logic clk;
    logic rst;

    logic [7:0] wartosc;
    logic zapisz_L;
    logic zapisz_H;
    logic zapisz_ctr; //zapisz do control_reg

    logic licznik_int;//przerwanie do uk.przerwan
    logic licznik_flaga; //flaga do sprawdzania 
    logic licznik_flaga_clear;

    licznik u_licznik(
        .*
    );

    initial clk = 1;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("licznik_tb.vcd");
        $dumpvars(0, licznik_tb);
    end
    
    initial begin
        licznik_flaga_clear = 0;
        rst = 1;
        wartosc = 0;
        zapisz_L = 0;
        zapisz_H = 0;
        zapisz_ctr = 0;
        #10;
        rst = 0;
        #10;
        //test: 
        wartosc = 0;
        zapisz_H = 1;
        #10;
        zapisz_H = 0;
        wartosc = 10;
        zapisz_L = 1;
        #10;
        zapisz_L = 0;
        wartosc = 8'b10001001;
        zapisz_ctr = 1;
        #10;
        zapisz_ctr = 0;
        licznik_flaga_clear = 1;
        #10;
        licznik_flaga_clear = 0;
        #100;
        wartosc = 8'b00001001;
        zapisz_ctr = 1;
        #10;
        wartosc = 8'b10001010;
        zapisz_ctr = 1;
        licznik_flaga_clear = 1;
        #10;
        licznik_flaga_clear = 0;
        #100;
        licznik_flaga_clear = 1;
        #10;
        licznik_flaga_clear = 0;
        #(50000);

        //---

        #500;
        $finish;
    end


endmodule