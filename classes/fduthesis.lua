--- Fudan University Thesis Document Class for SILE
--- Supports bachelor, master, and doctoral degree theses.
--- Based on the 2024 revision of Fudan University thesis regulations.
--- Reference: fduthesis LaTeX template (https://github.com/stone-zeng/fduthesis)
--- @use classes.fduthesis

local book = require("classes.book")
local plain = require("classes.plain")

local class = pl.class(book)
class._name = "fduthesis"

local _digits = { "一", "二", "三", "四", "五", "六", "七", "八", "九" }

local function toChineseNumber (n)
   n = tonumber(n) or 0
   if n <= 0 then
      return ""
   end
   if n <= 9 then
      return _digits[n]
   end
   if n == 10 then
      return "十"
   end
   if n <= 19 then
      return "十" .. _digits[n - 10]
   end
   local tens = math.floor(n / 10)
   local ones = n % 10
   if ones == 0 then
      return _digits[tens] .. "十"
   end
   return _digits[tens] .. "十" .. _digits[ones]
end

class.defaultFrameset = {
   content = {
      left = "31.8mm",
      right = "178.2mm",
      top = "35mm",
      bottom = "top(footnotes)",
   },
   folio = {
      left = "left(content)",
      right = "right(content)",
      top = "bottom(footnotes)+3mm",
      bottom = "bottom(footnotes)+12mm",
   },
   runningHead = {
      left = "left(content)",
      right = "right(content)",
      top = "14mm",
      bottom = "30mm",
   },
   footnotes = {
      left = "left(content)",
      right = "right(content)",
      height = "0",
      bottom = "271.6mm",
   },
}

function class:_init (options)
   options = options or {}
   options.papersize = "a4"
   SILE.scratch.fduthesis = {
      schoolCode = "10246",
      studentId = "",
      title = "",
      titleEn = "",
      author = "",
      supervisor = "",
      department = "",
      major = "",
      date = "",
      keywordsCn = "",
      keywordsEn = "",
      clc = "",
      secretLevel = "",
      secretYear = "",
      tongdengxueli = "",
      englishProject = "",
      suppressHeaders = false,
   }
   book._init(self, options)
   SILE.scratch.fduthesis.type = self.options.type
   SILE.scratch.fduthesis.degree = self.options.degree
   self:loadPackage("linespacing")
   self:loadPackage("pdf")
   self:loadPackage("image")
   self:loadPackage("color")
   self:loadPackage("rules")
   self:loadPackage("raiselower")
   SILE.settings:set("document.language", "zh-hans", true)
   SILE.settings:set("font.family", "SimSun", true)
   SILE.settings:set("font.size", 12, true)
   SILE.settings:set("document.baselineskip", SILE.types.node.vglue("20pt"), true)
   SILE.settings:set("document.parindent", SILE.types.node.glue("2em"), true)

   self:_registerTocOverrides()
end

function class:_registerTocOverrides ()
   self:registerCommand("tableofcontents:headerfont", function (_, content)
      SILE.call("font", { family = "SimHei", weight = 700, size = "16pt" }, content)
   end)

   self:registerCommand("tableofcontents:header", function (_, _)
      SILE.typesetter:leaveHmode()
      SILE.call("center", {}, function ()
         SILE.call("tableofcontents:headerfont", {}, function ()
            SILE.typesetter:typeset("目　　录")
         end)
      end)
      SILE.call("bigskip")
      SILE.call("left-running-head", {}, function ()
         SILE.call("book:left-running-head-font", {}, function ()
            SILE.typesetter:typeset("目录")
         end)
      end)
      SILE.call("right-running-head", {}, function ()
         SILE.call("book:right-running-head-font", {}, function ()
            SILE.call("raggedleft", {}, function ()
               SILE.typesetter:typeset("目录")
            end)
         end)
      end)
   end)

   self:registerCommand("tableofcontents:notocmessage", function (_, _)
      SILE.call("tableofcontents:headerfont", {}, function ()
         SILE.typesetter:typeset("目录内容将在第二次编译后生成")
      end)
   end)

   self:registerCommand("tableofcontents:footer", function (_, _) end)

   self:registerCommand("tableofcontents:level1item", function (_, content)
      SILE.call("goodbreak")
      SILE.call("medskip")
      SILE.call("noindent")
      SILE.call("font", { family = "SimHei", size = "12pt", weight = 700 }, content)
      SILE.call("par")
   end)

   self:registerCommand("tableofcontents:level2item", function (_, content)
      SILE.settings:temporarily(function ()
         SILE.settings:set("document.lskip", SILE.types.node.glue("2em"))
         SILE.call("noindent")
         SILE.call("font", { family = "SimSun", size = "12pt" }, content)
         SILE.call("par")
      end)
   end)

   self:registerCommand("tableofcontents:level3item", function (_, content)
      SILE.settings:temporarily(function ()
         SILE.settings:set("document.lskip", SILE.types.node.glue("4em"))
         SILE.call("noindent")
         SILE.call("font", { family = "SimSun", size = "10.5pt" }, content)
         SILE.call("par")
      end)
   end)

   self:registerCommand("tableofcontents:level1number", function (_, content)
      SILE.process(content)
   end)
   self:registerCommand("tableofcontents:level2number", function (_, content)
      SILE.process(content)
   end)
   self:registerCommand("tableofcontents:level3number", function (_, content)
      SILE.process(content)
   end)
end

function class:endPage ()
   if not SILE.scratch.headers.skipthispage and not SILE.scratch.fduthesis.suppressHeaders then
      local headerContent
      if self:oddPage() then
         headerContent = SILE.scratch.headers.right
      else
         headerContent = SILE.scratch.headers.left
      end
      if headerContent then
         SILE.typesetNaturally(SILE.getFrame("runningHead"), function ()
            SILE.settings:toplevelState()
            SILE.settings:set("current.parindent", SILE.types.node.glue())
            SILE.settings:set("document.lskip", SILE.types.node.glue())
            SILE.settings:set("document.rskip", SILE.types.node.glue())
            SILE.settings:set("document.baselineskip", SILE.types.node.vglue("12pt"))
            SILE.process(headerContent)
            SILE.call("par")
            SILE.typesetter:leaveHmode()
            SILE.call("noindent")
            SILE.call("hrulefill", { thickness = "0.5pt", raise = "0pt" })
            SILE.typesetter:leaveHmode()
         end)
      end
   end
   SILE.scratch.headers.skipthispage = false
   return plain.endPage(self)
end

function class:declareOptions ()
   book.declareOptions(self)
   self:declareOption("type", function (_, value)
      if value then
         self._thesisType = value
      end
      return self._thesisType or "doctor"
   end)
   self:declareOption("degree", function (_, value)
      if value then
         self._degreeType = value
      end
      return self._degreeType or "academic"
   end)
end

function class:registerCommands ()
   book.registerCommands(self)

   local metaKeys = {
      "title",
      "titleEn",
      "author",
      "supervisor",
      "department",
      "major",
      "date",
      "studentId",
      "schoolCode",
      "keywordsCn",
      "keywordsEn",
      "clc",
      "secretLevel",
      "secretYear",
      "tongdengxueli",
      "englishProject",
   }
   for _, key in ipairs(metaKeys) do
      self:registerCommand("fdu:" .. key, function (_, content)
         if SU.ast.hasContent(content) then
            SILE.scratch.fduthesis[key] = SU.ast.contentToString(content)
         end
      end, "Set thesis metadata: " .. key)
   end

   self:registerCommand("fdu:heiti", function (_, content)
      SILE.call("font", { family = "SimHei" }, content)
   end, "黑体 font")

   self:registerCommand("fdu:songti", function (_, content)
      SILE.call("font", { family = "SimSun" }, content)
   end, "宋体 font")

   self:registerCommand("fdu:kaiti", function (_, content)
      SILE.call("font", { family = "KaiTi" }, content)
   end, "楷体 font")

   self:registerCommand("fdu:fangsong", function (_, content)
      SILE.call("font", { family = "FangSong" }, content)
   end, "仿宋 font")

   self:registerCommand("fdu:code", function (_, content)
      SILE.call("font", { family = "Hack", size = "0.9em", language = "und" }, content)
   end, "Inline code font")

   self:registerCommand("fdu:emph", function (_, content)
      SILE.call("font", { family = "KaiTi" }, content)
   end, "Chinese emphasis using 楷体")

   self:registerCommand("fdu:bold", function (_, content)
      SILE.call("font", { weight = 700 }, content)
   end, "Bold text")

   self:registerCommand("fdu:italic", function (_, content)
      SILE.call("font", { style = "italic" }, content)
   end, "Italic text")

   self:registerCommand("fdu:bolditalic", function (_, content)
      SILE.call("font", { weight = 700, style = "italic" }, content)
   end, "Bold italic text")

   self:registerCommand("book:chapterfont", function (_, content)
      SILE.call("font", { family = "SimHei", weight = 700, size = "16pt" }, content)
   end)
   self:registerCommand("book:sectionfont", function (_, content)
      SILE.call("font", { family = "SimHei", weight = 700, size = "14pt" }, content)
   end)
   self:registerCommand("book:subsectionfont", function (_, content)
      SILE.call("font", { family = "SimHei", weight = 700, size = "12pt" }, content)
   end)

   self:registerCommand("book:left-running-head-font", function (_, content)
      SILE.call("font", { family = "SimSun", size = "10.5pt" }, content)
   end)
   self:registerCommand("book:right-running-head-font", function (_, content)
      SILE.call("font", { family = "SimSun", size = "10.5pt" }, content)
   end)

   -- =========================================================================
   -- Cover page
   -- =========================================================================

   self:registerCommand("fdu:makecover", function (_, _)
      local info = SILE.scratch.fduthesis

      SILE.call("nofolios")
      SILE.scratch.headers.skipthispage = true

      SILE.settings:temporarily(function ()
         SILE.settings:set("document.lskip", SILE.types.node.glue("97mm"))
         SILE.settings:set("document.parindent", SILE.types.node.glue("0pt"))
         SILE.call("font", { family = "SimSun", size = "14pt" }, function ()
            SILE.call("noindent")
            SILE.typesetter:typeset("学校代码：" .. info.schoolCode)
            SILE.call("par")
            SILE.call("noindent")
            SILE.typesetter:typeset("学　　号：" .. info.studentId)
            SILE.call("par")
         end)
      end)

      if info.secretLevel ~= "" then
         SILE.settings:temporarily(function ()
            SILE.settings:set("document.lskip", SILE.types.node.glue("95mm"))
            SILE.settings:set("document.parindent", SILE.types.node.glue("0pt"))
            SILE.call("font", { family = "SimSun", size = "14pt" }, function ()
               SILE.call("noindent")
               local secretText = "密　　级：" .. info.secretLevel
               if info.secretYear ~= "" then
                  secretText = secretText .. info.secretYear
               end
               SILE.typesetter:typeset(secretText)
               SILE.call("par")
            end)
         end)
      end

      if info.tongdengxueli ~= "" or info.englishProject ~= "" then
         SILE.typesetter:leaveHmode()
         SILE.call("raggedleft", {}, function ()
            SILE.call("font", { family = "SimSun", size = "14pt" }, function ()
               local parts = {}
               if info.tongdengxueli ~= "" then
                  table.insert(parts, "同等学力人员")
               end
               if info.englishProject ~= "" then
                  table.insert(parts, "英文项目")
               end
               SILE.typesetter:typeset(table.concat(parts, "/"))
            end)
         end)
      end

      SILE.call("bigskip")
      SILE.call("vfill")

      SILE.typesetter:leaveHmode()
      SILE.call("center", {}, function ()
         SILE.call("noindent")
         local ok = pcall(function ()
            SILE.call("img", { src = "fudan-name.pdf", height = "80pt" })
         end)
         if not ok then
            SILE.call("font", { family = "SimSun", weight = 700, size = "36pt" }, function ()
               SILE.typesetter:typeset("复 旦 大 学")
            end)
         end
      end)

      SILE.call("bigskip")

      local degreeTitle
      if info.type == "doctor" then
         degreeTitle = "博 士 学 位 论 文"
      elseif info.type == "master" then
         degreeTitle = "硕 士 学 位 论 文"
      else
         degreeTitle = "本 科 毕 业 论 文"
      end

      SILE.typesetter:leaveHmode()
      SILE.call("center", {}, function ()
         SILE.call("noindent")
         SILE.call("font", { family = "SimHei", weight = 700, size = "26pt" }, function ()
            SILE.typesetter:typeset(degreeTitle)
         end)
      end)

      if info.type ~= "bachelor" then
         SILE.call("medskip")
         SILE.typesetter:leaveHmode()
         SILE.call("center", {}, function ()
            SILE.call("noindent")
            SILE.call("font", { family = "SimSun", size = "16pt" }, function ()
               if info.degree == "professional" then
                  SILE.typesetter:typeset("（专业学位）")
               else
                  SILE.typesetter:typeset("（学术学位）")
               end
            end)
         end)
      end

      SILE.call("vfill")

      SILE.typesetter:leaveHmode()
      SILE.call("center", {}, function ()
         SILE.call("noindent")
         SILE.call("font", { family = "SimHei", weight = 700, size = "22pt" }, function ()
            SILE.typesetter:typeset(info.title)
         end)
      end)

      SILE.call("medskip")

      SILE.typesetter:leaveHmode()
      SILE.call("center", {}, function ()
         SILE.call("noindent")
         SILE.call("font", { family = "Times New Roman", weight = 700, size = "16pt" }, function ()
            SILE.typesetter:typeset(info.titleEn)
         end)
      end)

      SILE.call("vfill")

      SILE.settings:temporarily(function ()
         local lskip = "32mm"
         if info.degree == "professional" and info.type ~= "bachelor" then
            lskip = "18mm"
         end
         SILE.settings:set("document.lskip", SILE.types.node.glue(lskip))
         SILE.settings:set("document.parindent", SILE.types.node.glue("0pt"))
         SILE.settings:set("document.baselineskip", SILE.types.node.vglue("28pt"))
         SILE.call("font", { family = "SimSun", size = "16pt" }, function ()
            SILE.call("noindent")
            SILE.typesetter:typeset("院　　系：" .. info.department)
            SILE.call("par")
            SILE.call("noindent")
            if info.degree == "professional" and info.type ~= "bachelor" then
               SILE.typesetter:typeset("专业学位类别（领域）：" .. info.major)
            else
               SILE.typesetter:typeset("专　　业：" .. info.major)
            end
            SILE.call("par")
            SILE.call("noindent")
            SILE.typesetter:typeset("姓　　名：" .. info.author)
            SILE.call("par")
            SILE.call("noindent")
            SILE.typesetter:typeset("指导教师：" .. info.supervisor)
            SILE.call("par")
            SILE.call("noindent")
            SILE.typesetter:typeset("完成日期：" .. info.date)
            SILE.call("par")
         end)
      end)

      SILE.call("bigskip")
      SILE.call("bigskip")
      SILE.call("par")
      SILE.call("supereject")
   end, "Generate thesis cover page")

   -- =========================================================================
   -- Declaration page
   -- =========================================================================

   self:registerCommand("fdu:declaration", function (_, _)
      SILE.scratch.fduthesis.suppressHeaders = true
      SILE.call("nofolios")
      SILE.scratch.headers.skipthispage = true
      SILE.call("noindent")
      SILE.call("vfill")

      SILE.typesetter:leaveHmode()
      SILE.call("center", {}, function ()
         SILE.call("font", { family = "SimHei", weight = 700, size = "16pt" }, function ()
            SILE.typesetter:typeset("复旦大学")
         end)
      end)
      SILE.typesetter:leaveHmode()
      SILE.call("center", {}, function ()
         SILE.call("font", { family = "SimHei", weight = 700, size = "16pt" }, function ()
            SILE.typesetter:typeset("学位论文独创性声明")
         end)
      end)
      SILE.call("bigskip")

      SILE.settings:temporarily(function ()
         SILE.settings:set("document.baselineskip", SILE.types.node.vglue("22pt"))
         SILE.call("font", { family = "SimSun", size = "12pt" }, function ()
            SILE.typesetter:typeset(
               "本人郑重声明：所呈交的学位论文，是本人在导师的指导下，独立进行研究工作所取得的成果。论文中除特别标注的内容外，不包含任何其他个人或机构已经发表或撰写过的研究成果。对本研究做出重要贡献的个人和集体，均已在论文中作了明确的声明并表示了谢意。本声明的法律结果由本人承担。"
            )
            SILE.call("par")
         end)
      end)

      SILE.call("bigskip")
      SILE.call("bigskip")
      SILE.typesetter:leaveHmode()
      SILE.call("raggedleft", {}, function ()
         SILE.call("font", { family = "SimSun", size = "12pt" }, function ()
            SILE.typesetter:typeset("作者签名：　　　　　　　　日期：　　　年　　月　　日")
         end)
      end)

      SILE.call("vfill")

      SILE.typesetter:leaveHmode()
      SILE.call("center", {}, function ()
         SILE.call("font", { family = "SimHei", weight = 700, size = "16pt" }, function ()
            SILE.typesetter:typeset("复旦大学")
         end)
      end)
      SILE.typesetter:leaveHmode()
      SILE.call("center", {}, function ()
         SILE.call("font", { family = "SimHei", weight = 700, size = "16pt" }, function ()
            SILE.typesetter:typeset("学位论文使用授权声明")
         end)
      end)
      SILE.call("bigskip")

      SILE.settings:temporarily(function ()
         SILE.settings:set("document.baselineskip", SILE.types.node.vglue("22pt"))
         SILE.call("font", { family = "SimSun", size = "12pt" }, function ()
            SILE.typesetter:typeset(
               "本人完全了解复旦大学有关收藏和利用博士、硕士学位论文的规定，即：学校有权收藏、使用并向国家有关部门或机构送交论文的印刷本和电子版本；允许论文被查阅和借阅；学校可以公布论文的全部或部分内容，可以采用影印、缩印或其它复制手段保存论文。涉密学位论文在解密后遵守此规定。"
            )
            SILE.call("par")
         end)
      end)

      SILE.call("bigskip")
      SILE.call("bigskip")
      SILE.typesetter:leaveHmode()
      SILE.call("raggedleft", {}, function ()
         SILE.call("font", { family = "SimSun", size = "12pt" }, function ()
            SILE.typesetter:typeset("作者签名：　　　　　导师签名：　　　　　日期：　　　年　　月　　日")
         end)
      end)

      SILE.call("vfill")
      SILE.call("par")
      SILE.call("supereject")
   end, "Generate declaration pages")

   -- =========================================================================
   -- Instructor list page
   -- =========================================================================

   self:registerCommand("fdu:instructors", function (_, content)
      SILE.scratch.headers.skipthispage = true
      SILE.call("nofolios")
      SILE.call("noindent")

      SILE.typesetter:leaveHmode()
      SILE.call("center", {}, function ()
         SILE.call("font", { family = "SimHei", weight = 700, size = "16pt" }, function ()
            SILE.typesetter:typeset("指导小组成员名单")
         end)
      end)

      SILE.call("bigskip")

      SILE.settings:temporarily(function ()
         SILE.settings:set("document.baselineskip", SILE.types.node.vglue("22pt"))
         SILE.settings:set("document.parindent", SILE.types.node.glue("0pt"))
         SILE.typesetter:leaveHmode()
         SILE.call("center", {}, function ()
            SILE.call("font", { family = "SimSun", size = "12pt" }, function ()
               SILE.process(content)
            end)
         end)
      end)

      SILE.call("par")
      SILE.call("supereject")
   end, "Instructor group list page")

   -- =========================================================================
   -- Chinese abstract
   -- =========================================================================

   self:registerCommand("fdu:abstract", function (_, content)
      SILE.call("open-spread", { double = false })
      SILE.scratch.headers.skipthispage = true
      SILE.call("noindent")
      SILE.call("tocentry", { level = 1 }, { "摘要" })

      SILE.call("left-running-head", {}, function ()
         SILE.call("book:left-running-head-font", {}, function ()
            SILE.typesetter:typeset("摘要")
         end)
      end)
      SILE.call("right-running-head", {}, function ()
         SILE.call("book:right-running-head-font", {}, function ()
            SILE.call("raggedleft", {}, function ()
               SILE.typesetter:typeset("摘要")
            end)
         end)
      end)

      SILE.typesetter:leaveHmode()
      SILE.call("center", {}, function ()
         SILE.call("font", { family = "SimHei", weight = 700, size = "16pt" }, function ()
            SILE.typesetter:typeset("摘　　要")
         end)
      end)
      SILE.call("bigskip")

      SILE.settings:temporarily(function ()
         SILE.settings:set("document.baselineskip", SILE.types.node.vglue("20pt"))
         SILE.call("font", { family = "SimSun", size = "12pt" }, function ()
            SILE.process(content)
            SILE.call("par")
         end)
      end)

      local info = SILE.scratch.fduthesis
      if info.keywordsCn ~= "" then
         SILE.call("bigskip")
         SILE.call("noindent")
         SILE.call("font", { family = "SimHei", weight = 700, size = "12pt" }, function ()
            SILE.typesetter:typeset("关键词：")
         end)
         SILE.call("font", { family = "SimSun", size = "12pt" }, function ()
            SILE.typesetter:typeset(info.keywordsCn)
         end)
         SILE.call("par")
      end

      if info.clc ~= "" then
         SILE.call("noindent")
         SILE.call("font", { family = "SimHei", weight = 700, size = "12pt" }, function ()
            SILE.typesetter:typeset("中图分类号：")
         end)
         SILE.call("font", { family = "SimSun", size = "12pt" }, function ()
            SILE.typesetter:typeset(info.clc)
         end)
         SILE.call("par")
      end

      SILE.call("par")
      SILE.call("supereject")
   end, "Chinese abstract section")

   -- =========================================================================
   -- English abstract
   -- =========================================================================

   self:registerCommand("fdu:abstract-en", function (_, content)
      SILE.call("open-spread", { double = false })
      SILE.scratch.headers.skipthispage = true
      SILE.call("noindent")
      SILE.call("tocentry", { level = 1 }, { "Abstract" })

      SILE.call("left-running-head", {}, function ()
         SILE.call("book:left-running-head-font", {}, function ()
            SILE.typesetter:typeset("Abstract")
         end)
      end)
      SILE.call("right-running-head", {}, function ()
         SILE.call("book:right-running-head-font", {}, function ()
            SILE.call("raggedleft", {}, function ()
               SILE.typesetter:typeset("Abstract")
            end)
         end)
      end)

      SILE.typesetter:leaveHmode()
      SILE.call("center", {}, function ()
         SILE.call("font", { family = "Times New Roman", weight = 700, size = "16pt" }, function ()
            SILE.typesetter:typeset("Abstract")
         end)
      end)
      SILE.call("bigskip")

      SILE.settings:temporarily(function ()
         SILE.settings:set("document.baselineskip", SILE.types.node.vglue("20pt"))
         SILE.call("font", { family = "Times New Roman", size = "12pt" }, function ()
            SILE.process(content)
            SILE.call("par")
         end)
      end)

      local info = SILE.scratch.fduthesis
      if info.keywordsEn ~= "" then
         SILE.call("bigskip")
         SILE.call("noindent")
         SILE.call("font", { family = "Times New Roman", weight = 700, size = "12pt" }, function ()
            SILE.typesetter:typeset("Keywords: ")
         end)
         SILE.call("font", { family = "Times New Roman", size = "12pt" }, function ()
            SILE.typesetter:typeset(info.keywordsEn)
         end)
         SILE.call("par")
      end

      SILE.call("par")
      SILE.call("supereject")
   end, "English abstract section")

   -- =========================================================================
   -- Front/Main/Back matter
   -- =========================================================================

   self:registerCommand("fdu:frontmatter", function (_, _)
      SILE.call("open-spread", { double = false })
      SILE.call("folios")
      SILE.call("set-counter", { id = "folio", value = 1, display = "roman" })
   end, "Start front matter with lowercase Roman page numbers")

   self:registerCommand("fdu:mainmatter", function (_, _)
      SILE.call("open-spread", { double = false })
      SILE.call("folios")
      SILE.call("set-counter", { id = "folio", value = 1, display = "arabic" })
   end, "Start main matter with Arabic page numbers")

   self:registerCommand("fdu:backmatter", function (_, _)
   end, "Start back matter (continues current numbering)")

   -- =========================================================================
   -- Acknowledgements
   -- =========================================================================

   self:registerCommand("fdu:acknowledgements", function (_, content)
      SILE.call("par")
      SILE.call("open-spread", { double = false })
      SILE.call("noindent")
      SILE.call("tocentry", { level = 1 }, { "致谢" })

      SILE.call("left-running-head", {}, function ()
         SILE.call("book:left-running-head-font", {}, function ()
            SILE.typesetter:typeset("致谢")
         end)
      end)
      SILE.call("right-running-head", {}, function ()
         SILE.call("book:right-running-head-font", {}, function ()
            SILE.call("raggedleft", {}, function ()
               SILE.typesetter:typeset("致谢")
            end)
         end)
      end)

      SILE.typesetter:leaveHmode()
      SILE.call("center", {}, function ()
         SILE.call("font", { family = "SimHei", weight = 700, size = "16pt" }, function ()
            SILE.typesetter:typeset("致　　谢")
         end)
      end)
      SILE.call("bigskip")

      SILE.settings:temporarily(function ()
         SILE.settings:set("document.baselineskip", SILE.types.node.vglue("20pt"))
         SILE.call("font", { family = "SimSun", size = "12pt" }, function ()
            SILE.process(content)
            SILE.call("par")
         end)
      end)
   end, "Acknowledgements section")

   -- =========================================================================
   -- Bibliography
   -- =========================================================================

   self:registerCommand("fdu:bibliography", function (_, content)
      SILE.call("par")
      SILE.call("open-spread", { double = false })
      SILE.call("noindent")
      SILE.call("tocentry", { level = 1 }, { "参考文献" })

      SILE.call("left-running-head", {}, function ()
         SILE.call("book:left-running-head-font", {}, function ()
            SILE.typesetter:typeset("参考文献")
         end)
      end)
      SILE.call("right-running-head", {}, function ()
         SILE.call("book:right-running-head-font", {}, function ()
            SILE.call("raggedleft", {}, function ()
               SILE.typesetter:typeset("参考文献")
            end)
         end)
      end)

      SILE.typesetter:leaveHmode()
      SILE.call("center", {}, function ()
         SILE.call("font", { family = "SimHei", weight = 700, size = "16pt" }, function ()
            SILE.typesetter:typeset("参考文献")
         end)
      end)
      SILE.call("bigskip")

      SILE.settings:temporarily(function ()
         SILE.settings:set("document.baselineskip", SILE.types.node.vglue("18pt"))
         SILE.call("font", { family = "SimSun", size = "10.5pt" }, function ()
            SILE.process(content)
            SILE.call("par")
         end)
      end)
   end, "Bibliography section")

   -- =========================================================================
   -- Appendix
   -- =========================================================================

   self:registerCommand("fdu:appendix", function (_, content)
      SILE.call("par")
      SILE.call("open-spread", { double = false })
      SILE.call("noindent")
      SILE.call("tocentry", { level = 1 }, { "附录" })

      SILE.call("left-running-head", {}, function ()
         SILE.call("book:left-running-head-font", {}, function ()
            SILE.typesetter:typeset("附录")
         end)
      end)
      SILE.call("right-running-head", {}, function ()
         SILE.call("book:right-running-head-font", {}, function ()
            SILE.call("raggedleft", {}, function ()
               SILE.typesetter:typeset("附录")
            end)
         end)
      end)

      SILE.typesetter:leaveHmode()
      SILE.call("center", {}, function ()
         SILE.call("font", { family = "SimHei", weight = 700, size = "16pt" }, function ()
            SILE.typesetter:typeset("附　　录")
         end)
      end)
      SILE.call("bigskip")

      SILE.scratch.fduthesis.appendixCounter = 0

      SILE.settings:temporarily(function ()
         SILE.settings:set("document.baselineskip", SILE.types.node.vglue("20pt"))
         SILE.call("font", { family = "SimSun", size = "12pt" }, function ()
            SILE.process(content)
            SILE.call("par")
         end)
      end)
   end, "Appendix section")

   self:registerCommand("fdu:appendix-section", function (_, content)
      SILE.scratch.fduthesis.appendixCounter = (SILE.scratch.fduthesis.appendixCounter or 0) + 1
      local counter = SILE.scratch.fduthesis.appendixCounter
      local letter = string.char(64 + counter)
      local label = "附录 " .. letter

      SILE.call("par")
      SILE.call("bigskip")
      SILE.call("goodbreak")
      SILE.call("noindent")
      SILE.call("tocentry", { level = 2, number = label }, SU.ast.subContent(content))

      SILE.typesetter:leaveHmode()
      SILE.call("center", {}, function ()
         SILE.call("font", { family = "SimHei", weight = 700, size = "14pt" }, function ()
            SILE.typesetter:typeset(label .. "　")
            SILE.process(content)
         end)
      end)
      SILE.call("par")
      SILE.call("medskip")
      SILE.call("noindent")
   end, "Appendix sub-section (A, B, C...)")

   -- =========================================================================
   -- Chapter command (Chinese style)
   -- =========================================================================

   self:registerCommand("chapter", function (options, content)
      SILE.call("par")
      SILE.call("open-spread", { double = false })
      SILE.call("noindent")
      SILE.call("set-counter", { id = "footnote", value = 1 })

      local numbering = SU.boolean(options.numbering, true)
      local toc = SU.boolean(options.toc, true)
      local chapterNum, chineseLabel

      if numbering then
         SILE.call("increment-multilevel-counter", { id = "sectioning", level = 1 })
         chapterNum = self:getMultilevelCounter("sectioning").value[1]
         chineseLabel = "第" .. toChineseNumber(chapterNum) .. "章"
      end

      if toc then
         SILE.call("tocentry", { level = 1, number = chineseLabel or "" }, SU.ast.subContent(content))
      end

      SILE.typesetter:leaveHmode()
      SILE.call("center", {}, function ()
         SILE.call("book:chapterfont", {}, function ()
            if numbering then
               SILE.typesetter:typeset(chineseLabel .. "　")
            end
            SILE.process(content)
         end)
      end)

      SILE.call("left-running-head", {}, function ()
         SILE.call("book:left-running-head-font", {}, function ()
            if numbering then
               SILE.typesetter:typeset(chineseLabel .. "　")
            end
            SILE.process(content)
         end)
      end)
      SILE.call("right-running-head", {}, function ()
         SILE.call("book:right-running-head-font", {}, function ()
            SILE.call("raggedleft", {}, function ()
               if numbering then
                  SILE.typesetter:typeset(chineseLabel .. "　")
               end
               SILE.process(content)
            end)
         end)
      end)

      SILE.call("novbreak")
      SILE.call("bigskip")
      SILE.call("novbreak")
      SILE.call("noindent")
   end, "Start a new chapter (Chinese style)")

   -- =========================================================================
   -- Section command
   -- =========================================================================

   self:registerCommand("section", function (options, content)
      SILE.call("par")
      SILE.call("noindent")
      SILE.call("bigskip")
      SILE.call("goodbreak")

      local numbering = SU.boolean(options.numbering, true)
      local toc = SU.boolean(options.toc, true)
      local number

      if numbering then
         SILE.call("increment-multilevel-counter", { id = "sectioning", level = 2 })
         number = self.packages.counters:formatMultilevelCounter(self:getMultilevelCounter("sectioning"))
      end

      if toc then
         SILE.call("tocentry", { level = 2, number = number }, SU.ast.subContent(content))
      end

      SILE.call("book:sectionfont", {}, function ()
         if numbering then
            SILE.call("show-multilevel-counter", { id = "sectioning", level = 2 })
            SILE.typesetter:typeset("　")
         end
         SILE.process(content)
      end)

      SILE.call("right-running-head", {}, function ()
         SILE.call("book:right-running-head-font", {}, function ()
            SILE.call("raggedleft", {}, function ()
               if numbering then
                  SILE.call("show-multilevel-counter", { id = "sectioning", level = 2 })
                  SILE.typesetter:typeset("　")
               end
               SILE.process(content)
            end)
         end)
      end)

      SILE.call("par")
      SILE.call("novbreak")
      SILE.call("smallskip")
      SILE.call("novbreak")
      SILE.call("noindent")
   end, "Start a new section")

   -- =========================================================================
   -- Subsection command
   -- =========================================================================

   self:registerCommand("subsection", function (options, content)
      SILE.call("par")
      SILE.call("noindent")
      SILE.call("medskip")
      SILE.call("goodbreak")

      local numbering = SU.boolean(options.numbering, true)
      local toc = SU.boolean(options.toc, true)
      local number

      if numbering then
         SILE.call("increment-multilevel-counter", { id = "sectioning", level = 3 })
         number = self.packages.counters:formatMultilevelCounter(self:getMultilevelCounter("sectioning"))
      end

      if toc then
         SILE.call("tocentry", { level = 3, number = number }, SU.ast.subContent(content))
      end

      SILE.call("book:subsectionfont", {}, function ()
         if numbering then
            SILE.call("show-multilevel-counter", { id = "sectioning", level = 3 })
            SILE.typesetter:typeset("　")
         end
         SILE.process(content)
      end)

      SILE.call("par")
      SILE.call("novbreak")
      SILE.call("smallskip")
      SILE.call("novbreak")
      SILE.call("noindent")
   end, "Start a new subsection")

   -- =========================================================================
   -- PDF metadata helper
   -- =========================================================================

   self:registerCommand("fdu:pdfmetadata", function (_, _)
      local info = SILE.scratch.fduthesis
      if info.title ~= "" then
         SILE.call("pdf:metadata", { key = "Title", value = info.title })
      end
      if info.author ~= "" then
         SILE.call("pdf:metadata", { key = "Author", value = info.author })
      end
   end, "Set PDF metadata from thesis info")
end

return class
