# Solve It: Concrete Examples

Real-world scenarios demonstrating Polya's method for software problems.

## Table of Contents
- [Simple Bug: Null Pointer Exception](#simple-bug-null-pointer-exception)
- [Complex Bug: Intermittent API Failures](#complex-bug-intermittent-api-failures)
- [Feature: Adding Search Functionality](#feature-adding-search-functionality)
- [Refactoring Decision: Monolith to Services](#refactoring-decision-monolith-to-services)
- [Performance: Slow Dashboard Loading](#performance-slow-dashboard-loading)

---

## Simple Bug: Null Pointer Exception

**Scenario:** Users report "TypeError: Cannot read property 'name' of undefined" when viewing their profile.

### Phase 1: Understand

- **Expected:** Profile page shows user's name
- **Actual:** Crashes with null pointer error
- **Reproduce:** Log in as new user, go to /profile
- **Key insight:** Error happens for NEW users specifically

### Phase 2: Plan

- **Hypothesis:** New users don't have a profile object yet
- **Check:** Look at user creation flow - is profile created?
- **Simplification:** Compare database records: old user vs new user

### Phase 3: Execute

```javascript
// Found the issue - profile is optional but not handled
const userName = user.profile.name; // crashes if profile is null

// Fix with optional chaining
const userName = user.profile?.name ?? 'New User';
```

### Phase 4: Look Back

- **Works?** Yes, tested with new and existing users
- **Simpler?** Could also initialize profile on user creation
- **Learning:** Always handle optional relationships
- **Diary:** `/solve-it:diary` - captured pattern for handling optional data

---

## Complex Bug: Intermittent API Failures

**Scenario:** Production alerts show 5% of API calls failing with timeout, but can't reproduce locally.

### Phase 1: Understand

- **Expected:** API calls complete in <500ms
- **Actual:** 5% timeout after 30 seconds
- **Reproduce:** Can't reproduce locally - only in production under load
- **Data collected:**
  - Happens across all endpoints
  - No pattern by user, time, or endpoint
  - Started after last deployment

### Phase 2: Plan

**Hypotheses (ranked):**
1. Connection pool exhaustion (deployment changed pool size?)
2. Database lock contention
3. External service slowdown
4. Memory pressure / GC pauses

**Investigation plan:**
- Compare deployment configs (what changed?)
- Add connection pool metrics
- Check database slow query logs
- Review memory usage graphs

### Phase 3: Execute

1. **Config diff:** Found connection pool reduced from 20 to 5 (accidental)
2. **Metrics confirmed:** Pool utilization at 100% during failures
3. **Fix:** Restored pool size to 20
4. **Validation:** Deployed to canary, failures dropped to 0%

### Phase 4: Look Back

- **Root cause:** Config change in deployment, not caught in review
- **Prevention:** Add alerting on connection pool utilization
- **Learning:** Always diff configs before and after deployment
- **Diary:** `/solve-it:diary` - documented the debugging process

---

## Feature: Adding Search Functionality

**Scenario:** Add search to an e-commerce product catalog (10K products).

### Phase 1: Understand

- **Goal:** Users can search products by name, description, category
- **Inputs:** Search query string, filters (category, price range)
- **Outputs:** Ranked list of matching products
- **Constraints:**
  - Results in <200ms
  - Must handle typos (fuzzy matching)
  - 10K products now, planning for 100K

### Phase 2: Plan

**Using beads to track the implementation:**

```
/beads:create "Product Search Feature" -t feature -p 1
# Returns: bd-srch1

/beads:create "Evaluate search solutions (Elasticsearch vs Algolia vs DB)" -t task -p 1
/beads:create "Implement search indexing" -t task -p 2
/beads:create "Build search API endpoint" -t task -p 2
/beads:create "Add search UI component" -t task -p 2
/beads:create "Write search integration tests" -t task -p 3

# Dependencies
/beads:dep add bd-srch1 bd-eval1 --type parent
/beads:dep add bd-eval1 bd-idx2 --type blocks  # Can't implement until decision made
```

**Decision:** PostgreSQL full-text search for now (10K products), plan migration path to Elasticsearch if needed.

### Phase 3: Execute

1. Spike on PostgreSQL full-text search - confirmed viable for 10K
2. Added tsvector column and GIN index
3. Built search API with ranking
4. Integrated UI with debounced input
5. Performance tested: 50ms average

```
/beads:close bd-srch1 --reason "Implemented PostgreSQL full-text search. 50ms average response time. Documented migration path to Elasticsearch in ADR-007."
```

### Phase 4: Look Back

- **Met requirements?** Yes, <200ms, handles basic typos
- **Simpler?** Could have used LIKE queries, but wouldn't scale
- **Future:** Document when to migrate to Elasticsearch
- **Diary:** `/solve-it:diary` - captured search architecture decision

---

## Refactoring Decision: Monolith to Services

**Scenario:** Team debates splitting the monolith. How to decide?

### Phase 1: Understand

- **Goal:** Determine if/how to split the monolith
- **Current state:** 200K LOC monolith, 10 developers, 2-week release cycles
- **Pain points:**
  - Slow CI (45 min builds)
  - Merge conflicts in shared code
  - One team's changes break another's features
- **Constraints:**
  - Can't stop feature development
  - Limited DevOps capacity

### Phase 2: Plan

**Reframe the question:**
- Not "should we use microservices?" but "what specific problems are we solving?"
- Slow builds → could use incremental builds, caching
- Merge conflicts → could use module boundaries within monolith
- Breaking changes → could add better testing, contracts

**Simplification:**
- What's the minimum change that addresses the biggest pain point?
- Can we modularize WITHOUT deploying separately first?

**Decision framework:**
1. Identify the most painful boundary
2. Extract to a module with clean interface
3. Add contract tests
4. THEN decide if separate deployment helps

### Phase 3: Execute

1. Identified payments as the clearest boundary
2. Created internal module with defined API
3. Added contract tests between payments and core
4. Build time for payments changes: 5 min (down from 45)
5. Deferred microservices decision - module approach working

### Phase 4: Look Back

- **Solved the problem?** Partially - builds faster for one team
- **Learning:** Module-first is lower risk than service-first
- **Next:** Extract two more modules, reassess
- **Diary:** `/solve-it:diary` - documented architectural decision and rationale

---

## Performance: Slow Dashboard Loading

**Scenario:** Dashboard takes 8 seconds to load, users complaining.

### Phase 1: Understand

- **Target:** Dashboard loads in <2 seconds
- **Current:** 8 seconds average, 15 seconds P95
- **Profile results:**
  - 6 API calls, all sequential
  - Largest API call: 4 seconds (fetching all historical data)
  - Frontend rendering: 500ms

### Phase 2: Plan

**Opportunities (by impact):**
1. Parallelize API calls (6 sequential → 6 parallel)
2. Paginate historical data (4s → estimated 200ms for recent)
3. Add caching for static data

**Simplification:** Fix the 4-second call first - it's 50% of the problem

### Phase 3: Execute

**Change 1:** Paginate historical data
- Before: Fetch all 100K records
- After: Fetch last 30 days (1K records)
- Result: 4s → 300ms

**Change 2:** Parallelize remaining calls
- Before: 6 calls × 500ms average = 3s sequential
- After: 6 calls in parallel = 600ms
- Result: 3s → 600ms

**Total:** 8s → 900ms (target achieved)

### Phase 4: Look Back

- **Target met?** Yes, 900ms < 2s target
- **Unexpected:** Pagination had bigger impact than parallelization
- **Monitoring:** Added dashboard load time metric to alerting
- **Diary:** `/solve-it:diary` - documented performance investigation

---

## Key Patterns Across Examples

1. **Always measure** before and after - don't guess
2. **Simplify first** - solve the smallest version of the problem
3. **One change at a time** - isolate variables
4. **Document decisions** - future you will thank present you
5. **Record learnings** - `/solve-it:diary` captures patterns for reuse
