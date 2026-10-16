# Word Wise (KOReader plugin)

Shows short inline definitions above difficult words, like Kindle's Word Wise —
painted as a per-page overlay on the book you're reading (no copy, no file
rewrite). Difficulty is adjustable: a low hint level shows only rare/hard words,
a high one also glosses more common ones.

![Word Wise showing glosses above difficult words](screenshot.png)

## Install

1. Download **`wordwise.koplugin.zip`** from the
   [latest release](https://github.com/asxelot/wordwise.koplugin/releases/latest)
   and unzip it. It expands to a correctly-named `wordwise.koplugin/` folder
   (dictionary bundled) — ready to copy, no renaming needed.
2. Copy the `wordwise.koplugin` folder into KOReader's `koreader/plugins/`
   directory on your Android device.
3. Restart KOReader.

<details>
<summary>Install from source instead</summary>

`git clone` this repo, or use the green **Code → Download ZIP** button and
unzip it. A ZIP download unzips as **`wordwise.koplugin-main`** — remove the
`-main` so the folder ends in `.koplugin`, or KOReader won't recognize it
(cloning already gives the right name). Then copy it into `plugins/` as above.
</details>

## Activate

Open a book, then: **☰ (or ⋮) → more tools → Word Wise → Show inline hints**.
Pick a hint level (1 = only the rarest words … 5 = most hints). Short definitions
then appear above difficult words on every page. Turn it off from the same menu.

## A dictionary is included

The plugin **ships with a built-in open dictionary** (`wordwise.db`, ~30k hard
words), so it works out of the box — no setup. The bundled dictionary contains
no proprietary content and is freely redistributable (see *How the bundled
dictionary is built* below).

### Where the dictionary lives

There is exactly one location: `wordwise.db` inside the plugin folder
(`koreader/plugins/wordwise.koplugin/wordwise.db`). To use a different
dictionary, replace that file.

### Canonical schema

Whatever the source, the engine reads exactly this shape:

```sql
CREATE TABLE entries (
    word       TEXT PRIMARY KEY COLLATE NOCASE,
    short_def  TEXT NOT NULL,      -- the gloss shown above the word
    difficulty INTEGER NOT NULL,   -- 1 rarest .. 5 most common
    pos        TEXT                -- part of speech (optional)
);
```

A word is glossed when `difficulty <= hint level`. Lookups fall back to a few
cheap English de-inflections (plurals, `-ed`, `-ing`, `-ly`) so inflected forms
in the text still match base-form entries.

## How the bundled dictionary is built

`wordwise.db` is assembled from three open ingredients (`tools/build_open_dict.py`):

- **word list** — Open English WordNet lemmas (permissive license)
- **difficulty** — word-frequency (Zipf) from the [`wordfreq`](https://pypi.org/project/wordfreq/)
  package; only words below the "common" threshold are kept as hard words
- **glosses** — short definitions written for this project, stored in the
  editable source `tools/open_glosses.tsv` (`word<TAB>gloss`)

To improve a definition, edit `open_glosses.tsv` and rebuild:

```sh
cd tools
python3 build_open_dict.py build --glosses open_glosses.tsv --out ../wordwise.db
```

To regenerate the hard-word list itself (needs `pip install wn wordfreq` and the
`oewn:2024` lexicon):

```sh
python3 build_open_dict.py candidates > candidates.tsv
```

### Alternative sources

- **Wiktionary (CC BY-SA)** via the [Proficiency](https://github.com/xxyzz/Proficiency)
  `en_en` data, reshaped into the canonical schema.
