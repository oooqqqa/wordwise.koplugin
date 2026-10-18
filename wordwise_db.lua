-- Word Wise data layer.
--
-- The plugin is dictionary-agnostic: it reads a single canonical SQLite schema
-- and does not care how the database was produced. The database is always
-- wordwise.db inside the plugin folder (main.lua decides the path).
--
-- Canonical schema:
--   entries(word TEXT PRIMARY KEY COLLATE NOCASE,   -- lemma (base form)
--           short_def TEXT NOT NULL,
--           difficulty INTEGER NOT NULL,   -- 1 rarest .. 5 most common
--           pos TEXT)
--   forms(form TEXT PRIMARY KEY COLLATE NOCASE,     -- every spelling to look up,
--         lemma TEXT NOT NULL)                      -- the lemma itself included
--
-- Book words are looked up exactly in forms; the database decides which
-- inflections belong to which lemma, so the plugin never guesses.
--
-- A word is glossed when its difficulty <= the user's hint level, so a low
-- hint level shows only rare/hard words and a high one also shows common ones.
local SQ3 = require("lua-ljsqlite3/init")
local logger = require("logger")

local LOOKUP_SQL = "SELECT e.short_def, e.difficulty, e.word FROM forms f "
    .. "JOIN entries e ON e.word = f.lemma WHERE f.form = ?1 LIMIT 1;"

local WordWiseDB = {}
WordWiseDB.__index = WordWiseDB

-- Glosses are shown in full, untrimmed -- just tidy surrounding whitespace.
local function shorten(def)
    if not def or def == "" then return nil end
    def = def:gsub("^%s+", ""):gsub("%s+$", "")
    if def == "" then return nil end
    return def
end

function WordWiseDB.open(path)
    local ok, conn = pcall(SQ3.open, path)
    if not ok or not conn then
        logger.warn("WordWiseDB: cannot open", path, tostring(conn))
        return nil
    end
    local self = setmetatable({ conn = conn, cache = {} }, WordWiseDB)
    local ok2, stmt = pcall(function() return conn:prepare(LOOKUP_SQL) end)
    if not ok2 or not stmt then
        logger.warn("WordWiseDB: prepare failed", tostring(stmt))
        pcall(function() conn:close() end)
        return nil
    end
    self.stmt = stmt
    return self
end

-- One exact lookup in forms. Returns {gloss, difficulty, key} or nil.
function WordWiseDB:_query(key)
    local result = nil
    local ok, err = pcall(function()
        self.stmt:reset():clearbind()
        self.stmt:bind(key)
        local row = self.stmt:step()
        if row then
            local gloss = shorten(row[1])
            local difficulty = tonumber(row[2])
            if gloss and difficulty then
                -- key is the lemma, so callers can suppress every form of it.
                result = { gloss = gloss, difficulty = difficulty, key = row[3] }
            end
        end
        self.stmt:clearbind():reset()
    end)
    if not ok then
        logger.warn("WordWiseDB: lookup failed for", key, tostring(err))
    end
    return result
end

-- The forms key for a book word, or nil. crengine hands over words already
-- split at spaces, punctuation, apostrophes and hyphens (one’s -> one, s), so
-- a word that is not plain ASCII letters has an accent in it (naïve, coupé):
-- skip it, since dropping the accent looks up another word (nave, coup).
function WordWiseDB.keyFor(word)
    local key = word:lower()
    if #key >= 3 and key:match("^%a+$") then return key end
    return nil
end

-- Return { gloss = <string>, difficulty = <int>, key = <lemma> } or nil.
-- Cached per key (including negative results).
function WordWiseDB:lookup(word)
    local key = WordWiseDB.keyFor(word)
    if not key then return nil end
    local cached = self.cache[key]
    if cached ~= nil then
        return cached or nil
    end
    local result = self:_query(key)
    self.cache[key] = result or false
    return result
end

function WordWiseDB:close()
    if self.stmt then pcall(function() self.stmt:close() end) end
    if self.conn then pcall(function() self.conn:close() end) end
    self.stmt, self.conn = nil, nil
end

return WordWiseDB
