//////////////////////////
//Przerwanie bez masek i priorytet ma zewnetrzne przerwanie nad licznikiem

//////////////////////////

module przerwanie(
    input wire clk,
    input wire rst,

    //enable, disable .. z ID
    input wire int_enable,//sei  + RETI
    input wire int_disable,//cli

    //zrodla
    input wire ext_int,//zewnetrzne przerwanie .. przycisk
    input wire timer_int,//wewnetrzne przerwanie z licznika
    output logic [7:0] int_vector, //wektor przerwania

    output logic przerwanie
);

//rejestr
//rejestr na wejsciu od ext_int sygnalizuje ze pojawilo sie zbocze np i RETI to resetuje dopiero
logic przerwanie_en;//SREG

logic ext_int_prev;//do wykrycia zbocza
logic timer_int_prev;
logic int_a; // przerwanie przycisk
logic int_b; //przerwanie timer

//Interrupt Controller
/* To idzie najpierw do ID a potem do pc z ID idzie   */

always @(posedge clk) begin
    if(rst) begin
        przerwanie_en <= '0;
        przerwanie <= '0;
        //ext_int_en <= '0;//domyslnie nie ma przerwania
        ext_int_prev <= '0;
        timer_int_prev <= '0;
        int_a <= '0;
        int_b <= '0;
        int_vector <= '0;
    end else begin
        
        przerwanie <= '0;
        int_vector <= '0;

        if(int_enable) begin
            przerwanie_en <= 1'b1; 
        end else if(int_disable) begin
            przerwanie_en <= 1'b0; 
        end

        //zbocze i ext_int_en
        ext_int_prev <= ext_int;
        timer_int_prev <= timer_int;
        if(przerwanie_en && ext_int && ~ext_int_prev) begin
            int_a <= 1'b1;
        end
        if(przerwanie_en && timer_int && ~timer_int_prev) begin
            int_b <= 1'b1;
        end

        //priorytet
        if(int_a && przerwanie_en) begin
            przerwanie <= 1'b1;
            int_vector <= 8'h02;
            int_a <= '0;
        end else if(int_b && przerwanie_en && ~przerwanie) begin
            przerwanie <= 1'b1;
            int_vector <= 8'h04;
            int_b <= '0;
        end
    end
end

endmodule