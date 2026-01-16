`timescale 1ns/1ps

module port_tb;


    localparam A = 8;
    localparam B = 3;
    // --- sygnały ---
    logic clk;
    logic rst;

    logic [7:0] dane;
    logic [1:0] nr_P_DDRx;
    logic [1:0] nr_P_PORTx;
    logic [1:0] nr_P_PINx;
    logic wr_DDRx;
    logic wr_PORTx;

    logic [7:0] out;

    wire [7:0] in_out_A;
    wire [7:0] in_out_B;
    // wire [3:0] in_out_A;
    // wire [3:0] in_out_B;
    wire [7:0] in_out_C;

    // --- symulowane SW ---
    logic [7:0] SW_A_driver;
    logic [7:0] SW_B_driver;

    
    // logic [3:0] SW_A_driver;
    // logic [3:0] SW_B_driver;


    // --- podłączenie "inout" ---
    assign in_out_A[0] = SW_A_driver[0];
    assign in_out_A[1] = SW_A_driver[1];
    assign in_out_A[2] = SW_A_driver[2];
    assign in_out_A[3] = SW_A_driver[3];
    assign in_out_A[4] = SW_A_driver[4];
    assign in_out_A[5] = SW_A_driver[5];
    assign in_out_A[6] = SW_A_driver[6];
    assign in_out_A[7] = SW_A_driver[7];
    assign in_out_B = SW_B_driver;
    // diody in_out_C są wyjściem, więc nie podpinamy niczego

    // --- instancja modułu ---
    port #(.Port_rozm_data(A),
            .Port_liczba(B)
    ) uut (
        .clk(clk),
        .rst(rst),
        .dane(dane),
        .nr_P_DDRx(nr_P_DDRx),
        .nr_P_PORTx(nr_P_PORTx),
        .nr_P_PINx(nr_P_PINx),
        .wr_DDRx(wr_DDRx),
        .wr_PORTx(wr_PORTx),
        .out(out),
        .in_out_A(in_out_A),
        .in_out_B(in_out_B),
        .in_out_C(in_out_C)
    );

    // --- zegar 10ns ---
    initial clk = 1;
    always #5 clk = ~clk;

    // --- procedura testowa ---
    initial begin
        $dumpfile("port_tb.vcd"); // do GTKWave
        $dumpvars(0, port_tb);
        // inicjalizacja
        rst = 0;
        #10
        rst = 1;
        wr_DDRx = 0;
        wr_PORTx = 0;
        dane = 0;
        nr_P_DDRx = 0;
        nr_P_PORTx = 0;
        nr_P_PINx = 0;
        SW_A_driver = 8'h00;
        SW_B_driver = 8'h00;

        #20;
        rst = 0;

        $display("---- RESET DONE ----");
    
        // ustawienie DDR: port A i B jako wejścia, port C jako wyjście
        nr_P_DDRx = 0; dane = 8'b00000000; wr_DDRx = 1; //8'b11111110
        #10;
        wr_DDRx = 0;
        #10;
        nr_P_DDRx = 1; dane = 8'h00; wr_DDRx = 1; #10;
        wr_DDRx = 0;
        #10;
        nr_P_DDRx = 2; dane = 8'hFF; wr_DDRx = 1; #10;
        wr_DDRx = 0;
        #10;

        // $display("DDR ustawione: A=%h B=%h C=%h", 
        //          uut.rejestr_DDR[0], uut.rejestr_DDR[1], uut.rejestr_DDR[2]);

        // // zapis do PORT C (LED)
        // nr_P_PORTx = 2; dane = 8'hA5; wr_PORTx = 1; #10;
        // wr_PORTx = 0;
        // #10;
        // $display("PORT C po zapisie: %h", uut.rejestr_PORT[2]);
        // $display("in_out_C = %h, out = %h", in_out_C, out);

        // ustawienie PIN do odczytu z portu C
        // nr_P_PINx = 2;
        // #10;
        // $display("Odczyt out z portu C: %h", out);

        // symulacja zmian SW_A i SW_B
        SW_A_driver = 8'h01; // przycisk wcisniety
        #10;
        SW_B_driver = 8'h04;
        #10;
        nr_P_PINx = 0; #10; //$display("Odczyt out z portu A: %h", out);
        nr_P_PINx = 1; #10; //$display("Odczyt out z portu B: %h", out);

        dane = SW_A_driver + SW_B_driver;
        wr_PORTx = 1;
        nr_P_PORTx = 2;


        #100;
        $display("---- TEST DONE ----");
        $finish;
    end

endmodule