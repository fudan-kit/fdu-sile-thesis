SILE_BIN ?= sile
SILE     := env -u LUA_PATH -u LUA_CPATH FONTCONFIG_FILE=$(CURDIR)/config/fontconfig-texlive.conf $(SILE_BIN)
MAIN     := paper
SRC_DIR  := src
CLS_DIR  := classes

SOURCES  := $(wildcard $(SRC_DIR)/*.sil)
CLASS    := $(CLS_DIR)/fduthesis.lua
FONTCONF := config/fontconfig-texlive.conf
OUTPUT   := $(MAIN).pdf
TOC      := $(MAIN).toc
AUX      := $(TOC) $(MAIN).lof $(MAIN).lot

.PHONY: all thesis clean distclean help

all: thesis ## 默认目标：编译 SILE 模板教程

thesis: $(OUTPUT) ## 编译论文（三轮收敛目录及图表清单页码）

$(OUTPUT): $(MAIN).sil $(SOURCES) $(CLASS) $(FONTCONF) assets/fudan-name.pdf
	@echo "========================================="
	@echo "  第一轮：收集目录、插图和附表数据"
	@echo "========================================="
	$(SILE) $<
	@echo ""
	@echo "========================================="
	@echo "  编译完成：$(OUTPUT)"
	@echo "========================================="
	@echo "  第二轮：填充目录和图表清单页码"
	@echo "========================================="
	$(SILE) $<
	@echo ""
	@echo "========================================="
	@echo "  第三轮：稳定分页与全部页码"
	@echo "========================================="
	$(SILE) $<
	@echo ""
	@echo "========================================="

clean: ## 清理中间文件（保留 PDF）
	rm -f $(AUX)

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
	@echo "  SILE_BIN=<path>        指定 sile 可执行文件路径（默认：sile）"
	@echo ""
	@echo "示例:"
	@echo "  make             编译论文"
	@echo "  make clean       清理中间文件"
	@echo "  make distclean   清理所有生成文件"
