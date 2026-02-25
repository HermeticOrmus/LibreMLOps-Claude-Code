# /model-registry

A quick-access command for model-registry workflows in Claude Code.

## Trigger

`/model-registry [action] [options]`

## Input

### Actions
- `analyze` - Analyze existing model-registry implementation
- `generate` - Generate new model-registry artifacts
- `improve` - Suggest improvements to current implementation
- `validate` - Check implementation against best practices
- `document` - Generate documentation for model-registry artifacts

### Options
- `--context <path>` - Specify the file or directory to operate on
- `--format <type>` - Output format (markdown, json, yaml)
- `--verbose` - Include detailed explanations
- `--dry-run` - Preview changes without applying them

## Process

### Step 1: Context Gathering
- Read relevant files and configuration
- Identify the current state of model-registry artifacts
- Determine applicable standards and conventions

### Step 2: Analysis
- Evaluate against model-registry-patterns patterns
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
## Model Registry - [Action] Complete

### Changes Made
- [List of changes]

### Validation
- [Checks passed]

### Next Steps
- [Recommended follow-up actions]
```

### Error
```
## Model Registry - [Action] Failed

### Issue
[Description of the problem]

### Suggested Fix
[How to resolve the issue]
```

## Examples

```bash
# Analyze current implementation
/model-registry analyze

# Generate new artifacts
/model-registry generate --context ./src

# Validate against best practices
/model-registry validate --verbose

# Generate documentation
/model-registry document --format markdown
```
