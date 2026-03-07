---
name: diataxis-docs
description: Generate comprehensive codebase documentation using the Diataxis framework. Use when the user asks to create documentation, generate docs, document a codebase, write project docs, or mentions "diataxis". Triggers on phrases like "create docs", "document this project", "generate documentation", "write docs for this codebase".
---

# Diataxis Documentation Generator

## Prerequisites

Before generating any documentation, fetch the Diataxis framework reference from https://diataxis.fr to understand the four documentation categories and their principles. Use WebFetch to retrieve the main page content. Additionally fetch these key pages for deeper understanding:

- https://diataxis.fr/tutorials/
- https://diataxis.fr/how-to-guides/
- https://diataxis.fr/reference/
- https://diataxis.fr/explanation/

## Workflow

1. **Learn the framework** - Fetch and read the Diataxis site pages listed above
2. **Analyze the codebase** - Explore the project structure, key modules, entry points, configuration, and public APIs
3. **Plan the documentation** - Determine which Diataxis categories apply and what content belongs in each:
   - **Tutorials** - Learning-oriented walkthroughs for newcomers
   - **How-to guides** - Task-oriented instructions for specific goals
   - **Reference** - Information-oriented technical descriptions (APIs, config, CLI)
   - **Explanation** - Understanding-oriented discussion of concepts and decisions
4. **Propose the plan** - Present the documentation plan to the user for approval before writing
5. **Generate documentation** - Write the docs following Diataxis principles, placing files in a `docs/` directory (or the project's existing docs location)

## Guidelines

- Not every project needs all four categories. Skip categories that don't apply.
- Keep each document focused on its category. Do not mix tutorial content with reference content.
- Use the project's existing conventions for file naming, formatting, and structure.
- If docs already exist, assess gaps against the Diataxis framework rather than rewriting everything.
