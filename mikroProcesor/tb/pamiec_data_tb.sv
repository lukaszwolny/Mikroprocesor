`timescale 1ns/1ps

module pamiec_data_tb;

    parameter ADDR_WIDTH = 8;
    parameter DATA_WIDTH = 8;
    parameter STRONY_WIDTH = 4;

    // sygnały
    logic clk;
    logic wr_mem;
    logic [7:0] adres;
    logic [7:0] dane;
    logic [7:0] out;
    logic rst;

    // instancja modułu
    pamiec_data DUT (
        .clk(clk),
        .rst(rst),
        .wr_mem(wr_mem),
        .adres(adres),
        .dane(dane),
        .out(out)
    );

    // zegar 100 MHz
    initial clk = 1;
    always #5 clk = ~clk;

//===================

     // Zadania pomocnicze - POPRAWIONE!
    task zapisz(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
        begin
            adres = addr;
            dane = data;
            wr_mem = 1;
            @(posedge clk);  // Czekaj na zbocze
            #1; // Czekaj na stabilizację po zboczu
            $display("[%0t] ZAPIS: adres=%0d(0x%h), dane=0x%h, out=0x%h", 
                     $time, addr, addr, data, out);
            // NIE ZERUJ wr_mem od razu! Poczekaj do następnego taktu
            wr_mem = 0;
            // Pusty cykl między operacjami
            @(posedge clk);
            #1;
        end
    endtask
    
    task odczytaj(input [ADDR_WIDTH-1:0] addr);
        begin
            adres = addr;
            wr_mem = 0;
            // Czekaj cały cykl na odczyt
            @(posedge clk);
            #1;
            $display("[%0t] ODCZYT: adres=%0d(0x%h), out=0x%h", 
                     $time, addr, addr, out);
            // Pusty cykl między operacjami
            @(posedge clk);
            #1;
        end
    endtask
    
    task zmien_strone(input [STRONY_WIDTH-1:0] strona);
        begin
            zapisz({ADDR_WIDTH{1'b1}}, {4'b0, strona});
        end
    endtask
    
    task sprawdz(input [DATA_WIDTH-1:0] expected, string message = "");
        begin
            if (out !== expected) begin
                $display("[%0t] BŁĄD: Oczekiwano 0x%h, otrzymano 0x%h %s",
                         $time, expected, out, message);
                $finish;
            end else begin
                $display("[%0t] OK: 0x%h %s", $time, out, message);
            end
        end
    endtask
    
    // ===== POPRAWIONA SEKWENCJA TESTU =====
    initial begin
        
        $display("\n=== START TESTU PAMIĘCI STRONICOWANEJ ===");
        $display("Rozmiar strony: %0d bajtów", 1 << ADDR_WIDTH);
        $display("Liczba stron: %0d", 1 << STRONY_WIDTH);
        
        // Inicjalizacja
        rst = 0;
        wr_mem = 0;
        adres = 0;
        dane = 0;
        @(posedge clk);
        
        // --------------------
        // 1. RESET
        // --------------------
        $display("\n--- 1. TEST RESETU ---");
        rst = 1;
        @(posedge clk);
        @(posedge clk); // Dwa takty resetu
        rst = 0;
        @(posedge clk);
        #1;
        
        // Sprawdź czy rejestr strony wyzerowany
        odczytaj(255);
        sprawdz(8'h00, "Rejestr strony po resecie");
        
        // --------------------
        // 2. TEST ZAPISU/ODCZYTU NA STRONIE 0
        // --------------------
        $display("\n--- 2. TEST STRONY 0 (domyślna) ---");
        
        // Zapisz na różnych adresach strony 0
        zapisz(0, 8'h01);
        zapisz(100, 8'hAA);
        zapisz(200, 8'hBB);
        zapisz(254, 8'hCC);
        
        // Odczytaj te same adresy (każdy w osobnym cyklu!)
        odczytaj(0);
        sprawdz(8'h01, "Adres 0 strony 0");
        
        odczytaj(100);
        sprawdz(8'hAA, "Adres 100 strony 0");
        
        odczytaj(200);
        sprawdz(8'hBB, "Adres 200 strony 0");
        
        odczytaj(254);
        sprawdz(8'hCC, "Adres 254 strony 0");
        
        // --------------------
        // 3. TEST ZMIANY STRONY
        // --------------------
        $display("\n--- 3. TEST ZMIANY NA STRONĘ 5 ---");
        zmien_strone(5);
        
        // Sprawdź rejestr strony
        odczytaj(255);
        sprawdz(8'h05, "Rejestr strony = 5");
        
        // Zapisz na TEJ SAMEJ lokalizacji ale innej stronie
        zapisz(0, 8'h11);
        zapisz(100, 8'h55);
        zapisz(200, 8'h66);
        
        // Odczytaj ze strony 5
        odczytaj(0);
        sprawdz(8'h11, "Adres 0 strony 5");
        
        odczytaj(100);
        sprawdz(8'h55, "Adres 100 strony 5");
        
        odczytaj(200);
        sprawdz(8'h66, "Adres 200 strony 5");
        
        // --------------------
        // 4. TEST POWROTU DO STRONY 0
        // --------------------
        $display("\n--- 4. TEST POWROTU DO STRONY 0 ---");
        zmien_strone(0);
        
        odczytaj(255);
        sprawdz(8'h00, "Rejestr strony = 0");
        
        // Sprawdź czy dane na stronie 0 nadal są
        odczytaj(0);
        sprawdz(8'h01, "Adres 0 strony 0 (nadal 0x01)");
        
        odczytaj(100);
        sprawdz(8'hAA, "Adres 100 strony 0 (nadal 0xAA)");
        
        // --------------------
        // 5. TEST WRITE-THROUGH - KLUCZOWY TEST!
        // --------------------
        $display("\n--- 5. TEST WRITE-THROUGH (1-cyklowy CPU) ---");
        
        // SCENARIUSZ: CPU 1-cyklowe - zapis i odczyt w "tym samym" cyklu
        #9;
        $display("\nScenariusz A: Zapis i NATYCHMIASTOWY odczyt w tym samym cyklu");
        adres = 80;
        dane = 8'h77;
        wr_mem = 1;
        #1; // Połowa taktu - sprawdź czy out ma już nową wartość
        if (out !== 8'h77) begin
            $display("BŁĄD: Write-through nie działa! out=0x%h, oczekiwano 0x77", out);
            #50;$finish;
        end
        $display("OK: out=0x%h (write-through działa natychmiast)", out);
        
        // Zakończ zapis
        @(posedge clk);
        #1;
        wr_mem = 0;
        
        // Odczyt w następnym cyklu (powinno być to samo)
        $display("\nScenariusz B: Odczyt w następnym cyklu");
        odczytaj(80);
        sprawdz(8'h77, "Odczyt po zapisie");
        
        // --------------------
        // 6. TEST SZYBKIEGO NADPISYWANIA
        // --------------------
        $display("\n--- 6. TEST SZYBKIEGO NADPISYWANIA ---");
        
        zmien_strone(3);
        
        // Cykl 1: Pierwszy zapis
        adres = 90;
        dane = 8'h33;
        wr_mem = 1;
        @(posedge clk);
        #1;
        sprawdz(8'h33, "Cykl 1: Zapis 0x33, out=0x33");
        
        // Cykl 2: Nadpisanie (bez zerowania wr_mem między!)
        dane = 8'h44;
        @(posedge clk);
        #1;
        sprawdz(8'h44, "Cykl 2: Nadpisanie 0x44, out=0x44");
        
        // Cykl 3: Odczyt
        wr_mem = 0;
        @(posedge clk);
        #1;
        sprawdz(8'h44, "Cykl 3: Odczyt 0x44 z pamięci");
        
        // --------------------
        // 7. TEST REJESTRU STRONY
        // --------------------
        $display("\n--- 7. TEST REJESTRU STRONY ---");
        
        // Zapis rejestru strony
        adres = 255;
        dane = 8'h09; // Strona 9
        wr_mem = 1;
        @(posedge clk);
        #1;
        sprawdz(8'h09, "Zapis strony 9 - out pokazuje zapisywaną wartość");
        wr_mem = 0;
        
        // Odczyt rejestru strony
        @(posedge clk);
        #1;
        sprawdz(8'h09, "Odczyt strony 9 z rejestru");
        
        // Zapisz coś używając nowej strony
        adres = 50;
        dane = 8'h99;
        wr_mem = 1;
        @(posedge clk);
        #1;
        sprawdz(8'h99, "Zapis 0x99 na stronie 9, adres 50");
        wr_mem = 0;
        
        // --------------------
        // 8. TEST WSZYSTKICH STRON
        // --------------------
        $display("\n--- 8. TEST WSZYSTKICH 16 STRON ---");
        
        for (int strona = 0; strona < 16; strona++) begin
            // Ustaw stronę
            adres = 255;
            dane = strona;
            wr_mem = 1;
            @(posedge clk);
            #1;
            wr_mem = 0;
            
            // Zapisz unikalną wartość
            adres = 50;
            dane = 8'h10 + strona;
            wr_mem = 1;
            @(posedge clk);
            #1;
            wr_mem = 0;
            
            // Odczytaj i sprawdź
            @(posedge clk);
            #1;
            if (out !== (8'h10 + strona)) begin
                $display("BŁĄD: Strona %0d - out=0x%h, oczekiwano 0x%h", 
                        strona, out, 8'h10 + strona);
                $finish;
            end
            $display("OK: Strona %0d - 0x%h", strona, out);
            
            // Pusty cykl między stronami
            @(posedge clk);
        end
        
        // --------------------
        // 9. TEST "CZARNEJ DZIURY"
        // --------------------
        $display("\n--- 9. TEST CZARNEJ DZIURY ---");
        $display("UWAGA: Fizyczny adres 255 w RAM jest niedostępny!");
        
        // Wróć do strony 0
        adres = 255;
        dane = 0;
        wr_mem = 1;
        @(posedge clk);
        #1;
        wr_mem = 0;
        
        // Potwierdź że adres 255 zawsze zwraca rejestr strony
        odczytaj(255);
        sprawdz(8'h00, "Adres 255 = rejestr strony (0)");
        
        // Próba dostępu do fizycznego adresu 255 jest NIEMOŻLIWA
        $display("Fizyczny bajt 255: NIEDOSTĘPNY (rezerwacja na rejestr strony)");
        
        // --------------------
        // PODSUMOWANIE
        // --------------------
        $display("\n=== WSZYSTKIE TESTY ZALICZONE! ===");
        $display("Pamięć stronnicowana działa poprawnie:");
        $display("- 16 stron po 255 bajtów (4080 bajtów dostępnych)");
        $display("- 1 bajt zarezerwowany na rejestr strony (adres 255)");
        $display("- Write-through działa (dane dostępne w tym samym takcie)");
        $display("- Izolacja stron poprawna");
        $display("- Idealne dla 1-cyklowego CPU!");
        
        #100;
        $finish;
    end


//===================



    // // test sekwencyjny
    // initial begin
    //     // inicjalizacja
    //     rst = 1;
    //     wr_mem = 0;
    //     adres  = 0;
    //     dane   = 0;
    //     #10;
    //     rst = 0;
    //     #10;
    //     adres = 255;
    //     dane = 0;
    //     wr_mem = 1;
    //     #10;
    //     wr_mem = 0;

    //     #10;
    //     for(int i=100;i<50;i++) begin
    //         wr_mem = 1;
    //         adres  = i;
    //         dane   = 50 + i;
    //     end 
    //     #10;
    //     wr_mem = 0;
    //     #10;
    //     wr_mem = 1;
    //     adres  = 255;
    //     dane   = 5;
    //     #10;
    //     for(int i=0;i<50;i++) begin
    //         wr_mem = 1;
    //         adres  = i;
    //         dane   = 50 + i;
    //     end 

    //     // zapis do adresu 0
    //     @(posedge clk);
    //     wr_mem = 1;
    //     adres  = 8'd0;
    //     dane   = 8'hAA;
    //     @(posedge clk);
    //     wr_mem = 0;

        

    //     // zapis do adresu 1
    //     @(posedge clk);
    //     wr_mem = 1;
    //     adres  = 8'd1;
    //     dane   = 8'h55;
    //     @(posedge clk);
    //     wr_mem = 0;

    //     // zapis do adresu 10
    //     @(posedge clk);
    //     wr_mem = 1;
    //     adres  = 8'd10;
    //     dane   = 8'hCC;
    //     @(posedge clk);
    //     wr_mem = 0;


    //     @(posedge clk);
    //     wr_mem = 1;
    //     adres  = 8'd255;
    //     dane   = 8'h01;
    //     @(posedge clk);
    //     wr_mem = 0;
        
    //     @(posedge clk);
    //     wr_mem = 1;
    //     adres  = 8'd0;
    //     dane   = 8'hAA;
    //     @(posedge clk);
    //     wr_mem = 0;

    //     @(posedge clk);
    //     wr_mem = 1;
    //     adres  = 8'd55;
    //     dane   = 8'hAA;
    //     @(posedge clk);
    //     wr_mem = 0;

    //     // odczyty
    //     @(posedge clk);
    //     adres = 8'd0;
    //     #1 $display("Strona 1 Adres 0 = %h", out);

    //     @(posedge clk);
    //     wr_mem = 1;
    //     adres  = 8'd255;
    //     dane   = 8'h00;
    //     @(posedge clk);
    //     wr_mem = 0;

    //    @(posedge clk);
    //     adres = 8'd0;
    //     #1 $display("Strona 0 Adres 0 = %h", out);

    //     @(posedge clk);
    //     adres = 8'd1;
    //     #1 $display("Adres 1 = %h", out);

    //     @(posedge clk);
    //     adres = 8'd10;
    //     #1 $display("Adres 10 = %h", out);

    //     @(posedge clk);
    //     adres = 8'd2;
    //     #1 $display("Adres 2 (nie zapisany) = %h", out);

    //     #300;
    //     $finish;
    // end

    // opcjonalnie do GTKWave
    initial begin
        $dumpfile("pamiec_data_tb.vcd");
        $dumpvars(0, pamiec_data_tb);
    end

endmodule

/*

        // zapis do adresu 0
        @(posedge clk);
        wr_mem = 1;
        adres  = 8'd0;
        dane   = 8'hAA;
        @(posedge clk);
        wr_mem = 0;

        // zapis do adresu 1
        @(posedge clk);
        wr_mem = 1;
        adres  = 8'd1;
        dane   = 8'h55;
        @(posedge clk);
        wr_mem = 0;

        // zapis do adresu 10
        @(posedge clk);
        wr_mem = 1;
        adres  = 8'd10;
        dane   = 8'hCC;
        @(posedge clk);
        wr_mem = 0;

        // odczyty
        @(posedge clk);
        adres = 8'd0;
        #1 $display("Adres 0 = %h", out);

        @(posedge clk);
        adres = 8'd1;
        #1 $display("Adres 1 = %h", out);

        @(posedge clk);
        adres = 8'd10;
        #1 $display("Adres 10 = %h", out);

        @(posedge clk);
        adres = 8'd2;
        #1 $display("Adres 2 (nie zapisany) = %h", out);
*/