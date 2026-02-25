# /evaluate-model

A quick-access command for model-evaluation workflows in Claude Code.

## Trigger

`/evaluate-model [action] [options]`

## Input

### Actions
- `analyze` - Analyze existing model-evaluation implementation
- `generate` - Generate new model-evaluation artifacts
- `improve` - Suggest improvements to current implementation
- `validate` - Check implementation against best practices
- `document` - Generate documentation for model-evaluation artifacts

### Options
- `--context <path>` - Specify the file or directory to operate on
- `--format <type>` - Output format (markdown, json, yaml)
- `--verbose` - Include detailed explanations
- `--dry-run` - Preview changes without applying them

## Process

### Step 1: Context Gathering
- Read relevant files and configuration
- Identify the current state of model-evaluation artifacts
- Determine applicable standards and conventions

### Step 2: Analysis
- Evaluate against model-evaluation-patterns patterns
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
## Model Evaluation - [Action] Complete

### Changes Made
- [List of changes]

### Validation
- [Checks passed]

### Next Steps
- [Recommended follow-up actions]
```

### Error
```
## Model Evaluation - [Action] Failed

### Issue
[Description of the problem]

### Suggested Fix
[How to resolve the issue]
```

## Examples

```bash
# Analyze current implementation
/evaluate-model analyze

# Generate new artifacts
/evaluate-model generate --context ./src

# Validate against best practices
/evaluate-model validate --verbose

# Generate documentation
/evaluate-model document --format markdown
```
