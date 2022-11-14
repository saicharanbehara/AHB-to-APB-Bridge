module AHBLite_APB_Bridge #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
)
(
  input                           HRESETn,
  input                           HCLK,
  input                           HSEL,
  input      [ADDR_WIDTH-1:0]     HADDR,
  input      [DATA_WIDTH-1:0]     HWDATA,
  input                           HWRITE,
  input      [2:0]                HSIZE,
  input      [2:0]                HBURST,//Not used
  input      [3:0]                HPROT,//Not used
  input      [1:0]                HTRANS,
  input                           HMASTERLOCK,//Not used
  input                           HREADYIN,
  output reg                      HREADYOUT,
  output reg [DATA_WIDTH-1:0]     HRDATA,
  output reg                      HRESP,

  input                           PRESETn,
  input                           PCLK,
  output reg                      PSEL,
  output reg                      PENABLE,
  output     [2:0]                PROT,
  output reg                      PWRITE,
  output reg [(DATA_WIDTH/8)-1:0] PSTRB,
  output reg [ADDR_WIDTH-1:0]     PADDR,
  output reg [DATA_WIDTH-1:0]     PWDATA,
  input      [DATA_WIDTH-1:0]     PRDATA,
  input                           PREADY,
  input                           PSLVERR
);

parameter ST_AHB_IDLE     = 2'b00,
          ST_AHB_TRANSFER = 2'b01,
          ST_AHB_ERROR    = 2'b10;

reg  [1:0]            ahb_state;
wire                  ahb_transfer;
reg                   apb_treq;
reg                   apb_treq_toggle;
reg  [2:0]            apb_treq_sync;
wire                  apb_treq_pulse;

reg                   apb_tack;
reg                   apb_tack_toggle;
reg  [2:0]            apb_tack_sync;
wire                  apb_tack_pulse;
reg                   apb_tack_pulse_Q1;
reg  [ADDR_WIDTH-1:0] ahb_HADDR;
reg                   ahb_HWRITE;
reg  [2:0]            ahb_HSIZE;
reg  [DATA_WIDTH-1:0] ahb_HWDATA;
reg                   latch_HWDATA;
reg  [DATA_WIDTH-1:0] apb_PRDATA;
reg                   apb_PSLVERR;
reg  [DATA_WIDTH-1:0] apb_PRDATA_HCLK;
reg                   apb_PSLVERR_HCLK;

assign ahb_transfer = (HSEL & HREADYIN & (HTRANS == 2'b10 || HTRANS == 2'b11)) ? 1'b1 : 1'b0;

always@(posedge HCLK or negedge HRESETn)begin
  if(!HRESETn)begin
    HREADYOUT  <= 1'b1;
    HRESP      <= 1'b0;
    HRDATA     <=  'd0;
    ahb_HADDR  <=  'd0;
    ahb_HWRITE <= 1'b0;
    ahb_HSIZE  <=  'd0;
    ahb_state  <= ST_AHB_IDLE;
    apb_treq   <= 1'b0;
  end else begin
    apb_treq   <= 1'b0;
    case (ahb_state)
      ST_AHB_IDLE : begin
        HREADYOUT  <= 1'b1;
        HRESP      <= 1'b0;
        ahb_HADDR  <= HADDR;
        ahb_HWRITE <= HWRITE;
        ahb_HSIZE  <= HSIZE;
        if(ahb_transfer)begin
          ahb_state <= ST_AHB_TRANSFER;
          HREADYOUT <= 1'b0;
          apb_treq  <= 1'b1;
        end
      end
      ST_AHB_TRANSFER : begin
        HREADYOUT <= 1'b0;
        if(apb_tack_pulse_Q1)begin
          HRDATA <= apb_PRDATA_HCLK;
          if(apb_PSLVERR_HCLK)begin
            HRESP     <= 1'b1;
            ahb_state <= ST_AHB_ERROR;
          end else begin
            HREADYOUT <= 1'b1;
            HRESP     <= 1'b0;
            ahb_state <= ST_AHB_IDLE;
          end
        end
      end
      ST_AHB_ERROR : begin
        HREADYOUT <= 1'b1;
        ahb_state <= ST_AHB_IDLE;
      end
      default: begin
        ahb_state <= ST_AHB_IDLE;
      end
    endcase
  end
end

always@(posedge HCLK or negedge HRESETn)begin
  if(!HRESETn)begin
    ahb_HWDATA   <=  'd0;
    latch_HWDATA <= 1'b0;
  end else begin
    if(ahb_transfer && HWRITE) latch_HWDATA <= 1'b1;
    else                       latch_HWDATA <= 1'b0;
    if(latch_HWDATA)begin
      ahb_HWDATA <= HWDATA;
    end
  end
end

always@(posedge HCLK or negedge HRESETn)begin
  if(!HRESETn)begin
    apb_treq_toggle <= 1'b0;
  end else begin
    if(apb_treq) apb_treq_toggle <= ~apb_treq_toggle;
  end
end

always@(posedge PCLK or negedge PRESETn)begin
  if(!PRESETn)begin
     apb_treq_sync  <=  'd0;
  end else begin
     apb_treq_sync <= {apb_treq_sync[1:0], apb_treq_toggle};
  end
end

assign apb_treq_pulse = apb_treq_sync[2] ^ apb_treq_sync[1];


