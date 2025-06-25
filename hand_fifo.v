

module	hand_fifo
#(
	parameter WIDTH = 8,
	parameter DEPTH = 8							//FIFO深度
)
(
	input										clk				,		//系统时钟
	input										rst_n			,       //低电平有效的复位信号
	input	[WIDTH-1:0]							wr_data			,       //写入的数据
	input										rd_en			,       //读使能信号，高电平有效
	input										wr_en			,       //写使能信号，高电平有效

	output	reg	[WIDTH-1:0]						rd_data			,	    //输出的数据
	output	reg 								data_out_valid	,	    //空标志，高电平表示当前FIFO已被写满
	output										data_in_ready		    //满标志，高电平表示当前FIFO已被读空
);                                                              
 
//reg define
//用二维数组实现RAM
reg [WIDTH - 1 : 0]			fifo_buffer[DEPTH - 2 : 0];	
reg [$clog2(DEPTH) : 0]		wr_ptr;						//写地址指针，位宽多一位	
reg [$clog2(DEPTH) : 0]		rd_ptr;						//读地址指针，位宽多一位	
 
//wire define
wire [$clog2(DEPTH) - 1 : 0]	wr_ptr_true;			//真实写地址指针
wire [$clog2(DEPTH) - 1 : 0]	rd_ptr_true;			//真实读地址指针
wire								wr_ptr_msb;			//写地址指针地址最高位
wire								rd_ptr_msb;			//读地址指针地址最高位
wire nempty,nfull,ready_f;
assign {wr_ptr_msb,wr_ptr_true} = wr_ptr;				//将最高位与其他位拼接
assign {rd_ptr_msb,rd_ptr_true} = rd_ptr;				//将最高位与其他位拼接

wire rd_en_flag = ready_f && nempty;
wire wr_en_flag = nfull && wr_en ;
//读操作,更新读地址
always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		rd_ptr <= 'd0;
	else if((rd_en_flag)&((rd_ptr_true==DEPTH - 2))) begin
		rd_ptr[$clog2(DEPTH)-1:0] <= 'd0;
		rd_ptr[$clog2(DEPTH)]     <= ~rd_ptr[$clog2(DEPTH)];
	end
	else if(rd_en_flag)
		rd_ptr <= rd_ptr + 1'd1;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rd_data <= 'd0;
	else if (rd_en_flag)								//读使能有效且非空
		rd_data <= fifo_buffer[rd_ptr_true];
end
//写操作,更新写地址
always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		wr_ptr <= 0;
	else if((wr_en_flag)&(wr_ptr_true==DEPTH - 2)) begin
		wr_ptr[$clog2(DEPTH)-1:0] <= 'd0;
		wr_ptr[$clog2(DEPTH)]     <= ~wr_ptr[$clog2(DEPTH)];
	end
	else if(wr_en_flag)
		wr_ptr <= wr_ptr + 1'd1;
end
always @(posedge clk ) begin
	if (wr_en_flag)									   //写使能有效且非满
		fifo_buffer[wr_ptr_true] <= wr_data;
end
//更新指示信号
//当所有位相等时，读指针追到到了写指针，FIFO被读空,注意这里是非空
assign	nempty = ( wr_ptr != rd_ptr );
//当最高位不同但是其他位相等时，写指针超过读指针一圈，FIFO被写满
assign	nfull  = ( (wr_ptr_msb == rd_ptr_msb ) | ( wr_ptr_true != rd_ptr_true ) );
assign ready_f   = rd_en | ~data_out_valid;
assign data_in_ready = nfull;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		data_out_valid <= 1'b0;
	end
	else if(ready_f) begin
		data_out_valid <= nempty;
	end
end
endmodule
