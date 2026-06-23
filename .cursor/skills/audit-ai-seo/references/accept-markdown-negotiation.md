# Accept: text/markdown negotiation checklist

Language-agnostic requirements to pass [acceptmarkdown.com readiness](https://acceptmarkdown.com/#readiness) and `verify_seo.rb`. Implement in an edge function, Rack middleware, reverse proxy, or framework hook — same rules everywhere.

**Offered representations:** `text/html` and `text/markdown` only (same canonical URL).

**Skip negotiation** for: static assets (`.css`, `.js`, images, fonts, …), explicit `.md` URLs, build internals (`/_bridgetown/`, etc.), and other non-page paths.

---

## Readiness map (acceptmarkdown.com)

| # | Readiness check | What to implement |
|---|-----------------|-------------------|
| 1 | Serves Markdown for `Accept: text/markdown` | When Markdown wins q-comparison, rewrite/fetch the `.md` mirror and return `Content-Type: text/markdown` |
| 2 | Sets `Vary: Accept` | On **every** negotiated response (HTML and Markdown) |
| 3 | Rejects unsupported types with `406` | When client Accept has q=0 for both `text/html` and `text/markdown` |
| 4 | Honors `q`-values | Parse `;q=` weights; never use substring matching on the header |

---

## Algorithm (copy into any language)

### 1. Parse `Accept`

Split on commas. For each media range:

- Extract type (e.g. `text/markdown`, `text/html`, `*/*`) — lowercase
- Extract optional `q=` (default `1.0`; invalid → `0`)

Empty/missing `Accept` → treat as `*/*;q=1`.

### 2. Score each offered type

```
htmlQ  = max(q for text/html, q for */* if present)
mdQ    = max(q for text/markdown, q for */* if present)
mdNamed = Accept header explicitly lists text/markdown (not only */*)
```

### 3. Decide representation

```
if htmlQ == 0 AND mdQ == 0:
  return 406 Not Acceptable
  headers: Vary: Accept

if NOT mdNamed:
  return HTML   # */* alone must NOT return Markdown

if mdQ >= htmlQ:
  return Markdown (fetch .md mirror for this path)
else:
  return HTML
```

**Critical:** `Accept: */*` or `Accept: text/html` without `text/markdown` → HTML only. Agents that send bare `*/*` must not get Markdown (cloaking risk).

### 4. Map HTML path → `.md` mirror

| HTML path | Markdown path |
|-----------|-----------------|
| `/` | `/index.md` |
| `/guide` or `/guide/` | `/guide.md` |
| `/blog` or `/blog/` | `/blog.md` |
| `/path/to/page/` | `/path/to/page.md` |

Strip trailing slashes and `/index.html` before mapping. Skip if path already ends with `.md`.

### 5. Response headers

**HTML response** (negotiated or default):

```
Vary: Accept
Link: </path/to/page.md>; rel="alternate"; type="text/markdown"
```

**Markdown response:**

```
Content-Type: text/markdown
Vary: Accept
Link: </path/to/page/>; rel="alternate"; type="text/html"
```

(`Link` on Markdown is required by Layer 1 checks; acceptmarkdown focuses on Accept/Vary/406/q.)

### 6. Missing `.md` fallback

If Markdown was chosen but `.md` file returns 404:

- If `htmlQ > 0` → serve HTML with `Vary: Accept`
- Else → `406 Not Acceptable`

---

## Test matrix (curl)

Run against a content page (not `/feed.xml` or assets):

```bash
URL=https://example.com/guide/introduction/

# 1 — Markdown served
curl -sI -H 'Accept: text/markdown, text/html;q=0.5' "$URL"
# Expect: 200, body is Markdown, Vary: Accept

# 2 — Vary on HTML
curl -sI -H 'Accept: text/html' "$URL"
# Expect: Vary: Accept

# 3 — 406 unsupported
curl -sI -H 'Accept: application/json' "$URL"
# Expect: 406, Vary: Accept, NOT 200 HTML

# 4a — q-values: HTML wins
curl -sI -H 'Accept: text/html, text/markdown;q=0.5' "$URL"
# Expect: 200 HTML

# 4b — wildcard without explicit markdown → HTML
curl -sI -H 'Accept: */*' "$URL"
# Expect: 200 HTML (not Markdown)
```

External checker: [acceptmarkdown.com](https://acceptmarkdown.com/#readiness)

---

## Where to hook (by stack)

| Stack | Hook point |
|-------|------------|
| Netlify | Edge function on `/*` (see minitestrails pattern) |
| Cloudflare | Worker `fetch` handler or [zero-config rules](https://acceptmarkdown.com) |
| Rack (Rails) | Middleware before router; `env["HTTP_ACCEPT"]`, rewrite to `.md` route or internal redirect |
| Nginx / Caddy | `map $http_accept` + `error_page 406` — [recipes](https://acceptmarkdown.com) |
| Next.js / Astro | Middleware `request.headers.get("accept")` |
| Bridgetown | Netlify edge + static `.md` output from plugin |

Rack sketch:

```ruby
# config.middleware.use AcceptMarkdownNegotiation
# 1. return 406 if htmlQ.zero? && mdQ.zero?
# 2. return @app.call(env) for HTML
# 3. internally pass to /path.md or read file for Markdown
# 4. set Vary: Accept and Link on both branches
```

---

## verify_seo.rb coverage

When `require_markdown_negotiation: true` in `site-pages.json`:

| Check | Accept header | Expected |
|-------|---------------|----------|
| Markdown served | `text/markdown, text/html;q=0.5` | 200 Markdown + `Vary: Accept` |
| Unsupported rejected | `application/json` | 406 |
| q-values honored | `text/html, text/markdown;q=0.5` | 200 HTML |
| Wildcard safe | `*/*` | 200 HTML |

Plus Layer 1 HTML checks: `<link rel="alternate" type="text/markdown">`, HTTP `Link` header, hidden LLM pointer.

---

## Anti-patterns

| Do not | Why |
|--------|-----|
| Return Markdown when `Accept` is only `*/*` | Fails q-value / explicit-type rules |
| Return HTML for `Accept: application/json` | Fails 406 check |
| Match `Accept` with `include?("markdown")` | Breaks q-value parsing |
| Sniff `User-Agent` for bots | Cloaking |
| Negotiate on `.css`, `.js`, images | Breaks assets |
