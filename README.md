# 复旦大学学位论文 SILE 模板

这是一个可直接编译的复旦大学博士、硕士学位论文 SILE 模板。示例论文《复旦大学学位论文 SILE 排版模板教程》同时也是完整使用手册。

模板依据《复旦大学博士、硕士学位论文规范（2026 年 6 月修订版）》实现，并以 `fduthesis-2026` v0.9a-2026.1 的 XeLaTeX 输出为版式基准。覆盖硕士、博士论文的学术学位与专业学位封面。本科 `bachelor` 选项只是兼容扩展，不代表已经覆盖本科毕业设计的独立规范。

## 已实现内容

- A4 页面、与 `fduthesis-2026` 对齐的版心、正文小四号与 20 磅行距
- 2026 版规范封面字段，以及涉密、同等学力、英文项目可选标记
- 指导小组、目录、中英文摘要、插图清单、附表清单
- 正文从右页开始、每章另起页、中文章号与多级目录
- 双面页眉、前置罗马数字页码、正文阿拉伯数字页码
- 按章编号的图片和表格题注，自动生成 `.lof` 与 `.lot`
- 参考文献、附录、致谢
- 末尾同页排版的独创性声明与使用授权声明
- PDF 标题、作者和主题元数据

## 环境

模板针对 SILE 0.15 系列开发，当前验证版本为 `0.15.13.r8-gf69069f`。字体与 `fduthesis-2026` 在 Linux 下的默认配置一致：

- XITS：拉丁正文、数字和数学风格文字
- FandolSong：中文正文及其粗体
- FandolHei：中文标题及其粗体
- FandolKai、FandolFang：楷体与仿宋命令
- TeX Gyre Heros、TeX Gyre Cursor：英文无衬线标题与代码块

`config/fontconfig-texlive.conf` 将 TeX Live 的 OpenType 字体目录提供给 SILE，并修正 TeX Live 2025 Fandol Regular/Bold 在 fontconfig 中权重相同的问题。文档类还包含针对 SILE 0.15 混合字体回退顺序的局部修正，保证“2026年6月”等中英数字混排不会被重新排序。字体全部嵌入最终 PDF。

检查环境：

```bash
sile --version
FONTCONFIG_FILE="$PWD/config/fontconfig-texlive.conf" fc-match XITS
FONTCONFIG_FILE="$PWD/config/fontconfig-texlive.conf" fc-match FandolSong
FONTCONFIG_FILE="$PWD/config/fontconfig-texlive.conf" fc-match FandolHei
```

## 编译

```bash
make
```

Makefile 固定运行三轮 SILE。第一轮收集目录和图表位置，第二轮填入页码，第三轮稳定因目录变化引起的分页。也可手动执行：

```bash
FONTCONFIG_FILE="$PWD/config/fontconfig-texlive.conf" sile paper.sil
FONTCONFIG_FILE="$PWD/config/fontconfig-texlive.conf" sile paper.sil
FONTCONFIG_FILE="$PWD/config/fontconfig-texlive.conf" sile paper.sil
```

输出为 `paper.pdf`。`make clean` 删除 `.toc`、`.lof` 与 `.lot`，保留 PDF；`make distclean` 还会删除 PDF。

## 开始写论文

在 `paper.sil` 开头选择类型：

```sil
% 硕士学术学位
\begin[class=fduthesis, type=master, degree=academic]{document}

% 硕士专业学位
\begin[class=fduthesis, type=master, degree=professional]{document}

% 博士学术学位
\begin[class=fduthesis, type=doctor, degree=academic]{document}
```

然后替换主文件中的元数据：

```sil
\fdu:studentId{12345678901}
\fdu:title{中文论文题目}
\fdu:titleEn{English Thesis Title}
\fdu:author{学生姓名}
\fdu:supervisor{导师姓名　职称}
\fdu:department{培养单位}
\fdu:major{学科专业}
\fdu:date{2026年6月}
\fdu:clc{TP391}
\fdu:keywordsCn{关键词一；关键词二；关键词三}
\fdu:keywordsEn{keyword one; keyword two; keyword three}
```

按需启用特殊封面标记：

```sil
\fdu:secretLevel{秘密}
\fdu:secretYear{五年}
\fdu:tongdengxueli{true}
\fdu:englishProject{true}
```

公开论文不要设置密级。中文摘要一般为 300 至 1000 字，关键词为 3 至 8 个，论文题目原则上不超过 30 个汉字。

## 目录结构

```text
.
├── classes/fduthesis.lua     文档类与版式命令
├── config/                   TeX Live 字体的项目私有 fontconfig
├── assets/fudan-name.pdf     封面校名矢量图
├── paper.sil                 主文件、元数据与论文结构
├── src/                      摘要、五章教程及后置材料
├── Makefile                  三轮 SILE 编译入口
└── paper.pdf                 编译后的示例教程
```

完整命令示例请直接阅读 `paper.pdf` 和 `src` 下的源文件。图片使用 `fdu:figure`，表题使用 `fdu:table-caption`；存在图片或表格时，主文件中应保留 `fdu:listoffigures` 和 `fdu:listoftables`。

## 提交前检查

模板不能替代院系审核。正式提交前应确认学校与培养单位没有更新要求，并检查：

- 封面元数据、论文类别和密级
- 摘要字数与关键词数量
- 目录及图表清单页码
- 正文右页起排、各章分页、双面页眉页码
- 图表清晰度、题注与正文引用
- 参考文献符合提交时现行 GB/T 7714
- 声明页位于全文末尾且没有页眉页码
- 双面打印效果以及线装或热胶装订

推荐同时运行 `pdfinfo paper.pdf`、`pdffonts paper.pdf`，并把所有页面渲染为图片后逐页查看。

## 许可证

本项目采用 [GNU GPL v3.0](LICENSE) 许可证。
