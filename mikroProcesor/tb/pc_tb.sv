`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////


module pc_tb;
    localparam W = 8;

    logic clk;
    logic rst;
    //logic ID_ink;
    logic ID_rst;
    logic [W-1:0] PC_count;

    logic skok_pc;
    logic [7:0] adres_skok_pc;
    
    
    pc #(.W(W)) uut_pc(
        .*
    );
    
    initial clk = 1;
    always #5 clk = ~clk;

        // Sekwencja testowa
    initial begin
        // Dump pliku do GTKWave
        $dumpfile("pc_tb.vcd");
        $dumpvars(0, pc_tb);

        // Inicjalizacja sygnałów
        rst = 0;
        skok_pc = 0;
        adres_skok_pc = 8'h00;
        //ID_ink = 0;
        ID_rst = 0;
        #20;               
        rst = 1;
        #23; 

        rst = 0;           
        // #10;

        // Inkrementacje
        // repeat (4) begin
        //     ID_ink = 1;
        //     #40;
        //     ID_ink = 0;
        //     #40;
        // end
        //#7;#1
        //ID_ink = 1;
       // #10;
        //ID_ink = 0;
        //#6;

        #7;
        #20;
        skok_pc = 1;
        adres_skok_pc = 8'hAA;
        #10;
        skok_pc = 0;


        // Reset lokalny
        // ID_rst = 1;
        // #10;
        // ID_rst = 0;
        // #10;

        // // Kolejne kilka inkrementacji
        // repeat (3) begin
        //     #1;
        //     ID_ink = 1;
        //     #10;
        //     ID_ink = 0;
        //     #9;
        // end

        // Koniec symulacji
        #20;
        $finish;
    end
    

endmodule