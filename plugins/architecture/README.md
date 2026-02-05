# Architecture Plugin

A comprehensive plugin for software architecture analysis, design, and documentation.

## Features

### Agents

- **architecture-analyzer**: Analyzes existing codebases to document their architecture, identify patterns, map dependencies, and highlight areas of concern
- **architecture-designer**: Helps design new system architectures or refactor existing ones based on requirements and constraints
- **adr-writer**: Creates Architecture Decision Records (ADRs) following industry best practices

### Commands

- `/arch:analyze [output-file]` - Analyze the current codebase and generate comprehensive architecture documentation
- `/arch:adr <title>` - Create a new Architecture Decision Record

### Skills

- **architecture-patterns** - Reference guide for software architecture patterns including layered, microservices, event-driven, hexagonal, clean architecture, and CQRS

## Installation

Add this plugin to your Claude Code configuration:

```bash
claude plugins add architecture
```

Or add it to your `.claude/settings.json`:

```json
{
  "plugins": [
    "path/to/plugins/architecture"
  ]
}
```

## Usage

### Analyzing Architecture

Run a comprehensive architecture analysis:

```
/arch:analyze
```

This will:
1. Examine your project structure
2. Identify technology stack
3. Detect architectural patterns
4. Map dependencies
5. Generate documentation at `docs/ARCHITECTURE.md`

Specify a custom output path:

```
/arch:analyze my-architecture.md
```

### Creating ADRs

Document important architectural decisions:

```
/arch:adr Use PostgreSQL for persistent storage
```

This will:
1. Find or create the ADR directory
2. Determine the next ADR number
3. Guide you through capturing context and consequences
4. Generate a properly formatted ADR

### Using the Architecture Designer

Ask Claude to design a system:

```
Help me design the architecture for a real-time notification system that needs to handle 10,000 messages per second
```

The architecture-designer agent will:
1. Gather requirements
2. Evaluate appropriate patterns
3. Design components and integrations
4. Document the architecture

## Directory Structure

```
architecture/
├── .claude-plugin/
│   └── plugin.json
├── README.md
├── agents/
│   ├── architecture-analyzer.md
│   ├── architecture-designer.md
│   └── adr-writer.md
├── commands/
│   ├── analyze.md
│   └── adr.md
└── skills/
    └── architecture-patterns/
        └── SKILL.md
```

## Architecture Patterns Covered

The plugin includes knowledge of:

- **Layered (N-Tier)** - Traditional horizontal layer separation
- **Microservices** - Independent deployable services
- **Event-Driven** - Asynchronous event-based communication
- **Hexagonal (Ports & Adapters)** - Domain isolation pattern
- **Clean Architecture** - Concentric layers with inward dependencies
- **CQRS** - Command Query Responsibility Segregation

## ADR Template

Generated ADRs follow this structure:

```markdown
# ADR-XXX: [Title]

## Status
[Proposed | Accepted | Deprecated | Superseded]

## Date
[YYYY-MM-DD]

## Context
[Background and forces at play]

## Decision
[What was decided]

## Consequences
### Positive
### Negative
### Neutral

## Alternatives Considered
[Other options evaluated]

## References
[Related documents]
```

## Best Practices

1. **Run analysis early**: Understand existing architecture before making changes
2. **Document decisions**: Create ADRs for significant architectural choices
3. **Review generated docs**: Architecture analysis is a starting point for refinement
4. **Keep ADRs immutable**: Create new ADRs to supersede rather than edit

## License

Apache-2.0
