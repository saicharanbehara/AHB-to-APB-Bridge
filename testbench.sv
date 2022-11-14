`include "uvm_macros.svh"
import uvm_pkg::*;
`include "definition.sv"
`include "ahb_intf.sv"
`include "apb_intf.sv"
`include "package.sv"
`include "test.sv"

module tb_top;
  logic clk;
  logic reset;
  initial begin
    clk=1'b0;
    forever 
      #10 clk = ~clk;
  end
   initial begin 
    reset = 1'b0;
    #10;
    reset = 1'b1;
  end 

  
  ahb_intf ahb_vif(clk);
  apb_intf apb_vif(clk);
  
  
AHBLite_APB_Bridge DUT (.HRESETn (reset), .HCLK(clk), .HSEL(ahb_vif.Hsel), .HADDR(ahb_vif.Haddr), .HWDATA(ahb_vif.Hwdata), .HWRITE(ahb_vif.Hwrite), .HSIZE(ahb_vif.Hsize), .HBURST(ahb_vif.Hburst), .HPROT(ahb_vif.Hprot), .HTRANS(ahb_vif.Htrans), .HMASTERLOCK(ahb_vif.lock), .HREADYIN(ahb_vif.Hreadyin), .HREADYOUT(ahb_vif.Hreadyout), .HRDATA(ahb_vif.Hrdata), .HRESP(ahb_vif.Hresp), .PRESETn(reset), .PSEL(apb_vif.Psel), .PCLK(clk), .PENABLE(apb_vif.Penable), .PWRITE(apb_vif.Pwrite), .PADDR(apb_vif.Paddr), .PWDATA(apb_vif.Pwdata), .PRDATA(apb_vif.Prdata), .PREADY(apb_vif.Pready), .PSLVERR(apb_vif.Pslverr));
  
  initial begin
    uvm_config_db#(virtual ahb_intf)::set(uvm_root::get(), "*", "ahb_vif", ahb_vif);
    uvm_config_db#(virtual apb_intf)::set(uvm_root::get(), "*", "apb_vif", apb_vif);
  end
  
  initial begin
    run_test("test");
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb_top);
  end

endmodule
  
  


