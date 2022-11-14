//APB Driver

class apb_drv extends uvm_driver#(apb_trans);
  apb_trans tx;
  virtual apb_intf apb_vif;
  `uvm_component_utils(apb_drv)
  extern function new(string name="apb_drv",uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task drive(apb_trans tx);
endclass
    
    function apb_drv::new(string name="apb_drv",uvm_component parent);
      super.new(name,parent);
    endfunction
    
    function void apb_drv::build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db #(virtual apb_intf)::get(this,"","apb_vif",apb_vif))
        `uvm_fatal("APB Driver","error in getting interface")
        tx = apb_trans::type_id::create("tx");
    endfunction
    
    task apb_drv::run_phase(uvm_phase phase);
      forever begin
        seq_item_port.get_next_item(tx);
        drive(tx);
        seq_item_port.item_done();
      end
    endtask
    
    task apb_drv::drive(apb_trans tx);
      @(posedge apb_vif.Pclk); //T1
      apb_vif.Pslverr = 1'b0;	//1 indicates a transfer failure
      apb_vif.Pready = 1; // 1 indicates completion of apb transfer
      @(posedge apb_vif.Pclk); //T2
      wait(apb_vif.Psel)
      tx.Pwrite = apb_vif.Pwrite;
      tx.Paddr = apb_vif.Paddr;
      
      // Read Transfer
      
      if ((apb_vif.Pwrite==0)) begin
        @(posedge apb_vif.Pclk); //T3
        wait(apb_vif.Penable)
        apb_vif.Prdata = tx.Prdata;        
      end
      
      //Write Transfer
      
      else begin
        tx.Pwdata = apb_vif.Pwdata;
        @(posedge apb_vif.Pclk);
        wait(apb_vif.Penable);
      end
    endtask