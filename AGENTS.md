# Repository Guidelines

## Project Structure & Module Organization

SSRecord is a Ruby on Rails 7.1 application for tracking sleep and study records. Core MVC code lives under `app/`: models in `app/models`, controllers in `app/controllers`, views in `app/views`, helpers in `app/helpers`, and Stimulus JavaScript in `app/javascript`. Styles are in `app/assets/stylesheets`.

Database migrations, schema, and seed data are in `db/`. Custom rake tasks belong in `lib/tasks`. RSpec tests are in `spec/`, grouped by type (`models`, `requests`, `system`, `views`, `helpers`) with factories in `spec/factories` and shared helpers in `spec/support`. Diagrams are kept in `docs/`.

## Build, Test, and Development Commands

- `bundle install`: install Ruby gems from `Gemfile.lock`.
- `rails db:create db:migrate db:seed`: create databases, apply migrations, and seed test data. Set `BASIC_DB_USER`, `BASIC_DB_PASSWORD`, and `TEST_PASSWORD` first.
- `bin/dev`: run the local development server with Sass support; use this instead of plain `rails server`.
- `bundle exec rspec`: run the full RSpec suite.
- `bundle exec rspec spec/models`: run a focused test group.
- `bundle exec rubocop`: run Ruby, Rails, RSpec, and Capybara lint checks.

## Coding Style & Naming Conventions

Target Ruby 3.2 and follow Rails conventions: snake_case files and methods, CamelCase classes, plural table names, and RESTful controller actions. Keep views in ERB and styles in SCSS. Prefer small model methods and helpers over duplicated view logic. RuboCop is configured in `.rubocop.yml`.

## Testing Guidelines

Use RSpec as the primary test framework. Add model specs for validations and business rules, request specs for controller behavior, and system specs for user flows. Name files with the `_spec.rb` suffix and place factories in `spec/factories`. Cover edge cases around time ranges, unfinished records, authentication, and date grouping.

## Commit & Pull Request Guidelines

Recent history uses concise Japanese commit summaries. For new work, prefer conventional prefixes such as `feat:`, `fix:`, `test:`, `refactor:`, or `docs:` followed by a clear English summary. Keep commits focused on one logical change.

Pull requests should include a short purpose statement, key changes, test results, linked issues if any, and screenshots or GIFs for UI changes.

## Security & Configuration Tips

Do not commit secrets or local credentials. Keep database credentials and the seed user password in environment variables. Ensure `TEST_PASSWORD` is at least 8 characters and includes both letters and numbers, because seeds depend on Devise password validation.
