`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
    pc.
    Moduł pc implementuje licznik rozkazów procesora. Licznik inkrementuje się o 1 przy każdym takcie zegara, chyba że aktywny jest sygnał skoku (skok_pc) lub reset (rst/ID_rst). Moduł obsługuje także skoki z wykorzystaniem adresu pobranego ze stosu (np. powrót z wywołania lub przerwania).

    REQ_PC:
        REQ_PC_1:
            Moduł musi przechowywać bieżący adres rozkazu w rejestrze PC_count o szerokości W.
        REQ_PC_2:
            Wartość PC_count musi być aktualizowana w każdym cyklu zegara clk.
        REQ_PC_3:
            Jeśli skok_pc = 1, licznik ma wykonać skok do adresu podanego na wejściu adres_skok_pc.
        REQ_PC_4:
            W przypadku aktywacji sygnału skoku (skok_pc) oraz sygnału powrotu z podprogramu (skok_pc_stos), licznik musi załadować nową wartość adresu bezpośrednio ze stosu do pc oraz zinkrementowa swoja nowa wartosc o 1.
        REQ_PC_5: 
            W przypadku aktywacji sygnału skoku (skok_pc) oraz sygnału powrotu z przerwania (skok_pc_stos, reti_int_en), licznik musi załadować nową wartość adresu bezpośrednio ze stosu do pc.  
        REQ_PC_6:
            Po odebraniu sygnału reset (rst) lub resetu licznika (ID_rst), zawartość akumulatora musi zostać wyzerowana w ciągu jednego cyklu zegarowego.

*/
//////////////////////////////////////////////////////////////////////////////////

module pc
    #(
        parameter W = 8
    )(
        input wire clk,
        input wire rst,
        input wire ID_rst,
        input wire skok_pc,
        input wire skok_pc_stos,
        input wire [7:0] adres_skok_pc, // z rozkazu
        input wire [7:0] adres_skok_pc_stos, // ze stosu
        output logic [W-1:0] PC_count,
        input wire reti_int_en // jak reti to int_en jest + skok_pc i skok_pc_stos i wtedy bez +1
    );

    always @( posedge clk ) begin : LicznikRozkazow  //always_ff  always @( posedge clk )
        if(rst || ID_rst) PC_count <= '0;
        else if(skok_pc) begin   /*if(ID_ink)*/ 
            if(skok_pc_stos) begin
                PC_count <= adres_skok_pc_stos + ((reti_int_en) ? 1'b0 : 1'b1); // +1 żeby przejsc do nastepnej instrukcji dla CALL.
            end else begin
                PC_count <= adres_skok_pc;
            end
        end else PC_count <= PC_count + 1'b1;
    end

endmodule