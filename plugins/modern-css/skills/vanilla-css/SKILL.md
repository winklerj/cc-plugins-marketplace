---
name: vanilla-css
description: Modern vanilla CSS techniques for building responsive, maintainable web interfaces without preprocessors or frameworks. Covers CSS custom properties, OKLCH colors, :has() selector, cascade layers, container queries, view transitions, @starting-style, logical properties, clamp/min/max, and native nesting. Use when user mentions CSS styling, responsive design, theming, dark mode, CSS variables, animations, transitions, or modern CSS features.
---

# Modern Vanilla CSS

Modern CSS has evolved to include features that previously required preprocessors like Sass or build tools. This skill covers techniques for writing maintainable, performant CSS using only native browser capabilities.

## Core Principles

1. **No build step required** - All features work natively in modern browsers
2. **Progressive enhancement** - Provide fallbacks with `@supports` for older browsers
3. **Logical properties** - Use for internationalization and writing-mode support
4. **Container queries** - Component-level responsiveness over page-level media queries
5. **clamp()** - Fluid typography and spacing without breakpoints
6. **OKLCH** - Perceptually uniform colors for consistent design systems
7. **@layer** - Cascade control for manageable specificity
8. **Native nesting** - Organized code without preprocessors

## Key Features Overview

### CSS Custom Properties (Variables)
Define reusable values with `--property-name` syntax, scoped to selectors. Use `var(--property-name, fallback)` to reference with fallbacks.

```css
:root {
  --color-primary: oklch(0.6 0.15 250);
  --spacing-md: clamp(1rem, 3vw, 2rem);
}

.button {
  background: var(--color-primary);
  padding: var(--spacing-md);
}
```

### OKLCH Color Space
Perceptually uniform color model where equal lightness values appear equally bright across all hues.

```css
:root {
  --color-brand: oklch(0.65 0.2 250);
  --color-brand-light: oklch(0.85 0.1 250);
  --color-brand-dark: oklch(0.45 0.2 250);
}
```

### :has() Selector (Parent Selector)
Style elements based on their descendants or subsequent siblings.

```css
/* Style form group when input has error */
.form-group:has(input:user-invalid) {
  border-color: var(--color-error);
}

/* Card with image gets different layout */
.card:has(> img) {
  grid-template-rows: auto 1fr;
}
```

### CSS Cascade Layers (@layer)
Control cascade priority independently of specificity.

```css
@layer reset, base, components, utilities;

@layer reset {
  * { margin: 0; box-sizing: border-box; }
}

@layer utilities {
  .hidden { display: none; }
}
```

### Native CSS Nesting
Nest selectors directly in CSS without preprocessors.

```css
.card {
  padding: var(--spacing-md);

  &:hover {
    box-shadow: var(--shadow-lg);
  }

  & .title {
    font-size: var(--font-lg);
  }

  @media (width >= 768px) {
    padding: var(--spacing-lg);
  }
}
```

### Container Queries
Style components based on their container size, not viewport.

```css
.sidebar {
  container-type: inline-size;
  container-name: sidebar;
}

@container sidebar (width >= 300px) {
  .widget {
    display: grid;
    grid-template-columns: 1fr 1fr;
  }
}
```

### clamp(), min(), max()
Fluid responsive values without media queries.

```css
h1 {
  font-size: clamp(1.5rem, 4vw + 0.5rem, 3rem);
}

.container {
  width: min(100% - 2rem, 1200px);
  padding: clamp(1rem, 5%, 3rem);
}
```

### View Transitions API
Smooth animated transitions between page states.

```css
@view-transition {
  navigation: auto;
}

::view-transition-old(root) {
  animation: fade-out 0.25s ease-out;
}

::view-transition-new(root) {
  animation: fade-in 0.25s ease-in;
}
```

### @starting-style
Animate elements from `display: none` state.

```css
dialog {
  opacity: 1;
  transform: translateY(0);
  transition: opacity 0.3s, transform 0.3s, display 0.3s allow-discrete;

  @starting-style {
    opacity: 0;
    transform: translateY(-20px);
  }
}

dialog:not([open]) {
  opacity: 0;
  transform: translateY(-20px);
}
```

### Logical Properties
Writing-mode aware properties for internationalization.

```css
.element {
  margin-inline: auto;        /* left/right in LTR */
  padding-block: 1rem;        /* top/bottom */
  inline-size: 100%;          /* width in LTR */
  border-start-start-radius: 8px; /* top-left in LTR */
}
```

## Accessibility Requirements

Always implement these accessibility features:

```css
/* Respect motion preferences */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}

/* Support color scheme preferences */
@media (prefers-color-scheme: dark) {
  :root {
    --color-bg: oklch(0.15 0.01 250);
    --color-text: oklch(0.95 0.01 250);
  }
}

/* Minimum touch target size */
button, a {
  min-block-size: 44px;
  min-inline-size: 44px;
}
```

## Browser Support Strategy

Use `@supports` for progressive enhancement:

```css
/* Base styles for all browsers */
.element {
  display: flex;
  gap: 1rem;
}

/* Enhanced styles for modern browsers */
@supports (container-type: inline-size) {
  .element {
    container-type: inline-size;
  }
}

@supports selector(:has(*)) {
  .form:has(:focus-visible) {
    outline: 2px solid var(--color-focus);
  }
}
```

## Additional Resources

For detailed workflows and examples, see:
- [workflows.md](workflows.md) - Workflow patterns for theming, responsive design, and animations
- [examples.md](examples.md) - Concrete examples for common scenarios
- [reference.md](reference.md) - Complete feature reference and browser support
