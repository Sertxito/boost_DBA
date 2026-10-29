# Contributing to boost-dba

## Scope

This repository provides DBA-oriented boost artifacts:

- Agents
- Specs
- Skills
- Patterns
- References
- Templates
- Examples

Contributions must preserve internal alignment across these artifact families.

## Contribution Workflow

1. Create a focused branch per change set.
1. Update artifacts in the smallest coherent unit (for example one capability domain).
1. Run local quality gates:

```bash
npm run quality
```

1. If adding or changing capabilities, verify `platform.json` and `boost.json` references remain valid.
1. Submit a PR with:
- change summary,
- impacted capabilities,
- validation evidence.

## Content Standards

- Use Spanish or English consistently inside each artifact.
- Ground recommendations in evidence and explicit reasoning inputs.
- Avoid placeholders or TODO-style content in committed artifacts.
- Preserve template structure for each artifact family.

## Capability Alignment Checklist

When changing a capability domain, keep these assets aligned:

- `skills/<domain>/SKILL.md`
- `specs/*` relevant to the domain
- `patterns/*` if anti-pattern coverage changes
- `templates/*` if output shape changes
- `platform.json` agent/skill registry
- `boost.json` package catalog

## Validation Gates

`npm run quality` currently verifies:

- JSON metadata integrity (`boost.json` and `platform.json`).

Do not open a PR if any gate fails.

## Pull Request Guidance

Include a short risk assessment:

- What can break?
- What evidence supports safety?
- How was behavior validated?

For larger changes, include a rollback note describing how to revert or disable the change safely.

## Main Branch Protection Policy

`main` must be protected in GitHub settings so changes are merged only through approved pull requests.

Recommended repository settings for `main`:

1. Require a pull request before merging.
1. Require at least 1 approval.
1. Dismiss stale pull request approvals when new commits are pushed.
1. Require status checks to pass before merging.
1. Select required checks:
   - `CI / validate`
1. Restrict who can push to matching branches (no direct user pushes).
1. Do not allow bypassing the above settings.

With these rules enabled:

- Before merge: PR + approval + green checks are required.
- After merge to `main`: publish workflow runs automatically.
