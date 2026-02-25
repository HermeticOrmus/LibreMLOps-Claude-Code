# /vectordb

A quick-access command for vector-databases workflows in Claude Code.

## Trigger

`/vectordb [action] [options]`

## Input

### Actions
- `analyze` - Analyze existing vector-databases implementation
- `generate` - Generate new vector-databases artifacts
- `improve` - Suggest improvements to current implementation
- `validate` - Check implementation against best practices
- `document` - Generate documentation for vector-databases artifacts

### Options
- `--context <path>` - Specify the file or directory to operate on
- `--format <type>` - Output format (markdown, json, yaml)
- `--verbose` - Include detailed explanations
- `--dry-run` - Preview changes without applying them

## Process

### Step 1: Context Gathering
- Read relevant files and configuration
- Identify the current state of vector-databases artifacts
- Determine applicable standards and conventions

### Step 2: Analysis
- Evaluate against vectordb-patterns patterns
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
## Vector Databases - [Action] Complete

### Changes Made
- [List of changes]

### Validation
- [Checks passed]

### Next Steps
- [Recommended follow-up actions]
```

### Error
```
## Vector Databases - [Action] Failed

### Issue
[Description of the problem]

### Suggested Fix
[How to resolve the issue]
```

## Examples

```bash
# Analyze current implementation
/vectordb analyze

# Generate new artifacts
/vectordb generate --context ./src

# Validate against best practices
/vectordb validate --verbose

# Generate documentation
/vectordb document --format markdown
```
