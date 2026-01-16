`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////


module pamiec_prog_tb;

    localparam ADDR_WIDTH = 8;
    localparam DATA_WIDTH = 15;

    // Sygnały
    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] out;

    // Instancja ROM
    pamiec_prog #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .a(addr),
        .out(out)
    );

    initial begin
        $dumpfile("pamiec_prog_tb.vcd"); // do GTKWave
        $dumpvars(0, pamiec_prog_tb);

        // Iterujemy po adresach 0-15 (bo w pliku są liczby 0-15)
        for (int i = 0; i <= 255; i++) begin
            addr = i;
            #10; // małe opóźnienie, żeby przypisanie się "rozpropagowało"
            //$display("Addr = %0d, Out = %0d", addr, out);
        end

        $finish;
    end
    
endmodule