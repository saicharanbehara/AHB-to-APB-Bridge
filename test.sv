//Test

class test extends uvm_test;
  `uvm_component_utils(test)
   env o_env;
   ahb_seq hseq;
   apb_seq pseq;
  extern function new(string name="test",uvm_component parent);
  extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    endclass
    
function test::new(string name="test",uvm_component parent);
  super.new(name,parent);
endfunction
    function void test::build_phase(uvm_phase phase);
      super.build_phase(phase);
      o_env=env::type_id::create("o_env",this);
      hseq = ahb_seq::type_id::create("hseq",this);
      pseq = apb_seq::type_id::create("pseq",this);
    endfunction
      
      task test::run_phase(uvm_phase phase);
            phase.raise_objection(this);
        fork
          hseq.start(o_env.h_agt.h_seqr);
          pseq.start(o_env.p_agt.p_seqr);
        join
        phase.drop_objection(this);
    
  endtask