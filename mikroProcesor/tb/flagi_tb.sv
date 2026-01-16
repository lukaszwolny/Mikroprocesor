`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module flagi_tb;

    logic clk;
    logic rst;

    logic C_OV_en;

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

    
    flagi uut_flagi(
        .*
    );
    
    initial clk = 1;
    always #5 clk = ~clk;

    initial begin
        // Dump pliku do GTKWave
        $dumpfile("flagi_tb.vcd");
        $dumpvars(0, flagi_tb);

        // Inicjalizacja sygnałów
        rst = 0;
        C_OV_en = 0;
        C_in = 0;
        OV_in = 0;
        P_in = 0;
        Z_in = 0;
        S_in = 0;

        #20;               
        rst = 1;
        #20; 

        rst = 0;           

        #10;
        C_in = 1;
        #10;
        C_in = 0;
        #10;
        P_in = 1;
        #10;
        Z_in = 1;
        #10;
        Z_in = 0;
        #10;
        P_in = 0;
        #10;
        S_in = 1;
        #10;
        S_in = 0;
        #10;
        C_OV_en = 1;
        OV_in = 1;
        #10;
        C_OV_en = 0;
        OV_in = 1;
        #10;
        C_OV_en = 1;
        C_in = 1;
        #10;
        C_OV_en = 0;
        C_in = 0;



        #20;
        $finish;
    end
    


endmodule