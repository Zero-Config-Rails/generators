---
name: rails
description: Use modern Rails (8.1+) features and avoid deprecated or removed APIs.
alwaysApply: true
---

# Rails Rules

Target **Rails 8.1+** (see `Gemfile`) with `config.load_defaults` at the latest version the app supports. Prefer current Rails APIs over patterns from Rails 6 and earlier.

## Before writing Rails code

1. Check `Gemfile` / `Gemfile.lock` for the Rails version.
2. Check `config/application.rb` for `config.load_defaults`.
3. When unsure, consult current Rails guides and API docs — not blog posts from older versions.
4. Run `bundle exec rails test` and `bundle exec brakeman` for security-sensitive changes.

## Prefer (modern Rails)

### Controllers

```ruby
# Strong parameters (Rails 8+)
def user_params
  params.expect(user: [:name, :email])
end

# Turbo-aware redirects
redirect_to posts_path, notice: t(".created")

# Explicit status codes
head :no_content
```

### Models

```ruby
# Attribute normalization (Rails 7.1+)
normalizes :email, with: -> { _1.strip.downcase }

# Token generation (Rails 7.1+)
generates_token_for :password_reset, expires_in: 15.minutes

# Query methods
Post.where(published: true).order(created_at: :desc)
User.where.missing(:profile)
Post.where.associated(:comments)

# Bulk writes when appropriate
User.insert_all(records)
User.upsert_all(records, unique_by: :email)

# Enums with instance methods
enum :status, %i[draft published], default: :draft
```

### Views / Hotwire

```erb
<%# Turbo Frames and Streams %>
<%= turbo_frame_tag dom_id(post) do %>
  ...
<% end %>

<%# Stimulus controllers for JS behavior — not inline script tags %>
<div data-controller="clipboard">
```

```ruby
# Turbo Stream responses
def create
  @post = Post.create!(post_params)
  respond_to do |format|
    format.turbo_stream
    format.html { redirect_to @post }
  end
end
```

### Configuration

```ruby
# config/application.rb
config.load_defaults 8.0  # bump when app is verified on new defaults

# Autoload lib (Rails 7+)
config.autoload_lib(ignore: %w[assets tasks])

# Solid Queue / Cache / Cable in new Rails 8 apps — use when the app adopts them
# config.active_job.queue_adapter = :solid_queue
```

### Generators & rake

```bash
bin/rails generate model Post title:string
bin/rails db:migrate
bin/rails test
```

### Credentials & secrets

```ruby
Rails.application.credentials.dig(:aws, :access_key_id)
# Never commit secrets; use credentials or ENV
```

## Avoid (deprecated / removed)

### Controllers & routing

| Do not use | Use instead |
|---|---|
| `before_filter`, `after_filter`, `around_filter` | `before_action`, `after_action`, `around_action` |
| `render text:` / `render nothing: true` | `render plain:` / `head :no_content` |
| `redirect_to :back` | `redirect_back fallback_location: root_path` |
| `params.require().permit()` in new code | `params.expect(...)` (Rails 8+) |
| `skip_before_filter` | `skip_before_action` |
| `render action:` | `render :action` or explicit template |
| `update_attributes` / `update_attributes!` | `update` / `update!` |
| `link_to ... method: :delete` | `button_to` or `data: { turbo_method: :delete }` |
| `protect_from_forgery` without `with:` | `protect_from_forgery with: :exception` (default) |

### Active Record

| Do not use | Use instead |
|---|---|
| `find_by_name(...)` dynamic finders | `find_by(name: ...)` |
| `where("name = ?", name)` when hash works | `where(name: name)` |
| `update_all` with raw SQL strings | Hash/Arel forms |
| `Model.connection` in app code | `ActiveRecord::Base.connection_pool.with_connection` |
| `enum` with keyword `enum status: { ... }` hash-only legacy forms | `enum :status, %i[...]` |
| `serialize` without `coder:` | `serialize :data, coder: JSON` |
| `default_scope` for soft deletes | `default_scope` only when truly needed; prefer explicit scopes |
| `belongs_to` optional by default hacks | Explicit `optional: true` where intended |
| `fixture_path` | `fixture_paths` (array) |
| `ActiveRecord::Base.configurations` direct mutation | `Rails.application.config` patterns |

### Active Support / misc

| Do not use | Use instead |
|---|---|
| `Rails.application.secrets` | `Rails.application.credentials` |
| `config.autoloader = :classic` | Zeitwerk (default) |
| `require_dependency` | Zeitwerk autoloading |
| `RAILS_ROOT` | `Rails.root` |
| `update_attributes` | `update` |
| `return false` to halt callbacks | `throw :abort` |
| UJS `data-remote`, `rails-ujs` | Turbo / Stimulus |
| Sprockets-only patterns in new JS | jsbundling/importmap per app setup |
| `webpacker` | jsbundling-rails or importmap-rails |

### Testing

| Do not use | Use instead |
|---|---|
| `fixtures :all` without thought | Explicit `fixtures :users, :posts` |
| `assigns(:var)` in controller tests | Assert on response body / `assert_response` |
| `travel_to` without block in parallel tests | Block form `travel_to(time) { ... }` |
| `assert_equal 2, Post.count` after create | `assert_difference "Post.count", 1` |

## Hotwire / frontend (this project)

- Use **Turbo** for navigation, frames, and streams — not Turbolinks or full-page AJAX.
- Use **Stimulus** for DOM behavior; register controllers in `app/javascript/controllers/`.
- Disable Turbo prefetch when it causes stale UI (`turbo-prefetch` meta or `data-turbo-prefetch="false"`).
- Build JS with `yarn build` after Stimulus changes.

## Database & migrations

```ruby
# reversible migrations
def change
  create_table :posts do |t|
    t.string :title, null: false
    t.references :user, null: false, foreign_key: true
    t.timestamps
  end
end

# Prefer t.references over manual t.integer :user_id
```

- Use `strong_migrations` patterns for large tables (if adopted).
- Never run destructive migrations (`drop_table`, `remove_column`) without explicit user confirmation.

## Security defaults

- Keep `config.force_ssl` enabled in production.
- Use parameterized queries — never interpolate user input into `where` SQL strings.
- Permit only intended attributes via `params.expect` / `permit`.
- Run `bundle exec brakeman` for auth and mass-assignment changes.

## When upgrading Rails

Use `.agents/skills/rails-upgrade.md` for version bumps. After upgrading:

1. Bump `config.load_defaults` only after enabling `new_framework_defaults` initializer.
2. Fix deprecation warnings before they become removals.
3. Re-run `rails_generate:parse_all` if this app's generator metadata depends on vanilla Rails help output.
