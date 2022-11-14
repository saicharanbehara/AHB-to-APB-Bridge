//AHB Driver

class ahb_drv extends uvm_driver#(ahb_trans);
  
  ahb_trans tx;
  virtual ahb_intf ahb_vif;
  `uvm_component_utils(ahb_drv);
  extern function new(string name="ahb_drv",uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task drive(ahb_trans tx);
      
endclass
    
    function ahb_drv::new(string name="ahb_drv",uvm_component parent);
      super.new(name,parent);
    endfunction
    
    function void ahb_drv::build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db #(virtual ahb_intf)::get(this,"","ahb_vif",ahb_vif))
        `uvm_fatal("AHB Driver","error in getting interface");
      tx = ahb_trans::type_id::create("tx");
    endfunction
    
    task ahb_drv::drive(ahb_trans tx);
      @(posedge ahb_vif.Hclk);   //T1
      wait(ahb_vif.Hreadyout)
      ahb_vif.Hwrite = tx.Hwrite;
      ahb_vif.Haddr = tx.Haddr;
      ahb_vif.Hsel =  1'b1;
      ahb_vif.Hreadyin = 1;
      ahb_vif.Htrans = 2'b10;
      ahb_vif.Hsize = 3'b010;
      ahb_vif.Hburst = 1'b0;
      ahb_vif.lock = 0;
      ahb_vif.Hprot=4'b0011;
      @(posedge ahb_vif.Hclk);   //T2
      
      //Write Transfer
      
      if(ahb_vif.Hwrite) begin
        ahb_vif.Hwdata = tx.Hwdata;
      end
      
      //Read Transfer
      
      else begin
        @(posedge ahb_vif.Hclk);   //T3
        wait(ahb_vif.Hreadyout);
      end
    endtask
    
    //Run Phase
    task ahb_drv::run_phase(uvm_phase phase);
      forever begin
        seq_item_port.get_next_item(tx);
        drive(tx);
        seq_item_port.item_done();
      end
    endtask