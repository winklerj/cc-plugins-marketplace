# DBOS Go API Reference

> **Latest Documentation:** Always check https://docs.dbos.dev/golang/programming-guide for the most current API. Key reference pages:
> - Programming Guide: https://docs.dbos.dev/golang/programming-guide
> - Workflow Tutorial: https://docs.dbos.dev/golang/tutorials/workflow-tutorial
> - Workflow Communication: https://docs.dbos.dev/golang/tutorials/workflow-communication
> - Queue Tutorial: https://docs.dbos.dev/golang/tutorials/queue-tutorial
> - Methods Reference: https://docs.dbos.dev/golang/reference/methods

## Table of Contents

1. [Core Pattern](#core-pattern)
2. [DBOS Lifecycle](#dbos-lifecycle)
3. [Workflows](#workflows)
4. [Steps](#steps)
5. [Queues](#queues)
6. [Scheduled Workflows](#scheduled-workflows)
7. [Workflow Communication](#workflow-communication)
8. [Workflow Events](#workflow-events)
9. [Workflow Handles](#workflow-handles)
10. [Workflow Management](#workflow-management)
11. [Configuration](#configuration)
12. [DBOS Client](#dbos-client)

---

## Core Pattern

```go
package main

import (
    "context"
    "fmt"
    "os"
    "time"

    "github.com/dbos-inc/dbos-transact-golang/dbos"
)

// Steps: wrap functions that access external services or are non-deterministic
func sendEmail(ctx context.Context, to string, subject string) (string, error) {
    // Send email via external service
    return "sent", nil
}

func processPayment(ctx context.Context, amount float64) (string, error) {
    // Process payment via external service
    return "payment-123", nil
}

// Workflow: orchestrates steps with durable execution
func checkoutWorkflow(ctx dbos.DBOSContext, input CheckoutInput) (string, error) {
    paymentID, err := dbos.RunAsStep(ctx, func(stepCtx context.Context) (string, error) {
        return processPayment(stepCtx, input.Amount)
    }, dbos.WithStepName("processPayment"))
    if err != nil {
        return "", err
    }

    _, err = dbos.RunAsStep(ctx, func(stepCtx context.Context) (string, error) {
        return sendEmail(stepCtx, input.UserID, "Payment received")
    }, dbos.WithStepName("sendEmail"))
    if err != nil {
        return "", err
    }

    return paymentID, nil
}

type CheckoutInput struct {
    UserID string
    Amount float64
}

func main() {
    dbosContext, err := dbos.NewDBOSContext(context.Background(), dbos.Config{
        AppName:     "my-app",
        DatabaseURL: os.Getenv("DBOS_SYSTEM_DATABASE_URL"),
    })
    if err != nil {
        panic(fmt.Sprintf("Initializing DBOS failed: %v", err))
    }

    dbos.RegisterWorkflow(dbosContext, checkoutWorkflow)

    err = dbos.Launch(dbosContext)
    if err != nil {
        panic(fmt.Sprintf("Launching DBOS failed: %v", err))
    }
    defer dbos.Shutdown(dbosContext, 5*time.Second)

    // Run workflow
    handle, err := dbos.RunWorkflow(dbosContext, checkoutWorkflow, CheckoutInput{
        UserID: "user-123",
        Amount: 99.99,
    })
    if err != nil {
        panic(err)
    }

    result, err := handle.GetResult()
    if err != nil {
        panic(err)
    }
    fmt.Println("Payment ID:", result)
}
```

---

## DBOS Lifecycle

### Initialization

```go
dbosContext, err := dbos.NewDBOSContext(context.Background(), dbos.Config{
    AppName:            "my-app",                              // Required
    DatabaseURL:        os.Getenv("DBOS_SYSTEM_DATABASE_URL"), // Required (or SystemDBPool)
    DatabaseSchema:     "dbos",                                // Optional, defaults to "dbos"
    AdminServer:        true,                                  // Optional, enables admin HTTP server
    AdminServerPort:    3001,                                  // Optional, default 3001
    ApplicationVersion: "1.0.0",                               // Optional
    ExecutorID:         "executor-1",                          // Optional
})
```

### Launch and Shutdown

```go
// Register all workflows and create queues BEFORE launch
dbos.RegisterWorkflow(dbosContext, myWorkflow)
queue := dbos.NewWorkflowQueue(dbosContext, "my-queue")

// Launch DBOS
err := dbos.Launch(dbosContext)
if err != nil {
    panic(err)
}
defer dbos.Shutdown(dbosContext, 5*time.Second)
```

---

## Workflows

### Workflow Registration

```go
// Workflow signature must match:
// func(ctx dbos.DBOSContext, input P) (R, error)

func myWorkflow(ctx dbos.DBOSContext, input string) (string, error) {
    // Workflow logic
    return "result", nil
}

// Register before DBOS.Launch()
dbos.RegisterWorkflow(dbosContext, myWorkflow)

// With options
dbos.RegisterWorkflow(dbosContext, myWorkflow,
    dbos.WithWorkflowName("custom-name"),
    dbos.WithMaxRetries(3),
)
```

### Running Workflows

```go
// Run workflow and get handle
handle, err := dbos.RunWorkflow(dbosContext, myWorkflow, "input")
if err != nil {
    return err
}

// Wait for result
result, err := handle.GetResult()

// With custom workflow ID (for idempotency)
handle, err := dbos.RunWorkflow(dbosContext, myWorkflow, "input",
    dbos.WithWorkflowID("unique-order-123"),
)

// With timeout
timeoutCtx, cancel := dbos.WithTimeout(dbosContext, 30*time.Minute)
defer cancel()
handle, err := dbos.RunWorkflow(timeoutCtx, myWorkflow, "input")
```

### Workflow Determinism

Workflows must be deterministic. Move non-deterministic operations to steps:

```go
// DON'T do this in a workflow
func badWorkflow(ctx dbos.DBOSContext, _ string) (int, error) {
    return rand.Intn(100), nil  // Non-deterministic!
}

// DO this instead
func generateRandom(ctx context.Context) (int, error) {
    return rand.Intn(100), nil
}

func goodWorkflow(ctx dbos.DBOSContext, _ string) (int, error) {
    return dbos.RunAsStep(ctx, generateRandom, dbos.WithStepName("generateRandom"))
}
```

**Do NOT** use goroutines or `select` in workflows - use them only inside steps.

---

## Steps

### Basic Step Usage

```go
// Step function signature: func(ctx context.Context) (R, error)

func fetchData(ctx context.Context) (string, error) {
    resp, err := http.Get("https://api.example.com/data")
    if err != nil {
        return "", err
    }
    defer resp.Body.Close()
    body, _ := io.ReadAll(resp.Body)
    return string(body), nil
}

func myWorkflow(ctx dbos.DBOSContext, _ string) (string, error) {
    // Run function as a step
    return dbos.RunAsStep(ctx, fetchData, dbos.WithStepName("fetchData"))
}
```

### Steps with Arguments

```go
func processItem(ctx context.Context, item string, count int) (string, error) {
    return fmt.Sprintf("processed %s x%d", item, count), nil
}

func myWorkflow(ctx dbos.DBOSContext, item string) (string, error) {
    return dbos.RunAsStep(ctx, func(stepCtx context.Context) (string, error) {
        return processItem(stepCtx, item, 5)
    }, dbos.WithStepName("processItem"))
}
```

### Step Retries

```go
result, err := dbos.RunAsStep(ctx, func(stepCtx context.Context) (string, error) {
    return unreliableAPICall(stepCtx)
},
    dbos.WithStepName("apiCall"),
    dbos.WithStepMaxRetries(10),           // Max retries on failure
    dbos.WithBaseInterval(500*time.Millisecond),  // Initial delay
    dbos.WithMaxInterval(30*time.Second),  // Max delay
    dbos.WithBackoffFactor(2.0),           // Exponential backoff multiplier
)
```

---

## Queues

### Basic Queue Usage

```go
// Create queue before DBOS.Launch()
queue := dbos.NewWorkflowQueue(dbosContext, "task-queue")

func taskWorkflow(ctx dbos.DBOSContext, task string) (string, error) {
    // Process task
    return "completed", nil
}

// Enqueue workflow
handle, err := dbos.RunWorkflow(dbosContext, taskWorkflow, "task-1",
    dbos.WithQueue(queue.Name),
)
```

### Queue Concurrency Limits

```go
// Worker concurrency: max 5 per process
queue := dbos.NewWorkflowQueue(dbosContext, "queue",
    dbos.WithWorkerConcurrency(5),
)

// Global concurrency: max 10 across all processes
queue := dbos.NewWorkflowQueue(dbosContext, "queue",
    dbos.WithGlobalConcurrency(10),
)
```

### Rate Limiting

```go
// Max 100 workflows per 60 seconds
queue := dbos.NewWorkflowQueue(dbosContext, "rate-limited",
    dbos.WithRateLimiter(&dbos.RateLimiter{
        Limit:  100,
        Period: 60 * time.Second,
    }),
)
```

### Parallel Task Processing

```go
func taskWorkflow(ctx dbos.DBOSContext, task int) (int, error) {
    dbos.Sleep(ctx, 5*time.Second)
    return task, nil
}

func batchWorkflow(ctx dbos.DBOSContext, queue dbos.WorkflowQueue) (int, error) {
    handles := make([]dbos.WorkflowHandle[int], 10)
    for i := range 10 {
        handle, err := dbos.RunWorkflow(ctx, taskWorkflow, i,
            dbos.WithQueue(queue.Name),
        )
        if err != nil {
            return 0, err
        }
        handles[i] = handle
    }

    var total int
    for _, handle := range handles {
        result, err := handle.GetResult()
        if err != nil {
            return 0, err
        }
        total += result
    }
    return total, nil
}
```

### Deduplication

```go
// Only one workflow with this dedup ID can be enqueued at a time
handle, err := dbos.RunWorkflow(dbosContext, taskWorkflow, task,
    dbos.WithQueue(queue.Name),
    dbos.WithDeduplicationID("user-12345"),
)
```

### Priority

```go
// Enable priority on queue
queue := dbos.NewWorkflowQueue(dbosContext, "priority-queue",
    dbos.WithPriorityEnabled(),
)

// Lower number = higher priority
handle, err := dbos.RunWorkflow(dbosContext, taskWorkflow, urgentTask,
    dbos.WithQueue(queue.Name),
    dbos.WithPriority(1),  // High priority
)

handle, err := dbos.RunWorkflow(dbosContext, taskWorkflow, normalTask,
    dbos.WithQueue(queue.Name),
    dbos.WithPriority(100),  // Low priority
)
```

---

## Scheduled Workflows

```go
// Scheduled workflow must take time.Time as input
func dailyBackup(ctx dbos.DBOSContext, scheduledTime time.Time) (string, error) {
    fmt.Printf("Backup scheduled for: %s\n", scheduledTime.Format(time.RFC3339))
    _, err := dbos.RunAsStep(ctx, performBackup, dbos.WithStepName("backup"))
    return "completed", err
}

// Register with cron schedule
dbos.RegisterWorkflow(dbosContext, dailyBackup,
    dbos.WithSchedule("0 0 2 * * *"),  // Daily at 2:00 AM (seconds precision)
)
```

### Crontab Examples (with seconds)
- `0 */15 * * * *` - Every 15 minutes
- `0 0 * * * *` - Every hour
- `0 0 2 * * *` - Daily at 2:00 AM
- `0 0 0 * * 0` - Weekly on Sunday at midnight

---

## Workflow Communication

### Send/Receive Messages

```go
const PaymentTopic = "payment_status"

// Receiver workflow waits for message
func paymentWorkflow(ctx dbos.DBOSContext, orderID string) (string, error) {
    // Wait up to 5 minutes for payment notification
    notification, err := dbos.Recv[PaymentNotification](ctx, PaymentTopic, 5*time.Minute)
    if err != nil {
        return "", fmt.Errorf("payment timeout: %w", err)
    }

    if notification.Status == "completed" {
        _, err = dbos.RunAsStep(ctx, func(c context.Context) (string, error) {
            return fulfillOrder(c, orderID)
        }, dbos.WithStepName("fulfillOrder"))
    }
    return notification.Status, err
}

type PaymentNotification struct {
    Status string
    Amount float64
}

// Sender (e.g., webhook handler)
func paymentWebhook(dbosContext dbos.DBOSContext, workflowID string, notification PaymentNotification) error {
    return dbos.Send(dbosContext, workflowID, notification, PaymentTopic)
}
```

---

## Workflow Events

Publish key-value pairs from workflows for clients to read.

### Set Event

```go
const PaymentURLKey = "payment_url"

func checkoutWorkflow(ctx dbos.DBOSContext, orderID string) (string, error) {
    // Generate payment URL
    paymentURL, err := dbos.RunAsStep(ctx, func(c context.Context) (string, error) {
        return generatePaymentURL(c, orderID)
    }, dbos.WithStepName("generatePaymentURL"))
    if err != nil {
        return "", err
    }

    // Publish for client to read
    err = dbos.SetEvent(ctx, PaymentURLKey, paymentURL)
    if err != nil {
        return "", err
    }

    // Wait for payment completion
    // ...
    return "completed", nil
}
```

### Get Event

```go
// Client waits for event
handle, err := dbos.RunWorkflow(dbosContext, checkoutWorkflow, orderID)
if err != nil {
    return err
}

// Wait up to 30 seconds for payment URL
url, err := dbos.GetEvent[string](dbosContext, handle.GetWorkflowID(), PaymentURLKey, 30*time.Second)
if err != nil {
    return err
}

// Redirect user to payment URL
fmt.Printf("Redirect to: %s\n", url)
```

---

## Workflow Handles

```go
handle, err := dbos.RunWorkflow(dbosContext, myWorkflow, input)

// Get workflow ID
workflowID := handle.GetWorkflowID()

// Wait for result
result, err := handle.GetResult()

// Get status
status, err := handle.GetStatus()
```

### WorkflowStatus

```go
type WorkflowStatus struct {
    ID                 string             // Workflow UUID
    Status             WorkflowStatusType // PENDING, ENQUEUED, SUCCESS, ERROR, CANCELLED, MAX_RECOVERY_ATTEMPTS_EXCEEDED
    Name               string             // Workflow function name
    Output             any                // Result (after completion)
    Error              error              // Error (if status is ERROR)
    CreatedAt          time.Time
    UpdatedAt          time.Time
    ApplicationVersion string
    Attempts           int
    QueueName          string
    Timeout            time.Duration
    Input              any
    Priority           int
}
```

---

## Workflow Management

### Retrieve Existing Workflow

```go
handle, err := dbos.RetrieveWorkflow[string](dbosContext, workflowID)
result, err := handle.GetResult()
```

### List Workflows

```go
workflows, err := dbos.ListWorkflows(dbosContext,
    dbos.WithStatus([]dbos.WorkflowStatusType{dbos.WorkflowStatusSuccess}),
    dbos.WithStartTime(time.Now().Add(-24*time.Hour)),
    dbos.WithLimit(100),
    dbos.WithName("checkoutWorkflow"),
)
```

### List Workflow Steps

```go
steps, err := dbos.GetWorkflowSteps(dbosContext, workflowID)
for _, step := range steps {
    fmt.Printf("Step %d: %s\n", step.StepID, step.StepName)
}
```

### Cancel Workflow

```go
err := dbos.CancelWorkflow(dbosContext, workflowID)
// Sets status to CANCELLED, removes from queue, preempts at next step
```

### Resume Workflow

```go
handle, err := dbos.ResumeWorkflow[string](dbosContext, workflowID)
// Resumes from last completed step
```

### Fork Workflow

```go
// Start new execution from a specific step
handle, err := dbos.ForkWorkflow[string](dbosContext, dbos.ForkWorkflowInput{
    OriginalWorkflowID: originalWorkflowID,
    ForkedWorkflowID:   "new-workflow-id",
    StartStep:          3,  // Resume from step 3
    ApplicationVersion: "v2.0",
})
```

---

## Durable Sleep

```go
func scheduledTask(ctx dbos.DBOSContext, delay time.Duration) (string, error) {
    // Sleep survives restarts - wakes up on schedule even after crash
    _, err := dbos.Sleep(ctx, delay)
    if err != nil {
        return "", err
    }

    return dbos.RunAsStep(ctx, executeTask, dbos.WithStepName("executeTask"))
}
```

---

## Configuration

```go
type Config struct {
    AppName            string           // Required: Application name
    DatabaseURL        string           // PostgreSQL connection string (required unless SystemDBPool provided)
    SystemDBPool       *pgxpool.Pool    // Optional: custom connection pool
    DatabaseSchema     string           // Schema name (default: "dbos")
    Logger             *slog.Logger     // Custom logger
    AdminServer        bool             // Enable admin HTTP server
    AdminServerPort    int              // Admin server port (default: 3001)
    ConductorURL       string           // DBOS Conductor URL
    ConductorAPIKey    string           // Conductor API key
    ApplicationVersion string           // App version string
    ExecutorID         string           // Executor identifier
}
```

---

## DBOS Client

Use the client to interact with DBOS from outside your application:

```go
config := dbos.ClientConfig{
    DatabaseURL: os.Getenv("DBOS_SYSTEM_DATABASE_URL"),
}
client, err := dbos.NewClient(context.Background(), config)
if err != nil {
    log.Fatal(err)
}
defer client.Shutdown(5 * time.Second)

// Enqueue workflow
handle, err := dbos.Enqueue[ProcessInput, ProcessOutput](
    client,
    "pipeline_queue",    // Queue name
    "dataPipeline",      // Workflow name
    ProcessInput{TaskID: "task-123", Data: "data"},
    dbos.WithEnqueueTimeout(30*time.Minute),
    dbos.WithEnqueuePriority(5),
)

// Get result
result, err := handle.GetResult()

// Other client methods
client.ListWorkflows(opts...)
client.Send(workflowID, message, topic)
client.GetEvent(workflowID, key, timeout)
client.RetrieveWorkflow(workflowID)
client.CancelWorkflow(workflowID)
client.ResumeWorkflow(workflowID)
client.ForkWorkflow(input)
client.GetWorkflowSteps(workflowID)
```

---

## Context Variables

```go
// Get current workflow ID (returns error if not in workflow)
workflowID, err := dbos.GetWorkflowID(ctx)

// Get current step ID (returns error if not in step)
stepID, err := dbos.GetStepID(ctx)

// Get application version
version := dbos.GetApplicationVersion()

// Get executor ID
executorID := dbos.GetExecutorID()
```

---

## Context Management

### Timeouts

```go
// Create context with timeout
timeoutCtx, cancel := dbos.WithTimeout(dbosContext, 12*time.Hour)
defer cancel()

handle, err := dbos.RunWorkflow(timeoutCtx, myWorkflow, input)
```

### Detach Child Workflows

```go
// Child workflow won't be cancelled when parent times out
detachedCtx := dbos.WithoutCancel(ctx)
dbos.RunWorkflow(detachedCtx, childWorkflow, input)
```

---

## Integration with Gin

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

func workflow(ctx dbos.DBOSContext, input string) (string, error) {
    _, err := dbos.RunAsStep(ctx, stepOne, dbos.WithStepName("stepOne"))
    if err != nil {
        return "", err
    }
    return "success", nil
}

func stepOne(ctx context.Context) (string, error) {
    return "completed", nil
}

func main() {
    dbosContext, err := dbos.NewDBOSContext(context.Background(), dbos.Config{
        AppName:     "gin-app",
        DatabaseURL: os.Getenv("DBOS_SYSTEM_DATABASE_URL"),
    })
    if err != nil {
        panic(err)
    }

    dbos.RegisterWorkflow(dbosContext, workflow)

    err = dbos.Launch(dbosContext)
    if err != nil {
        panic(err)
    }
    defer dbos.Shutdown(dbosContext, 5*time.Second)

    r := gin.Default()

    r.POST("/process", func(c *gin.Context) {
        var input struct {
            Data string `json:"data"`
        }
        if err := c.BindJSON(&input); err != nil {
            c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
            return
        }

        handle, err := dbos.RunWorkflow(dbosContext, workflow, input.Data)
        if err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
            return
        }

        result, err := handle.GetResult()
        if err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
            return
        }

        c.JSON(http.StatusOK, gin.H{"result": result})
    })

    r.Run(":8080")
}
```
