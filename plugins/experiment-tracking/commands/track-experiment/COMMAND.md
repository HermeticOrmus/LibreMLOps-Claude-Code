# /track-experiment

A quick-access command for experiment-tracking workflows in Claude Code.

## Trigger

`/track-experiment [action] [options]`

## Input

### Actions
- `analyze` - Analyze existing experiment-tracking implementation
- `generate` - Generate new experiment-tracking artifacts
- `improve` - Suggest improvements to current implementation
- `validate` - Check implementation against best practices
- `document` - Generate documentation for experiment-tracking artifacts

### Options
- `--context <path>` - Specify the file or directory to operate on
- `--format <type>` - Output format (markdown, json, yaml)
- `--verbose` - Include detailed explanations
- `--dry-run` - Preview changes without applying them

## Process

### Step 1: Context Gathering
- Read relevant files and configuration
- Identify the current state of experiment-tracking artifacts
- Determine applicable standards and conventions

### Step 2: Analysis
- Evaluate against experiment-tracking-patterns patterns
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
## Experiment Tracking - [Action] Complete

### Changes Made
- [List of changes]

### Validation
- [Checks passed]

### Next Steps
- [Recommended follow-up actions]
```

### Error
```
## Experiment Tracking - [Action] Failed

### Issue
[Description of the problem]

### Suggested Fix
[How to resolve the issue]
```

## Examples

```bash
# Analyze current implementation
/track-experiment analyze

# Generate new artifacts
/track-experiment generate --context ./src

# Validate against best practices
/track-experiment validate --verbose

# Generate documentation
/track-experiment document --format markdown
```
