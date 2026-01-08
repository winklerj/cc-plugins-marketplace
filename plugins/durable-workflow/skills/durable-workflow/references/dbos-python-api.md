# DBOS Python API Reference

## Table of Contents

1. [Queues](#queues)
2. [Scheduled Workflows](#scheduled-workflows)
3. [Workflow Communication](#workflow-communication)
4. [Workflow Events](#workflow-events)
5. [Workflow Streaming](#workflow-streaming)
6. [Debouncing](#debouncing)
7. [Async Workflows](#async-workflows)
8. [Transactions](#transactions)
9. [Workflow Handles](#workflow-handles)
10. [Workflow Management](#workflow-management)
11. [Configuration](#configuration)
12. [Class-Based Workflows](#class-based-workflows)

---

## Queues

Use queues to run many workflows with managed concurrency.

### Basic Queue Usage

```python
from dbos import DBOS, Queue

queue = Queue("example_queue")

@DBOS.workflow()
def process_task(task):
    # ...
    pass

# Enqueue workflow
handle = queue.enqueue(process_task, task)
result = handle.get_result()
```

### Queue with Concurrency Limits

```python
# Worker concurrency: max 5 concurrent per process
queue = Queue("example_queue", worker_concurrency=5)

# Global concurrency: max 10 concurrent across all processes
queue = Queue("example_queue", concurrency=10)

# In-order processing: one at a time
serial_queue = Queue("serial_queue", concurrency=1)
```

### Rate Limiting

```python
# Max 50 workflows per 30 seconds
queue = Queue("rate_limited", limiter={"limit": 50, "period": 30})
```

### Parallel Task Processing with Queues

```python
queue = Queue("parallel_queue")

@DBOS.workflow()
def process_task(task):
    pass

@DBOS.workflow()
def parallel_processor(tasks):
    handles = []
    for task in tasks:
        handle = queue.enqueue(process_task, task)
        handles.append(handle)
    return [h.get_result() for h in handles]
```

### Queue Partitioning

```python
from dbos import SetEnqueueOptions

# Partition by user ID - each user gets max 1 concurrent task
queue = Queue("user_queue", partition_queue=True, concurrency=1)

def on_user_task(user_id: str, task):
    with SetEnqueueOptions(queue_partition_key=user_id):
        queue.enqueue(task_workflow, task)
```

### Deduplication

```python
from dbos import SetEnqueueOptions
from dbos import error as dboserror

# Only one workflow with this dedup ID can be enqueued at a time
with SetEnqueueOptions(deduplication_id=f"user-{user_id}"):
    try:
        handle = queue.enqueue(task_workflow, task)
    except dboserror.DBOSQueueDeduplicatedError:
        # Handle deduplication error
        pass
```

### Priority

```python
queue = Queue("priority_queue", priority_enabled=True)

# Lower number = higher priority (1 is highest)
with SetEnqueueOptions(priority=1):  # High priority
    queue.enqueue(task_workflow, urgent_task)

with SetEnqueueOptions(priority=100):  # Low priority
    queue.enqueue(task_workflow, normal_task)
```

### Queue Timeouts

```python
from dbos import SetWorkflowTimeout

with SetWorkflowTimeout(60):  # 60 second timeout
    queue.enqueue(task_workflow, task)
```

---

## Scheduled Workflows

Run workflows on a schedule using crontab syntax.

```python
@DBOS.scheduled("0 0 * * *")  # Daily at midnight
@DBOS.workflow()
def daily_cleanup(scheduled_time, actual_time):
    DBOS.logger.info(f"Scheduled at {scheduled_time}, started at {actual_time}")
    perform_cleanup()
```

### Crontab Examples
- `* * * * *` - Every minute
- `0 * * * *` - Every hour
- `0 0 * * *` - Daily at midnight
- `0 0 * * 0` - Weekly on Sunday

### Scheduled-Only App (No HTTP Server)

```python
import threading

if __name__ == "__main__":
    DBOS.launch()
    threading.Event().wait()  # Block forever
```

Or with asyncio:

```python
import asyncio

async def main():
    DBOS.launch()
    await asyncio.Event().wait()

if __name__ == "__main__":
    asyncio.run(main())
```

---

## Workflow Communication

### Send/Receive Messages

```python
# Sender (from anywhere)
DBOS.send(workflow_id, {"status": "approved"}, "payment-topic")

# Receiver (in workflow)
@DBOS.workflow()
def payment_workflow():
    notification = DBOS.recv("payment-topic", timeout_seconds=300)  # 5 min
    if notification and notification["status"] == "approved":
        process_payment()
```

### Webhook Pattern

```python
# Workflow waits for external notification
@DBOS.workflow()
def order_workflow(order_id: str):
    submit_order(order_id)
    confirmation = DBOS.recv("order-confirmed", timeout_seconds=3600)
    if not confirmation:
        handle_timeout(order_id)
    return confirmation

# Webhook endpoint sends notification
@app.post("/webhook/order-confirmed/{workflow_id}/{status}")
def payment_webhook(workflow_id: str, status: str):
    DBOS.send(workflow_id, status, "order-confirmed")
```

---

## Workflow Events

Publish key-value pairs from workflows for clients to read.

### Set Event

```python
@DBOS.workflow()
def checkout_workflow(order_id: str):
    payment_url = get_payment_url(order_id)
    DBOS.set_event("payment-url", payment_url)  # Publish for client
    paid = DBOS.recv("payment-complete", timeout_seconds=600)
    # ...
```

### Get Event

```python
# Client waits for event
handle = DBOS.start_workflow(checkout_workflow, order_id)
payment_url = DBOS.get_event(handle.get_workflow_id(), "payment-url", timeout_seconds=30)
if payment_url:
    return RedirectResponse(payment_url)
```

### Get All Events

```python
events = DBOS.get_all_events(workflow_id)
# Returns Dict[str, Any] with all events
```

---

## Workflow Streaming

Stream data in real-time from workflows to clients.

### Write to Stream

```python
@DBOS.workflow()
def processing_workflow(items):
    for item in items:
        result = process_item(item)
        DBOS.write_stream("progress", {"item": item, "result": result})
    DBOS.close_stream("progress")
```

### Read from Stream

```python
handle = DBOS.start_workflow(processing_workflow, items)

for value in DBOS.read_stream(handle.get_workflow_id(), "progress"):
    print(f"Received: {value}")
```

---

## Debouncing

Delay workflow execution until input stops arriving.

```python
from dbos import Debouncer

@DBOS.workflow()
def process_input(user_input: str):
    analyze_input(user_input)

debouncer = Debouncer.create(process_input)

def on_user_input(user_id: str, user_input: str):
    # Delays 60 seconds; uses last input if debounced multiple times
    debouncer.debounce(user_id, 60, user_input)
```

### Debouncer with Timeout

```python
debouncer = Debouncer.create(
    process_input,
    debounce_timeout_sec=300,  # Max 5 minutes from first call
    queue=my_queue  # Optional: enqueue instead of direct execution
)
```

### Async Debouncer

```python
debouncer = Debouncer.create_async(async_workflow)
await debouncer.debounce_async(key, period_sec, *args)
```

---

## Async Workflows

Coroutines (async functions) can be DBOS workflows.

```python
import aiohttp
import asyncio

@DBOS.step()
async def fetch_url():
    async with aiohttp.ClientSession() as session:
        async with session.get("https://example.com") as response:
            return await response.text()

@DBOS.workflow()
async def async_workflow():
    await DBOS.sleep_async(10)
    body = await fetch_url()
    # For transactions, use asyncio.to_thread
    result = await asyncio.to_thread(sync_transaction, body)
    return result

# Start async workflow
handle = await DBOS.start_workflow_async(async_workflow)

# Async communication methods
await DBOS.send_async(workflow_id, message, topic)
message = await DBOS.recv_async(topic, timeout_seconds)
await DBOS.set_event_async(key, value)
value = await DBOS.get_event_async(workflow_id, key, timeout_seconds)
```

**Note:** DBOS does not support async transactions. Use `asyncio.to_thread` for database operations.

---

## Transactions

Transactions are optimized database steps. ONLY use with Postgres and when specifically requested.

```python
from sqlalchemy import Table, Column, String, MetaData, select, text

greetings = Table(
    "greetings",
    MetaData(),
    Column("name", String),
    Column("note", String)
)

@DBOS.transaction()
def insert_greeting(name: str, note: str):
    DBOS.sql_session.execute(greetings.insert().values(name=name, note=note))

@DBOS.transaction()
def get_greeting(name: str):
    row = DBOS.sql_session.execute(
        select(greetings.c.note).where(greetings.c.name == name)
    ).first()
    return row[0] if row else None

# Raw SQL
@DBOS.transaction()
def raw_insert(name: str, note: str):
    sql = text("INSERT INTO greetings (name, note) VALUES (:name, :note)")
    DBOS.sql_session.execute(sql, {"name": name, "note": note})
```

**Important:** NEVER use `async def` for transactions.

---

## Workflow Handles

```python
handle = DBOS.start_workflow(my_workflow, arg1, arg2)
# Or from queue
handle = queue.enqueue(my_workflow, arg1, arg2)

handle.get_workflow_id()  # Get workflow ID
handle.get_result()       # Wait for and get result
handle.get_status()       # Get WorkflowStatus object
```

### WorkflowStatus

```python
class WorkflowStatus:
    workflow_id: str
    status: str  # ENQUEUED, PENDING, SUCCESS, ERROR, CANCELLED, MAX_RECOVERY_ATTEMPTS_EXCEEDED
    name: str
    recovery_attempts: int
    class_name: Optional[str]
    config_name: Optional[str]
    input: Optional[WorkflowInputs]
    output: Optional[Any]
    error: Optional[Exception]
    created_at: Optional[int]  # Unix epoch ms
    updated_at: Optional[int]
    queue_name: Optional[str]
    app_version: Optional[str]
```

---

## Workflow Management

### List Workflows

```python
workflows = DBOS.list_workflows(
    name="checkout_workflow",
    status="PENDING",
    start_time="2024-01-01T00:00:00Z",
    limit=100,
)
```

### List Queued Workflows

```python
queued = DBOS.list_queued_workflows(
    queue_name="payment_queue",
    status="ENQUEUED",
)
```

### List Workflow Steps

```python
steps = DBOS.list_workflow_steps(workflow_id)
# Returns List[StepInfo] with function_id, function_name, output, error, child_workflow_id
```

### Cancel Workflow

```python
DBOS.cancel_workflow(workflow_id)
# Sets status to CANCELLED, removes from queue, preempts at next step
```

### Resume Workflow

```python
handle = DBOS.resume_workflow(workflow_id)
# Resumes cancelled or failed workflow from last completed step
```

### Fork Workflow

```python
from dbos import SetWorkflowID

# Restart from a specific step (useful for fixing bugs)
with SetWorkflowID("new-workflow-id"):
    handle = DBOS.fork_workflow(workflow_id, start_step=3, application_version="v2.0")
```

---

## Configuration

```python
from dbos import DBOS, DBOSConfig

config: DBOSConfig = {
    "name": "my-app",
    "system_database_url": os.environ.get("DBOS_SYSTEM_DATABASE_URL"),
    "application_database_url": os.environ.get("DBOS_APP_DATABASE_URL"),  # For transactions
    "sys_db_pool_size": 20,
    "enable_otlp": False,
    "log_level": "INFO",
    "run_admin_server": True,
    "admin_port": 3001,
    "application_version": "1.0.0",
}
DBOS(config=config)
DBOS.launch()
```

### Database URLs

**PostgreSQL:**
```
postgresql://[username]:[password]@[hostname]:[port]/[database]
```

**SQLite (default if not specified):**
```
sqlite:///[path/to/database.sqlite]
```

### Custom Serialization

```python
from dbos import Serializer
import json

class JsonSerializer(Serializer):
    def serialize(self, data) -> str:
        return json.dumps(data)

    def deserialize(self, serialized_data: str):
        return json.loads(serialized_data)

config: DBOSConfig = {
    "name": "my-app",
    "serializer": JsonSerializer()
}
```

---

## Class-Based Workflows

Use when class instances need workflow methods. Avoid when possible.

```python
from dbos import DBOS, DBOSConfiguredInstance
import requests

@DBOS.dbos_class()
class URLFetcher(DBOSConfiguredInstance):
    def __init__(self, url: str):
        self.url = url
        super().__init__(config_name=url)  # Must be unique

    @DBOS.workflow()
    def fetch_workflow(self):
        return self.fetch_url()

    @DBOS.step()
    def fetch_url(self):
        return requests.get(self.url).text

# Must instantiate before DBOS.launch()
example_fetcher = URLFetcher("https://example.com")
DBOS.launch()

print(example_fetcher.fetch_workflow())
```

**Important:**
- `config_name` must be unique per instance
- All DBOS-decorated classes must be instantiated before `DBOS.launch()`

---

## Context Variables

```python
DBOS.workflow_id  # Current workflow ID (None if not in workflow)
DBOS.logger       # DBOS logger instance
DBOS.sql_session  # SQLAlchemy session (in transactions only)
```

---

## External Client

Interact with DBOS from outside your application:

```python
from dbos import DBOSClient, EnqueueOptions

client = DBOSClient(system_database_url=os.environ["DBOS_SYSTEM_DATABASE_URL"])

# Enqueue workflow
options: EnqueueOptions = {
    "queue_name": "pipeline_queue",
    "workflow_name": "data_pipeline",
}
handle = client.enqueue(options, task_arg)
result = handle.get_result()

# Retrieve existing workflow
handle = client.retrieve_workflow(workflow_id)
```
