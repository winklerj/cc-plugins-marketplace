# DBOS Java API Reference

> **Latest Documentation:** Always check https://docs.dbos.dev/java/programming-guide for the most current API. Key reference pages:
> - Programming Guide: https://docs.dbos.dev/java/programming-guide
> - Integrating DBOS: https://docs.dbos.dev/java/integrating-dbos
> - Examples: https://docs.dbos.dev/java/examples/widget-store

## Table of Contents

1. [Getting Started](#getting-started)
2. [Workflows and Steps](#workflows-and-steps)
3. [Workflow Registration](#workflow-registration)
4. [Starting Workflows](#starting-workflows)
5. [Queues](#queues)
6. [Scheduled Workflows](#scheduled-workflows)
7. [Workflow Communication](#workflow-communication)
8. [Workflow Events](#workflow-events)
9. [Workflow Handles](#workflow-handles)
10. [Workflow Management](#workflow-management)
11. [Configuration](#configuration)
12. [Spring Boot Integration](#spring-boot-integration)

---

## Getting Started

### Gradle Setup

Add dependencies to `build.gradle`:

```groovy
dependencies {
    implementation 'dev.dbos:transact:0.6+'
    implementation 'ch.qos.logback:logback-classic:1.5.18'
}
```

### Database Setup

DBOS requires PostgreSQL. Set up with Docker:

```shell
docker run -d \
  --name dbos-postgres \
  -e POSTGRES_PASSWORD=dbos \
  -p 5432:5432 \
  postgres:17
```

### Environment Variables

```shell
export PGUSER=postgres
export PGPASSWORD=dbos
export DBOS_SYSTEM_JDBC_URL=jdbc:postgresql://localhost:5432/myapp
```

### Build and Run

```shell
./gradlew assemble
./gradlew run
```

---

## Workflows and Steps

Workflows provide **durable execution** so programs are **resilient to any failure**. If a workflow is interrupted (executor restarts, crashes, etc.), it automatically resumes from the last completed step.

### Core Pattern

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

        // Call workflow through proxy
        String result = proxy.checkoutWorkflow("user123", 99.99);
    }
}
```

### Using Lambda Steps with DBOS.runStep

For one-time steps, use lambdas:

```java
@Workflow(name = "workflowWithLambdaSteps")
public String workflowFunction(String input) {
    // Run a lambda as a checkpointed step
    int randomNumber = DBOS.runStep(
        () -> new Random().nextInt(100),
        "generateRandom"
    );

    String apiResult = DBOS.runStep(
        () -> fetchFromApi(input),
        "fetchFromApi"
    );

    return apiResult + "-" + randomNumber;
}
```

### Step Options with Retries

```java
import dev.dbos.transact.workflow.StepOptions;

@Workflow(name = "fetchWorkflow")
public String fetchWorkflow(String url) throws Exception {
    return DBOS.runStep(
        () -> fetchStep(url),
        new StepOptions("fetchStep")
            .withRetriesAllowed(true)
            .withMaxAttempts(10)
            .withIntervalSeconds(0.5)
            .withBackoffRate(2.0)
    );
}
```

### @Step Annotation

```java
public @interface Step {
    String name();  // Required: unique name for the step
}
```

### @Workflow Annotation

```java
public @interface Workflow {
    String name();               // Required: unique workflow name
    int maxRecoveryAttempts();   // Optional: max recovery attempts before dead letter
}
```

---

## Workflow Registration

All workflows must be registered before `DBOS.launch()`.

### Basic Registration

```java
static <T> T registerWorkflows(Class<T> interfaceClass, T implementation)
```

```java
Checkout proxy = DBOS.registerWorkflows(Checkout.class, new CheckoutImpl());
```

### Named Instance Registration

Use when creating multiple instances of the same class:

```java
static <T> T registerWorkflows(Class<T> interfaceClass, T implementation, String instanceName)
```

```java
Checkout highPriority = DBOS.registerWorkflows(Checkout.class, new CheckoutImpl(highConfig), "high-priority");
Checkout lowPriority = DBOS.registerWorkflows(Checkout.class, new CheckoutImpl(lowConfig), "low-priority");
```

---

## Starting Workflows

### Direct Invocation

```java
// Runs synchronously, waits for result
String result = proxy.checkoutWorkflow("user123", 99.99);
```

### Background Execution

```java
import dev.dbos.transact.StartWorkflowOptions;
import dev.dbos.transact.workflow.WorkflowHandle;

// Start in background, get handle
WorkflowHandle<String, Exception> handle = DBOS.startWorkflow(
    () -> proxy.checkoutWorkflow("user123", 99.99),
    new StartWorkflowOptions()
);

// Wait for result
String result = handle.getResult();
```

### With Workflow ID (Idempotency)

```java
String orderId = "order-12345";
WorkflowHandle<String, Exception> handle = DBOS.startWorkflow(
    () -> proxy.checkoutWorkflow("user123", 99.99),
    new StartWorkflowOptions().withWorkflowId(orderId)
);
```

### With Timeout

```java
import java.time.Duration;

WorkflowHandle<Void, InterruptedException> handle = DBOS.startWorkflow(
    () -> proxy.longRunningWorkflow(),
    new StartWorkflowOptions().withTimeout(Duration.ofHours(12))
);
```

### StartWorkflowOptions Methods

- `withWorkflowId(String)` - Set idempotency key
- `withQueue(Queue)` - Enqueue on a queue
- `withTimeout(Duration)` - Set workflow timeout
- `withDeduplicationId(String)` - Queue deduplication (requires queue)
- `withPriority(int)` - Queue priority (requires queue with priority enabled)

---

## Queues

Control concurrency and rate limiting for workflows.

### Basic Queue Usage

```java
import dev.dbos.transact.workflow.Queue;

Queue queue = new Queue("task_queue");
DBOS.registerQueue(queue);

// Enqueue workflow
WorkflowHandle<String, Exception> handle = DBOS.startWorkflow(
    () -> proxy.taskWorkflow(task),
    new StartWorkflowOptions().withQueue(queue)
);
```

### Worker Concurrency

Limit concurrent workflows per process:

```java
Queue queue = new Queue("example_queue")
    .withWorkerConcurrency(5);  // Max 5 per process
DBOS.registerQueue(queue);
```

### Global Concurrency

Limit across all processes:

```java
Queue queue = new Queue("example_queue")
    .withConcurrency(10);  // Max 10 total
DBOS.registerQueue(queue);
```

### Rate Limiting

```java
Queue queue = new Queue("rate_limited_queue")
    .withRateLimit(100, 60.0);  // 100 workflows per 60 seconds
DBOS.registerQueue(queue);
```

### Priority

```java
Queue queue = new Queue("priority_queue")
    .withPriorityEnabled(true);
DBOS.registerQueue(queue);

// Lower number = higher priority (1 is highest)
DBOS.startWorkflow(
    () -> proxy.urgentTask(),
    new StartWorkflowOptions().withQueue(queue).withPriority(1)
);

DBOS.startWorkflow(
    () -> proxy.normalTask(),
    new StartWorkflowOptions().withQueue(queue).withPriority(100)
);
```

### Deduplication

```java
// Only one workflow with this dedup ID can be enqueued at a time
DBOS.startWorkflow(
    () -> proxy.userTask(task),
    new StartWorkflowOptions()
        .withQueue(queue)
        .withDeduplicationId("user-" + userId)
);
```

### External Enqueuing with DBOSClient

```java
import dev.dbos.transact.DBOSClient;

DBOSClient client = new DBOSClient(dbUrl, dbUser, dbPassword);

DBOSClient.EnqueueOptions options = new DBOSClient.EnqueueOptions(
    "com.example.CheckoutImpl",  // Class name
    "checkoutWorkflow",          // Workflow name
    "task_queue"                 // Queue name
);

WorkflowHandle<String, Exception> handle = client.enqueueWorkflow(
    options,
    new Object[]{"user123", 99.99}  // Arguments
);
```

---

## Scheduled Workflows

Run workflows on a cron schedule.

```java
import dev.dbos.transact.workflow.Scheduled;
import java.time.Instant;

class ScheduledJobsImpl implements ScheduledJobs {

    @Workflow
    @Scheduled(cron = "0 * * * * *")  // Every minute
    public void everyMinute(Instant scheduled, Instant actual) {
        DBOS.logger.info("Scheduled: " + scheduled + ", Actual: " + actual);
        // Perform scheduled task
    }

    @Workflow
    @Scheduled(cron = "0 0 * * *")  // Daily at midnight
    public void dailyCleanup(Instant scheduled, Instant actual) {
        performCleanup();
    }
}
```

**Important:** Scheduled workflows MUST take two `Instant` arguments: scheduled time and actual start time.

### Crontab Examples

- `0 * * * * *` - Every minute
- `0 0 * * * *` - Every hour
- `0 0 0 * * *` - Daily at midnight
- `0 0 0 * * 0` - Weekly on Sunday

---

## Workflow Communication

### Send/Receive Messages

```java
// Send message to a workflow (from anywhere)
DBOS.send(workflowId, "approved", "payment-topic");

// Receive in workflow
@Workflow(name = "paymentWorkflow")
public void paymentWorkflow() {
    String status = (String) DBOS.recv("payment-topic", Duration.ofMinutes(5));
    if (status != null && status.equals("approved")) {
        processPayment();
    } else {
        handleTimeout();
    }
}
```

### Webhook Pattern

```java
// Workflow waits for external notification
@Workflow(name = "checkout-workflow")
public void checkoutWorkflow() {
    String paymentStatus = (String) DBOS.recv("payment_status", Duration.ofSeconds(60));
    if (paymentStatus != null && paymentStatus.equals("paid")) {
        handleSuccessfulPayment();
    } else {
        handleFailedPayment();
    }
}

// Webhook endpoint (e.g., with Javalin)
app.post("/payment_webhook/{workflow_id}/{payment_status}", ctx -> {
    String workflowId = ctx.pathParam("workflow_id");
    String paymentStatus = ctx.pathParam("payment_status");
    DBOS.send(workflowId, paymentStatus, "payment_status");
    ctx.result("Payment status sent");
});
```

---

## Workflow Events

Publish key-value pairs from workflows for clients to read.

### Set Event

```java
@Workflow(name = "checkout-workflow")
public void checkoutWorkflow() {
    String paymentId = generatePaymentId();
    DBOS.setEvent("payment_id", paymentId);  // Publish for client

    // Continue processing...
}
```

### Get Event

```java
// Start workflow and wait for event
WorkflowHandle<Void, RuntimeException> handle = DBOS.startWorkflow(
    () -> checkoutProxy.checkoutWorkflow(),
    new StartWorkflowOptions().withWorkflowId(idempotencyKey)
);

String paymentId = (String) DBOS.getEvent(
    handle.workflowId(),
    "payment_id",
    Duration.ofSeconds(60)
);

if (paymentId != null) {
    return paymentId;
} else {
    throw new RuntimeException("Checkout failed to start");
}
```

---

## Workflow Handles

### Getting a Handle

```java
// From startWorkflow
WorkflowHandle<String, Exception> handle = DBOS.startWorkflow(
    () -> proxy.myWorkflow(args),
    new StartWorkflowOptions()
);

// Retrieve by ID
WorkflowHandle<String, Exception> handle = DBOS.retrieveWorkflow(workflowId);
```

### Handle Methods

```java
String workflowId = handle.workflowId();      // Get workflow ID
String result = handle.getResult();            // Wait for and get result
WorkflowStatus status = handle.getStatus();    // Get status object
```

### WorkflowStatus

```java
public record WorkflowStatus(
    String workflowId,
    String status,           // ENQUEUED, PENDING, SUCCESS, ERROR, CANCELLED, MAX_RECOVERY_ATTEMPTS_EXCEEDED
    String name,             // Workflow function name
    String className,        // Workflow class name
    String instanceName,     // Named instance, if any
    Object[] input,          // Deserialized workflow inputs
    Object output,           // Workflow output, if any
    ErrorResult error,       // Error, if any
    Long createdAt,          // Unix epoch ms
    Long updatedAt,          // Unix epoch ms
    String queueName,        // Queue name, if enqueued
    String executorId,       // Executor process ID
    String appVersion,       // Application version
    Long workflowTimeoutMs,  // Timeout, if set
    Long workflowDeadlineEpochMs,
    Integer recoveryAttempts
)
```

---

## Workflow Management

### List Workflows

```java
import dev.dbos.transact.ListWorkflowsInput;

List<WorkflowStatus> workflows = DBOS.listWorkflows(
    new ListWorkflowsInput()
        .withWorkflowName("checkoutWorkflow")
        .withStatus("PENDING")
        .withLimit(100)
);
```

### ListWorkflowsInput Methods

- `withWorkflowId(String)` / `withWorkflowIds(List<String>)` - Filter by ID(s)
- `withClassName(String)` - Filter by class name
- `withWorkflowName(String)` - Filter by workflow name
- `withStatus(String)` / `withStatuses(List<String>)` - Filter by status
- `withStartTime(OffsetDateTime)` - Workflows started after this time
- `withEndTime(OffsetDateTime)` - Workflows started before this time
- `withLimit(Integer)` - Max results
- `withOffset(Integer)` - Skip results (pagination)
- `withSortDesc(Boolean)` - Sort order
- `withQueueName(String)` - Filter by queue
- `withLoadInput(Boolean)` - Load workflow input data
- `withLoadOutput(Boolean)` - Load workflow output data

### List Workflow Steps

```java
List<StepInfo> steps = DBOS.listWorkflowSteps(workflowId);

// StepInfo contains:
// - functionId: Sequential step ID
// - functionName: Step name
// - output: Step output
// - error: Step error
// - childWorkflowId: Child workflow ID, if any
```

### Cancel Workflow

```java
DBOS.cancelWorkflow(workflowId);
// Sets status to CANCELLED, removes from queue, preempts at next step
```

### Resume Workflow

```java
WorkflowHandle<String, Exception> handle = DBOS.resumeWorkflow(workflowId);
// Resumes cancelled or failed workflow from last completed step
```

### Fork Workflow

```java
import dev.dbos.transact.ForkOptions;

// Restart from a specific step (useful for fixing bugs)
WorkflowHandle<String, Exception> handle = DBOS.forkWorkflow(
    workflowId,
    3,  // Start from step 3
    new ForkOptions()
        .withForkedWorkflowId("new-workflow-id")
        .withApplicationVersion("v2.0")
);
```

---

## Configuration

### Basic Configuration

```java
import dev.dbos.transact.config.DBOSConfig;
import org.slf4j.LoggerFactory;
import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;

public static void main(String[] args) throws Exception {
    Logger root = (Logger) LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME);
    root.setLevel(Level.INFO);

    DBOSConfig config = DBOSConfig.defaults("my-app")
        .withDatabaseUrl(System.getenv("DBOS_SYSTEM_JDBC_URL"))
        .withDbUser(System.getenv("PGUSER"))
        .withDbPassword(System.getenv("PGPASSWORD"));

    DBOS.configure(config);

    // Register workflows and queues here
    MyApp proxy = DBOS.registerWorkflows(MyApp.class, new MyAppImpl());

    DBOS.launch();
}
```

### DBOSConfig Methods

- `withAppName(String)` - Application name (required)
- `withDatabaseUrl(String)` - JDBC URL for system database (required)
- `withDbUser(String)` - Database username (required)
- `withDbPassword(String)` - Database password (required)
- `withMaximumPoolSize(int)` - Connection pool size
- `withConnectionTimeout(int)` - Connection timeout
- `withAdminServer(boolean)` - Enable HTTP admin server
- `withAdminServerPort(int)` - Admin server port (default: 3001)
- `withMigrate(boolean)` - Auto-apply migrations (default: true)
- `withConductorKey(String)` - DBOS Conductor API key
- `withAppVersion(String)` - Application version for workflow versioning

---

## Spring Boot Integration

### DBOSLifecycle Component

```java
import org.springframework.context.SmartLifecycle;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;

import dev.dbos.transact.DBOS;
import dev.dbos.transact.config.DBOSConfig;

import java.util.Objects;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component
@Lazy(false)
public class DBOSLifecycle implements SmartLifecycle {

    private static final Logger log = LoggerFactory.getLogger(DBOSLifecycle.class);
    private volatile boolean running = false;

    @Override
    public void start() {
        String databaseUrl = System.getenv("DBOS_SYSTEM_JDBC_URL");
        if (databaseUrl == null || databaseUrl.isEmpty()) {
            databaseUrl = "jdbc:postgresql://localhost:5432/myapp";
        }

        var config = DBOSConfig.defaults("my-spring-app")
            .withDatabaseUrl(databaseUrl)
            .withDbUser(Objects.requireNonNullElse(System.getenv("PGUSER"), "postgres"))
            .withDbPassword(Objects.requireNonNullElse(System.getenv("PGPASSWORD"), "dbos"))
            .withAdminServer(true)
            .withAdminServerPort(3001);

        DBOS.configure(config);
        log.info("Launch DBOS");
        DBOS.launch();
        running = true;
    }

    @Override
    public void stop() {
        log.info("Shut Down DBOS");
        try {
            DBOS.shutdown();
        } finally {
            running = false;
        }
    }

    @Override public boolean isRunning() { return running; }
    @Override public boolean isAutoStartup() { return true; }
    @Override public int getPhase() { return -1; }  // Start before web server
}
```

### Workflow Bean Configuration

```java
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import dev.dbos.transact.DBOS;

@Configuration
public class DBOSAppConfig {

    @Bean
    @Primary
    public MyAppService myAppService() {
        var impl = new MyAppServiceImpl();
        return DBOS.registerWorkflows(MyAppService.class, impl);
    }
}
```

---

## Durable Sleep

Sleep that survives restarts:

```java
@Workflow(name = "delayedTask")
public String delayedTask(String task) throws InterruptedException {
    // Sleep for 1 hour - survives restarts
    DBOS.sleep(Duration.ofHours(1));

    return DBOS.runStep(() -> executeTask(task), "executeTask");
}
```

---

## Determinism Rules

Workflow methods must be **deterministic**. Do NOT perform these operations directly in workflows:

- API calls / external services
- Database access
- Random number generation
- Getting current time
- File I/O
- Threading / concurrency APIs

**Wrong:**

```java
@Workflow(name = "badWorkflow")
public String badWorkflow() {
    int choice = new Random().nextInt(2);  // Non-deterministic!
    if (choice == 0) {
        return DBOS.runStep(() -> stepOne(), "stepOne");
    } else {
        return DBOS.runStep(() -> stepTwo(), "stepTwo");
    }
}
```

**Correct:**

```java
@Workflow(name = "goodWorkflow")
public String goodWorkflow() {
    int choice = DBOS.runStep(() -> new Random().nextInt(2), "generateChoice");
    if (choice == 0) {
        return DBOS.runStep(() -> stepOne(), "stepOne");
    } else {
        return DBOS.runStep(() -> stepTwo(), "stepTwo");
    }
}
```

---

## DBOS Context Variables

```java
DBOS.workflowId();  // Current workflow ID (null if not in workflow)
DBOS.stepId();      // Current step ID (null if not in step)
DBOS.inWorkflow();  // true if in workflow context
DBOS.inStep();      // true if in step context
```

---

## Serialization Requirements

Workflow arguments and step/workflow return values are serialized as JSON using Jackson. Use annotations when needed:

```java
import com.fasterxml.jackson.annotation.JsonProperty;

public class MyData {
    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    private String id;

    // ... getters and setters
}
```

---

## Required Imports

```java
import dev.dbos.transact.DBOS;
import dev.dbos.transact.DBOSClient;
import dev.dbos.transact.ForkOptions;
import dev.dbos.transact.ListWorkflowsInput;
import dev.dbos.transact.StartWorkflowOptions;
import dev.dbos.transact.config.DBOSConfig;
import dev.dbos.transact.workflow.Queue;
import dev.dbos.transact.workflow.Scheduled;
import dev.dbos.transact.workflow.Step;
import dev.dbos.transact.workflow.StepOptions;
import dev.dbos.transact.workflow.Timeout;
import dev.dbos.transact.workflow.Workflow;
import dev.dbos.transact.workflow.WorkflowHandle;
import dev.dbos.transact.workflow.WorkflowState;
import dev.dbos.transact.workflow.WorkflowStatus;
```
