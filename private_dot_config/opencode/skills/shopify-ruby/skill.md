---
name: shopify-ruby
description: Ruby/Rails development patterns at Shopify - slices, dev CLI, Sorbet, rubocop
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: ruby
---

# Shopify Ruby/Rails Development

## Dev CLI

- **Location:** `/opt/dev/bin/dev`
- **Always prefer `dev` commands** over direct tool access

```bash
dev check          # Run all checks
dev style          # Lint (rubocop)
dev typecheck      # Sorbet
dev test           # Tests
dev console        # Rails console
```

## Sorbet & Tapioca

**Do NOT add `extend T::Sig`** to classes. In `# typed: true` files, `sig` is available without it. `extend T::Sig` is a legacy pattern.

After adding/modifying models, associations, or using new DSLs:

```bash
bin/tapioca dsl                  # Regenerate all DSL RBIs
bin/tapioca dsl <ModelName>      # Regenerate specific model
bin/tapioca gem <gem-name>       # Regenerate gem RBIs
```

**Common triggers for `tapioca dsl`:**

- New ActiveRecord models
- New associations (has_many, belongs_to, etc.)
- New enums
- New scopes

## slices.yml

### Editing Caveat

**CAUTION:** The Edit tool corrupts YAML formatting by changing indentation throughout the file.

**Use Python for precise edits:**

```python
python3 << 'EOF'
with open('slices.yml', 'r') as f:
    content = f.read()
content = content.replace('old_pattern', 'new_pattern')
with open('slices.yml', 'w') as f:
    f.write(content)
EOF
```

**Or use awk for insertions:**

```bash
awk '/pattern/{print; print "  - new/entry/here"; next}1' slices.yml > tmp && mv tmp slices.yml
```

### Requirements

- Entries must be **alphabetically sorted** within each section
- Run `dev check slices-style` to verify formatting/ordering

### Interpreting slices-check Failures

`slices-check` may report "uncovered files" that are:

- From **parent branches** (in graphite stacks) - not your responsibility
- Local development files (`.opencode/`, etc.)

To verify if a file is from your branch:

```bash
git diff <parent-branch> -- <file>
```

## Code Style Preferences

### Always invert if/else — prefer early returns

Never write a large `if` block with an `else`. Instead, handle the short/simple case first with an early return, then let the main logic flow straight down without nesting.

```ruby
# BAD: nested if/else
def process(record)
  if record.valid?
    # 20 lines of main logic...
  else
    log_error("Invalid record")
  end
end

# GOOD: early return, main logic flows down
def process(record)
  unless record.valid?
    log_error("Invalid record")
    return
  end

  # 20 lines of main logic...
end
```

### Use StatsD.measure block syntax

Never manually time operations with `Process.clock_gettime`. Use the `StatsD.measure` block form instead.

Don't assign from `StatsD.measure`'s return value — the codebase convention is to assign inside the block. This also avoids issues with test stubs (`.yields` returns nil, not the block's return).

```ruby
# BAD: manual timing
start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
result = do_work
elapsed = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000
StatsD.measure("my_metric.time_ms", elapsed)

# BAD: assigning from StatsD.measure return value (breaks with test stubs)
result = StatsD.measure("my_metric.time_ms") do
  do_work
end

# GOOD: assign inside the block
result = T.let(nil, T.nilable(MyResultType))
StatsD.measure("my_metric.time_ms") do
  result = do_work
end
upsert_result = T.must(result)
```

### Use StatsD::Instrument::Assertions in tests

Never use mocha `StatsD.stubs(:measure).yields` / `StatsD.expects(:increment)` to test StatsD metrics. Use `StatsD::Instrument::Assertions` instead — it's the idiomatic pattern (80+ usages in the codebase).

```ruby
# BAD: mocha stubs
StatsD.stubs(:measure).yields
StatsD.stubs(:increment)
StatsD.expects(:increment).with("my_metric", 1, tags: { status: "success" })
@task.perform

# GOOD: StatsD::Instrument::Assertions
class MyTaskTest < ActiveSupport::TestCase
  include StatsD::Instrument::Assertions

  test "emits metrics" do
    assert_statsd_increment("my_metric", 1, tags: { status: "success" }) do
      @task.perform
    end
  end
end
```

Nest assertions to check multiple metrics from a single call:

```ruby
assert_statsd_measure("my_metric.time_ms") do
  assert_statsd_increment("my_metric.count", 1) do
    @operation.run!
  end
end
```

### Don't assert stubbed return values in tests

If you stub a method to return a value, don't then assert the return value matches the stub — it tests nothing.

```ruby
# BAD: asserting the stub's own return value
@mock_client.expects(:query).returns([])
result = @operation.fetch_all
assert_empty result  # This just tests mocha, not your code

# GOOD: assert on the behavior you care about (e.g., the query contents)
@mock_client.expects(:query).once.with do |sql|
  assert_match(/WHERE/, sql)
  true
end.returns([])
@operation.fetch_all
```

### Tasks should be thin — extract business logic to operations

Gordon tasks (and jobs) should be thin orchestrators focused on: error handling, logging, workflow links, and metrics. Business logic belongs in operations.

```ruby
# BAD: task doing business logic directly
class MyTask < ApplicationTask
  def perform
    results = bq_client.query("SELECT ...")
    results.each { |r| dataplex_client.upsert(r) }
  end
end

# GOOD: task orchestrates, operation does the work
class MyTask < ApplicationTask
  def perform
    dashboards = Operations::FetchDashboards.new.fetch_all
    Operations::UpsertDashboards.new(logger: logger).run!(dashboards: dashboards)
  end
end
```

### Check codebase conventions before naming

Before naming constants, methods, or modules, search the codebase for existing patterns. Don't invent new terminology when a convention already exists.

Examples from this codebase:
- "aspect key" not "aspect FQN" (Dataplex aspect identifiers)
- `*_workflow_policy.rb` not `*_policy.rb` (Gordon workflow policies)
- Namespace by domain (`Dashboards`) not implementation (`Dataplex`)

### Sorbet hygiene — avoid unnecessary annotations

Don't add `T.let` on constructors — Sorbet can infer the type from `.new`:

```ruby
# BAD: redundant T.let
@cache = T.let(Concurrent::Map.new, Concurrent::Map)

# GOOD: Sorbet infers the type
@cache = Concurrent::Map.new
```

Don't add overly defensive `T.must` on values that are obviously non-nil:

```ruby
# BAD: T.must on something that was just assigned
task_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
# ... later in ensure ...
elapsed = T.must(task_start)  # overly defensive

# GOOD: just use it directly
elapsed = task_start
```

Only use `T.let(nil, T.nilable(...))` when a variable genuinely needs to be initialized as nil for later reassignment (e.g., inside a block).

## Common Rubocop Fixes

| Issue                          | Fix                                 |
| ------------------------------ | ----------------------------------- |
| `unless .any?`                 | Use `if .none?`                     |
| `if` wrapping single statement | Use `next unless` / `return unless` |
| `return nil`                   | Use `return`                        |
| Single quotes in interpolation | Use double quotes                   |
| Missing frozen_string_literal  | Add `# frozen_string_literal: true` |
| Method calls without parens    | Add parentheses: `method(args)`     |

## dev check Interpretation

| Check                          | Your responsibility?                |
| ------------------------------ | ----------------------------------- |
| `style-ruby`                   | Yes - your code                     |
| `slices-style`                 | Yes - your slices.yml changes       |
| `slices-check` uncovered files | Maybe - check if from parent branch |
| `typecheck`                    | Yes - run `tapioca dsl` if needed   |
