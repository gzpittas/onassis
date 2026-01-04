# Repository Guidelines

## Project Structure & Module Organization
- `app/` contains Rails MVC plus `app/services/` and `app/jobs/`.
- `app/javascript/controllers/` holds Stimulus controllers; `app/assets/stylesheets/` holds CSS (`color_palette.css`, `application.css`).
- `db/migrate/` contains migrations; `db/schema.rb` is the canonical schema; `db/seeds.rb` holds seed data.
- `test/` contains Minitest tests with fixtures in `test/fixtures/`.
- `lib/tasks/` has custom rake tasks; `storage/` stores local Active Storage uploads; `public/` is for static assets.

## Build, Test, and Development Commands
- `bundle install` installs gems.
- `bin/setup` bootstraps the app (bundle check, `db:prepare`, clears tmp/logs). Add `--skip-server` to avoid auto-start.
- `bin/rails server` or `bin/dev` runs the app at `http://localhost:3000`.
- `bin/rails db:setup` for a fresh database; `bin/rails db:prepare` after pulling migrations.
- `bin/rubocop`, `bin/brakeman`, and `bin/importmap audit` run linting and security checks.

## Coding Style & Naming Conventions
- Ruby uses 2-space indentation; follow Rails Omakase via `.rubocop.yml` and `bin/rubocop`.
- Ruby files are `snake_case.rb` and classes/modules are `CamelCase`.
- Stimulus controllers use `*_controller.js` in `app/javascript/controllers/` with ES module syntax.
- Keep CSS edits in `app/assets/stylesheets/` and reuse variables from `color_palette.css`.

## Testing Guidelines
- Minitest lives in `test/` with files like `test/models/entry_test.rb` and `test/controllers/entries_controller_test.rb`.
- Use fixtures from `test/fixtures/*.yml` where practical.
- Run `bin/rails test` for unit/functional tests and `bin/rails test:system` for system tests; CI runs `bin/rails db:test:prepare test test:system`.

## Commit & Pull Request Guidelines
- Use short, imperative, capitalized commit messages (example: "Add locations lightbox to images"); no ticket prefixes appear in history.
- PRs should include a clear summary, testing notes, and screenshots for UI changes; call out migrations or data changes and link issues when available.

## Security & Configuration Tips
- Store API keys in `.env` (e.g., `OPENAI_API_KEY`, `GETTY_API_KEY`) per `config/initializers/openai.rb`.
- Avoid committing `storage/` uploads or credential changes unless intended.
