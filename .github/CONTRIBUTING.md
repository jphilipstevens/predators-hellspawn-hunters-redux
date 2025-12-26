# Contributing Guide

## Conventional Commits

This project uses [Conventional Commits](https://www.conventionalcommits.org/) for automatic versioning and changelog generation.

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: A new feature (triggers MINOR version bump, e.g., 1.0.0 → 1.1.0)
- **fix**: A bug fix (triggers PATCH version bump, e.g., 1.0.0 → 1.0.1)
- **docs**: Documentation changes (triggers PATCH version bump)
- **style**: Code style changes (formatting, missing semi-colons, etc.)
- **refactor**: Code refactoring (neither fixes a bug nor adds a feature)
- **perf**: Performance improvements (triggers PATCH version bump)
- **test**: Adding or updating tests
- **build**: Changes to build system or dependencies
- **ci**: Changes to CI configuration
- **chore**: Other changes that don't modify src files (NO version bump)
- **revert**: Reverts a previous commit

### Breaking Changes

To trigger a MAJOR version bump (e.g., 1.0.0 → 2.0.0), add `BREAKING CHANGE:` in the commit body or add `!` after the type:

```
feat!: redesign cloak mechanics

BREAKING CHANGE: Cloak now uses energy-based system instead of time-based
```

### Examples

```bash
# New feature (1.0.0 → 1.1.0)
git commit -m "feat: add energy-free cloaking option"

# Bug fix (1.0.0 → 1.0.1)
git commit -m "fix: correct plasma caster damage calculation"

# Documentation update (1.0.0 → 1.0.1)
git commit -m "docs: update installation instructions"

# No version change
git commit -m "chore: update .gitignore"

# Breaking change (1.0.0 → 2.0.0)
git commit -m "feat!: overhaul weapon switching system"
```

### Scopes (Optional)

You can add a scope to provide more context:

```bash
git commit -m "feat(cloak): add decoy-based invisibility"
git commit -m "fix(weapons): correct wrist blade hitbox"
git commit -m "docs(readme): add credits section"
```

## Automatic Releases

When you push commits to the `main` branch:

1. The GitHub Action will analyze your commit messages
2. Determine the next version based on conventional commits
3. Compile ACS scripts
4. Create a PK3 package with the version number
5. Generate a changelog
6. Create a GitHub release with the PK3 file attached
