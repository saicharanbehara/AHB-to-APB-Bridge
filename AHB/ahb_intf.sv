//AHB Inyerface

interface ahb_intf(input Hclk);
  
  logic  Hwrite;
  logic [`DATA_WIDTH-1:0] Hwdata;
  logic [`ADDR_WIDTH-1:0] Haddr;
  logic [`DATA_WIDTH-1:0] Hrdata;
  logic Hresp,lock;
  logic Hreadyout;
  logic Hreadyin;
  logic Hsel;
  logic [1:0] Htrans;
  logic [2:0] Hsize;
  logic [2:0] Hburst;
  logic [3:0] Hprot;
 
  
endinterface