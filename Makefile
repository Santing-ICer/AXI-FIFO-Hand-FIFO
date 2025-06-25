# 变量定义
TOP_MODULE = testbench        # 你的顶层仿真模块名（如 testbench.v 中定义的模块）
VFILES = $(wildcard *.v)      # 当前目录下所有 .v 文件
OUT_FILE = sim_out            # iverilog 编译生成的输出文件名
WAVE_FILE = wave.vcd      # 仿真生成的波形文件名

# 默认目标：编译+运行+查看波形
all: run view

# 编译目标
$(OUT_FILE): $(VFILES)
	iverilog -o $(OUT_FILE) $(VFILES)

# 运行仿真生成波形
run: $(OUT_FILE)
	vvp $(OUT_FILE)

# 查看波形
view: $(WAVE_FILE)
	gtkwave $(WAVE_FILE)

# 清理中间文件
clean:
	rm -f $(OUT_FILE) $(WAVE_FILE)
