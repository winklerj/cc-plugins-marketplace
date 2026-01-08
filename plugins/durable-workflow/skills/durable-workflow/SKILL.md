---
name: durable-workflow
description: "Create durable, resilient workflows using DBOS that automatically resume after failures. Supports TypeScript, Python, Go, and Java. Use proactively when: (1) Multi-step processes that must complete reliably, (2) Operations calling external APIs or services that might fail, (3) Long-running background tasks, (4) Scheduled/recurring jobs, (5) User asks for durable, resilient, reliable, or fault-tolerant workflows, (6) Processes involving payments, notifications, or other critical operations that cannot be lost."
---

# Durable Workflows with DBOS

Build reliable applications with DBOS. Workflows provide **durable execution** so programs are **resilient to any failure**. If a workflow is interrupted (executor restarts, crashes, etc.), it automatically resumes from the last completed step.

## Latest Documentation

**IMPORTANT:** Before implementing, check the latest DBOS documentation at https://docs.dbos.dev/ for the most up-to-date API references and best practices. Documentation locations may change, but the guidance below remains valid for reference.

### Documentation Site Structure (https://docs.dbos.dev/)

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

## Core Pattern - TypeScript

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

## Core Pattern - Python

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

# Steps: wrap functions that access external services or are non-deterministic
@DBOS.step()
def send_email(to: str, subject: str):
    email_service.send(to, subject)

@DBOS.step()
def process_payment(amount: float) -> str:
    return payment_service.charge(amount)

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

## Core Pattern - Go

```go
package main

import (
    "context"
    "fmt"
    "net/http"
    "os"
    "time"

    "github.com/dbos-inc/dbos-transact-golang/dbos"
    "github.com/gin-gonic/gin"
)

// Steps: wrap functions that access external services or are non-deterministic
func sendEmail(ctx context.Context, to string, subject string) (string, error) {
    // emailService.Send(to, subject)
    return "sent", nil
}

func processPayment(ctx context.Context, amount float64) (string, error) {
    // paymentService.Charge(amount)
    return "payment-123", nil
}

// Workflow: orchestrates steps with durable execution
func checkoutWorkflow(ctx dbos.DBOSContext, input CheckoutInput) (string, error) {
    paymentID, err := dbos.RunAsStep(ctx, func(c context.Context) (string, error) {
        return processPayment(c, input.Amount)
    }, dbos.WithStepName("processPayment"))
    if err != nil {
        return "", err
    }

    _, err = dbos.RunAsStep(ctx, func(c context.Context) (string, error) {
        return sendEmail(c, input.UserID, "Payment received")
    }, dbos.WithStepName("sendEmail"))
    if err != nil {
        return "", err
    }

    return paymentID, nil
}

type CheckoutInput struct {
    UserID string  `json:"user_id"`
    Amount float64 `json:"amount"`
}

func main() {
    dbosContext, err := dbos.NewDBOSContext(context.Background(), dbos.Config{
        AppName:     "my-app",
        DatabaseURL: os.Getenv("DBOS_SYSTEM_DATABASE_URL"),
    })
    if err != nil {
        panic(err)
    }

    dbos.RegisterWorkflow(dbosContext, checkoutWorkflow)

    err = dbos.Launch(dbosContext)
    if err != nil {
        panic(err)
    }
    defer dbos.Shutdown(dbosContext, 5*time.Second)

    r := gin.Default()

    r.POST("/checkout", func(c *gin.Context) {
        var input CheckoutInput
        if err := c.BindJSON(&input); err != nil {
            c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
            return
        }

        handle, _ := dbos.RunWorkflow(dbosContext, checkoutWorkflow, input)
        result, _ := handle.GetResult()
        c.JSON(http.StatusOK, gin.H{"payment_id": result})
    })

    r.Run(":8080")
}
```

## Core Pattern - Java

```java
import dev.dbos.transact.DBOS;
import dev.dbos.transact.config.DBOSConfig;
import dev.dbos.transact.workflow.Workflow;
import dev.dbos.transact.workflow.Step;
import io.javalin.Javalin;

// Define interface
interface Checkout {
    String checkoutWorkflow(String userId, double amount);
}

// Implement with annotations
class CheckoutImpl implements Checkout {

    // Steps: wrap functions that access external services or are non-deterministic
    @Step(name = "processPayment")
    public String processPayment(double amount) {
        return paymentService.charge(amount);
    }

    @Step(name = "sendEmail")
    public void sendEmail(String to, String subject) {
        emailService.send(to, subject);
    }

    // Workflow: orchestrates steps with durable execution
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

        Javalin app = Javalin.create().start(8080);
        app.post("/checkout", ctx -> {
            String result = proxy.checkoutWorkflow(
                ctx.queryParam("userId"),
                Double.parseDouble(ctx.queryParam("amount"))
            );
            ctx.json(java.util.Map.of("paymentId", result));
        });
    }
}
```

## Critical Rules

### Workflows
- Workflow functions MUST be deterministic
- Do NOT perform non-deterministic actions directly in workflows (API calls, random numbers, current time)
- Move non-deterministic actions to steps
- TypeScript: Do NOT use `Promise.all()` - use `Promise.allSettled()` or queues
- Python: Do NOT use threads - use `DBOS.start_workflow` and queues
- Go: Do NOT start goroutines or use `select` in workflows - use them only inside steps. Use `dbos.RunWorkflow` and queues for parallelism
- Java: Do NOT use threading APIs directly in workflows - use `DBOS.startWorkflow` and queues for parallelism

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
import dev.dbos.transact.StartWorkflowOptions;
import dev.dbos.transact.workflow.WorkflowHandle;

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
import java.time.Duration;

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
import dev.dbos.transact.workflow.StepOptions;

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
import dev.dbos.transact.workflow.Scheduled;
import java.time.Instant;

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
import dev.dbos.transact.workflow.Queue;

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

## Detailed Reference

For advanced features by language:

**TypeScript:** See [references/dbos-typescript-api.md](references/dbos-typescript-api.md)
- Queues, communication, events, streaming, debouncing, management

**Python:** See [references/dbos-python-api.md](references/dbos-python-api.md)
- Queues, communication, events, streaming, debouncing, transactions, async workflows

**Go:** See [references/dbos-go-api.md](references/dbos-go-api.md)
- Queues, communication, events, workflow management, DBOS client

**Java:** See [references/dbos-java-api.md](references/dbos-java-api.md)
- Queues, communication, events, workflow management, Spring Boot integration

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
// Use standard Go logging or configure a custom logger in DBOSContext
slog.Error("Error occurred", "error", err)

// Or with custom logger in config:
dbosContext, _ := dbos.NewDBOSContext(context.Background(), dbos.Config{
    AppName:     "my-app",
    DatabaseURL: os.Getenv("DBOS_SYSTEM_DATABASE_URL"),
    Logger:      slog.Default(),  // Custom slog.Logger
})
```

### Java
```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

private static final Logger logger = LoggerFactory.getLogger(MyClass.class);
logger.error("Error: {}", error.getMessage());
```