reg                   apb_treq_pulse_Q1;
reg  [ADDR_WIDTH-1:0] ahb_HADDR_PCLK;
reg                   ahb_HWRITE_PCLK;
reg  [2:0]            ahb_HSIZE_PCLK;
reg  [DATA_WIDTH-1:0] ahb_HWDATA_PCLK;

always@(posedge PCLK or negedge PRESETn)begin
  if(!PRESETn)begin
    apb_treq_pulse_Q1 <= 0;
    ahb_HADDR_PCLK    <= 0;
    ahb_HWRITE_PCLK   <= 0;
    ahb_HSIZE_PCLK    <= 0;
    ahb_HWDATA_PCLK   <= 0;
  end else begin
    apb_treq_pulse_Q1 <= apb_treq_pulse;
    if(apb_treq_pulse)begin
      ahb_HADDR_PCLK  <= ahb_HADDR;
      ahb_HWRITE_PCLK <= ahb_HWRITE;
      ahb_HSIZE_PCLK  <= ahb_HSIZE;
      ahb_HWDATA_PCLK <= ahb_HWDATA;
    end
  end
end


reg [(DATA_WIDTH/8)-1:0] lcl_PSTRB;

reg [1:0] apb_state;
parameter ST_APB_IDLE   = 2'b00,
          ST_APB_START  = 2'b01,
          ST_APB_ACCESS = 2'b10;

always@(posedge PCLK or negedge PRESETn)begin
  if(!PRESETn)begin
    apb_state   <= ST_APB_IDLE;
    PADDR       <=  'd0;
    PSEL        <=  'b0;
    PENABLE     <=  'b0;
    PWRITE      <=  'b0;
    PWDATA      <=  'b0;
    PSTRB       <=  'd0;
    apb_PSLVERR <= 1'b0;
    apb_tack    <= 1'b0;
    apb_PRDATA  <=  'd0;
  end else begin
    apb_tack    <= 1'b0;
    case (apb_state)
      ST_APB_IDLE: begin
        PSEL    <= 'b0;
        PENABLE <= 'b0;
        PWRITE  <= 'b0;
        if(apb_treq_pulse_Q1)begin
          apb_state <= ST_APB_START;
          PADDR     <= {ahb_HADDR_PCLK[ADDR_WIDTH-1:DATA_WIDTH/8], {{(DATA_WIDTH/8)}{1'b0}}};
          PSTRB     <= lcl_PSTRB;
          PSEL      <= 'b1;
          PWRITE    <= ahb_HWRITE_PCLK;
          PWDATA    <= ahb_HWDATA_PCLK;
        end
      end

      ST_APB_START: begin
        apb_state <= ST_APB_ACCESS;
        PSEL      <= 'b1;
        PENABLE   <= 'b1;
      end

      ST_APB_ACCESS: begin
        PENABLE <= PENABLE;
        PWRITE  <= PWRITE;
        if(PREADY)begin
          apb_state   <= ST_APB_IDLE;
          apb_tack    <= 1'b1;
          apb_PRDATA  <= PRDATA;
          PSEL        <= 'b0;
          PENABLE     <= 'b0;
          apb_PSLVERR <= PSLVERR;
        end
      end
    endcase
  end
end

always@(posedge PCLK or negedge PRESETn)begin
  if(!PRESETn)begin
    apb_tack_toggle <= 1'b0;
  end else begin
    if(apb_tack) apb_tack_toggle <= ~apb_tack_toggle;
  end
end

always@(posedge HCLK or negedge HRESETn)begin
  if(!HRESETn)begin
    apb_tack_sync <= 'd0;
  end else begin
    apb_tack_sync <= {apb_tack_sync[1:0], apb_tack_toggle};
  end
end

assign apb_tack_pulse = apb_tack_sync[2] ^ apb_tack_sync[1];


always@(posedge HCLK or negedge HRESETn)begin
  if(!HRESETn)begin
    apb_tack_pulse_Q1 <= 0;
    apb_PRDATA_HCLK   <= 0;
    apb_PSLVERR_HCLK  <= 0;
  end else begin
    apb_tack_pulse_Q1 <= apb_tack_pulse;
    if(apb_tack_pulse)begin
      apb_PRDATA_HCLK  <= apb_PRDATA;
      apb_PSLVERR_HCLK <= apb_PSLVERR;
    end
  end
end

reg [127:0] pstrb;
reg [6:0]   addr_mask;
always@(*)begin
  case(DATA_WIDTH/8)
    'd0: addr_mask <= 'h00;
    'd1: addr_mask <= 'h01;
    'd2: addr_mask <= 'h03;
    'd3: addr_mask <= 'h07;
    'd4: addr_mask <= 'h0f;
    'd5: addr_mask <= 'h1f;
    'd6: addr_mask <= 'h3f;
    'd7: addr_mask <= 'h7f;
  endcase

  case(ahb_HSIZE)
    'd1:     pstrb <= 'h3;
    'd2:     pstrb <= 'hf;
    'd3:     pstrb <= 'hff;
    'd4:     pstrb <= 'hffff;
    'd5:     pstrb <= 'hffff_ffff;
    'd6:     pstrb <= 'hffff_ffff_ffff_ffff;
    'd7:     pstrb <= 'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff;
    default: pstrb <= 'h1;
  endcase
end

always@(posedge HCLK or negedge HRESETn)begin
  if(!HRESETn)begin
    lcl_PSTRB <= 0;
  end else begin
    lcl_PSTRB <= pstrb[DATA_WIDTH/8-1:0] << (ahb_HADDR & addr_mask);
  end
end

endmodule