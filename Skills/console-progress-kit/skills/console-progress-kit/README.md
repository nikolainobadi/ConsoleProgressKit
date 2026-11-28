# ConsoleProgressKit API Reference Skill

Claude Code skill that gives the agent an API reference for [ConsoleProgressKit](https://github.com/nikolainobadi/ConsoleProgressKit) (macOS 15+, Swift 6.4+), so it writes code against the real signatures and behavior instead of guessing.

## Install

    claude plugin install console-progress-kit@nn-skills-marketplace --scope project

## Use

The skill loads automatically when a task involves ConsoleProgressKit types. You can also invoke it directly:

    /console-progress-kit:console-progress-kit how do I show a progress bar while my command uploads files?

## Files

| File | Role |
|------|------|
| `SKILL.md` | Entry point: package metadata, routing table, quick reference |
| `ApiReference.md` | Progress displays, terminal capabilities, text styling, and best practices |
| `TestingReference.md` | `ConsoleProgressTesting`: `MockProgressDisplay`, its recorded types, `TaggingTextStyler`, and a complete test example |

## Maintenance

This skill lives in the ConsoleProgressKit repo under `Skills/console-progress-kit`, so an API change and its documentation land in the same PR. The `nn-skills-marketplace` marketplace pins it to a release tag, so edits reach users when the package is tagged, not when they merge.
