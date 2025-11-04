# Beads Workflow Patterns

Detailed workflow guidance for complex scenarios and agent-specific operations.

## Table of Contents
- [Agent Workflow Patterns](#agent-workflow-patterns)
- [Breaking Down Complex Work](#breaking-down-complex-work)
- [Handling Blockers](#handling-blockers)
- [Multi-Issue Workflows](#multi-issue-workflows)
- [Status Management](#status-management)

## Agent Workflow Patterns

### Starting a Session with JSON
```bash
# Get ready work as structured data
/beads:ready --json

# Parse for highest priority
# Select issue and start
/beads:update <id> --status in_progress

# Check dependencies if needed
bd dep tree <id>
```

### Discovering Issues During Work
When you find new issues while working:

1. **Create immediately** (don't defer):
   ```
   /beads:create "Security vulnerability in auth" -t bug -p 1
   ```

2. **Link to current work** to track origin:
   ```
   /beads:dep add <current-issue-id> <new-issue-id> --type discovered-from
   ```

3. **Assess blocking status:**
   - If it must be fixed before proceeding:
     ```
     /beads:dep add <new-issue-id> <current-issue-id> --type blocks
     /beads:update <current-issue-id> --status blocked
     ```
   - If it's related but not blocking:
     ```
     /beads:dep add <current-issue-id> <new-issue-id> --type related
     ```

4. **Decide next action:**
   - Critical blocker: Switch to it immediately
   - Non-critical: Note it and continue current work
   - Can parallelize: Create both as independent tasks

### Completing Work and Finding Next Task
```bash
# 1. Verify work is complete
# 2. Close with detailed reason
/beads:close <id> --reason "Implemented JWT refresh tokens, added unit tests, verified in staging environment"

# 3. Check for newly unblocked work
/beads:ready

# 4. Select next highest priority
/beads:update <next-id> --status in_progress
```

## Breaking Down Complex Work

### Parent-Child Decomposition
For large features, use hierarchical breakdown:

```bash
# 1. Create parent feature
/beads:create "User Authentication System" -t feature -p 1
# Returns: bd-auth1

# 2. Create component sub-tasks
/beads:create "JWT token generation and validation" -t task -p 2
# Returns: bd-jwt2

/beads:create "Password hashing with bcrypt" -t task -p 2
# Returns: bd-pass3

/beads:create "Login/logout API endpoints" -t task -p 2
# Returns: bd-api4

# 3. Link as parent-child
/beads:dep add bd-auth1 bd-jwt2 --type parent
/beads:dep add bd-auth1 bd-pass3 --type parent
/beads:dep add bd-auth1 bd-api4 --type parent

# 4. Add blockers between children if needed
/beads:dep add bd-jwt2 bd-api4 --type blocks
```

**Benefits:**
- Work on children independently (if no blockers)
- Track progress on parent feature
- Clear project organization

## Handling Blockers

### When You Hit a Blocker

1. **Identify the blocker:**
   - Missing dependency/library
   - Blocked by another task
   - Need information/decision
   - Technical limitation

2. **Create blocker issue if it doesn't exist:**
   ```
   /beads:create "Setup PostgreSQL database connection" -t task -p 1
   ```

3. **Add dependency:**
   ```
   /beads:dep add <blocker-id> <current-id> --type blocks
   ```

4. **Update current issue:**
   ```
   /beads:update <current-id> --status blocked
   ```

5. **Choose next action:**
   - Work on blocker if possible
   - Find other ready work: `/beads:ready`
   - Request help/information

### Unblocking Work
When a blocker is resolved:

```bash
# 1. Close the blocker
/beads:close <blocker-id> --reason "Database connection configured and tested"

# 2. Check what became ready
/beads:ready

# 3. Previously blocked issues should now appear as ready
# 4. Resume work on unblocked issue
/beads:update <unblocked-id> --status in_progress
```

## Multi-Issue Workflows

### Working on Multiple Related Issues

When issues are related but can proceed in parallel:

```bash
# Link as related, not blocking
/beads:dep add <issue-1> <issue-2> --type related

# Both can be in_progress simultaneously
/beads:update <issue-1> --status in_progress
/beads:update <issue-2> --status in_progress
```

Use this for:
- Frontend and backend of same feature
- Documentation and implementation
- Related but independent components

### Batch Operations for Similar Issues

For multiple similar issues (e.g., bug fixes):

```bash
# Create issues
/beads:create "Fix login validation bug" -t bug -p 2 -l "auth,validation"
/beads:create "Fix signup validation bug" -t bug -p 2 -l "auth,validation"
/beads:create "Fix password reset validation" -t bug -p 2 -l "auth,validation"

# Work through them sequentially
# Filter to see all: /beads:list --labels auth,validation --status open
```

## Status Management

### Status Transitions

**Normal flow:**
```
open → in_progress → closed
```

**With blocker:**
```
open → in_progress → blocked → in_progress → closed
```

**Reopening:**
```
closed → open → in_progress → closed
```

### Best Practices

1. **Mark in_progress when you start** - Signals to other agents/developers
2. **Mark blocked immediately** - Prevents wasted effort
3. **Close with detailed reasons** - Creates valuable project history
4. **One in_progress at a time** - Focus and clarity (when possible)

### Handling Status Edge Cases

**Issue no longer needed:**
```
/beads:close <id> --reason "No longer needed - requirements changed"
```

**Duplicate issue:**
```
/beads:close <id> --reason "Duplicate of bd-other1 - closing in favor of that issue"
```

**Cannot reproduce bug:**
```
/beads:close <id> --reason "Cannot reproduce - need more information"
```

**Wrong approach:**
```
/beads:close <id> --reason "Closing in favor of alternative approach in bd-new2"
```

## Advanced Patterns

### Dependency Chain Planning

For complex dependency chains:

```bash
# 1. Visualize before adding
bd dep tree <issue-id>

# 2. Check for cycles after adding
bd dep cycles

# 3. If cycle detected, identify and break it
/beads:dep remove <id-1> <id-2>
```

### Using JSON for Automation

```bash
# Get all open issues as JSON
/beads:list --status open --json

# Get blocked issues
bd blocked --json

# Get ready work
/beads:ready --json

# Filter by priority
/beads:list --priority 1 --json
```

Parse JSON to:
- Select next work automatically
- Generate reports
- Monitor project health
- Integrate with other tools

### Project Health Checks

Regular checks to maintain project health:

```bash
# Check for circular dependencies
bd dep cycles

# View blocked issues
bd blocked

# Check high priority open work
/beads:list --priority 1 --status open

# View project statistics
bd stats
```

## Workflow Anti-Patterns to Avoid

❌ **Don't create issues without context** - Include descriptions and appropriate metadata

❌ **Don't leave status stale** - Update promptly when state changes

❌ **Don't create circular dependencies** - Check with `bd dep cycles`

❌ **Don't use wrong dependency types** - `blocks` means blocking, not just related

❌ **Don't close without reasons** - Detailed close reasons are project documentation

❌ **Don't nest dependencies too deep** - Keep chains short and manageable

✅ **Do check ready work first** - Before creating new issues

✅ **Do link discovered issues** - Track where work came from

✅ **Do break down large features** - Use parent-child relationships

✅ **Do update blockers immediately** - Prevent wasted effort

✅ **Do use JSON for automation** - Programmatic access enables powerful workflows
