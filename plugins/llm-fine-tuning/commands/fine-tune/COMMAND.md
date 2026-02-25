# /fine-tune

A quick-access command for llm-fine-tuning workflows in Claude Code.

## Trigger

`/fine-tune [action] [options]`

## Input

### Actions
- `analyze` - Analyze existing llm-fine-tuning implementation
- `generate` - Generate new llm-fine-tuning artifacts
- `improve` - Suggest improvements to current implementation
- `validate` - Check implementation against best practices
- `document` - Generate documentation for llm-fine-tuning artifacts

### Options
- `--context <path>` - Specify the file or directory to operate on
- `--format <type>` - Output format (markdown, json, yaml)
- `--verbose` - Include detailed explanations
- `--dry-run` - Preview changes without applying them

## Process

### Step 1: Context Gathering
- Read relevant files and configuration
- Identify the current state of llm-fine-tuning artifacts
- Determine applicable standards and conventions

### Step 2: Analysis
- Evaluate against llm-tuning-patterns patterns
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
## Llm Fine Tuning - [Action] Complete

### Changes Made
- [List of changes]

### Validation
- [Checks passed]

### Next Steps
- [Recommended follow-up actions]
```

### Error
```
## Llm Fine Tuning - [Action] Failed

### Issue
[Description of the problem]

### Suggested Fix
[How to resolve the issue]
```

## Examples

```bash
# Analyze current implementation
/fine-tune analyze

# Generate new artifacts
/fine-tune generate --context ./src

# Validate against best practices
/fine-tune validate --verbose

# Generate documentation
/fine-tune document --format markdown
```
