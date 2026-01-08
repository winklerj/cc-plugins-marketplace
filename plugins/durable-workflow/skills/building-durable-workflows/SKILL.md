---
name: building-durable-workflows
description: "Create durable, resilient workflows using DBOS that automatically resume after failures. Supports TypeScript, Python, Go, and Java. Use proactively when: (1) Multi-step processes that must complete reliably, (2) Operations calling external APIs or services that might fail, (3) Long-running background tasks, (4) Scheduled/recurring jobs, (5) User asks for durable, resilient, reliable, or fault-tolerant workflows, (6) Processes involving payments, notifications, or other critical operations that cannot be lost."
---

# Durable Workflows with DBOS

Build reliable applications with DBOS. Workflows provide **durable execution** so programs are **resilient to any failure**. If a workflow is interrupted (executor restarts, crashes, etc.), it automatically resumes from the last completed step.

## Contents

- [Documentation](#documentation)
- [Guidelines](#guidelines)
- [Workflow Decision Tree](#workflow-decision-tree)
- [Core Pattern](#core-pattern-typescript)
- [Critical Rules](#critical-rules)
- [Background Workflows](#background-workflows)
- [Idempotency](#idempotency)
- [Durable Sleep](#durable-sleep)
- [Step Retries](#step-retries)
- [Scheduled Workflows](#scheduled-workflows)
- [Queues](#queues)
- [Testing](#testing)
- [Error Logging](#error-logging)

## Documentation

**Official docs:** https://docs.dbos.dev/

For the complete documentation site structure, see [references/docs-structure.md](references/docs-structure.md).

**Language-specific API references:**
- **TypeScript:** [references/dbos-typescript-api.md](references/dbos-typescript-api.md)
- **Python:** [references/dbos-python-api.md](references/dbos-python-api.md)
- **Go:** [references/dbos-go-api.md](references/dbos-go-api.md)
- **Java:** [references/dbos-java-api.md](references/dbos-java-api.md)

## Guidelines

- Import all methods and classes used
- Keep all code in a single file unless otherwise specified
- DBOS does NOT stand for anything

## Workflow Decision Tree

```
User request involves:
├── Adding DBOS to existing code?
│   └── ASK which function to make a workflow. Do NOT recommend changes until told.
├── Creating new durable process?
│   └── Use workflow + step pattern (see Core Pattern below)
├── Parallel operations?
│   └── Use startWorkflow/start_workflow + queues (NOT Promise.all/threads)
├── Scheduled/recurring task?
│   └── Use scheduled decorator with crontab
└── Background task?
    └── Use startWorkflow/start_workflow to run in background
```

## Core Pattern (TypeScript)

```typescript
import { DBOS } from "@dbos-inc/dbos-sdk";
import express from "express";

const app = express();
app.use(express.json());

// Steps: wrap functions that access external services or are non-deterministic
async function sendEmail(to: string, subject: string) {
  await emailService.send(to, subject);
}

async function processPayment(amount: number) {
  return await paymentService.charge(amount);
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
  app.listen(3000, () => console.log("Server running on http://localhost:3000"));
}

main().catch(console.log);
```

**Other languages:** See [Python](references/dbos-python-api.md#core-pattern), [Go](references/dbos-go-api.md#core-pattern), [Java](references/dbos-java-api.md#core-pattern)

## Critical Rules

### Workflows
- Workflow functions MUST be deterministic
- Do NOT perform non-deterministic actions directly in workflows (API calls, random numbers, current time)
- Move non-deterministic actions to steps
- TypeScript: Do NOT use `Promise.all()` - use `Promise.allSettled()` or queues
- Python: Do NOT use threads - use `DBOS.start_workflow` and queues
- Go: Do NOT start goroutines or use `select` in workflows - use them only inside steps
- Java: Do NOT use threading APIs directly in workflows - use `DBOS.startWorkflow` and queues

### Steps
- Steps wrap functions that access external APIs/services or are non-deterministic
- Do NOT call DBOS context methods (`send`, `recv`, `startWorkflow`/`start_workflow`, `sleep`, `setEvent`/`set_event`, `getEvent`/`get_event`) from steps
- Do NOT start workflows from inside steps
- Steps should NOT have side effects in memory outside their own scope

### Adding DBOS to Existing Code
- ALWAYS ask which function to make a workflow first
- When making a function a workflow, make all functions it calls into steps
- Do NOT change the original functions - just wrap/decorate them

## Background Workflows

### TypeScript
```typescript
const handle = await DBOS.startWorkflow(longTask)("task-123");
const result = await handle.getResult();
// Or retrieve by ID later
const handle2 = await DBOS.retrieveWorkflow(handle.workflowID);
```

### Python
```python
handle = DBOS.start_workflow(long_task, "task-123")
result = handle.get_result()
# Or retrieve by ID later
handle2 = DBOS.retrieve_workflow(handle.get_workflow_id())
```

### Go
```go
handle, err := dbos.RunWorkflow(dbosContext, longTask, "task-123")
result, err := handle.GetResult()
// Or retrieve by ID later
handle2, err := dbos.RetrieveWorkflow[string](dbosContext, handle.GetWorkflowID())
```

### Java
```java
WorkflowHandle<String, Exception> handle = DBOS.startWorkflow(
    () -> proxy.longTask("task-123"),
    new StartWorkflowOptions()
);
String result = handle.getResult();
// Or retrieve by ID later
WorkflowHandle<String, Exception> handle2 = DBOS.retrieveWorkflow(handle.workflowId());
```

## Idempotency

### TypeScript
```typescript
const handle = await DBOS.startWorkflow(checkout, { workflowID: `order-${orderId}` })(userId, amount);
```

### Python
```python
from dbos import SetWorkflowID

with SetWorkflowID(f"order-{order_id}"):
    result = checkout_workflow(user_id, amount)
```

### Go
```go
handle, err := dbos.RunWorkflow(dbosContext, checkout, input,
    dbos.WithWorkflowID(fmt.Sprintf("order-%s", orderID)),
)
```

### Java
```java
WorkflowHandle<String, Exception> handle = DBOS.startWorkflow(
    () -> proxy.checkout(userId, amount),
    new StartWorkflowOptions().withWorkflowId("order-" + orderId)
);
```

## Durable Sleep

### TypeScript
```typescript
await DBOS.sleep(delayMs);  // Survives restarts
```

### Python
```python
DBOS.sleep(delay_seconds)  # Survives restarts
```

### Go
```go
dbos.Sleep(ctx, 30*time.Second)  // Survives restarts
```

### Java
```java
DBOS.sleep(Duration.ofSeconds(30));  // Survives restarts
```

## Step Retries

### TypeScript
```typescript
const data = await DBOS.runStep(() => unreliableApiCall(), {
  name: "apiCall",
  retriesAllowed: true,
  maxAttempts: 5,
  intervalSeconds: 2,
  backoffRate: 2,
});
```

### Python
```python
@DBOS.step(retries_allowed=True, max_attempts=5, interval_seconds=2, backoff_rate=2)
def unreliable_api_call():
    return requests.get("https://example.com").text
```

### Go
```go
result, err := dbos.RunAsStep(ctx, unreliableAPICall,
    dbos.WithStepName("apiCall"),
    dbos.WithStepMaxRetries(5),
    dbos.WithBaseInterval(2*time.Second),
    dbos.WithBackoffFactor(2.0),
    dbos.WithMaxInterval(30*time.Second),
)
```

### Java
```java
String data = DBOS.runStep(
    () -> unreliableApiCall(),
    new StepOptions("apiCall")
        .withRetriesAllowed(true)
        .withMaxAttempts(5)
        .withIntervalSeconds(2)
        .withBackoffRate(2.0)
);
```

## Scheduled Workflows

### TypeScript
```typescript
async function dailyCleanup(schedTime: Date, startTime: Date) {
  await DBOS.runStep(() => performCleanup(), { name: "cleanup" });
}
const scheduledCleanup = DBOS.registerWorkflow(dailyCleanup);
DBOS.registerScheduled(scheduledCleanup, { crontab: "0 0 * * *" });
```

### Python
```python
@DBOS.scheduled("0 0 * * *")
@DBOS.workflow()
def daily_cleanup(scheduled_time, actual_time):
    perform_cleanup()
```

### Go
```go
// Scheduled workflow must take time.Time as input
func dailyCleanup(ctx dbos.DBOSContext, scheduledTime time.Time) (string, error) {
    _, err := dbos.RunAsStep(ctx, performCleanup, dbos.WithStepName("cleanup"))
    return "completed", err
}

// Register with cron schedule (seconds precision)
dbos.RegisterWorkflow(dbosContext, dailyCleanup,
    dbos.WithSchedule("0 0 0 * * *"),  // Daily at midnight
)
```

### Java
```java
@Workflow
@Scheduled(cron = "0 0 * * * *")  // Every hour
public void dailyCleanup(Instant scheduled, Instant actual) {
    performCleanup();
}
```

**Note:** TypeScript/Python/Java scheduled workflows take two datetime arguments (scheduled and actual time). Go scheduled workflows take one `time.Time` argument (scheduled time).

## Queues

### TypeScript
```typescript
import { WorkflowQueue } from "@dbos-inc/dbos-sdk";

const queue = new WorkflowQueue("task_queue", { workerConcurrency: 5 });

const handle = await DBOS.startWorkflow(taskWorkflow, { queueName: queue.name })(task);
```

### Python
```python
from dbos import Queue

queue = Queue("task_queue", worker_concurrency=5)

handle = queue.enqueue(task_workflow, task)
result = handle.get_result()
```

### Go
```go
// Create queue before DBOS.Launch()
queue := dbos.NewWorkflowQueue(dbosContext, "task_queue",
    dbos.WithWorkerConcurrency(5),
)

// Enqueue workflow
handle, err := dbos.RunWorkflow(dbosContext, taskWorkflow, task,
    dbos.WithQueue(queue.Name),
)
result, err := handle.GetResult()
```

### Java
```java
// Create and register queue before DBOS.launch()
Queue queue = new Queue("task_queue").withWorkerConcurrency(5);
DBOS.registerQueue(queue);

// Enqueue workflow
WorkflowHandle<String, Exception> handle = DBOS.startWorkflow(
    () -> proxy.taskWorkflow(task),
    new StartWorkflowOptions().withQueue(queue)
);
String result = handle.getResult();
```

## Testing

### TypeScript (Jest)
```typescript
beforeAll(async () => {
  DBOS.setConfig({
    name: 'my-app',
    databaseUrl: process.env.DBOS_TESTING_DATABASE_URL,
  });
  await DBOS.launch();
});
```

### Python (pytest)
```python
@pytest.fixture()
def reset_dbos():
    DBOS.destroy()
    config: DBOSConfig = {
        "name": "my-app",
        "database_url": os.environ.get("TESTING_DATABASE_URL"),
    }
    DBOS(config=config)
    DBOS.reset_system_database()
    DBOS.launch()
```

### Go (testing)
```go
func TestMain(m *testing.M) {
    dbosContext, err := dbos.NewDBOSContext(context.Background(), dbos.Config{
        AppName:     "my-app-test",
        DatabaseURL: os.Getenv("DBOS_TESTING_DATABASE_URL"),
    })
    if err != nil {
        panic(err)
    }

    dbos.RegisterWorkflow(dbosContext, myWorkflow)

    err = dbos.Launch(dbosContext)
    if err != nil {
        panic(err)
    }
    defer dbos.Shutdown(dbosContext, 5*time.Second)

    os.Exit(m.Run())
}
```

### Java (JUnit)
```java
public class WorkflowTest {
    static MyApp proxy;

    @BeforeAll
    static void setup() throws Exception {
        DBOSConfig config = DBOSConfig.defaults("my-app-test")
            .withDatabaseUrl(System.getenv("DBOS_TESTING_JDBC_URL"))
            .withDbUser(System.getenv("PGUSER"))
            .withDbPassword(System.getenv("PGPASSWORD"));
        DBOS.configure(config);
        proxy = DBOS.registerWorkflows(MyApp.class, new MyAppImpl());
        DBOS.launch();
    }

    @AfterAll
    static void teardown() {
        DBOS.shutdown();
    }
}
```

## Error Logging

### TypeScript
```typescript
DBOS.logger.error(`Error: ${(error as Error).message}`);
```

### Python
```python
DBOS.logger.error(f"Error: {error}")
```

### Go
```go
slog.Error("Error occurred", "error", err)
```

### Java
```java
private static final Logger logger = LoggerFactory.getLogger(MyClass.class);
logger.error("Error: {}", error.getMessage());
```
