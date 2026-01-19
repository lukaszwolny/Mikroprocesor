`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
    Dekoder rozkazow.

    REQ_Dekoder:
      REQ_Dekoder_1:
        
*/
//////////////////////////////////////////////////////////////////////////////////

module ID#(
        parameter I_WIDTH = 16,
        parameter ID_rozm_dana = 8,
        parameter ID_rozm_adres = 8
    )
    (
        input wire [I_WIDTH-1:0] rozkaz,

        output logic [2:0] nr_Rx,
        output logic [ID_rozm_adres-1:0] adres,
        output logic [ID_rozm_dana-1:0] wartosc_IM,
        output logic [1:0] nr_P_DDRx,
        output logic [1:0] nr_P_PORTx,
        output logic [1:0] nr_P_PINx,

        //sterujace
        output logic ID_rst,
        output logic wr_Rx,// do Rx
        output logic MUX_adres,//adres albo Rx(posrednie adresowanie) do MEM
        output logic wr_MEM,
        output logic wr_DDRx,
        output logic wr_PORTx,
        output logic [2:0] MUX_IM_Rx_MEM_PORT,
        output logic A_ce,
        output logic [3:0] ALU_op,//operacje do alu

        //pc skoki
        output logic skok_ID,
        output logic [7:0] adres_skok_ID,

        //flagi
        output logic C_OV_en,
        input wire P_in, OV_in, Z_in, S_in, C_in,
        output logic C_OV_kasowanie,
        // output logic flagi_en,

        //Stos
        output logic ID_push,
        output logic ID_pop,
        input wire ID_stos_empty,
        input wire ID_stos_full,

        //pc - stos
        output logic ID_push_pc,
        output logic ID_pop_pc,
        input wire ID_stos_pc_empty,
        input wire ID_stos_pc_full,
        output logic skok_pc_ID,

        //przerwanie
        output logic int_en,
        output logic int_dis,
        input wire [7:0] int_vec,
        input wire jest_przerwanie,

        //licznik
        output logic [7:0] licznik_wartosc,
        output logic ID_zapisz_L,
        output logic ID_zapisz_H,
        output logic ID_zapisz_control,
        output logic ID_flaga_clear_licznik,
        input wire ID_flaga_licznik,

        output logic ID_dioda_error
    );

    logic [4:0] instrukcja;

    always @(*)  begin : ID_always   //always_comb   always @(*)  begin : ID_always
        instrukcja = rozkaz[15:11]; 
        
        nr_Rx = '0;
        adres = '0;
        wartosc_IM = '0;
        nr_P_DDRx = '0;
        nr_P_PORTx = '0;
        nr_P_PINx = '0;

        ID_rst = '0;
        wr_Rx = '0;
        MUX_adres = '0;
        wr_MEM = '0;
        wr_DDRx = '0;
        wr_PORTx = '0;
        MUX_IM_Rx_MEM_PORT = '0;
        A_ce = '0;
        ALU_op = '0;   
        //------------------------------
        skok_ID = '0;
        adres_skok_ID = '0;
        //------------------------------
        C_OV_en = '0;
        C_OV_kasowanie = '0;
        //------------------------------
        ID_push = '0;
        ID_pop = '0;
        ID_push_pc = '0;
        ID_pop_pc = '0;
        skok_pc_ID = '0;
        //-----------------------
        int_en = '0;
        int_dis = '0;
        //-----------------------
        licznik_wartosc = '0;
        ID_zapisz_L = '0;
        ID_zapisz_H = '0;
        ID_zapisz_control = '0;
        ID_flaga_clear_licznik = '0;
        //-----------------------
        ID_dioda_error = '0;

        //Najpierw przerwanie
        if(jest_przerwanie) begin
            int_dis = '1;//off  + zapis na stos + zapis pc wketor przerwaia
            skok_ID = '1;
            ID_push_pc = '1;
            adres_skok_ID = int_vec;
            skok_pc_ID = '0;
        end else begin //normalne dekodowanie
            //--------
            //case
            case(instrukcja)
                5'b00000: begin
                    //RST
                    ID_rst = '1;
                end
                5'b00001: begin
                    //LD
                    case(rozkaz[10:8])
                        3'b000: begin
                            //address
                            MUX_adres = '0;
                            adres = rozkaz[7:0];
                            MUX_IM_Rx_MEM_PORT = 3'b010;//2
                            ALU_op = rozkaz[15:12];
                            A_ce = '1;
                        end
                        3'b001: begin
                            //Rx
                            nr_Rx = rozkaz[2:0];
                            MUX_IM_Rx_MEM_PORT = 3'b001;//1
                            ALU_op = rozkaz[15:12];
                            A_ce = '1;
                        end
                        3'b010: begin
                            //PINx
                            nr_P_PINx = rozkaz[1:0]; //1bit
                            MUX_IM_Rx_MEM_PORT = 3'b011;//3
                            ALU_op = rozkaz[15:12];
                            A_ce = '1;
                        end
                        3'b011: begin
                            //IM - zmienna
                            wartosc_IM = rozkaz[7:0]; //1bit
                            MUX_IM_Rx_MEM_PORT = 3'b000;//0
                            ALU_op = rozkaz[15:12];
                            A_ce = '1;
                        end
                        3'b100: begin
                            //@Rx
                            nr_Rx = rozkaz[2:0];
                            MUX_adres = '1;
                            MUX_IM_Rx_MEM_PORT = 3'b010;//2
                            ALU_op = rozkaz[15:12];
                            A_ce = '1;
                        end
                    endcase
                end
                5'b00010: begin
                    //AND
                    ALU_op = rozkaz[15:12];
                    A_ce = '1;
                    MUX_IM_Rx_MEM_PORT = 3'b001;//1
                    nr_Rx = rozkaz[2:0];
                    C_OV_kasowanie = '1;
                end
                5'b00011: begin
                    //ST
                    case(rozkaz[9:8])
                        2'b00: begin
                            //address
                            wr_MEM = '1;
                            MUX_adres = '0;
                            adres = rozkaz[7:0];
                        end
                        2'b01: begin
                            //Rx
                            wr_Rx = '1;
                            nr_Rx = rozkaz[2:0];
                        end
                        2'b10: begin
                            //PORTx
                            wr_PORTx = '1;
                            nr_P_PORTx = rozkaz[1:0];
                        end
                        2'b11: begin
                            //DDRx
                            wr_DDRx = '1;
                            nr_P_DDRx = rozkaz[1:0];
                        end
                    endcase
                end
                //---
                5'b00100: begin
                    //JMP
                    skok_ID = '1;
                    adres_skok_ID = rozkaz[7:0];
                end
                //--
                5'b00101: begin
                    //OR
                    ALU_op = rozkaz[15:12];
                    A_ce = '1;
                    MUX_IM_Rx_MEM_PORT = 3'b001;//1
                    nr_Rx = rozkaz[2:0];
                    C_OV_kasowanie = '1;
                end
                5'b00110: begin
                    //XOR
                    ALU_op = rozkaz[15:12];
                    A_ce = '1;
                    MUX_IM_Rx_MEM_PORT = 3'b001;//1
                    nr_Rx = rozkaz[2:0];
                    C_OV_kasowanie = '1;
                    //ID_ink = '1;
                end
                5'b00111: begin
                    //JZ
                    if(Z_in) begin
                        skok_ID = '1;
                        adres_skok_ID = rozkaz[7:0];                    
                    end
                end

                5'b01000: begin
                    //???
                    //NOP
                end
                5'b01001: begin
                    //ADD
                    ALU_op = rozkaz[15:12];
                    A_ce = '1;
                    MUX_IM_Rx_MEM_PORT = 3'b001;//1
                    nr_Rx = rozkaz[2:0];
                    C_OV_en = '1;
                end
                5'b01010: begin
                    //SUB
                    ALU_op = rozkaz[15:12];
                    A_ce = '1;
                    MUX_IM_Rx_MEM_PORT = 3'b001;//1
                    nr_Rx = rozkaz[2:0];
                    C_OV_en = '1;
                end
                5'b01011: begin
                    //JNZ
                    if(!Z_in) begin
                        skok_ID = '1;
                        adres_skok_ID = rozkaz[7:0];                    
                    end                
                end
                5'b01100: begin
                    //JC
                    if(C_in) begin
                        skok_ID = '1;
                        adres_skok_ID = rozkaz[7:0];                    
                    end                
                end
                5'b01101: begin
                    //INC
                    ALU_op = rozkaz[15:12];
                    A_ce = '1;
                end
                5'b01110: begin
                    //NOT
                    ALU_op = rozkaz[15:12];
                    A_ce = '1;
                    C_OV_kasowanie = '1;   
                end
                5'b01111: begin
                    //JP
                    if(P_in) begin
                        skok_ID = '1;
                        adres_skok_ID = rozkaz[7:0];                    
                    end                    
                end
                
                5'b11000: begin
                    //SEI  -- on
                    int_en = '1;
                end
                5'b11001: begin
                    //CLI  -- off
                    int_dis = '1;        
                end
                5'b11010: begin
                    //RETI  -- powrot z przerwania. on+ze stosu
                    int_en = '1;
                    ID_pop_pc = '1;
                    skok_ID = '1;
                    skok_pc_ID = '1;                    
                end
                5'b11011: begin
                    //TIMER_SET_L  --ustawia wartosc wartosc-max.
                    licznik_wartosc = rozkaz[7:0];
                    ID_zapisz_L = '1;
                end
                5'b11100: begin
                    //TIMER_READ -- IF flagi  JF
                    if(ID_flaga_licznik) begin
                        skok_ID = '1;
                        adres_skok_ID = rozkaz[7:0];
                        ID_flaga_clear_licznik = '1;
                    end
                end
                5'b11101: begin
                    //TIMER_CTRL  --ctr
                    licznik_wartosc = rozkaz[7:0];
                    ID_zapisz_control = '1;
                end
                5'b11110: begin
                    //TIMER_SET_H
                    licznik_wartosc = rozkaz[7:0];
                    ID_zapisz_H = '1;
                end
                5'b11111: begin
                    //NOP
                end

                5'b10000: begin
                    //ADDC
                    ALU_op = rozkaz[15:12];
                    A_ce = '1;
                    MUX_IM_Rx_MEM_PORT = 3'b001;//1
                    nr_Rx = rozkaz[2:0];
                    C_OV_en = '1;                
                end
                5'b10001: begin
                    //JS
                    if(S_in) begin
                        skok_ID = '1;
                        adres_skok_ID = rozkaz[7:0];                    
                    end                 
                end
                5'b10010: begin
                    //JOV
                    if(OV_in) begin
                        skok_ID = '1;
                        adres_skok_ID = rozkaz[7:0];                    
                    end                 
                end
                5'b10011: begin
                    //SUBC
                    ALU_op = rozkaz[15:12];
                    A_ce = '1;
                    MUX_IM_Rx_MEM_PORT = 3'b001;//1
                    nr_Rx = rozkaz[2:0];
                    C_OV_en = '1;                
                end
                5'b10100: begin
                    //PUSH  STOS <- ACC
                    if(ID_stos_full) begin
                        //wyjatek od przpelnienia
                        skok_ID = '1;
                        adres_skok_ID = 8'b00000110; // 0x06 wyjatek
                        ID_dioda_error = '1;
                        int_dis = '1; // off przerwania
                    end else begin
                        ID_push = '1;
                    end
                end
                5'b10101: begin
                    //POP  ACC <- STOS
                    if(ID_stos_empty) begin
                        skok_ID = '1;
                        adres_skok_ID = 8'b00000110; // 0x06 wyjatek
                        ID_dioda_error = '1;
                        int_dis = '1;
                    end else begin
                        ID_pop = '1;
                        ALU_op = '0;
                        A_ce = '1;
                        MUX_IM_Rx_MEM_PORT = 3'b100;//4
                    end
                end
                5'b10110: begin
                    //CALL
                    if(ID_stos_pc_full) begin
                        skok_ID = '1;
                        adres_skok_ID = 8'b00000110; // 0x06 wyjatek
                        ID_dioda_error = '1;
                        int_dis = '1;
                    end else begin
                        skok_ID = '1;
                        ID_push_pc = '1;
                        adres_skok_ID = rozkaz[7:0];
                        skok_pc_ID = '0;
                    end
                end
                5'b10111: begin
                    //RET
                    if(ID_stos_pc_empty) begin
                        skok_ID = '1;
                        adres_skok_ID = 8'b00000110; // 0x06 wyjatek
                        ID_dioda_error = '1;
                        int_dis = '1;
                    end else begin
                        ID_pop_pc = '1;
                        skok_ID = '1;
                        skok_pc_ID = '1;
                    end
                end
                default: ;
            endcase        
        end //end else if 
    end

endmodule