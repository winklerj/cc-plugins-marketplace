# DBOS API Reference

## Table of Contents

1. [Queues](#queues)
2. [Scheduled Workflows](#scheduled-workflows)
3. [Workflow Communication](#workflow-communication)
4. [Workflow Events](#workflow-events)
5. [Workflow Streaming](#workflow-streaming)
6. [Debouncing](#debouncing)
7. [Workflow Handles](#workflow-handles)
8. [Workflow Management](#workflow-management)
9. [Configuration](#configuration)
10. [Class-Based Workflows](#class-based-workflows)

---

## Queues

Use queues to run many workflows with managed concurrency.

### Basic Queue Usage

```typescript
import { DBOS, WorkflowQueue } from "@dbos-inc/dbos-sdk";

const queue = new WorkflowQueue("example_queue");

async function taskFunction(task: Task) {
  await DBOS.runStep(() => processTask(task), { name: "processTask" });
}
const taskWorkflow = DBOS.registerWorkflow(taskFunction);

// Enqueue workflow
const handle = await DBOS.startWorkflow(taskWorkflow, { queueName: queue.name })(task);
```

### Queue with Concurrency Limits

```typescript
// Worker concurrency: max 5 concurrent per process
const queue = new WorkflowQueue("example_queue", { workerConcurrency: 5 });

// Global concurrency: max 10 concurrent across all processes
const queue = new WorkflowQueue("example_queue", { concurrency: 10 });

// In-order processing: one at a time
const serialQueue = new WorkflowQueue("serial_queue", { concurrency: 1 });
```

### Rate Limiting

```typescript
// Max 50 workflows per 30 seconds
const queue = new WorkflowQueue("rate_limited", {
  rateLimit: { limitPerPeriod: 50, periodSec: 30 }
});
```

### Parallel Task Processing with Queues

```typescript
const queue = new WorkflowQueue("parallel_queue");

async function parallelProcessor(tasks: Task[]) {
  const handles = [];
  for (const task of tasks) {
    handles.push(await DBOS.startWorkflow(taskWorkflow, { queueName: queue.name })(task));
  }
  const results = [];
  for (const h of handles) {
    results.push(await h.getResult());
  }
  return results;
}
const parallelWorkflow = DBOS.registerWorkflow(parallelProcessor);
```

### Queue Partitioning

```typescript
// Partition by user ID - each user gets max 1 concurrent task
const queue = new WorkflowQueue("user_queue", { partitionQueue: true, concurrency: 1 });

async function onUserTask(userId: string, task: Task) {
  await DBOS.startWorkflow(taskWorkflow, {
    queueName: queue.name,
    enqueueOptions: { queuePartitionKey: userId }
  })(task);
}
```

### Deduplication

```typescript
// Only one workflow with this dedup ID can be enqueued at a time
try {
  const handle = await DBOS.startWorkflow(taskWorkflow, {
    queueName: queue.name,
    enqueueOptions: { deduplicationID: `user-${userId}` }
  })(task);
} catch (e) {
  // Handle DBOSQueueDuplicatedError
}
```

### Priority

```typescript
const queue = new WorkflowQueue("priority_queue", { usePriority: true });

// Lower number = higher priority (1 is highest)
await DBOS.startWorkflow(taskWorkflow, {
  queueName: queue.name,
  enqueueOptions: { priority: 1 }  // High priority
})(urgentTask);

await DBOS.startWorkflow(taskWorkflow, {
  queueName: queue.name,
  enqueueOptions: { priority: 100 }  // Low priority
})(normalTask);
```

### Queue Timeouts

```typescript
const handle = await DBOS.startWorkflow(taskWorkflow, {
  queueName: queue.name,
  timeoutMS: 60000  // 1 minute timeout
})(task);
```

---

## Scheduled Workflows

Run workflows on a schedule using crontab syntax.

```typescript
async function dailyCleanup(schedTime: Date, startTime: Date) {
  DBOS.logger.info(`Scheduled at ${schedTime}, started at ${startTime}`);
  await DBOS.runStep(() => performCleanup(), { name: "cleanup" });
}
const scheduledCleanup = DBOS.registerWorkflow(dailyCleanup);
DBOS.registerScheduled(scheduledCleanup, { crontab: "0 0 * * *" });  // Daily at midnight
```

### Crontab Examples
- `*/30 * * * * *` - Every 30 seconds
- `0 * * * *` - Every hour
- `0 0 * * *` - Daily at midnight
- `0 0 * * 0` - Weekly on Sunday

---

## Workflow Communication

### Send/Receive Messages

```typescript
// Sender (from anywhere)
await DBOS.send(workflowID, { status: "approved" }, "payment-topic");

// Receiver (in workflow)
async function paymentWorkflow() {
  const notification = await DBOS.recv<{ status: string }>("payment-topic", 300);  // 5 min timeout
  if (notification?.status === "approved") {
    await DBOS.runStep(() => processPayment(), { name: "processPayment" });
  }
}
```

### Webhook Pattern

```typescript
// Workflow waits for external notification
async function orderWorkflow(orderId: string) {
  await DBOS.runStep(() => submitOrder(orderId), { name: "submitOrder" });
  const confirmation = await DBOS.recv<OrderConfirmation>("order-confirmed", 3600);
  if (!confirmation) {
    await DBOS.runStep(() => handleTimeout(orderId), { name: "handleTimeout" });
  }
  return confirmation;
}

// Webhook endpoint sends notification
app.post("/webhook/order-confirmed", async (req, res) => {
  const { workflowID, confirmation } = req.body;
  await DBOS.send(workflowID, confirmation, "order-confirmed");
  res.sendStatus(200);
});
```

---

## Workflow Events

Publish key-value pairs from workflows for clients to read.

### Set Event

```typescript
async function checkoutWorkflow(orderId: string) {
  const paymentUrl = await DBOS.runStep(() => getPaymentUrl(orderId), { name: "getPaymentUrl" });
  await DBOS.setEvent("payment-url", paymentUrl);  // Publish for client
  const paid = await DBOS.recv<boolean>("payment-complete", 600);
  // ...
}
```

### Get Event

```typescript
// Client waits for event
const handle = await DBOS.startWorkflow(checkoutWorkflow)(orderId);
const paymentUrl = await DBOS.getEvent<string>(handle.workflowID, "payment-url", 30);
if (paymentUrl) {
  res.redirect(paymentUrl);
}
```

---

## Workflow Streaming

Stream data in real-time from workflows to clients.

### Write to Stream

```typescript
async function processingWorkflow(items: string[]) {
  for (const item of items) {
    const result = await DBOS.runStep(() => processItem(item), { name: `process-${item}` });
    await DBOS.writeStream("progress", { item, result, timestamp: Date.now() });
  }
  await DBOS.closeStream("progress");
}
```

### Read from Stream

```typescript
const handle = await DBOS.startWorkflow(processingWorkflow)(items);

for await (const value of DBOS.readStream(handle.workflowID, "progress")) {
  console.log(`Processed: ${value.item} -> ${value.result}`);
}
```

---

## Debouncing

Delay workflow execution until input stops arriving.

```typescript
import { Debouncer } from "@dbos-inc/dbos-sdk";

async function processInput(userInput: string) {
  await DBOS.runStep(() => analyzeInput(userInput), { name: "analyze" });
}
const processInputWorkflow = DBOS.registerWorkflow(processInput);

const debouncer = new Debouncer({
  workflow: processInputWorkflow,
  debounceTimeoutMs: 300000,  // Max 5 minutes from first call
});

// Each call delays execution by 60 seconds
async function onUserInput(userId: string, input: string) {
  await debouncer.debounce(userId, 60000, input);
}
```

---

## Workflow Handles

### Handle Methods

```typescript
const handle = await DBOS.startWorkflow(myWorkflow)(args);

handle.workflowID;           // Get workflow ID
await handle.getResult();    // Wait for and get result
await handle.getStatus();    // Get WorkflowStatus object
```

### WorkflowStatus

```typescript
interface WorkflowStatus {
  workflowID: string;
  status: "ENQUEUED" | "PENDING" | "SUCCESS" | "ERROR" | "CANCELLED" | "RETRIES_EXCEEDED";
  workflowName: string;
  queueName?: string;
  output?: unknown;
  error?: unknown;
  input?: unknown[];
  createdAt: number;      // UNIX epoch ms
  updatedAt?: number;
  timeoutMS?: number;
}
```

---

## Workflow Management

### List Workflows

```typescript
const workflows = await DBOS.listWorkflows({
  workflowName: "checkoutWorkflow",
  status: "PENDING",
  startTime: "2024-01-01T00:00:00Z",
  limit: 100,
});
```

### List Queued Workflows

```typescript
const queued = await DBOS.listQueuedWorkflows({
  queueName: "payment_queue",
  status: "ENQUEUED",
});
```

### List Workflow Steps

```typescript
const steps = await DBOS.listWorkflowSteps(workflowID);
// Returns StepInfo[] with stepID, name, output, error, childWorkflowID
```

### Cancel Workflow

```typescript
await DBOS.cancelWorkflow(workflowID);
// Sets status to CANCELLED, removes from queue, preempts at next step
```

### Resume Workflow

```typescript
const handle = await DBOS.resumeWorkflow(workflowID);
// Resumes cancelled or failed workflow from last completed step
```

### Fork Workflow

```typescript
// Restart from a specific step (useful for fixing bugs)
const handle = await DBOS.forkWorkflow(workflowID, 3, {
  newWorkflowID: "forked-workflow-id",
  applicationVersion: "v2.0",
});
```

---

## Configuration

```typescript
DBOS.setConfig({
  name: "my-app",
  systemDatabaseUrl: process.env.DBOS_SYSTEM_DATABASE_URL,
  systemDatabasePoolSize: 10,
  enableOTLP: false,
  logLevel: "info",
  runAdminServer: true,
  adminPort: 3001,
  applicationVersion: "1.0.0",
});
await DBOS.launch();
```

### Required Environment Variable
- `DBOS_SYSTEM_DATABASE_URL`: PostgreSQL connection string for DBOS system database

---

## Class-Based Workflows

Use decorators for class-based organization. Avoid when possible - prefer `registerWorkflow`.

```typescript
class OrderProcessor extends ConfiguredInstance {
  constructor(name: string, private config: Config) {
    super(name);
  }

  @DBOS.workflow()
  async processOrder(orderId: string) {
    await this.validateOrder(orderId);
    await this.chargePayment(orderId);
  }

  @DBOS.step()
  async validateOrder(orderId: string) {
    // ...
  }

  @DBOS.step()
  async chargePayment(orderId: string) {
    // ...
  }
}

// Must instantiate before DBOS.launch()
const processor = new OrderProcessor("main-processor", config);
```

---

## Parallel Steps (Limited)

Starting concurrent steps followed by `Promise.allSettled` is valid if started deterministically:

```typescript
// ALLOWED - deterministic start order
const results = await Promise.allSettled([
  DBOS.runStep(() => step1(), { name: "step1" }),
  DBOS.runStep(() => step2(), { name: "step2" }),
  DBOS.runStep(() => step3(), { name: "step3" }),
]);

// NOT ALLOWED - non-deterministic order
const results = await Promise.allSettled([
  async () => { await step1(); await step2(); },  // Order depends on timing
  async () => { await step3(); await step4(); },
]);
```

For complex parallel execution, use `DBOS.startWorkflow` with queues instead.

---

## DBOS Context Variables

```typescript
DBOS.workflowID;  // Current workflow ID (undefined if not in workflow)
DBOS.stepID;      // Current step ID (undefined if not in step)
DBOS.stepStatus;  // { stepID, currentAttempt?, maxAttempts? }
```
