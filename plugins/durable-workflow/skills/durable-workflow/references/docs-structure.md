# DBOS Documentation Structure

The official DBOS documentation is at https://docs.dbos.dev/

## Site Map

```
docs.dbos.dev/
├── quickstart                    # Getting started guide (Python, TypeScript, Go, Java)
├── why-dbos                      # Benefits and use cases
├── architecture                  # Core architecture, scaling, recovery mechanisms
│
├── python/                       # Python Documentation
│   ├── programming-guide         # Complete Python programming reference
│   ├── integrating-dbos          # Adding DBOS to existing Python apps
│   ├── tutorials/
│   │   ├── workflow-tutorial     # Workflow basics and patterns
│   │   ├── step-tutorial         # Steps and non-deterministic operations
│   │   ├── queue-tutorial        # Queues and concurrency control
│   │   ├── transaction-tutorial  # Database transactions
│   │   ├── scheduled-workflows   # Cron-based scheduling
│   │   ├── workflow-management   # Cancel, resume, fork workflows
│   │   ├── workflow-communication # Send/recv messaging, events
│   │   ├── database-connection   # SQLite vs PostgreSQL configuration
│   │   ├── kafka-integration     # Kafka consumer integration
│   │   ├── authentication-authorization # Auth patterns
│   │   ├── logging-and-tracing   # Observability
│   │   └── testing               # Unit testing with DBOS
│   ├── examples/
│   │   ├── hacker-news-agent     # AI agent example
│   │   ├── document-detective    # Document ingestion pipeline
│   │   └── widget-store          # Fault-tolerant checkout
│   └── reference/
│       ├── dbos-class            # DBOS class API
│       ├── configuration         # Configuration options
│       ├── queues                # Queue API reference
│       └── cli                   # CLI commands
│
├── typescript/                   # TypeScript Documentation
│   ├── programming-guide         # Complete TypeScript programming reference
│   ├── integrating-dbos          # Adding DBOS to existing apps
│   ├── tutorials/
│   │   ├── workflow-tutorial     # Workflow basics
│   │   ├── step-tutorial         # Steps and retries
│   │   ├── queue-tutorial        # Queues, concurrency, rate limiting
│   │   ├── transaction-tutorial  # Transactions and datasources
│   │   ├── logging               # Logging and OpenTelemetry tracing
│   │   └── debugging             # Debugging workflows
│   ├── examples/
│   │   ├── hacker-news-agent     # AI agent example
│   │   ├── checkout-tutorial     # Fault-tolerant checkout
│   │   └── task-scheduler        # Task scheduling patterns
│   └── reference/
│       ├── dbos-class            # DBOS lifecycle and methods
│       ├── configuration         # Configuration reference
│       ├── client                # External DBOS client
│       └── plugins               # Plugin architecture
│
├── golang/                       # Go Documentation
│   ├── programming-guide         # Go programming reference
│   ├── integrating-dbos          # Adding DBOS to Go apps
│   ├── tutorials/
│   │   ├── workflow-tutorial     # Workflows with DBOSContext
│   │   ├── workflow-communication # Send/recv, events
│   │   └── queue-tutorial        # Queues and concurrency
│   ├── examples/
│   │   └── widget-store          # Fault-tolerant checkout
│   └── reference/
│       └── methods               # DBOS methods and variables
│
├── java/                         # Java Documentation
│   ├── programming-guide         # Java programming reference
│   ├── integrating-dbos          # Spring Boot integration
│   └── examples/
│       └── widget-store          # Fault-tolerant checkout
│
├── production/                   # Production Deployment
│   ├── self-hosting/
│   │   ├── conductor             # DBOS Conductor setup
│   │   ├── workflow-management   # Observability dashboard
│   │   ├── workflow-recovery     # Recovery mechanisms
│   │   └── hosting-with-kubernetes # Kubernetes deployment
│   └── dbos-cloud/
│       ├── deploying-to-cloud    # Cloud deployment guide
│       ├── application-management # Cloud app operations
│       └── byod-management       # Bring your own database
│
├── integrations/
│   └── supabase                  # Supabase integration
│
├── explanations/
│   ├── system-tables             # Internal database schema
│   └── how-workflows-work        # Technical deep-dive
│
└── faq                           # Troubleshooting and FAQ
```

## Quick Navigation by Task

| Task | Python | TypeScript | Go | Java |
|------|--------|------------|-----|------|
| Getting Started | python/programming-guide | typescript/programming-guide | golang/programming-guide | java/programming-guide |
| Add to Existing App | python/integrating-dbos | typescript/integrating-dbos | golang/integrating-dbos | java/integrating-dbos |
| Workflow Basics | python/tutorials/workflow-tutorial | typescript/tutorials/workflow-tutorial | golang/tutorials/workflow-tutorial | java/programming-guide |
| Queues | python/tutorials/queue-tutorial | typescript/tutorials/queue-tutorial | golang/tutorials/queue-tutorial | - |
| Scheduling | python/tutorials/scheduled-workflows | typescript/tutorials/workflow-tutorial | golang/tutorials/workflow-tutorial | - |
| Testing | python/tutorials/testing | typescript/tutorials/debugging | - | - |
