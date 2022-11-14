//APB Monitors

class apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_monitor)
  
  apb_trans apb_tx;
  virtual apb_intf apb_vif;
  
  uvm_analysis_port #(apb_trans) p_port;
  
  extern function new(string name="apb_monitor",uvm_component parent);
    extern function void build_phase(uvm_phase phase);
      extern task run_phase(uvm_phase phase);
        
endclass
        
        function apb_monitor::new(string name="apb_monitor",uvm_component parent);
          super.new(name,parent);
        endfunction
        
        function void apb_monitor::build_phase(uvm_phase phase);
          super.build_phase(phase);
          if(!uvm_config_db #(virtual apb_intf)::get(this,"","apb_vif",apb_vif))
            `uvm_fatal("MONITOR", "cannot get() vif")
          p_port = new("p_port", this);
        endfunction
        
        task apb_monitor::run_phase(uvm_phase phase);
          phase.raise_objection(this);
          repeat(`seq_size)
            begin
              apb_tx = apb_trans::type_id::create("apb_tx",this);
              
              @(posedge apb_vif.Pclk);//T1
              @(posedge apb_vif.Pclk);//T1
              @(posedge apb_vif.Pclk);
              wait(apb_vif.Psel)
              apb_tx.Pwrite = apb_vif.Pwrite;
              apb_tx.Paddr = apb_vif.Paddr;
              
              //Read transfer
              
              if((apb_vif.Pwrite == 0)) begin
                @(posedge apb_vif.Pclk);//T3
                wait(apb_vif.Penable)
                apb_tx.Prdata =  apb_vif.Prdata ;
                
              end
              
       		 //Write Transfer
              
              else begin
                apb_tx.Pwdata = apb_vif.Pwdata;
                @(posedge apb_vif.Pclk); //T4
                wait(apb_vif.Penable);
              end
              
              p_port.write(apb_tx);
            end
          phase.drop_objection(this);
        endtask
  
  