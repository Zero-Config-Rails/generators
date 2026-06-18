---
name: ruby
description: Use modern Ruby (4.0+) features and avoid deprecated or removed APIs.
alwaysApply: true
---

# Ruby Rules

Target **Ruby 4.0+** (see `.ruby-version`, currently **4.0.5**). Prefer current language features over legacy patterns.

## Before writing Ruby

1. Check `.ruby-version` and `Gemfile` for the project Ruby version.
2. When unsure whether an API is deprecated, consult current Ruby docs (context7 or ruby-doc.org) — do not rely on outdated examples.
3. Run `bundle exec rubocop` / `syntax_tree` if the change touches style-sensitive code.

## Prefer (modern Ruby)

```ruby
# frozen_string_literal: true at top of new files

# Set is a core class in Ruby 4 — no require needed
ids = Set[1, 2, 3]

# Pattern matching for structured data
case response
in { status: 200, body: String => body } then body
in { status: 404 } then nil
end

# Data.define for value objects
Point = Data.define(:x, :y)

# Endless method for trivial one-liners
def name = @name

# Numbered block params where it aids clarity
items.map { _1.upcase }

# `it` block param for single-arg blocks — only when unambiguous
names.select { it.start_with?("A") }

# Array search helpers (Ruby 4)
items.rfind(&:active?)
items.find(&:active?)

# Keyword arguments (never merge option hashes when keywords work)
def greet(name:, loud: false) = loud ? name.upcase : name

# Enumerable improvements
array.compact_blank
hash.deep_merge(other)
hash.deep_symbolize_keys

# Safe navigation and presence
user&.profile&.name
value.presence

# Literal syntax
%w[one two]   # not ['one', 'two'] for simple word lists
%i[id name]   # symbol arrays
```

## Ruby 4 specifics

| Topic | Guidance |
|---|---|
| `Set` | Core class — drop `require "set"` in new code |
| `Set#inspect` | Format is `Set[1, 2, 3]` — update assertions that parse inspect output |
| `to_set` with args | Deprecated — use `Set.new(enum)` or `enum.to_set` without arguments |
| Ractors | Old `Ractor.yield` / `#take` / `#close_incoming` removed — use `Ractor::Port` |
| JIT | YJIT remains the production JIT; ZJIT (`--zjit`) is experimental |
| Ruby Box | Experimental (`RUBY_BOX=1`) — do not adopt in app code unless explicitly requested |
| `Ruby` module | Toplevel `Ruby` module is now defined for Ruby-related constants |

## Avoid (deprecated / removed / legacy)

| Do not use | Use instead |
|---|---|
| `File.exists?`, `Dir.exists?` | `File.exist?`, `Dir.exist?` |
| `require "set"` in new Ruby 4 code | `Set` directly |
| `open("http://...")` for URLs | `URI.open` or HTTP client gems |
| `URI.escape` / `URI.decode` | `URI::DEFAULT_PARSER.escape`, `CGI`, `ERB::Util` |
| `$SAFE` | Remove — removed in Ruby 3.0 |
| `Random::DEFAULT` | `Random.new` |
| `Fixnum`, `Bignum` | `Integer` |
| `untaint`, `taint`, `trust` | Remove — removed in Ruby 3.2 |
| `Ractor.yield`, `Ractor#take` | `Ractor::Port` (Ruby 4) |
| `Object#=~` on non-strings for pattern match | Explicit `match?` / `===` |
| Mutable default args `def f(x=[])` | `def f(x: nil)` then `x ||= []` |
| `OpenStruct` for new domain objects | `Data.define`, `Struct`, or POROs |
| `Hash#[]` for dig chains on nested data | `dig` |
| Backticks for shell when portability matters | `Open3`, `system`, `IO.popen` |
| `require` gems without bundler context | `bundler/require` via Gemfile |

## Style aligned with this project

- Follow **rubocop-rails-omakase** conventions.
- Use `frozen_string_literal: true` in new `.rb` files.
- Prefer `module Foo; class Bar` nesting over `class Foo::Bar` for Zeitwerk-friendly constants.
- Use `%w[]` / `%i[]` for arrays without interpolation.
- Use heredocs with `<<~RUBY` for multiline strings in generators and templates.
- Prefer `then` keyword in one-line `if`/`case` branches when it reads clearly.

## Testing

```ruby
# Minitest (this project)
assert_equal expected, actual
assert_predicate obj, :valid?
assert_not_nil value

# Prefer refute over assert !
refute_empty collection
```

## When upgrading Ruby

- Read the [Ruby release notes](https://www.ruby-lang.org/en/downloads/releases/) for the target version.
- Search the codebase for APIs listed in deprecation/removal sections.
- Update `.ruby-version`, `Gemfile` (`ruby file:`), CI, and Docker images together.
