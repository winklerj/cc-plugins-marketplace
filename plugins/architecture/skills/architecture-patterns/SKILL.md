---
name: architecture-patterns
description: Reference guide for software architecture patterns, design principles, and best practices. Use when discussing architecture, system design, microservices, monoliths, event-driven systems, clean architecture, hexagonal architecture, CQRS, or architectural decisions.
---

# Architecture Patterns Skill

This skill provides comprehensive knowledge of software architecture patterns, helping you make informed decisions about system design.

## Common Architectural Patterns

### Layered (N-Tier) Architecture

**Structure**: Horizontal layers with each layer having a specific role.

```
┌─────────────────────────────┐
│     Presentation Layer      │  UI, API Controllers
├─────────────────────────────┤
│      Business Layer         │  Business Logic, Services
├─────────────────────────────┤
│     Persistence Layer       │  Repositories, DAOs
├─────────────────────────────┤
│       Database Layer        │  Database
└─────────────────────────────┘
```

**When to use**:
- Traditional enterprise applications
- Clear separation of concerns needed
- Team organized by technical specialty

**Trade-offs**:
- Simple and well-understood
- Can lead to monolithic deployments
- Changes often span multiple layers

---

### Microservices Architecture

**Structure**: Independent services organized around business capabilities.

```
┌──────────┐  ┌──────────┐  ┌──────────┐
│  Users   │  │  Orders  │  │ Products │
│ Service  │  │ Service  │  │ Service  │
└────┬─────┘  └────┬─────┘  └────┬─────┘
     │             │             │
     └─────────────┼─────────────┘
                   │
            ┌──────┴──────┐
            │   API GW    │
            └─────────────┘
```

**When to use**:
- Large teams that need independence
- Different scaling requirements per service
- Polyglot technology requirements

**Trade-offs**:
- Independent deployment and scaling
- Increased operational complexity
- Network latency and distributed system challenges

---

### Event-Driven Architecture

**Structure**: Components communicate through events.

```
┌──────────┐     ┌─────────────┐     ┌──────────┐
│ Producer │────▶│ Event Broker │────▶│ Consumer │
└──────────┘     └─────────────┘     └──────────┘
                        │
                        ▼
                 ┌──────────┐
                 │ Consumer │
                 └──────────┘
```

**When to use**:
- Decoupled systems
- Asynchronous processing
- Audit trail requirements
- Real-time data processing

**Trade-offs**:
- Loose coupling
- Complex debugging and tracing
- Eventual consistency

---

### Hexagonal Architecture (Ports & Adapters)

**Structure**: Core domain isolated from external concerns.

```
                    ┌─────────────────┐
                    │    REST API     │
                    │    (Adapter)    │
                    └────────┬────────┘
                             │
┌──────────────┐    ┌────────▼────────┐    ┌──────────────┐
│   CLI        │    │                 │    │   Database   │
│  (Adapter)   │───▶│   Core Domain   │◀───│  (Adapter)   │
└──────────────┘    │   (Ports)       │    └──────────────┘
                    └────────▲────────┘
                             │
                    ┌────────┴────────┐
                    │  Message Queue  │
                    │   (Adapter)     │
                    └─────────────────┘
```

**When to use**:
- High testability requirements
- Multiple input/output channels
- Domain logic must be independent of infrastructure

**Trade-offs**:
- Excellent testability
- Initial complexity overhead
- Clear dependency direction

---

### Clean Architecture

**Structure**: Concentric circles with dependencies pointing inward.

```
┌─────────────────────────────────────────┐
│           Frameworks & Drivers          │
│  ┌───────────────────────────────────┐  │
│  │       Interface Adapters          │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │      Application Layer      │  │  │
│  │  │  ┌───────────────────────┐  │  │  │
│  │  │  │   Enterprise Layer    │  │  │  │
│  │  │  │      (Entities)       │  │  │  │
│  │  │  └───────────────────────┘  │  │  │
│  │  └─────────────────────────────┘  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

**Layers**:
- **Entities**: Enterprise business rules
- **Use Cases**: Application business rules
- **Interface Adapters**: Controllers, presenters, gateways
- **Frameworks**: Web, database, external interfaces

**When to use**:
- Long-lived applications
- Complex business logic
- Need to swap frameworks/databases

---

### CQRS (Command Query Responsibility Segregation)

**Structure**: Separate models for reads and writes.

```
                    ┌─────────────────┐
                    │     Client      │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
      ┌───────▼───────┐             ┌───────▼───────┐
      │   Commands    │             │    Queries    │
      │    (Write)    │             │    (Read)     │
      └───────┬───────┘             └───────┬───────┘
              │                             │
      ┌───────▼───────┐             ┌───────▼───────┐
      │  Write Model  │────────────▶│  Read Model   │
      │   (Events)    │   Sync      │ (Projections) │
      └───────────────┘             └───────────────┘
```

**When to use**:
- Read/write ratio heavily skewed
- Complex querying requirements
- Event sourcing implementation
- Audit requirements

**Trade-offs**:
- Optimized read and write paths
- Increased complexity
- Eventual consistency between models

---

## Design Principles

### SOLID Principles

| Principle | Description |
|-----------|-------------|
| **S**ingle Responsibility | A class should have one reason to change |
| **O**pen/Closed | Open for extension, closed for modification |
| **L**iskov Substitution | Subtypes must be substitutable for base types |
| **I**nterface Segregation | Many specific interfaces over one general |
| **D**ependency Inversion | Depend on abstractions, not concretions |

### Other Key Principles

- **DRY** (Don't Repeat Yourself): Avoid duplication
- **KISS** (Keep It Simple): Simplest solution that works
- **YAGNI** (You Aren't Gonna Need It): Don't build for hypothetical futures
- **Separation of Concerns**: Group related, separate unrelated
- **Composition over Inheritance**: Prefer composition for flexibility

---

## Pattern Selection Guide

| Requirement | Recommended Pattern |
|-------------|---------------------|
| Simple CRUD application | Layered Architecture |
| Large team, independent deployment | Microservices |
| Complex domain logic | Clean/Hexagonal Architecture |
| Real-time processing | Event-Driven |
| Read-heavy workload | CQRS |
| Rapid prototyping | Monolith first |
| High testability | Hexagonal Architecture |
| Audit trail | Event Sourcing + CQRS |

---

## Anti-Patterns to Avoid

1. **Big Ball of Mud**: No clear structure
2. **Distributed Monolith**: Microservices without benefits
3. **Shared Database**: Services sharing a database
4. **Circular Dependencies**: Components depending on each other
5. **God Object**: One class doing everything
6. **Premature Optimization**: Complexity before proven need
