# Contributing to LibreMLOps-Claude-Code

Thank you for your interest in contributing. This project aims to build a comprehensive, open collection of Claude Code plugins for ML engineering and AI operations.

## How to Contribute

### Reporting Issues

- Use GitHub Issues for bugs, feature requests, or questions
- Include your Claude Code version and relevant environment details
- For plugin-specific issues, tag with the plugin name

### Submitting Changes

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes following the standards below
4. Test your changes with Claude Code
5. Submit a pull request

### Branch Naming

```
feature/plugin-name-description
fix/plugin-name-issue
docs/what-changed
chore/maintenance-task
```

## Plugin Structure

Every plugin must contain:

```
plugins/{plugin-name}/
├── README.md           # 50-80 lines: description, contents, examples
├── agents/
│   └── AGENT.md        # 80-150 lines: identity, expertise, behavior
├── commands/
│   └── COMMAND.md      # 60-100 lines: trigger, input, process, output
└── skills/
    └── SKILL.md        # 60-100 lines: knowledge, patterns, anti-patterns
```

### Agent Standards

- Define a clear identity and expertise domain
- Specify behavioral rules and constraints
- Include output format specifications
- Reference tools and methods the agent uses

### Command Standards

- One primary trigger per command
- Document all input parameters with types and defaults
- Describe the processing pipeline step by step
- Show example invocations and expected output

### Skill Standards

- Organize knowledge as named patterns with rationale
- Include anti-patterns with explanations of why they fail
- Reference authoritative sources (papers, docs, repos)
- Keep patterns actionable and specific

## Code Style

- Markdown: ATX-style headers, fenced code blocks, reference links
- Shell scripts: POSIX-compatible where possible, bash where necessary
- Line length: 100 characters soft limit for prose, no limit for code
- File encoding: UTF-8, LF line endings

## Commit Messages

Format: `type(scope): description`

```
feat(experiment-tracking): add W&B sweep integration
fix(gpu-optimization): correct mixed precision gradient scaling
docs(rag-architecture): add chunking strategy comparison
refactor(model-training): extract callback base class
```

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

## Review Process

1. All PRs require at least one review
2. Plugin PRs are tested by loading into a Claude Code session
3. Documentation PRs are checked for accuracy and completeness
4. Changes to hooks require testing across Python ML environments

## Philosophy

This project follows the Gold Hat principle: **empower users, teach while helping, respect autonomy**. Every contribution should:

- Teach the user something, not just do it for them
- Explain the "why" alongside the "what"
- Prefer open tools and standards over proprietary lock-in
- Build understanding that transfers beyond this specific toolset

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
