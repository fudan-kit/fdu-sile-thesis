# fduthesis-sile：复旦大学学位论文 SILE 模板

基于 [SILE](https://sile-typesetter.org/) 排版引擎的复旦大学学位论文模板，参照《复旦大学博士、硕士学位论文规范（2024年10月修订版）》和 [fduthesis](https://github.com/stone-zeng/fduthesis) LaTeX 模板设计。

支持本科毕业论文、硕士学位论文和博士学位论文。

## 项目结构

```
fdu-sile-thesis/
├── classes/
│   └── fduthesis.lua          # 复旦大学论文文档类（核心文件）
├── paper.sil                  # 主文档入口（示例论文）
├── src/
│   ├── abstract-cn.sil        # 中文摘要
│   ├── abstract-en.sil        # 英文摘要
│   ├── c01-introduction.sil   # 第一章 绪论
│   ├── c02-related-work.sil   # 第二章 相关工作
│   ├── c03-method.sil         # 第三章 方法
│   ├── c04-experiment.sil     # 第四章 实验与分析
│   ├── c05-conclusion.sil     # 第五章 总结与展望
│   ├── bibliography.sil       # 参考文献
│   └── acknowledgements.sil   # 致谢
├── fudan-name.pdf             # 复旦大学校名图片
├── README.md
└── LICENSE
```

## 功能特性

- 支持博士（`doctor`）、硕士（`master`）、本科（`bachelor`）三种论文类型
- 支持学术学位（`academic`）和专业学位（`professional`）分类
- 自动生成符合规范的封面页
- 学位论文独创性声明与使用授权声明页
- 扉页（指导小组成员名单）
- 中英文摘要页（含关键词、中图分类号）
- 自动生成中文目录（"第X章"格式编号）
- 中文章节标题格式（第一章、1.1、1.1.1）
- 前置部分罗马数字页码、正文部分阿拉伯数字页码
- 双面打印支持（左右页眉）
- 参考文献、附录、致谢等后置部分
- A4纸张，Word 默认页边距（上下2.54cm，左右3.18cm）
- 正文宋体小四号（12pt），20磅行距

## 环境要求

- [SILE](https://sile-typesetter.org/) >= 0.15.0
- 系统字体：
  - **SimSun**（宋体）— 正文字体
  - **SimHei**（黑体）— 标题字体
  - **KaiTi**（楷体）— 强调字体（可选）
  - **FangSong**（仿宋）— 可选
  - **Times New Roman** — 英文字体
  - **Hack** — 代码字体（可选）

### 安装 SILE

Ubuntu/Debian:
```bash
sudo add-apt-repository ppa:sile-typesetter/sile
sudo apt update
sudo apt install sile
```

其他系统请参考 [SILE 安装文档](https://github.com/sile-typesetter/sile/wiki/Installation)。

### 安装中文字体

如果系统没有中文字体，可安装文泉驿或思源字体：
```bash
sudo apt install fonts-wqy-microhei fonts-wqy-zenhei
```

或安装 Windows 字体后配置字体名映射。

## 使用方法

### 1. 基本使用

```bash
# 克隆项目
git clone https://github.com/your-username/fdu-sile-thesis.git
cd fdu-sile-thesis

# 编译论文（需运行两次以生成正确的目录页码）
sile paper.sil
sile paper.sil
```

### 2. 修改论文类型

在 `paper.sil` 的文档声明中修改选项：

```sil
% 博士学位论文（学术学位）
\begin[class=fduthesis, type=doctor, degree=academic]{document}

% 硕士学位论文（专业学位）
\begin[class=fduthesis, type=master, degree=professional]{document}

% 本科毕业论文
\begin[class=fduthesis, type=bachelor]{document}
```

### 3. 设置论文元数据

在 `paper.sil` 中使用以下命令设置论文信息：

```sil
\fdu:schoolCode{10246}
\fdu:studentId{12345678901}
\fdu:title{论文中文标题}
\fdu:titleEn{Thesis English Title}
\fdu:author{作者姓名}
\fdu:supervisor{导师姓名 教授}
\fdu:department{院系名称}
\fdu:major{专业名称}
\fdu:date{2026年6月}
\fdu:keywordsCn{关键词1，关键词2，关键词3}
\fdu:keywordsEn{Keyword1, Keyword2, Keyword3}
\fdu:clc{TP391}
```

### 4. 文档结构

标准论文的文档结构如下：

```sil
\begin[class=fduthesis, type=doctor, degree=academic]{document}

% 元数据设置
\fdu:title{...}
% ... 其他元数据

% 封面
\fdu:makecover

% 独创性声明
\fdu:declaration

% 前置部分
\fdu:frontmatter
\begin{fdu:instructors}
  指导小组成员列表...
\end{fdu:instructors}
\tableofcontents
\include[src=src/abstract-cn.sil]
\include[src=src/abstract-en.sil]

% 正文
\fdu:mainmatter
\include[src=src/c01-introduction.sil]
% ... 其他章节

% 后置部分
\fdu:backmatter
\include[src=src/bibliography.sil]
\include[src=src/acknowledgements.sil]

\end{document}
```

## 命令参考

### 元数据命令

| 命令 | 说明 |
|------|------|
| `\fdu:title{...}` | 中文标题 |
| `\fdu:titleEn{...}` | 英文标题 |
| `\fdu:author{...}` | 作者姓名 |
| `\fdu:supervisor{...}` | 指导教师 |
| `\fdu:department{...}` | 院系 |
| `\fdu:major{...}` | 专业 |
| `\fdu:date{...}` | 完成日期 |
| `\fdu:studentId{...}` | 学号 |
| `\fdu:schoolCode{...}` | 学校代码（默认10246） |
| `\fdu:keywordsCn{...}` | 中文关键词 |
| `\fdu:keywordsEn{...}` | 英文关键词 |
| `\fdu:clc{...}` | 中图分类号 |
| `\fdu:secretLevel{...}` | 密级 |
| `\fdu:secretYear{...}` | 保密年限 |

### 结构命令

| 命令 | 说明 |
|------|------|
| `\fdu:makecover` | 生成封面 |
| `\fdu:declaration` | 独创性声明和使用授权声明 |
| `\fdu:frontmatter` | 开始前置部分（罗马数字页码） |
| `\fdu:mainmatter` | 开始正文（阿拉伯数字页码） |
| `\fdu:backmatter` | 开始后置部分 |
| `\fdu:pdfmetadata` | 设置 PDF 文件元数据 |

### 环境命令

| 命令 | 说明 |
|------|------|
| `\begin{fdu:abstract}...\end{fdu:abstract}` | 中文摘要 |
| `\begin{fdu:abstract-en}...\end{fdu:abstract-en}` | 英文摘要 |
| `\begin{fdu:instructors}...\end{fdu:instructors}` | 指导小组名单 |
| `\begin{fdu:bibliography}...\end{fdu:bibliography}` | 参考文献 |
| `\begin{fdu:acknowledgements}...\end{fdu:acknowledgements}` | 致谢 |
| `\begin{fdu:appendix}...\end{fdu:appendix}` | 附录 |

### 字体命令

| 命令 | 说明 |
|------|------|
| `\fdu:songti{...}` | 宋体 |
| `\fdu:heiti{...}` | 黑体 |
| `\fdu:kaiti{...}` | 楷体 |
| `\fdu:fangsong{...}` | 仿宋 |
| `\fdu:code{...}` | 代码字体 |
| `\fdu:emph{...}` | 中文强调（楷体） |

### 章节命令

使用标准的 SILE 章节命令，已自动适配中文格式：

```sil
\chapter{章标题}           % 第X章 标题（黑体16pt居中）
\section{节标题}           % X.X 标题（黑体14pt）
\subsection{小节标题}      % X.X.X 标题（黑体12pt）
```

## 注意事项

1. **目录需要两次编译**：第一次编译生成 `.toc` 文件，第二次编译才能正确显示目录内容和页码。
2. **校名图片**：项目自带 `fudan-name.pdf`。如果文件缺失，封面会自动回退为文字"复旦大学"。
3. **字体依赖**：请确保系统安装了所需的中英文字体。字体名称可能因操作系统而异。
4. **涉密论文**：使用 `\fdu:secretLevel` 和 `\fdu:secretYear` 命令设置密级信息。

## 参考

- [复旦大学博士、硕士学位论文规范（2024年10月修订版）](https://gs.fudan.edu.cn)
- [fduthesis - 复旦大学 LaTeX 论文模板](https://github.com/stone-zeng/fduthesis)
- [SILE 排版引擎](https://sile-typesetter.org/)

## 许可证

本项目采用 [GNU General Public License v3.0](LICENSE) 许可证。
