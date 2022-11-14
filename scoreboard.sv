//scoreboard 

`uvm_analysis_imp_decl( _ahb)
`uvm_analysis_imp_decl( _apb)

class scoreboard extends uvm_scoreboard; 
  `uvm_component_utils(scoreboard)

  uvm_analysis_imp_ahb#(ahb_trans,scoreboard) ahb_value;
  uvm_analysis_imp_apb#(apb_trans,scoreboard) apb_value;
  
  ahb_trans ahb_tx_q[$];
  apb_trans apb_tx_q[$];
  
  extern function new(string name="scoreboard",uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void write_ahb(ahb_trans ahb_tx);
  extern function void write_apb(apb_trans apb_tx);
  extern function void compare(ahb_trans exp, apb_trans rcvd);
  extern function void report_phase(uvm_phase phase);
    
endclass
    
              function scoreboard::new(string name="scoreboard", uvm_component parent);
                super.new(name, parent);
              endfunction
              
              function void scoreboard::build_phase (uvm_phase phase);
                super.build_phase(phase);
                ahb_value=new("ahb_value", this);
                apb_value=new("apb_value", this);
              endfunction
              
              function void scoreboard::write_ahb(ahb_trans ahb_tx);
                ahb_tx_q.push_back(ahb_tx);
              endfunction
              
              function void scoreboard::write_apb (apb_trans apb_tx);
                apb_tx_q.push_back(apb_tx);
              endfunction
    
    function void scoreboard::compare(ahb_trans exp, apb_trans rcvd);
      
      if (exp.Haddr === rcvd.Paddr) begin
        `uvm_info("Address", $sformatf("Data Matched Successful	(AHB_Address = %h APB_Address = %h)", exp.Haddr, rcvd.Paddr), UVM_LOW)
      end else begin
        `uvm_error("Address", $sformatf("xxx Data Mismatch	(AHB_Address = %h APB_Address = %h) xxx", exp.Haddr, rcvd.Paddr))
      end
      
      if (exp.Hwrite === rcvd.Pwrite) begin
        `uvm_info("Operation", $sformatf("Data Matched Successful	(AHB_Write = %h	 APB_Write = %h)", exp.Hwrite, rcvd.Pwrite), UVM_LOW)
      end else begin
        `uvm_error("Operation", $sformatf("xxx Data Mismatch	(AHB_Write = %h	 APB_Write = %h) xxx", exp.Hwrite, rcvd.Pwrite))
      end
      
      if (exp.Hwdata === rcvd.Pwdata) begin
        `uvm_info("WData", $sformatf("Data Matched Successful	(AHB_WriteData = %h APB_WriteData = %h)", exp.Hwdata, rcvd.Pwdata), UVM_LOW)
      end else begin
        `uvm_error("WData", $sformatf("xxx Data Mismatch	(AHB_WriteData = %h APB_WriteData = %h) xxx", exp.Hwdata, rcvd.Pwdata))
      end
      
      if (exp.Hrdata === rcvd.Prdata) begin
        `uvm_info("RData", $sformatf("Data Matched Successful	(AHB_ReadData = %h APB_ReadData = %h)  \n", exp.Hrdata, rcvd.Prdata), UVM_LOW)
      end else begin
        `uvm_error("RData", $sformatf("xxx Data Mismatch	(AHB_ReadData = %h APB_ReadData = %h) xxx\n", exp.Hrdata, rcvd.Prdata))
      end
      
                  endfunction
                  
                  function void scoreboard::report_phase(uvm_phase phase );
      				integer i=0;
      					while(i<`seq_size)
                          begin
                            compare (ahb_tx_q[i], apb_tx_q[i]);
                            i++;
                          end
    			endfunction