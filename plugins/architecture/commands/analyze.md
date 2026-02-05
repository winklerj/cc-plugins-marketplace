---
description: Analyze the architecture of the current codebase and generate documentation
allowed-tools:
  - Read
  - Glob
  - Grep
  - LS
  - Task
  - Write
argument-hint: "[output-file] - Optional path for the architecture document"
---

# Analyze Architecture Command

Perform a comprehensive architecture analysis of the current codebase.

## Process

1. **Launch the architecture-analyzer agent** to examine the codebase
2. **Generate a comprehensive architecture document** covering:
   - Technology stack
   - Architectural patterns in use
   - Component breakdown
   - Dependency analysis
   - Data flow
   - Areas of concern

3. **Save the output** to the specified file or `docs/ARCHITECTURE.md` by default

## Usage Examples

```
/arch:analyze
```
Analyzes the codebase and writes to `docs/ARCHITECTURE.md`

```
/arch:analyze architecture-overview.md
```
Analyzes the codebase and writes to the specified file

## Expected Output

A markdown document containing:

- Executive summary
- Technology stack overview
- Architectural pattern analysis
- Component documentation
- Dependency map
- Data flow description
- Integration points
- Identified concerns and recommendations

## Notes

- For large codebases, focus on the most critical components first
- The analysis is based on code structure and may not capture runtime behavior
- Review and refine the generated documentation as needed
