module apb_slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 8
)(
    input wire PCLK,
    input wire PRESETn,
    input wire [ADDR_WIDTH-1:0] PADDR,
    input wire PSEL,
    input wire PENABLE,
    input wire PWRITE,
    input wire [DATA_WIDTH-1:0] PWDATA,
    output reg [DATA_WIDTH-1:0] PRDATA,
    output reg PREADY
);

    // Memory space
    reg [DATA_WIDTH-1:0] mem [0:2**ADDR_WIDTH-1];

    // main logic
    always @(posedge PCLK or negedge PRESETn) begin

      if (!PRESETn) begin
        PREADY <= 0;
        PRDATA <= 0;
      end

      else begin
        PREADY <= 0;
        if (PSEL && PENABLE) begin
          PREADY <= 1;
          if(PWRITE) begin
            mem[PADDR] <= PWDATA;
          end
	  else begin
            PRDATA <= mem[PADDR];
          end
        end
      end

    end

endmodule
