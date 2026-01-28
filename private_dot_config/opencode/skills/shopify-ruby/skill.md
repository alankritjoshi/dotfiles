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
