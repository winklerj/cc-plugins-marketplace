---
description: Manage issue dependencies
allowed-tools: Bash(bd:*)
argument-hint: <add|remove|tree|cycles> [issue-ids] [--type type]
---

Manage dependencies between issues in the beads issue tracker.

## Subcommands

- `add`: Add a dependency between two issues
- `remove`: Remove a dependency
- `tree`: Visualize dependency tree
- `cycles`: Detect circular dependencies

## Add Dependency

```
add <blocker-id> <blocked-id> [--type type]
```

Creates a dependency where `blocker-id` must be completed before `blocked-id` can be worked on.

### Dependency Types

- `blocks` (default): Blocker must complete before blocked can start
- `related`: Issues are related but not blocking
- `parent`: Parent-child relationship (blocker is parent)
- `discovered-from`: New issue discovered while working on another

### Examples

```
/beads:dep add bd-a1b2 bd-f14c
/beads:dep add bd-a1b2 bd-f14c --type blocks
/beads:dep add bd-a1b2 bd-f14c --type parent
/beads:dep add bd-a1b2 bd-f14c --type discovered-from
/beads:dep add bd-a1b2 bd-f14c --type related
```

## Remove Dependency

```
remove <blocker-id> <blocked-id>
```

Removes the dependency between two issues.

### Examples

```
/beads:dep remove bd-a1b2 bd-f14c
```

## Visualize Dependency Tree

```
tree <issue-id>
```

Shows a visual tree of all dependencies for an issue.

### Examples

```
/beads:dep tree bd-a1b2
```

Output:
```
bd-a1b2: Implement authentication
├── bd-f14c: Setup database [blocks]
│   └── bd-3e7a: Install PostgreSQL [blocks]
└── bd-9b8d: Create user model [blocks]
```

## Detect Circular Dependencies

```
cycles
```

Scans the entire project for circular dependencies (which would create deadlocks).

### Examples

```
/beads:dep cycles
```

Output:
```
Found 1 circular dependency:
bd-a1b2 → bd-f14c → bd-3e7a → bd-a1b2
```

## Understanding Dependency Types

### blocks (Default)
Issue A blocks issue B means:
- B cannot be started until A is completed
- B will show as "blocked" in status
- B won't appear in `bd ready` until A is closed

Example:
```
"Setup database" blocks "Create user model"
```

### related
Issues are connected but neither blocks the other:
- Both can be worked on independently
- Useful for tracking related work
- Doesn't affect ready status

Example:
```
"Frontend login" related to "Backend auth"
```

### parent (Parent-Child)
Hierarchical relationship:
- Parent encompasses child issues
- Child issues are sub-tasks of parent
- Useful for breaking down large features

Example:
```
"User authentication" parent of "Login UI"
"User authentication" parent of "JWT tokens"
```

### discovered-from
New issue found while working on another:
- Tracks where issues were discovered
- Useful for understanding work expansion
- Doesn't block work

Example:
```
"Fix memory leak" discovered from "Optimize performance"
```

## Agent Workflow

### When Starting Work

1. **Check dependencies before starting**:
   ```
   bd dep tree <issue-id>
   ```

2. **If blockers exist**:
   - Work on blockers first
   - Or remove unnecessary dependencies

### When Discovering New Work

1. **Create the new issue**:
   ```
   /beads:create "Fix security vulnerability" -t bug -p 1
   ```

2. **Link to current work**:
   ```
   /beads:dep add <current-issue-id> <new-issue-id> --type discovered-from
   ```

3. **Determine if it blocks current work**:
   ```
   /beads:dep add <new-issue-id> <current-issue-id> --type blocks
   ```

### When Breaking Down Work

1. **Create parent issue**:
   ```
   /beads:create "User authentication system" -t feature
   ```

2. **Create child issues**:
   ```
   /beads:create "Login UI" -t task
   /beads:create "JWT implementation" -t task
   /beads:create "Password hashing" -t task
   ```

3. **Link as parent-child**:
   ```
   /beads:dep add bd-parent bd-child1 --type parent
   /beads:dep add bd-parent bd-child2 --type parent
   /beads:dep add bd-parent bd-child3 --type parent
   ```

## Best Practices

1. **Keep dependency chains short**: Avoid deep nesting
2. **Use appropriate types**: Choose the right dependency type
3. **Document why**: Add comments explaining dependencies
4. **Check for cycles**: Run `cycles` regularly
5. **Review regularly**: Update dependencies as work progresses

## Error Handling

If dependency operations fail:
- Verify both issue IDs exist
- Check for circular dependencies (add operation)
- Ensure dependency type is valid
- Check if dependency already exists (add)
- Verify dependency exists (remove)

## Notes

- Dependencies automatically affect `bd ready` output
- Closing an issue may unblock other issues
- Use `bd blocked` to see all blocked issues
- Dependency changes sync to git automatically
- Cycles create deadlocks and should be resolved immediately
- Multiple issues can depend on the same blocker
- An issue can have multiple blockers (all must be resolved)

## Execution

```bash
bd dep $ARGUMENTS
```
