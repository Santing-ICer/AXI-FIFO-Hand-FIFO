`timescale  1ns / 1ps

module tb_hand_fifo;

// hand_fifo Parameters
parameter PERIOD = 10;
parameter WIDTH  = 8;
parameter DEPTH  = 32;

// hand_fifo Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   wr_en                                = 0 ;
reg   rd_en                                = 0 ;
reg   [WIDTH - 1:0]  wr_data               = 0 ;

// hand_fifo Outputs
wire  [WIDTH - 1:0]  rd_data               ;    
wire  data_in_ready                        ;    
wire  data_out_valid                       ;    


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

hand_fifo #(
    .WIDTH ( WIDTH ),
    .DEPTH ( DEPTH ))
u_hand_fifo (
    .clk                     ( clk                           ),
    .rst_n                   ( rst_n                         ),
    .wr_en                   ( wr_en                         ),
    .rd_en                   ( rd_en                         ),
    .wr_data                 ( wr_data         [WIDTH - 1:0] ),
    .rd_data                 ( rd_data         [WIDTH - 1:0] ),
    .data_in_ready           ( data_in_ready                 ),
    .data_out_valid          ( data_out_valid                )
);
integer seed;
reg [31:0] random_num = 0;//例化一个随机数
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        random_num <= $random(seed);
    end
    else
        random_num <= {random_num[30:0],random_num[31]};
end
always@(posedge clk)begin
    rd_en <= random_num[0];
end

initial begin
    $dumpfile("wave.vcd");//iverilog & gtkwave       
    $dumpvars(0, tb_hand_fifo); 
end
initial begin

    wr_en = 0;
    wr_data = 0;
       
    #20;
    if (!$value$plusargs("seed=%d", seed)) seed = 8721;
    repeat(10)@(posedge clk);
    // 写入 DEPTH 个数据
    repeat(DEPTH) begin
      @(posedge clk);
      wr_en <= 1;
      wr_data <= wr_data + 1;
      @(posedge clk);
      wr_en <= 0;
    end

    @(posedge clk);
    wr_en <= 0;
    wr_data <= 0;

    repeat(30)@(posedge clk);
    $finish;
  end
endmodule
