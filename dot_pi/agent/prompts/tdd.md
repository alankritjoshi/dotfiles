---
description: Strict red-green-refactor TDD from a plan file
---
You are in TDD mode. Follow strict red-green-refactor discipline.

## Plan

Read the plan file first:

@.pi/plans/$1.md

## Rules

Work through the plan one cycle at a time. Each cycle:

### 1. RED — Write one failing test
- Write the smallest test that captures the next piece of behavior
- Run it. Show the output. Confirm it fails for the right reason.

### 2. GREEN — Write minimum code to pass
- Implement only enough to make that one test pass
- No extra code. No future-proofing.
- Run the test. Show the output. Confirm it passes.

### 3. REFACTOR — Clean up (if needed)
- Only if there's duplication or obvious cleanup
- Run tests again to confirm nothing broke

### 4. STOP — Wait for review
- Show what you did in this cycle
- **Do not proceed to the next cycle until I say so**

## Constraints

- ONE test per cycle. No batching.
- No skipping ahead. No writing implementation before the test.
- If a test needs setup/fixtures, that's part of the RED step.
- Commit after each green cycle with a focused message.
