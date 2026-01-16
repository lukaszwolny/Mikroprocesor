////////////////////
//iverilog -g2012 -o stos_tb.vvp ../stos.sv stos_tb.sv 

//////////////////////


module stos_tb;
    localparam A = 8;
    localparam B = 5;
   
    logic clk;
    logic rst;
    logic push;
    logic pop;
    logic stos_MUX;
    logic [A-1:0] data_pc;
    logic [A-1:0] data_acc;
    logic [A-1:0] data_out;
    logic full;
    logic empty;

    stos #(
        .STOS_data_rozm(A),
        .STOS_Rozm(B)
    ) u_stos(
        .*
    );  

    initial clk = 1;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("stos_tb.vcd");
        $dumpvars(0, stos_tb);
    end

    initial begin
        rst = 0;
        push = 0;
        pop = 0;
        stos_MUX = 0;
        data_acc = 0;
        data_pc = 0;
        #10;
        rst = 1;
        #10;
        rst = 0;
        #10;
        stos_MUX = 0;
        data_acc = 8'hAA;
        data_pc = 8'hBB;
        #10;
        push = 1;
        #10;
        push = 0;
        #10;
        pop = 1;
        #10;
        pop = 0;
        #10;
        // @(posedge clk);
        // push = 1;

        // @(posedge clk);
        // push = 0;
        // @(posedge clk);
        // pop = 1;
        // @(posedge clk);
        // pop = 0;

        // //pusty juz
        // for(int i=0; i < B - 1; i++) begin
        //     data_acc = i + 1;
        //     push = 1;
        //     #10;
        //     push = 0;
        //     #10;
        // end
        // #10;
        // for(int i=0; i < B - 1; i++) begin
        //     pop = 1;
        //     #10;
        //     pop = 0;
        //     #10;
        // end
//===========================================
        // #20;
        // for(int i=0; i < 4; i++) begin
            
        //     data_acc = 8'h0A + i;
        //     $display("PUSH wskaznik wskazuje na (przed push)=  %h", u_stos.stos_ptr);
        //     push = 1;
        //     #10;
        //     push = 0;
        //     $display("PUSH   stos = %h", u_stos.stos_pamiec[i]);
        //     $display(" PUSH  wskaznik wskazuje na (po push)=  %h", u_stos.stos_ptr);
        //     #10;
        // end
        // #20;
        // for(int i=0; i < 4; i++) begin
        //     //data_acc = 8'h0A + i;
        //     $display("POP wskaznik wskazuje na (przed POP)=  %h", u_stos.stos_ptr);
        //     pop = 1;
        //     #10;
        //     pop = 0;
        //     $display("POP wskaznik wskazuje na (po POP)=  %h", u_stos.stos_ptr);
        //     $display("POP   stos = %h", u_stos.stos_pamiec[u_stos.stos_ptr]);
        //     $display("data out = %h", u_stos.data_out);
        //     $display(" POP  wskaznik wskazuje na (po POP -KONIEC-)=  %h", u_stos.stos_ptr);            
        //     #10;
        // end             

        #300;
        $finish;
    end

endmodule