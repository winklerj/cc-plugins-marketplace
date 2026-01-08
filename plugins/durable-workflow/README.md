# Durable Workflow Plugin for Claude Code

Create durable, resilient workflows using DBOS that automatically resume after failures. Build reliable applications with workflows that survive crashes, restarts, and infrastructure failures.

## Overview

This plugin provides Claude Code with deep expertise in DBOS (Durable Execution Platform), enabling it to help you build workflows with **durable execution** - programs that are **resilient to any failure**. If a workflow is interrupted (executor restarts, crashes, etc.), it automatically resumes from the last completed step.

## Features

- **Durable Execution**: Workflows survive crashes, restarts, and infrastructure failures
- **Multi-Language Support**: TypeScript, Python, Go, and Java
- **Workflow + Step Pattern**: Orchestrate reliable multi-step processes
- **Background Workflows**: Run long-running tasks asynchronously
- **Queues**: Control concurrency and rate limiting
- **Scheduled Tasks**: Cron-based recurring workflows
- **Idempotency**: Safe retries with workflow IDs
- **Step Retries**: Configurable retry policies with backoff

## Installation

```bash
# Add to your Claude Code plugins in .claude/settings.local.json
{
  "plugins": [
    {
      "path": "/path/to/cc-plugins-marketplace/plugins/durable-workflow"
    }
  ]
}
```

## Skill Activation

The skill activates when you mention:
- Durable, resilient, or fault-tolerant workflows
- DBOS
- Multi-step processes that must complete reliably
- Operations calling external APIs that might fail
- Long-running background tasks
- Scheduled or recurring jobs
- Critical operations (payments, notifications)

## Core Pattern

### TypeScript

```typescript
import { DBOS } from "@dbos-inc/dbos-sdk";
import express from "express";

const app = express();
app.use(express.json());

// Steps: wrap functions that access external services
async function processPayment(amount: number) {
  return await paymentService.charge(amount);
}

async function sendEmail(to: string, subject: string) {
  await emailService.send(to, subject);
}

// Workflow: orchestrates steps with durable execution
async function checkoutWorkflow(userId: string, amount: number) {
  const paymentId = await DBOS.runStep(() => processPayment(amount), { name: "processPayment" });
  await DBOS.runStep(() => sendEmail(userId, "Payment received"), { name: "sendEmail" });
  return paymentId;
}
const checkout = DBOS.registerWorkflow(checkoutWorkflow);

app.post("/checkout", async (req, res) => {
  const result = await checkout(req.body.userId, req.body.amount);
  res.json({ paymentId: result });
});

async function main() {
  DBOS.setConfig({
    name: "my-app",
    systemDatabaseUrl: process.env.DBOS_SYSTEM_DATABASE_URL,
  });
  await DBOS.launch();
  app.listen(3000);
}

main().catch(console.log);
```

### Python

```python
import os
from dbos import DBOS, DBOSConfig
from fastapi import FastAPI
import uvicorn

app = FastAPI()
config: DBOSConfig = {
    "name": "my-app",
    "system_database_url": os.environ.get("DBOS_SYSTEM_DATABASE_URL"),
}
DBOS(config=config)

# Steps: wrap functions that access external services
@DBOS.step()
def process_payment(amount: float) -> str:
    return payment_service.charge(amount)

@DBOS.step()
def send_email(to: str, subject: str):
    email_service.send(to, subject)

# Workflow: orchestrates steps with durable execution
@DBOS.workflow()
def checkout_workflow(user_id: str, amount: float) -> str:
    payment_id = process_payment(amount)
    send_email(user_id, "Payment received")
    return payment_id

@app.post("/checkout")
def checkout_endpoint(user_id: str, amount: float):
    result = checkout_workflow(user_id, amount)
    return {"payment_id": result}

if __name__ == "__main__":
    DBOS.launch()
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### Java

```java
import dev.dbos.transact.DBOS;
import dev.dbos.transact.config.DBOSConfig;
import dev.dbos.transact.workflow.Workflow;
import dev.dbos.transact.workflow.Step;

// Define interface
interface Checkout {
    String checkoutWorkflow(String userId, double amount);
}

// Implement with annotations
class CheckoutImpl implements Checkout {

    @Step(name = "processPayment")
    public String processPayment(double amount) {
        return paymentService.charge(amount);
    }

