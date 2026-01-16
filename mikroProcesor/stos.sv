`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////


module stos#(
        parameter STOS_data_rozm = 8,
        parameter STOS_Rozm = 32
    )(
        input wire clk,
        input wire rst,
        input wire push,//sygnały push i pop
        input wire pop,
        input wire [STOS_data_rozm-1:0] data_in,
        output logic [STOS_data_rozm-1:0] data_out,
        output logic full,
        output logic empty
    );



    logic [STOS_data_rozm-1:0] stos_pamiec [STOS_Rozm-1:0];
    logic [$clog2(STOS_Rozm)-1:0] stos_ptr;

    always @( posedge clk ) begin : stos   //always_ff
        if(rst) begin
            for(int i=0;i < STOS_Rozm; i++) begin
                stos_pamiec[i] <= '0;
            end
            stos_ptr <= '0;
            full <= '0;
            empty <= '1;
        end else begin

            if(push && !pop) begin //bez !full.. bo to w ID jest..
                stos_pamiec[stos_ptr] <= data_in; //wpisuje pod 0
                stos_ptr <= stos_ptr + 1'b1;  // tutaj juz jest 1 - assign data_out wyswietli z pod 1. (dlatego -1 tam)
                empty <= '0;
                if(stos_ptr == STOS_Rozm - 1) full <= '1;
                //end
            end else if(pop && !push) begin //bez !empty bo to w ID
                stos_ptr <= stos_ptr - 1'b1;
                full <= '0;
                if(stos_ptr == 1) empty <= '1; // no bo potem bedzie 0
                //end
            end
            
        end
    end

    always @(*) begin : blockName   //always_comb
        if(pop && !empty) begin
           data_out = stos_pamiec[stos_ptr - 1];
        end else begin
           data_out = '0;
        end
    end

endmodule