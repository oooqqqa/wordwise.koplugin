-- Translations for Word Wise's own UI strings.
--
-- These are plugin-specific strings that are not part of KOReader's shipped
-- translation catalog. Only English and Simplified Chinese are kept; keys are
-- the KOReader language codes (gettext's current_lang, e.g. "zh_CN"). English
-- is the source text and lives under en_GB; WordWise:tr() falls back to it for
-- every other UI language.
--
-- The keys, and their English source strings:
--   know            = "I already know this word"   (mark word known -> hide hint)
--   show            = "Show Word Wise hint"        (reverse: un-mark a known word)
--   no_db           = "No Word Wise dictionary found.\nPlace wordwise.db in:\n"
--   toggle          = "Toggle Word Wise hints"     (dispatcher/gesture action title)
--   show_inline     = "Show inline hints"          (menu toggle)
--   underline       = "Underline hinted words"     (menu toggle: draw the rule)
--   hint_level      = "Hint level: %1"             (%1 = number)
--   level_rarest    = "1 — only the rarest words"  (hint-level 1 label)
--   level_most      = "5 — most hints"             (hint-level 5 label)
--   font_size_menu  = "Hint font size: %1"         (%1 = number)
--   font_size_title = "Hint font size"             (spin-widget title)
--
-- "Word Wise" is kept as a Latin product name, matching how Kindle presents the
-- feature name. "%1" placeholders and the "\n" / "wordwise.db" literals must be
-- preserved verbatim in the translation.
return {
    en_GB = {
        know = "I already know this word", show = "Show Word Wise hint",
        no_db = "No Word Wise dictionary found.\nPlace wordwise.db in:\n",
        toggle = "Toggle Word Wise hints",
        show_inline = "Show inline hints",
        underline = "Underline hinted words",
        hint_level = "Hint level: %1",
        level_rarest = "1 — only the rarest words",
        level_most = "5 — most hints",
        font_size_menu = "Hint font size: %1",
        font_size_title = "Hint font size",
    },
    zh_CN = {
        know = "我已经认识这个词", show = "显示 Word Wise 提示",
        no_db = "未找到 Word Wise 词典。\n请将 wordwise.db 放入：\n",
        toggle = "切换 Word Wise 提示",
        show_inline = "显示行内提示",
        underline = "为有提示的词加下划线",
        hint_level = "提示级别：%1",
        level_rarest = "1 — 仅最生僻的词",
        level_most = "5 — 最多提示",
        font_size_menu = "提示字体大小：%1",
        font_size_title = "提示字体大小",
    },
}
