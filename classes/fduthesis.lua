--- Fudan University Thesis Document Class for SILE
--- Supports bachelor, master, and doctoral degree theses.
--- Based on the 2024 revision of Fudan University thesis regulations.
--- Reference: fduthesis LaTeX template (https://github.com/stone-zeng/fduthesis)
--- @use classes.fduthesis

local book = require("classes.book")

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

-- A4 paper (210mm × 297mm) with Word default margins
-- Top/Bottom: 2.54cm (25.4mm), Left/Right: 3.18cm (31.8mm)
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
   SILE.settings:set("document.language", "zh", true)
   SILE.settings:set("font.family", "SimSun", true)
   SILE.settings:set("font.size", 12, true)
   SILE.settings:set("document.baselineskip", SILE.types.node.vglue("20pt"), true)
   SILE.settings:set("document.parindent", SILE.types.node.glue("2em"), true)
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

   -- =========================================================================
   -- Metadata commands
   -- =========================================================================

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

   -- =========================================================================
   -- Font style commands
   -- =========================================================================

   self:registerCommand("fdu:heiti", function (_, content)
      SILE.call("font", { family = "SimHei" }, content)
   end, "SimHei (黑体) font")

   self:registerCommand("fdu:songti", function (_, content)
      SILE.call("font", { family = "SimSun" }, content)
   end, "SimSun (宋体) font")

   self:registerCommand("fdu:kaiti", function (_, content)
      SILE.call("font", { family = "KaiTi" }, content)
   end, "KaiTi (楷体) font")

   self:registerCommand("fdu:fangsong", function (_, content)
      SILE.call("font", { family = "FangSong" }, content)
   end, "FangSong (仿宋) font")

   self:registerCommand("fdu:code", function (_, content)
      SILE.call("font", { family = "Hack", size = "0.9em", language = "und" }, content)
   end, "Inline code font")

   self:registerCommand("fdu:emph", function (_, content)
      SILE.call("font", { family = "KaiTi" }, content)
   end, "Chinese emphasis using KaiTi")

   -- Override book heading fonts for Chinese thesis
   self:registerCommand("book:chapterfont", function (_, content)
      SILE.call("font", { family = "SimHei", weight = 700, size = "16pt" }, content)
   end)
   self:registerCommand("book:sectionfont", function (_, content)
      SILE.call("font", { family = "SimHei", weight = 700, size = "14pt" }, content)
   end)
   self:registerCommand("book:subsectionfont", function (_, content)
      SILE.call("font", { family = "SimHei", weight = 700, size = "12pt" }, content)
   end)

   -- Running head fonts
   self:registerCommand("book:left-running-head-font", function (_, content)
      SILE.call("font", { family = "SimSun", size = "10pt" }, content)
   end)
   self:registerCommand("book:right-running-head-font", function (_, content)
      SILE.call("font", { family = "SimSun", size = "10pt" }, content)
   end)

   -- =========================================================================
   -- Table of Contents customization
   -- =========================================================================

   self:registerCommand("tableofcontents:headerfont", function (_, content)
      SILE.call("font", { family = "SimHei", weight = 700, size = "16pt" }, content)
   end)

   self:registerCommand("tableofcontents:header", function (_, _)
      SILE.call("par")
      SILE.call("noindent")
      SILE.call("center", {}, function ()
         SILE.call("tableofcontents:headerfont", {}, function ()
            SILE.typesetter:typeset("目　　录")
         end)
      end)
      SILE.call("bigskip")
   end)

   self:registerCommand("tableofcontents:level1item", function (_, content)
      SILE.call("goodbreak")
      SILE.call("noindent")
      SILE.call("font", { family = "SimHei", size = "12pt", weight = 700 }, content)
      SILE.call("smallskip")
   end)

   self:registerCommand("tableofcontents:level2item", function (_, content)
      SILE.settings:temporarily(function ()
         SILE.settings:set("document.lskip", SILE.types.node.glue("2em"))
         SILE.call("noindent")
         SILE.call("font", { family = "SimSun", size = "12pt" }, content)
      end)
      SILE.call("smallskip")
   end)

   self:registerCommand("tableofcontents:level3item", function (_, content)
      SILE.settings:temporarily(function ()
         SILE.settings:set("document.lskip", SILE.types.node.glue("4em"))
         SILE.call("noindent")
         SILE.call("font", { family = "SimSun", size = "10.5pt" }, content)
      end)
      SILE.call("smallskip")
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

   -- =========================================================================
   -- Cover page
   -- =========================================================================

   self:registerCommand("fdu:makecover", function (_, _)
      local info = SILE.scratch.fduthesis

      SILE.call("nofolios")
      SILE.scratch.headers.skipthispage = true

      -- Secret level (right-aligned, above school code per standard)
      if info.secretLevel ~= "" then
         SILE.call("raggedleft", {}, function ()
            SILE.call("font", { family = "SimSun", size = "14pt" }, function ()
               local secretText = "密级：" .. info.secretLevel
               if info.secretYear ~= "" then
                  secretText = secretText .. info.secretYear
               end
               SILE.typesetter:typeset(secretText)
            end)
         end)
      end

      -- School code and student ID (right-aligned)
      SILE.call("raggedleft", {}, function ()
         SILE.call("font", { family = "SimSun", size = "14pt" }, function ()
            SILE.typesetter:typeset("学校代码：" .. info.schoolCode)
         end)
      end)
      SILE.call("raggedleft", {}, function ()
         SILE.call("font", { family = "SimSun", size = "14pt" }, function ()
            SILE.typesetter:typeset("学　　号：" .. info.studentId)
         end)
      end)

      -- Tongdengxueli / English project (right-aligned, if applicable)
      if info.tongdengxueli ~= "" or info.englishProject ~= "" then
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

      -- University name (image or fallback text)
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

      -- Degree type title
      local degreeTitle
      if info.type == "doctor" then
         degreeTitle = "博 士 学 位 论 文"
      elseif info.type == "master" then
         degreeTitle = "硕 士 学 位 论 文"
      else
         degreeTitle = "本 科 毕 业 论 文"
      end

      SILE.call("center", {}, function ()
         SILE.call("noindent")
         SILE.call("font", { family = "SimHei", weight = 700, size = "26pt" }, function ()
            SILE.typesetter:typeset(degreeTitle)
         end)
      end)

      -- Degree category (academic/professional)
      if info.type ~= "bachelor" then
         SILE.call("medskip")
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

      -- Chinese title
      SILE.call("center", {}, function ()
         SILE.call("noindent")
         SILE.call("font", { family = "SimHei", weight = 700, size = "22pt" }, function ()
            SILE.typesetter:typeset(info.title)
         end)
      end)

      SILE.call("medskip")

      -- English title
      SILE.call("center", {}, function ()
         SILE.call("noindent")
         SILE.call("font", { family = "Times New Roman", weight = 700, size = "16pt" }, function ()
            SILE.typesetter:typeset(info.titleEn)
         end)
      end)

      SILE.call("vfill")

      -- Author information (left-aligned block, visually centered on page)
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
   -- Declaration page (独创性声明 + 使用授权声明)
   -- =========================================================================

   self:registerCommand("fdu:declaration", function (_, _)
      SILE.call("nofolios")
      SILE.scratch.headers.skipthispage = true
      SILE.call("noindent")
      SILE.call("vfill")

      -- Originality declaration
      SILE.call("center", {}, function ()
         SILE.call("font", { family = "SimHei", weight = 700, size = "16pt" }, function ()
            SILE.typesetter:typeset("复旦大学")
         end)
      end)
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
      SILE.call("raggedleft", {}, function ()
         SILE.call("font", { family = "SimSun", size = "12pt" }, function ()
            SILE.typesetter:typeset("作者签名：　　　　　　　　日期：　　　年　　月　　日")
         end)
      end)

      SILE.call("vfill")

      -- Authorization declaration
      SILE.call("center", {}, function ()
         SILE.call("font", { family = "SimHei", weight = 700, size = "16pt" }, function ()
            SILE.typesetter:typeset("复旦大学")
         end)
      end)
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
   -- Instructor list page (扉页：指导小组成员名单)
   -- =========================================================================

   self:registerCommand("fdu:instructors", function (_, content)
      SILE.scratch.headers.skipthispage = true
      SILE.call("nofolios")
      SILE.call("noindent")

      SILE.call("center", {}, function ()
         SILE.call("font", { family = "SimHei", weight = 700, size = "16pt" }, function ()
            SILE.typesetter:typeset("指导小组成员名单")
         end)
      end)

      SILE.call("bigskip")

      SILE.settings:temporarily(function ()
         SILE.settings:set("document.baselineskip", SILE.types.node.vglue("22pt"))
         SILE.call("font", { family = "SimSun", size = "12pt" }, function ()
            SILE.process(content)
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
      SILE.scratch.headers.skipthispage = true
      SILE.call("noindent")
      SILE.call("tocentry", { level = 1 }, { "致谢" })

      SILE.call("center", {}, function ()
         SILE.call("font", { family = "SimHei", weight = 700, size = "16pt" }, function ()
            SILE.typesetter:typeset("致　　谢")
         end)
      end)
      SILE.call("bigskip")

      SILE.call("left-running-head", {}, function ()
         SILE.call("book:left-running-head-font", {}, function ()
            SILE.typesetter:typeset("致谢")
         end)
      end)

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

      SILE.call("center", {}, function ()
         SILE.call("font", { family = "SimHei", weight = 700, size = "16pt" }, function ()
            SILE.typesetter:typeset("参考文献")
         end)
      end)
      SILE.call("bigskip")

      SILE.call("left-running-head", {}, function ()
         SILE.call("book:left-running-head-font", {}, function ()
            SILE.typesetter:typeset("参考文献")
         end)
      end)

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

      SILE.call("center", {}, function ()
         SILE.call("font", { family = "SimHei", weight = 700, size = "16pt" }, function ()
            SILE.typesetter:typeset("附　　录")
         end)
      end)
      SILE.call("bigskip")

      SILE.call("left-running-head", {}, function ()
         SILE.call("book:left-running-head-font", {}, function ()
            SILE.typesetter:typeset("附录")
         end)
      end)

      SILE.settings:temporarily(function ()
         SILE.settings:set("document.baselineskip", SILE.types.node.vglue("20pt"))
         SILE.call("font", { family = "SimSun", size = "12pt" }, function ()
            SILE.process(content)
            SILE.call("par")
         end)
      end)
   end, "Appendix section")

   -- =========================================================================
   -- Override chapter command for Chinese style
   -- =========================================================================

   self:registerCommand("chapter", function (options, content)
      SILE.call("par")
      SILE.call("open-spread", { double = false })
      SILE.call("noindent")
      SILE.scratch.headers.right = nil
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

      -- Chapter number line
      SILE.call("center", {}, function ()
         SILE.call("book:chapterfont", {}, function ()
            if numbering then
               SILE.typesetter:typeset(chineseLabel)
            end
         end)
      end)

      -- Chapter title line
      SILE.call("center", {}, function ()
         SILE.call("book:chapterfont", {}, function ()
            SILE.process(content)
         end)
      end)

      -- Set left running head
      SILE.call("left-running-head", {}, function ()
         SILE.call("book:left-running-head-font", {}, function ()
            if numbering then
               SILE.typesetter:typeset(chineseLabel .. "　")
            end
            SILE.process(content)
         end)
      end)

      SILE.call("nofoliothispage")
      SILE.call("novbreak")
      SILE.call("bigskip")
      SILE.call("novbreak")
      SILE.call("noindent")
   end, "Start a new chapter (Chinese style)")

   -- =========================================================================
   -- Override section command
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

      if not SILE.scratch.counters.folio.off then
         SILE.call("right-running-head", {}, function ()
            SILE.call("book:right-running-head-font", {}, function ()
               SILE.call("raggedleft", {}, function ()
                  if numbering then
                     SILE.call("show-multilevel-counter", { id = "sectioning", level = 2 })
                     SILE.typesetter:typeset(" ")
                  end
                  SILE.process(content)
               end)
            end)
         end)
      end

      SILE.call("par")
      SILE.call("novbreak")
      SILE.call("smallskip")
      SILE.call("novbreak")
      SILE.call("noindent")
   end, "Start a new section")

   -- =========================================================================
   -- Override subsection command
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
