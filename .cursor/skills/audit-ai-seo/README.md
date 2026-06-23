# audit-ai-seo

Audit and implement **Google SEO** and **LLM discoverability** for websites, docs, blogs, and landing pages.

An [Agent Skill](https://agentskills.io/home); works in **Cursor**, **Claude** (Claude Code / Claude.ai), and any agent that supports the open standard. Includes a stdlib Ruby verifier and a required `site-pages.json` config.

Full agent workflow: [SKILL.md](SKILL.md)

## What it covers

Two layers, equal priority:

| Layer | Goal |
|-------|------|
| **Layer 0 — Google/crawl** | robots.txt, sitemap, meta tags, Open Graph, JSON-LD, feeds, canonical URLs |
| **Layer 1 — LLM retrieval** | `/llms.txt`, `.md` mirrors, `Link` headers, `Accept: text/markdown` negotiation, Content-Signal |

The skill **refuses debunked patterns** (`ai.txt`, AI-specific meta tags, User-Agent sniffing) and ends every audit or implementation with a live verifier run.

## When to use

- New site or docs: baseline audit before launch
- Existing site: "why aren't we in AI answers / Google?"
- After shipping discoverability changes: confirm production with the verifier

## Setup

Complete all steps below **before** invoking the skill. The workflow always ends by running `verify_seo.rb` against production — that script requires `site-pages.json` with your real URLs, not the skill's placeholder paths.

```
1. Install the skill     →  .cursor/skills/ or .claude/skills/
2. Copy verifier files   →  script/verify_seo.rb + script/site-pages.json
3. Edit site-pages.json  →  your HTML paths, .md mirrors, section indexes
4. Invoke the skill      →  /audit-ai-seo with your production URL
```

### 1. Install the skill

**Project install (recommended)** — add the skill to the repo you're auditing so the whole team shares the same workflow. Git stays in `/tmp/zcr-skills` only; your project's skill folder is a plain copy with no `.git`. Do **not** `git clone` directly into `.cursor/skills/` or `.claude/skills/`.

**Cursor** — from your project root:

```bash
mkdir -p /tmp .cursor/skills
if [ -d /tmp/zcr-skills/.git ]; then
  git -C /tmp/zcr-skills pull --ff-only
else
  git clone git@github.com:Zero-Config-Rails/skills.git /tmp/zcr-skills
fi
rsync -a --delete --exclude='.git' /tmp/zcr-skills/audit-ai-seo/ .cursor/skills/audit-ai-seo/
```

**Claude Code** — from your project root:

```bash
mkdir -p /tmp .claude/skills
if [ -d /tmp/zcr-skills/.git ]; then
  git -C /tmp/zcr-skills pull --ff-only
else
  git clone git@github.com:Zero-Config-Rails/skills.git /tmp/zcr-skills
fi
rsync -a --delete --exclude='.git' /tmp/zcr-skills/audit-ai-seo/ .claude/skills/audit-ai-seo/
```

### Global install (optional)

Use on any project without installing the skill in each repo. Clone stays in `/tmp` only.

| Agent | Path |
|-------|------|
| Cursor | `~/.cursor/skills/audit-ai-seo` |
| Claude Code | `~/.claude/skills/audit-ai-seo` |

```bash
mkdir -p /tmp ~/.cursor/skills   # or ~/.claude/skills
if [ -d /tmp/zcr-skills/.git ]; then
  git -C /tmp/zcr-skills pull --ff-only
else
  git clone git@github.com:Zero-Config-Rails/skills.git /tmp/zcr-skills
fi
rsync -a --delete --exclude='.git' /tmp/zcr-skills/audit-ai-seo/ ~/.cursor/skills/audit-ai-seo/   # or ~/.claude/skills/
```

Other clients: same folder layout; see [agentskills.io](https://agentskills.io/home) for paths.

### 2. Copy the verifier into your project

The skill lives in `.cursor/skills/` or `.claude/skills/`. The verifier runs from your project — copy both files into `script/`:

```bash
mkdir -p script
cp .cursor/skills/audit-ai-seo/scripts/verify_seo.rb script/
cp .cursor/skills/audit-ai-seo/site-pages.json script/
```

For Claude Code, swap `.cursor` → `.claude` in those paths.

### 3. Configure `site-pages.json`

Edit `script/site-pages.json` with **your** live URLs. The bundled file ships with example paths (`/guide/introduction/`, etc.) — the verifier will fail against a real site until you replace them.

**Site map mental model** — how the keys relate:

```
https://example.com/
├── /                          ← html_paths + /index.md in md_paths
├── /guide/                    ← section_indexes (section landing)
│   ├── guide.md               ← section_indexes md pair
│   └── /guide/introduction/   ← html_paths (deep content page)
│       └── introduction.md    ← md_paths
└── /blog/                     ← section_indexes
    └── blog.md
```

#### `html_paths` (required)

**What:** Representative **HTML content pages** — not section indexes. Pick 2–4 live pages that use your main templates (home, one guide chapter, one blog post, one docs page).

**Why:** The verifier checks each for a single `<title>`, meta description, canonical, Open Graph, JSON-LD, `<link rel="alternate" type="text/markdown">`, hidden LLM pointer, and HTTP `Link` headers.

**Examples:**

| Site type | Good picks |
|-----------|------------|
| Marketing site | `["/"]` |
| Docs + blog | `["/", "/docs/getting-started/", "/blog/my-first-post/"]` |
| Guide only | `["/", "/guide/introduction/", "/guide/chapter-2/"]` |

```json
"html_paths": ["/", "/guide/introduction/", "/blog/2024/launch-post/"]
```

Use trailing slashes if that is how your site serves URLs (`/guide/introduction/` not `/guide/introduction`).

---

#### `md_paths` (required)

**What:** The **`.md` mirror URLs** for the same kinds of pages — direct fetches, not derived from HTML paths.

**Why:** Confirms agents get clean Markdown (not HTML), and that the `.md` response includes a `Link` header pointing back to HTML.

**Rule of thumb:** For every path in `html_paths`, add the matching `.md` URL:

| HTML | `.md` mirror |
|------|----------------|
| `/` | `/index.md` |
| `/guide/introduction/` | `/guide/introduction.md` |
| `/about/` | `/about.md` |

```json
"md_paths": ["/index.md", "/guide/introduction.md", "/blog/2024/launch-post.md"]
```

---

#### `section_indexes` (required)

**What:** **Section landing pages** — the index/listing page for each major area of the site (guide overview, blog index, docs hub). Each entry is an `html` + `md` pair.

**Why:** Section indexes often use a different template than inner pages. They need their own `.md` mirror (e.g. `/guide.md` for `/guide/`) and are easy to forget. The verifier runs the full HTML + MD checks on both URLs in each pair.

**Not** the same as `html_paths`:
- `section_indexes` → “table of contents” pages (`/guide/`, `/blog/`)
- `html_paths` → actual articles/chapters (`/guide/introduction/`)

**Examples:**

Docs site with guide and blog:

```json
"section_indexes": [
  { "html": "/guide/", "md": "/guide.md" },
  { "html": "/blog/", "md": "/blog.md" }
]
```

Single-page marketing site with no sections:

```json
"section_indexes": []
```

Only a blog (no separate guide):

```json
"section_indexes": [
  { "html": "/blog/", "md": "/blog.md" }
]
```

---

#### `check_llms_full_txt` (optional, default `true`)

**What:** Whether to fetch `/llms-full.txt` — one file with your entire docs corpus in Markdown.

**When `true`:** Docs sites, APIs, large guides (agents can load everything at once).

**When `false`:** Blogs, marketing sites, or anywhere you only ship `/llms.txt` + per-page `.md` mirrors.

```json
"check_llms_full_txt": false
```

---

#### `require_feed` (optional, default `false`)

**What:** Whether to check `/feed.xml` exists and looks like Atom/RSS.

**When `true`:** Site has a blog or publishes feed updates.

**When `false`:** Static landing page with no feed.

```json
"require_feed": true
```

---

#### `require_json_ld` (optional, default `true`)

**What:** Whether sample HTML pages must include `application/ld+json` with `schema.org`.

**When `true`:** Normal production sites targeting Google rich results.

**When `false`:** Staging, or you are only testing Layer 1 (LLM) checks for now.

```json
"require_json_ld": true
```

---

#### `require_markdown_negotiation` (optional, default `true`)

**What:** Whether to test `Accept: text/markdown` content negotiation on each `html_paths` URL.

**Checks when `true`** (matches [acceptmarkdown.com readiness](https://acceptmarkdown.com/#readiness)):

1. `Accept: text/markdown, text/html;q=0.5` → **200** Markdown + `Vary: Accept`
2. `Accept: application/json` only → **406 Not Acceptable**
3. `Accept: text/html, text/markdown;q=0.5` → **200** HTML (q-values honored)
4. `Accept: */*` → **200** HTML (wildcard must not return Markdown)

Full implementation checklist: [references/accept-markdown-negotiation.md](references/accept-markdown-negotiation.md)

**When `false`:** You only serve `.md` at explicit `.md` URLs and have not shipped negotiation yet.

```json
"require_markdown_negotiation": false
```

---

#### Full examples by site type

**Docs + blog** (default template in [site-pages.json](site-pages.json)):

```json
{
  "html_paths": ["/", "/guide/introduction/"],
  "md_paths": ["/index.md", "/guide/introduction.md"],
  "section_indexes": [
    { "html": "/guide/", "md": "/guide.md" },
    { "html": "/blog/", "md": "/blog.md" }
  ],
  "check_llms_full_txt": true,
  "require_feed": true,
  "require_json_ld": true,
  "require_markdown_negotiation": true
}
```

**Blog only:**

```json
{
  "html_paths": ["/", "/blog/hello-world/"],
  "md_paths": ["/index.md", "/blog/hello-world.md"],
  "section_indexes": [
    { "html": "/blog/", "md": "/blog.md" }
  ],
  "check_llms_full_txt": false,
  "require_feed": true,
  "require_json_ld": true,
  "require_markdown_negotiation": true
}
```

**Single landing page:**

```json
{
  "html_paths": ["/"],
  "md_paths": ["/index.md"],
  "section_indexes": [],
  "check_llms_full_txt": false,
  "require_feed": false,
  "require_json_ld": true,
  "require_markdown_negotiation": false
}
```

### 4. Invoke the skill

With the skill installed and `script/site-pages.json` configured, open the **project root** in your agent.

**Cursor** — type `/audit-ai-seo` in **Agent** chat, or use natural language:

```
Audit AI SEO for https://myapp.com — Layer 0 and Layer 1, then verify production using script/site-pages.json.
```

```
Implement llms.txt, .md mirrors, and Accept negotiation. Run script/verify_seo.rb when done.
```

```
We're not showing up in AI answers. Run audit-ai-seo and fix gaps.
```

To confirm the skill is loaded: **Cursor Settings → Rules** — `audit-ai-seo` should appear under skills.

**Claude Code** — from the project directory:

```
/audit-ai-seo
```

```
Follow audit-ai-seo. Audit https://myapp.com — script/site-pages.json is already configured.
```

**Include in your first prompt:**

| Include | Example |
|---------|---------|
| Production URL | `https://myapp.com` |
| Stack | Bridgetown, Rails, Next.js, static on Netlify, … |
| Scope | audit only, implement fixes, or verify after deploy |
| Config location | `script/site-pages.json` (so the agent uses your paths) |

## Agent workflow

What the skill does once invoked:

1. Audit the live site (or local build output)
2. Report gaps as Layer 0 vs Layer 1 vs content
3. Implement fixes (each step is independently shippable)
4. Verify with `script/verify_seo.rb` against the **production** URL
5. Re-run the verifier after deploys using the same `site-pages.json`

## Live verifier

Stdlib-only Ruby. No gems. Reads `script/site-pages.json` (required).

```bash
ruby script/verify_seo.rb https://example.com
# or
SITE=https://example.com ruby script/verify_seo.rb
```

The script finds `site-pages.json` next to itself or in the working directory. Override with an explicit path:

```bash
ruby script/verify_seo.rb https://example.com ./script/site-pages.json
```

Exit code `1` if any check **FAIL**s; **WARN** lines are backlog unless you want zero warnings.

### What it checks

**Layer 0:** robots.txt, sitemap, Sitemap directive, AI bots not blocked, Content-Signal, single title/description, canonical, Open Graph, JSON-LD, optional feed

**Layer 1:** `llms.txt`, `llms-full.txt`, `.md` mirrors, HTML `link alternate`, HTTP `Link` headers, hidden LLM pointer, `Accept: text/markdown` negotiation (including **406** for unsupported `Accept` types) + `Vary: Accept`

Optional external scanners after a green run:

- [acceptmarkdown.com](https://acceptmarkdown.com)
- [isitagentready.com](https://isitagentready.com)
- [ruby.evilmartians.com](https://ruby.evilmartians.com/)

## Stack notes

Documented for Bridgetown / static-site patterns in [SKILL.md](SKILL.md#stack-notes-bridgetown--static). The same outputs apply to Jekyll, Next.js, Rails, or Nginx/Caddy — different build hooks, same deliverables.

## References

- [Agent Skills](https://agentskills.io/home)
- [Ruby & Rails LLM discoverability scorecard](https://ruby.evilmartians.com/)
- [Making your site visible to LLMs](https://evilmartians.com/chronicles/how-to-make-your-website-visible-to-llms)
- [llms-visibility skill](https://evilmartians.com/skills/llms-visibility.md)
- [llmstxt.org](https://llmstxt.org/)
