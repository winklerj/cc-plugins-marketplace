# Beads Usage Examples

Concrete examples for common beads scenarios.

## Table of Contents
- [Simple Bug Tracking](#simple-bug-tracking)
- [Feature Development](#feature-development)
- [Discovering Issues During Development](#discovering-issues-during-development)
- [Handling Dependencies](#handling-dependencies)
- [Agent Automation](#agent-automation)

## Simple Bug Tracking

### Scenario: Report and Fix a Bug

```bash
# 1. Create bug report
/beads:create "Login fails with special characters in password" -d "Users cannot log in when password contains symbols like @, #, $" -t bug -p 1 -l "auth,critical"
# Returns: bd-a1b2

# 2. Start work
/beads:update bd-a1b2 --status in_progress

# 3. Implement fix, test, commit

# 4. Close with detailed reason
/beads:close bd-a1b2 --reason "Fixed password validation to properly escape special characters. Added unit tests for @#$%^&* symbols. Verified in staging."
```

### Scenario: Cannot Reproduce Bug

```bash
# User reports issue, but can't reproduce
/beads:create "App crashes on startup" -d "User reports crash, but no details provided" -t bug -p 2

# After investigation
/beads:close bd-c3d4 --reason "Cannot reproduce with current information. Need device details, OS version, and steps to reproduce. Closing until more info provided."
```

## Feature Development

### Scenario: Simple Feature Addition

```bash
# 1. Create feature issue
/beads:create "Add dark mode toggle to settings" -d "Users can switch between light and dark themes" -t feature -p 2 -l "ui,settings"
# Returns: bd-e5f6

# 2. Check if anything blocks it
/beads:ready

# 3. Start work
/beads:update bd-e5f6 --status in_progress

# 4. Implement, test, review

# 5. Close
/beads:close bd-e5f6 --reason "Dark mode toggle implemented in settings panel. Theme persists across sessions. Added tests for theme switching logic."
```

### Scenario: Large Feature with Breakdown

```bash
# 1. Create parent feature
/beads:create "Complete User Profile System" -t feature -p 1
# Returns: bd-prof1

# 2. Break into sub-tasks
/beads:create "Design profile data schema" -t task -p 1
# Returns: bd-sch2

/beads:create "Implement profile CRUD API" -t task -p 2
# Returns: bd-api3

/beads:create "Build profile UI components" -t task -p 2
# Returns: bd-ui4

/beads:create "Add profile image upload" -t task -p 3
# Returns: bd-img5

# 3. Link as parent-child
/beads:dep add bd-prof1 bd-sch2 --type parent
/beads:dep add bd-prof1 bd-api3 --type parent
/beads:dep add bd-prof1 bd-ui4 --type parent
/beads:dep add bd-prof1 bd-img5 --type parent

# 4. Add blocking dependencies
/beads:dep add bd-sch2 bd-api3 --type blocks  # API needs schema first
/beads:dep add bd-api3 bd-ui4 --type blocks   # UI needs API first

# 5. Start with ready work
/beads:ready
# Shows bd-sch2 as ready

/beads:update bd-sch2 --status in_progress
# Work on schema first, then API, then UI
```

## Discovering Issues During Development

### Scenario: Finding a Bug While Implementing Feature

```bash
# Currently working on bd-feat1
/beads:update bd-feat1 --status in_progress

# Discover a security vulnerability
/beads:create "SQL injection vulnerability in user search" -t bug -p 1 -l "security,critical"
# Returns: bd-vuln2

# Link to current work to track where it was found
/beads:dep add bd-feat1 bd-vuln2 --type discovered-from

# This is critical - it blocks the feature
/beads:dep add bd-vuln2 bd-feat1 --type blocks

# Mark feature as blocked
/beads:update bd-feat1 --status blocked

# Switch to vulnerability immediately
/beads:update bd-vuln2 --status in_progress

# Fix vulnerability first
/beads:close bd-vuln2 --reason "Fixed SQL injection by implementing parameterized queries. Added input validation. Security tested."

# Resume feature work
/beads:update bd-feat1 --status in_progress
```

### Scenario: Finding Related Work

```bash
# Working on backend API
/beads:update bd-api1 --status in_progress

# Realize documentation is needed
/beads:create "Document API endpoints for user service" -t docs -p 3
# Returns: bd-docs2

# Link as related (doesn't block API work)
/beads:dep add bd-api1 bd-docs2 --type related

# Mark as discovered from API work
/beads:dep add bd-api1 bd-docs2 --type discovered-from

# Continue API work - docs can be done later
```

## Handling Dependencies

### Scenario: Working Around a Blocker

```bash
# Need database migration to proceed
/beads:create "Run database migration for user preferences" -t task -p 1
# Returns: bd-mig1

# This blocks current feature
/beads:dep add bd-mig1 bd-feat2 --type blocks

# Can't do migration right now (needs DBA approval)
/beads:update bd-feat2 --status blocked

# Find other ready work instead
/beads:ready
# Shows other available issues

/beads:update bd-other3 --status in_progress
# Work on something else while waiting
```

### Scenario: Parallel Development

```bash
# Frontend and backend can be built in parallel
/beads:create "Build user dashboard backend API" -t task -p 2
# Returns: bd-back1

/beads:create "Build user dashboard frontend UI" -t task -p 2
# Returns: bd-front2

# Link as related (not blocking)
/beads:dep add bd-back1 bd-front2 --type related

# Both are ready - can work in parallel
/beads:update bd-back1 --status in_progress
/beads:update bd-front2 --status in_progress
```

## Agent Automation

### Scenario: Automated Work Selection

```bash
# Get ready work as JSON
/beads:ready --json

# Example response:
# {
#   "ready": [
#     {"id": "bd-a1b2", "priority": 1, "type": "bug", "title": "Critical auth bug"},
#     {"id": "bd-c3d4", "priority": 2, "type": "feature", "title": "Add export"},
#     {"id": "bd-e5f6", "priority": 1, "type": "bug", "title": "Data loss bug"}
#   ]
# }

# Agent logic: Select highest priority bug
# Selected: bd-a1b2

/beads:update bd-a1b2 --status in_progress

# Work on it...

/beads:close bd-a1b2 --reason "Fixed authentication token expiration issue. Added refresh token logic. All tests passing."

# Get next ready work
/beads:ready --json
```

### Scenario: Bulk Issue Creation from Discovery

```bash
# During code review, found multiple issues
/beads:create "Missing error handling in payment flow" -t bug -p 1 -l "payments,error-handling"
/beads:create "No retry logic for failed API calls" -t bug -p 2 -l "api,reliability"
/beads:create "Timeout values too aggressive" -t bug -p 3 -l "api,config"

# Link them as related
/beads:dep add bd-pay1 bd-api2 --type related
/beads:dep add bd-pay1 bd-time3 --type related
/beads:dep add bd-api2 bd-time3 --type related

# View all payment-related issues
/beads:list --labels payments --status open
```

### Scenario: Monitoring Project Health

```bash
# Check for blocked work
bd blocked
# Shows: 3 issues blocked

# Check for circular dependencies
bd dep cycles
# Shows: No cycles detected

# View high priority open work
/beads:list --priority 1 --status open
# Shows: 5 critical issues

# Check project statistics
bd stats
# Shows: 45 open, 12 in_progress, 8 blocked, 203 closed
```

## Real-World Complete Example

### Building Authentication System

```bash
# === PLANNING PHASE ===
# Create parent feature
/beads:create "Complete Authentication System" -t feature -p 1
# Returns: bd-auth1

# Break down into components
/beads:create "JWT token generation" -t task -p 1
# Returns: bd-jwt2

/beads:create "Password hashing with bcrypt" -t task -p 1
# Returns: bd-hash3

/beads:create "Login/logout endpoints" -t task -p 2
# Returns: bd-login4

/beads:create "Password reset flow" -t task -p 2
# Returns: bd-reset5

/beads:create "Session management" -t task -p 2
# Returns: bd-sess6

# Link hierarchy
/beads:dep add bd-auth1 bd-jwt2 --type parent
/beads:dep add bd-auth1 bd-hash3 --type parent
/beads:dep add bd-auth1 bd-login4 --type parent
/beads:dep add bd-auth1 bd-reset5 --type parent
/beads:dep add bd-auth1 bd-sess6 --type parent

# Add blocking dependencies
/beads:dep add bd-jwt2 bd-login4 --type blocks
/beads:dep add bd-hash3 bd-login4 --type blocks
/beads:dep add bd-login4 bd-sess6 --type blocks

# === EXECUTION PHASE ===
# Check what's ready
/beads:ready
# Shows: bd-jwt2, bd-hash3 (both no blockers)

# Start with JWT
/beads:update bd-jwt2 --status in_progress

# During implementation, discover security concern
/beads:create "Research JWT security best practices" -t task -p 1
# Returns: bd-sec7

/beads:dep add bd-jwt2 bd-sec7 --type discovered-from
/beads:dep add bd-sec7 bd-jwt2 --type blocks
/beads:update bd-jwt2 --status blocked

# Work on security research
/beads:update bd-sec7 --status in_progress
/beads:close bd-sec7 --reason "Researched JWT best practices. Documented requirements for token expiration, refresh tokens, and secure storage."

# Resume JWT work
/beads:update bd-jwt2 --status in_progress
/beads:close bd-jwt2 --reason "Implemented JWT generation with 15min access tokens and 7day refresh tokens. Following security best practices from bd-sec7."

# Password hashing (now ready, was already ready)
/beads:update bd-hash3 --status in_progress
/beads:close bd-hash3 --reason "Implemented bcrypt password hashing with salt rounds=12. Added password strength validation."

# Login endpoints (unblocked now)
/beads:ready
# Shows: bd-login4

/beads:update bd-login4 --status in_progress
/beads:close bd-login4 --reason "Implemented /login and /logout endpoints. Returns access and refresh tokens. Tested with Postman."

# Continue with remaining tasks...
```

This example shows:
- Parent-child breakdown
- Blocking dependencies
- Discovering issues during work
- Status management
- Detailed close reasons
- Natural workflow progression
