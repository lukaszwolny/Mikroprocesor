`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////


module Rejestry_tb;
    localparam W = 8;

    logic clk;
    logic rst;
    logic wr_Rx;
    logic [$clog2(W)-1:0] nr_Rx;
    logic [7:0] dane;
    logic [7:0] out;
    
    Rejestry #(.Rx_liczba(W)) uut_Rejestry(
        .*
    );
    
    initial clk = 1;
    always #5 clk = ~clk;

        // Sekwencja testowa
    initial begin
        // Dump pliku do GTKWave
        $dumpfile("Rejestry_tb.vcd");
        $dumpvars(0, Rejestry_tb);

        // Inicjalizacja sygnałów
        rst = 0;
        dane = 0;
        wr_Rx = 0;
        nr_Rx = 0;
        
        #20;               
        rst = 1;
        #23; 

        rst = 0;           

        #7;#1
        dane = 8'b11110000;
        #10;
        nr_Rx = 3;
        wr_Rx = 1;
        #10;
        wr_Rx = 0;


        #20;
        $finish;
    end
    

endmodule