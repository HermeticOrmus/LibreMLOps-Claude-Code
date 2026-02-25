# /prompt-eng

A quick-access command for prompt-engineering workflows in Claude Code.

## Trigger

`/prompt-eng [action] [options]`

## Input

### Actions
- `analyze` - Analyze existing prompt-engineering implementation
- `generate` - Generate new prompt-engineering artifacts
- `improve` - Suggest improvements to current implementation
- `validate` - Check implementation against best practices
- `document` - Generate documentation for prompt-engineering artifacts

### Options
- `--context <path>` - Specify the file or directory to operate on
- `--format <type>` - Output format (markdown, json, yaml)
- `--verbose` - Include detailed explanations
- `--dry-run` - Preview changes without applying them

## Process

### Step 1: Context Gathering
- Read relevant files and configuration
- Identify the current state of prompt-engineering artifacts
- Determine applicable standards and conventions

### Step 2: Analysis
- Evaluate against prompt-engineering-patterns patterns
- Identify gaps, issues, and opportunities
- Prioritize findings by impact and effort

### Step 3: Execution
- Apply the requested action
- Generate or modify artifacts as needed
- Validate changes against requirements

### Step 4: Output
- Present results in the requested format
- Include actionable next steps
- Flag any items requiring human decision

## Output

### Success
```
## Prompt Engineering - [Action] Complete

### Changes Made
- [List of changes]

### Validation
- [Checks passed]

### Next Steps
- [Recommended follow-up actions]
```

### Error
```
## Prompt Engineering - [Action] Failed

### Issue
[Description of the problem]

### Suggested Fix
[How to resolve the issue]
```

## Examples

```bash
# Analyze current implementation
/prompt-eng analyze

# Generate new artifacts
/prompt-eng generate --context ./src

# Validate against best practices
/prompt-eng validate --verbose

# Generate documentation
/prompt-eng document --format markdown
```
