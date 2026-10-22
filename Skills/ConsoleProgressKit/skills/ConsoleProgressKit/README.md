# ConsoleProgressKit API Reference Skill

Claude Code skill that gives the agent an API reference for [ConsoleProgressKit](https://github.com/nikolainobadi/ConsoleProgressKit) (macOS 15+, Swift 6.2+), so it writes code against the real signatures and behavior instead of guessing.

## Install

    claude plugin install ConsoleProgressKit@nn-swift-skills --scope project

## Use

The skill loads automatically when a task involves ConsoleProgressKit types. You can also invoke it directly:

    /ConsoleProgressKit how do I show a progress bar while my command uploads files?

## Files

| File | Role |
|------|------|
| `SKILL.md` | Entry point: package metadata, routing table, quick reference |
| `ApiReference.md` | All 7 public types, how the live and plain displays differ, and best practices |
| `TestingReference.md` | `ConsoleProgressTesting`: `MockProgressDisplay`, its recorded types, and a complete test example |
| `manifest.json` | Baseline for incremental updates (data; do not edit by hand) |

## Maintenance

This skill lives in the ConsoleProgressKit repo under `Skills/ConsoleProgressKit`, so an API change and its documentation land in the same PR. The `nn-swift-skills` marketplace pins it to a release tag, so edits reach users when the package is tagged, not when they merge.

Hand edits outside `<!-- type:... -->` anchors survive regeneration; edits inside them may be overwritten.
