module przerwanie_tb;

logic clk;
logic rst;

logic int_enable;
logic int_disable;

logic ext_int;
logic timer_int;

logic [7:0] int_vector;

logic przerwanie;


przerwanie u_przerwanie(
    .clk(clk),
    .rst(rst),

    .int_enable(int_enable),
    .int_disable(int_disable),

    //zrodla
    .ext_int(ext_int),//zewnetrzne przerwanie .. przycisk
    .timer_int(timer_int),//wewnetrzne przerwanie z licznika

    //bez tego bo autoamtucznie jak pojawi sie przerwanie bedzie cli a RETI bedzie sei.
    //input wire ext_int_rst,//reset do przerwania z ID .. RETI


    .int_vector(int_vector), //wektor przerwania
    //On bedzie w stylu gdzies na koncu 250. a drugie przerwanie 252 254 i dokadajac wiecej pamieci prog to najstawrsze nowe bity beda jedynkami....
    .przerwanie(przerwanie)

);

initial clk = 1;
always #5 clk = ~clk;

initial begin
    $dumpfile("przerwanie_tb.vcd");
    $dumpvars(0, przerwanie_tb);
end

initial begin
    rst = 1;
    int_enable = 0;
    int_disable = 0;

    ext_int = 0;
    timer_int = 0;
    #10;
    rst = 0;
    #10;
    int_enable = 1;
    #10;
    int_enable = 0;
    #50;
    ext_int = 1;
    timer_int = 1;
    #10;
    timer_int = 0;
    int_disable = 1; //wykonywanie sie przerwaniaa
    #10
    int_disable = 0;
    #20;
    ext_int = 0;
    int_enable = 1;//wlaczenie spowrote - teraz b powinno
    #10;
    int_enable = 0;

    #50; //nowe testy
    timer_int = 1;
    #10;
    timer_int = 0;

    #500;
    $finish;

end

endmodule