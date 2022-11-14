//APB Interface

interface apb_intf(input Pclk);
 
  logic  Pwrite;
  logic [`DATA_WIDTH-1:0] Pwdata;
  logic [`ADDR_WIDTH-1:0]  Paddr;
  logic [`DATA_WIDTH-1:0] Prdata;
  logic Penable;
  logic Pready;
  logic Psel;
  logic Pslverr;

  
endinterface