SILE     ?= env -u LUA_PATH -u LUA_CPATH sile
MAIN     := paper
SRC_DIR  := src
CLS_DIR  := classes

SOURCES  := $(wildcard $(SRC_DIR)/*.sil)
CLASS    := $(CLS_DIR)/fduthesis.lua
OUTPUT   := $(MAIN).pdf
TOC      := $(MAIN).toc

.PHONY: all thesis clean distclean help

all: thesis ## 默认目标：编译论文

thesis: $(OUTPUT) ## 编译论文（自动运行两次以生成正确目录）

$(OUTPUT): $(MAIN).sil $(SOURCES) $(CLASS)
	@echo "========================================="
	@echo "  第一次编译（生成目录数据）"
	@echo "========================================="
	$(SILE) $<
	@echo ""
	@echo "========================================="
	@echo "  第二次编译（填充目录页码）"
	@echo "========================================="
	$(SILE) $<
	@echo ""
	@echo "========================================="
	@echo "  编译完成：$(OUTPUT)"
	@echo "========================================="

clean: ## 清理中间文件（保留 PDF）
	rm -f $(TOC)

distclean: clean ## 清理所有生成文件（含 PDF）
	rm -f $(OUTPUT)

help: ## 显示帮助信息
	@echo "复旦大学学位论文 SILE 模板 - 构建系统"
	@echo ""
	@echo "用法: make [目标]"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "环境变量:"
	@echo "  SILE=<path>     指定 sile 可执行文件路径（默认：sile）"
	@echo ""
	@echo "示例:"
	@echo "  make             编译论文"
	@echo "  make clean       清理中间文件"
	@echo "  make distclean   清理所有生成文件"
