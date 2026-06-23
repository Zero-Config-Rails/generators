---
name: audit-ai-seo
description: Audit and implement Google SEO plus LLM/AI discoverability for websites, docs, blogs, and landing pages. Covers robots.txt, sitemaps, meta tags, JSON-LD, feeds, llms.txt, .md mirrors, Link headers, Accept text/markdown negotiation, and Content-Signal. Use for SEO audits, GEO/AI-readable sites, minitestrails-style Bridgetown/Rails static sites, or when the user wants a live verification script. Refuses debunked AI patterns (ai.txt, AI meta tags, UA sniffing). Ends every audit or implementation with a Ruby verifier against the live site.
---

# Audit AI SEO (Google + LLM discoverability)

Two layers, one workflow, **equal priority**: Google search and LLM agents both need a complete ship. Framework from [Evil Martians Ruby scorecard](https://ruby.evilmartians.com/) (Layer 0 crawl + Layer 1 retrieval) and [How to make your website visible to LLMs](https://evilmartians.com/chronicles/how-to-make-your-website-visible-to-llms). LLM mechanics follow the official [llms-visibility skill](https://evilmartians.com/skills/llms-visibility.md).

**JSON-LD is for Google/Bing rich results, not LLM citations.** Ship it anyway as part of Layer 0. Do not add schema.org *for* LLM visibility; do not remove existing structured data.

## When to use

- New site or docs: baseline audit before launch
- Existing site: "why aren't we in AI answers / Google?"
- After implementing discoverability: verify production with the Ruby script

## Workflow (always in this order)

1. **Audit** live site (or local build output if not deployed)
2. **Report** gaps as Layer 0 (Google/crawl) vs Layer 1 (LLM retrieval) vs content (comparisons, thin pages)
3. **Implement** fixes (each step is independently shippable). For Accept negotiation, follow [references/accept-markdown-negotiation.md](references/accept-markdown-negotiation.md) — language-agnostic algorithm, test matrix, Rack/edge hooks.
4. **Verify** with `scripts/verify_seo.rb` against production URL
5. **Hand off** a project-local copy of the verifier **and** `site-pages.json` (customized paths) so the user can re-run anytime

---

## Layer 0: Google SEO and crawl (ship first)

Goal: crawlers can find pages, index the right ones, show useful snippets, and qualify for rich results in Google.

### robots.txt

- [ ] `Sitemap: https://example.com/sitemap.xml` (absolute production URL)
- [ ] Do **not** `Disallow: /` for GPTBot, ClaudeBot, PerplexityBot, CCBot, Google-Extended
- [ ] Add Cloudflare `Content-Signal:` under `User-agent: *` (policy choice):

```
User-agent: *
Content-Signal: search=yes, ai-input=yes, ai-train=yes
```

Confirm `ai-train=yes` with the owner. Validators may warn about unknown directives; that is expected (RFC 9309: ignore unknown lines).

### sitemap.xml

- [ ] Valid XML `urlset`, only **published** URLs
- [ ] Include home, section indexes, live content pages
- [ ] Exclude drafts, coming-soon, future-dated posts, admin, thank-you pages
- [ ] Reasonable `changefreq` / `lastmod` (avoid `yearly` for normal pages)
- [ ] Submit in Google Search Console after deploy

### Page metadata (every indexable template)

- [ ] Exactly **one** `<title>` and **one** `<meta name="description">` (no duplicate tags from layout + plugin)
- [ ] `rel="canonical"` with absolute URL
- [ ] Open Graph: `og:title`, `og:description`, `og:image`, `og:url`
- [ ] `noindex, follow` for placeholders (coming-soon chapters, staging)
- [ ] Optional: Twitter card tags

### Structured data (Google, required)

Ship schema.org JSON-LD on every indexable page type. Validate with [Google Rich Results Test](https://search.google.com/test/rich-results) after deploy.

- [ ] Home: `WebSite` + `SearchAction` (or equivalent site-level type)
- [ ] Guide index: `Course` or `LearningResource` with `hasPart` / chapter list where practical
- [ ] Guide chapters: `LearningResource` (or `Article` for narrative chapters) + `BreadcrumbList`
- [ ] Blog posts: `Article` (or `BlogPosting`) + `BreadcrumbList`
- [ ] `@context` `https://schema.org`, absolute URLs, match visible title/description
- [ ] Do **not** claim this improves LLM citations (Layer 1 handles agents)

### Feeds and internal linking

- [ ] Atom/RSS at `/feed.xml` (blog or site updates)
- [ ] `<link rel="alternate" type="application/atom+xml">` in HTML head
- [ ] Internal links between related chapters/posts; prev/next on linear content
- [ ] Unique, descriptive titles (not "Chapter 3" alone)

### Content and GSC (human steps)

- [ ] Thin or duplicate pages: expand or noindex
- [ ] Comparison posts for high-intent queries (task-specific, with numbers) where relevant
- [ ] GSC: verify property, submit sitemap, request indexing for home + one deep page once

### Optional (usually skip unless asked)

- DNS-AID / SVCB records for agent discovery (needs DNSSEC + MCP server; low value for static marketing sites)
- Bing Webmaster Tools sitemap submit

---

## Layer 1: LLM retrieval (ship with Layer 0)

Goal: when a human pastes a URL or a coding agent fetches docs, the model gets **clean Markdown**, not HTML soup.

Priority (impact vs effort):

| # | Mechanism | Priority |
|---|-----------|----------|
| 0 | robots.txt + Content-Signal | Critical |
| 1 | `/llms.txt` | Critical |
| 2 | `.md` routes for content pages | Critical |
| 3 | `<link rel="alternate">` + HTTP `Link` header | High |
| 4 | Visually hidden Markdown pointer | Medium |
| 5 | `/llms-full.txt` | Medium (docs); optional for blogs |
| 6 | `Accept: text/markdown` negotiation | High |

### 1. `/llms.txt`

Curated Markdown at site root ([llmstxt.org](https://llmstxt.org/) format). README for AI conversations, not a sitemap dump.

```markdown
# Site Name

> One-sentence description.

## Guide

- [Introduction](/guide/introduction/): Start here
```

### 2. `.md` mirrors

For `/path/` serve `/path.md` (root → `/index.md`). **Single source of truth** (generate from same content as HTML). No YAML front matter in the served body.

### 3. Advertise Markdown (both HTML tag and HTTP header)

```html
<link rel="alternate" type="text/markdown" href="/guide/introduction.md" />
```

```
Link: </guide/introduction.md>; rel="alternate"; type="text/markdown"
```

Set `Link` on **both** HTML and `.md` responses. Pair with `Vary: Accept` on CDN/static host.

### 4. Visually hidden pointer (LLMs only)

```html
<div class="visually-hidden" aria-hidden="true">
  A Markdown version of this page is available at https://example.com/guide/introduction.md.
</div>
```

### 5. `/llms-full.txt` (optional)

Full corpus in one file. High value for docs/APIs; for blogs, concatenating posts or redirecting to `/index.md` is fine.

### 6. `Accept: text/markdown` content negotiation

Same URL, representation chosen by `Accept`. Full language-agnostic checklist (algorithm, test matrix, Rack/edge hooks): **[references/accept-markdown-negotiation.md](references/accept-markdown-negotiation.md)**.

Must pass [acceptmarkdown.com readiness](https://acceptmarkdown.com/#readiness):

1. Serves Markdown for `Accept: text/markdown`
2. Sets `Vary: Accept` on HTML and Markdown responses
3. Returns **406** when neither `text/html` nor `text/markdown` is acceptable
4. Honors **`q`-values** — `*/*` alone must not return Markdown; higher `q` on `text/html` wins over lower `text/markdown`

**Not cloaking.** User-Agent sniffing for bots is forbidden; use `Accept` only.

Static hosts (Netlify, Cloudflare): edge function or middleware; `_headers` for `Link`/`Vary` on static fallbacks. Stack recipes: [acceptmarkdown.com](https://acceptmarkdown.com).

### 7. Optional analytics

Server-side logs for `.md`, `/llms.txt`, `/llms-full.txt` by User-Agent and referrer (`chatgpt.com`, `claude.ai`, `perplexity.ai`).

---

## Anti-patterns (refuse and explain)

| Pattern | Why not |
|---------|---------|
| `<meta name="ai-content-url">`, `<meta name="llms">` | No spec, no adoption |
| `/.well-known/ai.txt`, `/ai.txt` | Competing proposals, unused |
| HTML comments for AI | Stripped by parsers |
| Human/AI toggle buttons | Agents do not click |
| UA sniffing → Markdown for bots | Cloaking |
| Dedicated "AI info pages" | `/llms.txt` is enough |
| JSON-LD for LLM visibility | Proven ignored by major LLMs |

---

## Stack notes (Bridgetown / static)

This repo pattern (adapt for other stacks):

- `plugins/builders/seo_discoverability.rb` → `sitemap.xml`, `feed.xml`
- `plugins/seo_discoverability.rb` → `llms.txt`, `llms-full.txt`, `.md` mirrors, `output/_headers`
- `src/_partials/_head.erb` → single `seo` tag, `link alternate`, feed link
- `netlify/edge-functions/` → Accept negotiation middleware (see [references/accept-markdown-negotiation.md](references/accept-markdown-negotiation.md))
- `Shared::MarkdownAlternatePointer` → hidden LLM hint

Other stacks: same outputs, different build hooks (Jekyll plugin, Next.js route, Rails `Mime::Type.register`, Nginx/Caddy recipes at [acceptmarkdown.com](https://acceptmarkdown.com)).

---

## Final step: Ruby live verifier (required)

After every audit or implementation pass:

1. Copy [scripts/verify_seo.rb](scripts/verify_seo.rb) and [site-pages.json](site-pages.json) into the project (e.g. `script/verify_seo.rb` and `script/site-pages.json`)
2. Edit `site-pages.json` — **required**. Lists which HTML pages, `.md` mirrors, and section indexes to probe:

```json
{
  "html_paths": ["/", "/guide/introduction/"],
  "md_paths": ["/index.md", "/guide/introduction.md"],
  "section_indexes": [
    { "html": "/guide/", "md": "/guide.md" },
    { "html": "/blog/", "md": "/blog.md" }
  ],
  "check_llms_full_txt": true,
  "require_feed": false,
  "require_json_ld": true,
  "require_markdown_negotiation": true
}
```

3. Run against **production** (negotiation and headers often differ from local):

```bash
ruby script/verify_seo.rb https://example.com
# or
SITE=https://example.com ruby script/verify_seo.rb
```

The script auto-finds `site-pages.json` next to itself or in the working directory. Pass an explicit path if needed:

```bash
ruby script/verify_seo.rb https://example.com ./script/site-pages.json
```

4. Fix any **FAIL** lines; treat **WARN** as backlog unless user wants zero warnings
5. Optionally re-check with [acceptmarkdown.com](https://acceptmarkdown.com) and [isitagentready.com](https://isitagentready.com)

The script uses stdlib only (no gems). Exit code 1 if any check failed.

### What the verifier checks

**Layer 0:** robots.txt, sitemap, Sitemap directive, AI bots not blocked, Content-Signal, single title/description, canonical, Open Graph, JSON-LD, optional feed

**Layer 1:** llms.txt, llms-full.txt, `.md` mirrors, HTML `link alternate`, HTTP `Link` headers, hidden LLM pointer, `Accept: text/markdown` negotiation (Markdown served, 406 unsupported, q-values, `*/*` → HTML, `Vary: Accept`) — see [references/accept-markdown-negotiation.md](references/accept-markdown-negotiation.md)

---

## Content beats infrastructure

For AI citation quality (GEO), recommend content changes after infra is green:

- Direct quotations (~43% lift in cited studies)
- Statistics in prose (~33%)
- Authoritative outbound citations (~115% for low-ranked pages)

Infrastructure gets agents **to** your text; content determines whether they **cite** you.

---

## Audit report template

```markdown
## SEO audit: {site}

**URL:** {production URL}
**Stack:** {Bridgetown, Rails, Next.js, …}

### Layer 0 (Google/crawl)
- robots.txt: …
- sitemap: …
- metadata: …
- GSC: …

### Layer 1 (LLM retrieval)
- llms.txt: …
- .md mirrors: …
- Link / alternate: …
- Accept negotiation: …

### Content gaps
- …

### Implemented
- …

### Verify
`ruby script/verify_seo.rb {URL}` (requires `script/site-pages.json`)
```

---

## References

- [Ruby & Rails LLM discoverability scorecard](https://ruby.evilmartians.com/)
- [Making your site visible to LLMs](https://evilmartians.com/chronicles/how-to-make-your-website-visible-to-llms)
- [llms-visibility skill (official)](https://evilmartians.com/skills/llms-visibility.md)
- [llmstxt.org](https://llmstxt.org/)
- [Content-Signal spec](https://contentsignals.org/)
