---
name: context7
description: Look up up-to-date documentation for a library via the Context7 API (https://context7.com). Use when the user asks how a library/framework works, asks for examples or API reference, wants "current" docs, names "context7" explicitly, or when you are about to admit "I don't know" about an unfamiliar dependency. Also use proactively before writing non-trivial code against any library whose API you cannot recall with confidence.
---

# Context7 Documentation Lookup

Context7 ingests library docs (GitHub repos, npm packages, llms.txt sites, uploaded docs) and re-exposes them via an API that returns relevant snippets for a natural-language query. Prefer it over training-data recall when:

- The library is unfamiliar or the specifics are fuzzy.
- The library moves fast (Next.js, Tailwind, React Router, framework APIs).
- The user explicitly asks for docs, examples, or "context7".
- The cost of getting it wrong is bigger than the cost of an API call.

## Auth

API keys live in `CONTEXT7_API_KEY`. Format: starts with `ctx7sk`. Get one at https://context7.com/dashboard.

Without a key, calls still succeed but trip low rate limits fast (a `429` is the giveaway). **Redact** the key — write `<REDACTED>` in any user-visible output. Read it from the environment, never paste it.

## Endpoint

`GET https://context7.com/api/v2/context`

### Query parameters

| Name | Required | Notes |
|---|---|---|
| `libraryId` | yes | ID as it appears in a Context7 URL. See cheat sheet below. |
| `query` | yes | Natural-language question. Drives the rerank — phrase it as the user did. |
| `type` | no | `json` (default) or `txt` (plain-text dump). |
| `fast` | no | `true` skips LLM reranking for lower latency. Start with `false`; escalate only when the user is waiting or the first call is mis-routed. |

### Library ID cheat sheet

| Source | Format | Example |
|---|---|---|
| GitHub repo | `/<owner>/<repo>` | `/vercel/next.js` |
| npm | `/packages/<name>` or `/npm/<name>` | `/packages/express` |
| Web docs site | `/websites/<site>` | `/websites/uploadcare` |
| llms.txt source | `/llmstxt/<source>` | `/llmstxt/nextjs` |
| Uploaded docs | `/docs/<name>` | `/docs/my-internal-lib` |

Version pinning: append `/<version>` or `@<version>`, e.g. `/vercel/next.js@v15` or `/vercel/next.js/15.0.0`. Omit unless the user named a version (or "latest" is wrong — pinning avoids surprise major breaks).

## Invocation

Use the helper script for one-shot calls — it handles URL-encoding, auth, status-code surfacing, and `jq`-ing the response:

```bash
scripts/context7.sh "$LIBRARY_ID" "$QUERY"        # JSON, full rerank
scripts/context7.sh "$LIBRARY_ID" "$QUERY" --txt  # plain text
scripts/context7.sh "$LIBRARY_ID" "$QUERY" --fast # skip rerank
```

Or roll your own curl when you need a parameter the script doesn't expose:

```bash
LIB=$(printf %s "$LIBRARY_ID" | jq -sRr @uri)
Q=$(printf %s "$QUERY"          | jq -sRr @uri)
curl -sS \
  -H "Authorization: Bearer ${CONTEXT7_API_KEY:-}" \
  "https://context7.com/api/v2/context?libraryId=$LIB&query=$Q&type=json" \
  -o response.json -w '%{http_code}\n'
```

`fetch_content` works for quick lookups too, but it cannot set the `Authorization` header — stick to `curl`/the script when auth matters.

## Status codes

| Code | Action |
|---|---|
| 200 | Parse the body. |
| 202 | Library not yet finalized. Surface the message and retry in a few seconds. |
| 301 | Relocated — read `redirectUrl`, use it as the new `libraryId`. Don't loop. |
| 401 | Bad or missing key (format check: `ctx7sk...`). Tell the user the key is wrong or unset. |
| 404 | Library not indexed. Ask the user to find the right ID at https://context7.com (often: search the package name), or try `/packages/<name>` vs `/npm/<name>`. |
| 422 | Malformed request — usually a bad `libraryId`. |
| 429 | Rate limited. Honour `Retry-After`, surface `RateLimit-Limit`/`-Remaining`/`-Reset`. Withdraw further calls for the window. |
| 5xx | Context7 server-side. Retry once after a short pause, otherwise surface the error. |

## Reading the response

A `200` JSON body is a `ContextResponse`:

- `codeSnippets[]` — runnable examples.
  - `codeTitle`, `codeDescription`, `codeLanguage`, `codeId` (source URL), `pageTitle`.
  - `codeList[]` — `language` + `code` per language. Use these to answer "how do I X".
  - `isDynamic` + `sourceFile` (optional) — flagged when the snippet came from the dynamic source-code index rather than the docs index. Mention it if true; the snippet is "real code", not "docs prose".
- `infoSnippets[]` — prose docs.
  - `pageId` (source URL), `breadcrumb`, `content`, `contentTokens`. Use these for "what is X" / "why does X work" questions.
- `rules` (optional) — `global`, `libraryOwn`, `libraryTeam` guideline strings. Respect them in any code you propose.

When showing snippets to the user:
- **Quote** code rather than paraphrasing.
- **Cite** `codeId` / `pageId` as the source.
- Pick the snippet whose `codeTitle` / `breadcrumb` actually matches the question; ignore tangentially-related hits.

## Workflow

1. **Resolve `libraryId`.** Map a GitHub URL, an npm name from `package.json`, or a docs site. If you cannot, ask.
2. **Phrase `query` as the user did.** Specific beats generic. "Show Server Components with auth" > "about next.js".
3. **First call:** `type=json`, `fast=false`. Inspect the response before escalating.
4. **Pick the right snippet type.** Code questions → `codeSnippets`. Conceptual questions → `infoSnippets`. Mixed → both, in that order.
5. **Cite sources.** Always include `codeId` / `pageId`.
6. **If both arrays are empty or off-topic:**
   - Tighten the `query` (add the exact API name, drop filler words).
   - Verify `libraryId` (a deliberate `404` confirms the ID is wrong, not the content).
   - Try a different ID format (npm: `/packages/x` ↔ `/npm/x`).
   - Try pinning a version if the latest is unstable.
   - As a last resort, ask the user.
7. **Don't loop.** One retargeted call. Then synthesise or escalate.

## Don't

- Don't print `CONTEXT7_API_KEY`. Read it; never echo it.
- Don't paraphrase `codeList[].code` — quote it.
- Don't re-run on `202`/`301` more than once or twice.
- Don't use this skill for tiny stable libraries where recall is reliable (lodash, stdlib, mdn API). Reserve it for places where recall fails or is costly.
- Don't ship a snippet without its `codeId` / `pageId`.
