//AHB Sequence

class ahb_seq extends uvm_sequence#(ahb_trans);
  `uvm_object_utils(ahb_seq)
  ahb_trans tx;
  extern function new(string name="ahb_seq");
  extern task body();
endclass
    
    function ahb_seq::new(string name="ahb_seq");
      super.new(name);
    endfunction
    
    task ahb_seq::body();
      repeat (`seq_size) begin
        tx=ahb_trans::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {tx.Haddr%16==0;});
        finish_item(tx);
      end
    endtask