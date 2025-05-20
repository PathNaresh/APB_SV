`include "apb_design.sv"

module apb_tb;

    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 8;

    reg PCLK;
    reg PRESETn;
    reg [ADDR_WIDTH-1:0] PADDR;
    reg PSEL;
    reg PENABLE;
    reg PWRITE;
    reg [DATA_WIDTH-1:0] PWDATA;
    wire [DATA_WIDTH-1:0] PRDATA;
    wire PREADY;

    apb_slave #(DATA_WIDTH, ADDR_WIDTH) uut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PADDR(PADDR),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY)
    );

    initial PCLK = 0;
    always #5 PCLK = ~PCLK;  // 10ns clock

    task apb_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
        begin
            @(negedge PCLK);
            PADDR = addr;
            PWDATA = data;
            PWRITE = 1;
            PSEL = 1;
            PENABLE = 0;
            @(negedge PCLK);
            PENABLE = 1;
            @(posedge PCLK);  // Wait for response
            while (!PREADY) @(posedge PCLK);
            @(negedge PCLK);
            $display("WRITE to %0h = %0h", addr, PWDATA);
            PSEL = 0;
            PENABLE = 0;
        end
    endtask

    task apb_read(input [ADDR_WIDTH-1:0] addr);
        begin
            @(negedge PCLK);
            PADDR = addr;
            PWRITE = 0;
            PSEL = 1;
            PENABLE = 0;
            @(negedge PCLK);
            PENABLE = 1;
            @(posedge PCLK);
            while (!PREADY) @(posedge PCLK);
            @(negedge PCLK);
            $display("Read from %0h = %0h", addr, PRDATA);
            PSEL = 0;
            PENABLE = 0;
        end
    endtask

    initial begin
        // VCD setup
        $dumpfile("apb.vcd");
        $dumpvars(0, apb_tb);

        // Initialization
        PRESETn = 0;
        PADDR = 0;
        PSEL = 0;
        PENABLE = 0;
        PWRITE = 0;
        PWDATA = 0;

        #20 PRESETn = 1;

        // Write transactions
        apb_write(8'h10, 32'hA5A5A5A5);
        apb_write(8'h20, 32'h12345678);

        // Read transactions
        apb_read(8'h10);
        apb_read(8'h20);

        #20;
        $finish;
    end
endmodule
