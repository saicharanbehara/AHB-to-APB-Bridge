//AHB Monitor

class ahb_monitor extends uvm_monitor;
  `uvm_component_utils(ahb_monitor)
  
  ahb_trans ahb_tx;
  virtual ahb_intf ahb_vif;
  
  uvm_analysis_port #(ahb_trans) h_port;
  
  extern function new(string name="ahb_monitor",uvm_component parent);
    extern function void build_phase(uvm_phase phase);
      extern task run_phase(uvm_phase phase);
        
endclass
        
        function ahb_monitor::new(string name="ahb_monitor",uvm_component parent);
          super.new(name,parent);
        endfunction
        
        function void ahb_monitor::build_phase(uvm_phase phase);
          super.build_phase(phase);
          if(!uvm_config_db #(virtual ahb_intf)::get(this,"","ahb_vif",ahb_vif))
            `uvm_fatal("MONITOR", "cannot get() vif")
          h_port = new("h_port", this);
        endfunction
    
        task ahb_monitor::run_phase(uvm_phase phase);
          phase.raise_objection(this);
          repeat(`seq_size)
            
            begin
              
              ahb_tx = ahb_trans::type_id::create("ahb_tx",this);
              @(posedge ahb_vif.Hclk);//T1
              wait(ahb_vif.Hreadyout);
              
              @(posedge ahb_vif.Hclk);//T1
              ahb_tx.Hwrite = ahb_vif.Hwrite;
              ahb_tx.Haddr = ahb_vif.Haddr;
              
               //Write Transfer
              
              @(posedge ahb_vif.Hclk);//T2
              if(ahb_vif.Hwrite) begin
                ahb_tx.Hwdata = ahb_vif.Hwdata ;
                
              end
              
              //Read Transfer
              
              else begin
                @(posedge ahb_vif.Hclk);//T3
                wait(ahb_vif.Hreadyout)
                ahb_tx.Hrdata = ahb_vif.Hrdata;
                
              end
              
              h_port.write(ahb_tx);
            end
          phase.drop_objection(this);
        endtask
    
  