    @Step(name = "sendEmail")
    public void sendEmail(String to, String subject) {
        emailService.send(to, subject);
    }

    @Workflow(name = "checkoutWorkflow")
    public String checkoutWorkflow(String userId, double amount) {
        String paymentId = processPayment(amount);
        sendEmail(userId, "Payment received");
        return paymentId;
    }
}

public class Main {
    public static void main(String[] args) throws Exception {
        DBOSConfig config = DBOSConfig.defaults("my-app")
            .withDatabaseUrl(System.getenv("DBOS_SYSTEM_JDBC_URL"))
            .withDbUser(System.getenv("PGUSER"))
            .withDbPassword(System.getenv("PGPASSWORD"));
        DBOS.configure(config);
        Checkout proxy = DBOS.registerWorkflows(Checkout.class, new CheckoutImpl());
        DBOS.launch();
    }
}
```

## Key Concepts

### Workflows
- Must be deterministic
- Do NOT perform non-deterministic actions directly (API calls, random, time)
- Move non-deterministic operations to steps

### Steps
- Wrap functions that access external APIs/services
- Do NOT call DBOS context methods from steps
- Do NOT start workflows from inside steps

## Advanced Features

### Background Workflows

```typescript
// TypeScript
const handle = await DBOS.startWorkflow(longTask)("task-123");
const result = await handle.getResult();
```

```python
# Python
handle = DBOS.start_workflow(long_task, "task-123")
result = handle.get_result()
```

```java
// Java
WorkflowHandle<String, Exception> handle = DBOS.startWorkflow(
    () -> proxy.longTask("task-123"),
    new StartWorkflowOptions()
);
String result = handle.getResult();
```

### Scheduled Workflows

```typescript
// TypeScript - runs daily at midnight
async function dailyCleanup(schedTime: Date, startTime: Date) {
  await DBOS.runStep(() => performCleanup(), { name: "cleanup" });
}
const scheduledCleanup = DBOS.registerWorkflow(dailyCleanup);
DBOS.registerScheduled(scheduledCleanup, { crontab: "0 0 * * *" });
```

```python
# Python - runs daily at midnight
@DBOS.scheduled("0 0 * * *")
@DBOS.workflow()
def daily_cleanup(scheduled_time, actual_time):
    perform_cleanup()
```

```java
// Java - runs daily at midnight
@Workflow
@Scheduled(cron = "0 0 0 * * *")
public void dailyCleanup(Instant scheduled, Instant actual) {
    performCleanup();
}
```

### Step Retries

```typescript
// TypeScript
const data = await DBOS.runStep(() => unreliableApiCall(), {
  name: "apiCall",
  retriesAllowed: true,
  maxAttempts: 5,
  intervalSeconds: 2,
  backoffRate: 2,
});
```

```python
# Python
@DBOS.step(retries_allowed=True, max_attempts=5, interval_seconds=2, backoff_rate=2)
def unreliable_api_call():
    return requests.get("https://example.com").text
```

```java
// Java
String data = DBOS.runStep(
    () -> unreliableApiCall(),
    new StepOptions("apiCall")
        .withRetriesAllowed(true)
        .withMaxAttempts(5)
        .withIntervalSeconds(2)
        .withBackoffRate(2.0)
);
```

## Directory Structure

```
durable-workflow/
├── README.md                            # This file
├── .claude-plugin/
│   └── plugin.json                      # Plugin metadata
└── skills/
    └── durable-workflow/
        ├── SKILL.md                     # Main skill definition
        └── references/
            ├── dbos-typescript-api.md   # TypeScript API reference
            ├── dbos-python-api.md       # Python API reference
            ├── dbos-go-api.md           # Go API reference
            └── dbos-java-api.md         # Java API reference
```

## Resources

- [DBOS Documentation](https://docs.dbos.dev)
- [DBOS TypeScript SDK](https://www.npmjs.com/package/@dbos-inc/dbos-sdk)
- [DBOS Python SDK](https://pypi.org/project/dbos/)
- [DBOS Java SDK](https://mvnrepository.com/artifact/dev.dbos/transact)
- [Claude Code Documentation](https://docs.claude.com/claude-code)

## License

Apache-2.0

## Author

Created with Claude Code
