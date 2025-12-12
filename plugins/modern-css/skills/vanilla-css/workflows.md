# Modern CSS Workflow Patterns

Detailed workflow guidance for common CSS development scenarios.

## Table of Contents
- [Project Setup Workflow](#project-setup-workflow)
- [Design Token Architecture](#design-token-architecture)
- [Theming and Dark Mode](#theming-and-dark-mode)
- [Responsive Design Strategy](#responsive-design-strategy)
- [Component Development](#component-development)
- [Animation and Transitions](#animation-and-transitions)
- [Form Styling](#form-styling)
- [Accessibility Workflow](#accessibility-workflow)
- [Performance Optimization](#performance-optimization)
- [Migration from Preprocessors](#migration-from-preprocessors)

## Project Setup Workflow

### Step 1: Establish Layer Structure

Create your CSS entry point with proper layer ordering:

```css
/* styles/main.css */

/* 1. Declare all layers upfront */
@layer reset, tokens, base, layout, components, utilities;

/* 2. Import reset/normalize */
@layer reset {
  @import url('./reset.css');
}

/* 3. Import design tokens */
@layer tokens {
  @import url('./tokens.css');
}

/* 4. Import base styles */
@layer base {
  @import url('./base.css');
}

/* 5. Import layout */
@layer layout {
  @import url('./layout.css');
}

/* 6. Import components */
@layer components {
  @import url('./components/index.css');
}

/* 7. Import utilities */
@layer utilities {
  @import url('./utilities.css');
}
```

### Step 2: Create Reset Layer

```css
/* styles/reset.css */
*,
*::before,
*::after {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html {
  -webkit-text-size-adjust: none;
  text-size-adjust: none;
}

body {
  min-block-size: 100dvh;
  line-height: 1.5;
}

img,
picture,
video,
canvas,
svg {
  display: block;
  max-inline-size: 100%;
}

input,
button,
textarea,
select {
  font: inherit;
  color: inherit;
}

p,
h1,
h2,
h3,
h4,
h5,
h6 {
  overflow-wrap: break-word;
}

a {
  color: inherit;
  text-decoration: inherit;
}

button {
  background: none;
  border: none;
  cursor: pointer;
}

ul,
ol {
  list-style: none;
}
```

### Step 3: Set Up Tokens File

```css
/* styles/tokens.css */
:root {
  /* Color tokens - using OKLCH */
  --color-gray-50: oklch(0.98 0 0);
  --color-gray-100: oklch(0.95 0 0);
  --color-gray-200: oklch(0.9 0 0);
  --color-gray-300: oklch(0.8 0 0);
  --color-gray-400: oklch(0.65 0 0);
  --color-gray-500: oklch(0.5 0 0);
  --color-gray-600: oklch(0.4 0 0);
  --color-gray-700: oklch(0.3 0 0);
  --color-gray-800: oklch(0.2 0 0);
  --color-gray-900: oklch(0.12 0 0);

  --color-brand-50: oklch(0.97 0.02 250);
  --color-brand-500: oklch(0.55 0.2 250);
  --color-brand-600: oklch(0.48 0.18 250);
  --color-brand-700: oklch(0.4 0.15 250);

  /* Semantic tokens */
  --color-bg: var(--color-gray-50);
  --color-surface: white;
  --color-text: var(--color-gray-900);
  --color-text-muted: var(--color-gray-600);
  --color-border: var(--color-gray-200);
  --color-accent: var(--color-brand-500);
  --color-accent-hover: var(--color-brand-600);

  /* Spacing scale */
  --space-xs: 0.25rem;
  --space-sm: 0.5rem;
  --space-md: 1rem;
  --space-lg: 1.5rem;
  --space-xl: 2rem;
  --space-2xl: 3rem;
  --space-3xl: 4rem;

  /* Typography */
  --font-sans: system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
  --font-mono: ui-monospace, 'Cascadia Code', 'Fira Code', monospace;

  --text-xs: clamp(0.75rem, 0.7rem + 0.2vw, 0.875rem);
  --text-sm: clamp(0.875rem, 0.8rem + 0.3vw, 1rem);
  --text-base: clamp(1rem, 0.9rem + 0.4vw, 1.125rem);
  --text-lg: clamp(1.125rem, 1rem + 0.5vw, 1.25rem);
  --text-xl: clamp(1.25rem, 1rem + 1vw, 1.5rem);
  --text-2xl: clamp(1.5rem, 1rem + 2vw, 2rem);
  --text-3xl: clamp(2rem, 1rem + 3vw, 3rem);

  /* Sizing */
  --radius-sm: 0.25rem;
  --radius-md: 0.5rem;
  --radius-lg: 1rem;
  --radius-full: 9999px;

  /* Shadows */
  --shadow-sm: 0 1px 2px oklch(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px oklch(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px oklch(0 0 0 / 0.1);

  /* Transitions */
  --transition-fast: 150ms ease;
  --transition-base: 250ms ease;
  --transition-slow: 350ms ease;
}
```

## Design Token Architecture

### Two-Layer Token System

```
Layer 1: Base/Primitive Tokens (Constants)
    |
    v
Layer 2: Semantic/Alias Tokens (Theming)
    |
    v
Component Styles
```

### Layer 1: Primitive Tokens

Never change these - they are your design system constants:

```css
:root {
  /* Primitive color tokens */
  --blue-50: oklch(0.97 0.02 250);
  --blue-100: oklch(0.93 0.05 250);
  --blue-200: oklch(0.85 0.1 250);
  --blue-300: oklch(0.75 0.15 250);
  --blue-400: oklch(0.65 0.18 250);
  --blue-500: oklch(0.55 0.2 250);
  --blue-600: oklch(0.48 0.18 250);
  --blue-700: oklch(0.4 0.15 250);
  --blue-800: oklch(0.32 0.12 250);
  --blue-900: oklch(0.25 0.08 250);

  /* Primitive spacing */
  --size-1: 0.25rem;
  --size-2: 0.5rem;
  --size-3: 0.75rem;
  --size-4: 1rem;
  --size-5: 1.25rem;
  --size-6: 1.5rem;
  --size-8: 2rem;
  --size-10: 2.5rem;
  --size-12: 3rem;
  --size-16: 4rem;
}
```

### Layer 2: Semantic Tokens

These map primitives to meaningful names and enable theming:

```css
:root {
  /* Semantic color tokens */
  --color-bg-primary: var(--gray-50);
  --color-bg-secondary: var(--gray-100);
  --color-bg-surface: white;
  --color-bg-surface-raised: white;

  --color-text-primary: var(--gray-900);
  --color-text-secondary: var(--gray-700);
  --color-text-muted: var(--gray-500);
  --color-text-inverse: white;

  --color-border-default: var(--gray-200);
  --color-border-strong: var(--gray-300);

  --color-interactive-default: var(--blue-500);
  --color-interactive-hover: var(--blue-600);
  --color-interactive-active: var(--blue-700);

  /* Semantic spacing */
  --space-component-gap: var(--size-4);
  --space-section-gap: var(--size-8);
  --space-page-margin: var(--size-4);
}
```

### Component-Level Tokens

Optional third layer for component customization:

```css
.button {
  /* Component tokens with semantic defaults */
  --button-bg: var(--color-interactive-default);
  --button-text: var(--color-text-inverse);
  --button-padding-x: var(--size-4);
  --button-padding-y: var(--size-2);
  --button-radius: var(--radius-md);

  background: var(--button-bg);
  color: var(--button-text);
  padding: var(--button-padding-y) var(--button-padding-x);
  border-radius: var(--button-radius);
}

/* Override component tokens for variants */
.button--secondary {
  --button-bg: transparent;
  --button-text: var(--color-interactive-default);
}
```

## Theming and Dark Mode

### System Preference Detection

```css
/* Light mode (default) */
:root {
  --color-bg: var(--gray-50);
  --color-surface: white;
  --color-text: var(--gray-900);
  --color-text-muted: var(--gray-600);
  --color-border: var(--gray-200);

  color-scheme: light dark;
}

/* Dark mode - override semantic tokens only */
@media (prefers-color-scheme: dark) {
  :root {
    --color-bg: var(--gray-900);
    --color-surface: var(--gray-800);
    --color-text: var(--gray-50);
    --color-text-muted: var(--gray-400);
    --color-border: var(--gray-700);
  }
}
```

### Manual Theme Toggle

```css
/* Light theme (explicit) */
[data-theme="light"] {
  --color-bg: var(--gray-50);
  --color-surface: white;
  --color-text: var(--gray-900);
  --color-text-muted: var(--gray-600);
  --color-border: var(--gray-200);

  color-scheme: light;
}

/* Dark theme (explicit) */
[data-theme="dark"] {
  --color-bg: var(--gray-900);
  --color-surface: var(--gray-800);
  --color-text: var(--gray-50);
  --color-text-muted: var(--gray-400);
  --color-border: var(--gray-700);

  color-scheme: dark;
}
```

```javascript
// Theme toggle JavaScript
function setTheme(theme) {
  document.documentElement.dataset.theme = theme;
  localStorage.setItem('theme', theme);
}

function initTheme() {
  const saved = localStorage.getItem('theme');
  if (saved) {
    setTheme(saved);
  } else if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
    setTheme('dark');
  } else {
    setTheme('light');
  }
}

initTheme();
```

### Multiple Theme Support

```css
/* Theme: Default */
:root {
  --color-accent: var(--blue-500);
  --color-accent-hover: var(--blue-600);
}

/* Theme: Ocean */
[data-accent="ocean"] {
  --color-accent: oklch(0.6 0.15 200);
  --color-accent-hover: oklch(0.5 0.15 200);
}

/* Theme: Forest */
[data-accent="forest"] {
  --color-accent: oklch(0.55 0.15 145);
  --color-accent-hover: oklch(0.45 0.15 145);
}

/* Theme: Sunset */
[data-accent="sunset"] {
  --color-accent: oklch(0.65 0.2 30);
  --color-accent-hover: oklch(0.55 0.2 30);
}
```

## Responsive Design Strategy

### Mobile-First Foundation

```css
/* Base (mobile) styles */
.layout {
  display: grid;
  gap: var(--space-md);
  padding: var(--space-md);
}

.sidebar {
  display: none;
}

/* Tablet and up */
@media (width >= 768px) {
  .layout {
    grid-template-columns: 250px 1fr;
    padding: var(--space-lg);
  }

  .sidebar {
    display: block;
  }
}

/* Desktop */
@media (width >= 1024px) {
  .layout {
    grid-template-columns: 300px 1fr 250px;
    max-inline-size: 1400px;
    margin-inline: auto;
  }
}
```

### Container Queries for Components

```css
/* Component responds to its container, not viewport */
.card {
  container-type: inline-size;
  display: grid;
  gap: var(--space-sm);
}

/* Card internal layout responds to card size */
@container (width >= 400px) {
  .card {
    grid-template-columns: 150px 1fr;
    gap: var(--space-md);
  }
}

@container (width >= 600px) {
  .card {
    grid-template-columns: 200px 1fr;
  }
}
```

### When to Use Each

| Use Case | Technique |
|----------|-----------|
| Page layout | Media queries |
| Component layout | Container queries |
| Typography | `clamp()` |
| Spacing | `clamp()` or media queries |
| Show/hide elements | Media queries or `:has()` |

### Fluid Design Without Breakpoints

```css
/* Fluid grid */
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(300px, 100%), 1fr));
  gap: var(--space-md);
}

/* Fluid typography */
h1 {
  font-size: clamp(1.75rem, 1rem + 3vw, 3rem);
}

/* Fluid spacing */
section {
  padding-block: clamp(2rem, 5vw, 5rem);
}

/* Fluid container */
.container {
  inline-size: min(100% - 2rem, 1200px);
  margin-inline: auto;
}
```

## Component Development

### Component Template

```css
/* component.css */
@layer components {
  .component {
    /* 1. Component-level custom properties */
    --component-bg: var(--color-surface);
    --component-text: var(--color-text);
    --component-padding: var(--space-md);
    --component-radius: var(--radius-md);

    /* 2. Container setup (if needed) */
    container-type: inline-size;

    /* 3. Base styles using custom properties */
    background: var(--component-bg);
    color: var(--component-text);
    padding: var(--component-padding);
    border-radius: var(--component-radius);

    /* 4. State styles */
    &:hover {
      box-shadow: var(--shadow-md);
    }

    &:focus-within {
      outline: 2px solid var(--color-accent);
      outline-offset: 2px;
    }

    /* 5. Child element styles */
    & .component-header {
      font-size: var(--text-lg);
      margin-block-end: var(--space-sm);
    }

    & .component-body {
      color: var(--color-text-muted);
    }

    /* 6. Responsive adjustments */
    @container (width >= 400px) {
      --component-padding: var(--space-lg);
    }

    /* 7. Variants */
    &--elevated {
      box-shadow: var(--shadow-lg);
    }

    &--bordered {
      border: 1px solid var(--color-border);
    }
  }
}
```

### Using :has() for Component States

```css
.card {
  /* Has featured badge */
  &:has(.badge--featured) {
    border-color: var(--color-accent);
    box-shadow: var(--shadow-md);
  }

  /* Has media */
  &:has(> img:first-child),
  &:has(> video:first-child) {
    padding-block-start: 0;

    & > img:first-child,
    & > video:first-child {
      border-radius: var(--radius-md) var(--radius-md) 0 0;
    }
  }

  /* Interactive card (has link) */
  &:has(> a) {
    cursor: pointer;
    transition: transform var(--transition-fast);

    &:hover {
      transform: translateY(-2px);
    }
  }
}
```

## Animation and Transitions

### Transition Workflow

```css
/* 1. Define what transitions */
.element {
  transition-property: transform, opacity, background-color;
  transition-duration: var(--transition-base);
  transition-timing-function: ease;

  /* Or shorthand */
  transition:
    transform var(--transition-base),
    opacity var(--transition-base),
    background-color var(--transition-fast);
}

/* 2. Define state changes */
.element:hover {
  transform: translateY(-2px);
  background-color: var(--color-surface-hover);
}

/* 3. Handle reduced motion */
@media (prefers-reduced-motion: reduce) {
  .element {
    transition: none;
  }
}
```

### Entry Animations with @starting-style

```css
/* Modal/dialog animation */
.modal {
  /* Final open state */
  opacity: 1;
  transform: translateY(0) scale(1);

  /* Transitions */
  transition:
    opacity 0.3s ease,
    transform 0.3s ease,
    display 0.3s allow-discrete,
    overlay 0.3s allow-discrete;

  /* Entry state */
  @starting-style {
    opacity: 0;
    transform: translateY(-20px) scale(0.95);
  }
}

/* Exit state */
.modal:not([open]),
.modal.closing {
  opacity: 0;
  transform: translateY(20px) scale(0.95);
}

/* Backdrop */
.modal::backdrop {
  background: oklch(0 0 0 / 0.5);
  transition: opacity 0.3s;

  @starting-style {
    opacity: 0;
  }
}
```

### View Transitions for Navigation

```css
/* Enable MPA view transitions */
@view-transition {
  navigation: auto;
}

/* Default crossfade */
::view-transition-old(root) {
  animation: fade-and-scale-out 0.3s ease forwards;
}

::view-transition-new(root) {
  animation: fade-and-scale-in 0.3s ease forwards;
}

@keyframes fade-and-scale-out {
  to {
    opacity: 0;
    transform: scale(0.95);
  }
}

@keyframes fade-and-scale-in {
  from {
    opacity: 0;
    transform: scale(1.05);
  }
}

/* Named element transitions */
.page-title {
  view-transition-name: page-title;
}

::view-transition-old(page-title) {
  animation: slide-out-left 0.25s ease forwards;
}

::view-transition-new(page-title) {
  animation: slide-in-right 0.25s ease forwards;
}

/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
  ::view-transition-group(*) {
    animation-duration: 0.01ms !important;
  }
}
```

## Form Styling

### Modern Form Reset

```css
@layer base {
  input,
  textarea,
  select {
    font: inherit;
    color: inherit;
    background: var(--color-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    padding: var(--space-sm) var(--space-md);
  }

  input:focus,
  textarea:focus,
  select:focus {
    outline: 2px solid var(--color-accent);
    outline-offset: 2px;
    border-color: var(--color-accent);
  }

  /* Accent color for checkboxes/radios */
  input[type="checkbox"],
  input[type="radio"] {
    accent-color: var(--color-accent);
  }
}
```

### Form Validation with :has()

```css
.form-field {
  display: grid;
  gap: var(--space-xs);

  /* Valid state */
  &:has(input:user-valid:not(:placeholder-shown)) {
    & .field-icon--valid {
      display: block;
    }
  }

  /* Invalid state */
  &:has(input:user-invalid) {
    & input {
      border-color: var(--color-error);
      background: oklch(from var(--color-error) l c h / 0.05);
    }

    & .field-error {
      display: block;
    }

    & .field-icon--error {
      display: block;
    }
  }

  /* Required indicator */
  &:has(input:required) {
    & .field-label::after {
      content: " *";
      color: var(--color-error);
    }
  }
}

/* Form submit button disabled until valid */
form:has(:user-invalid) button[type="submit"] {
  opacity: 0.5;
  pointer-events: none;
}
```

## Accessibility Workflow

### Accessibility Checklist

```css
/* 1. Reduced motion support */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}

/* 2. Focus visibility */
:focus-visible {
  outline: 2px solid var(--color-accent);
  outline-offset: 2px;
}

:focus:not(:focus-visible) {
  outline: none;
}

/* 3. Minimum touch targets */
button,
a,
input,
select {
  min-block-size: 44px;
  min-inline-size: 44px;
}

/* 4. Text sizing with rem */
html {
  font-size: 100%; /* Respects user preference */
}

body {
  font-size: var(--text-base); /* Uses rem-based scale */
}

/* 5. High contrast support */
@media (prefers-contrast: more) {
  :root {
    --color-border: var(--gray-900);
    --color-text-muted: var(--gray-800);
  }
}

/* 6. Color scheme */
:root {
  color-scheme: light dark;
}

/* 7. Skip link */
.skip-link {
  position: absolute;
  inset-inline-start: -9999px;
  padding: var(--space-sm) var(--space-md);
  background: var(--color-accent);
  color: white;

  &:focus {
    inset-inline-start: var(--space-md);
    inset-block-start: var(--space-md);
  }
}
```

### WCAG Color Contrast

```css
/* Use OKLCH for predictable contrast */
:root {
  /* Text on light background - L difference >= 0.4 */
  --color-bg-light: oklch(0.98 0 0);      /* L: 0.98 */
  --color-text-dark: oklch(0.2 0 0);       /* L: 0.2, diff: 0.78 */

  /* Text on dark background */
  --color-bg-dark: oklch(0.15 0 0);        /* L: 0.15 */
  --color-text-light: oklch(0.95 0 0);     /* L: 0.95, diff: 0.80 */

  /* Interactive elements - ensure visible on both */
  --color-link: oklch(0.45 0.2 250);       /* Works on light */
  --color-link-dark: oklch(0.7 0.15 250);  /* Works on dark */
}
```

## Performance Optimization

### Efficient Custom Properties

```css
/* Use @property for animated values */
@property --gradient-angle {
  syntax: "<angle>";
  initial-value: 0deg;
  inherits: false; /* Prevents inheritance overhead */
}

.animated-gradient {
  background: linear-gradient(var(--gradient-angle), var(--color-1), var(--color-2));
  animation: rotate 3s linear infinite;
}

@keyframes rotate {
  to { --gradient-angle: 360deg; }
}
```

### Reduce Repaints

```css
/* Use transform/opacity for animations */
.animate-in {
  /* Good - compositor properties */
  transform: translateY(0);
  opacity: 1;

  /* Avoid animating these */
  /* width, height, top, left, margin, padding */
}

/* contain for layout isolation */
.card {
  contain: layout style;
}

.widget {
  contain: content; /* strictest */
}
```

### Efficient Selectors

```css
/* Good - specific, limited scope */
.card > .card-title { }
.nav-item:hover { }

/* Avoid - forces full document scan */
.page:has(.deeply .nested .element) { }
*:has(> .something) { }
```

## Migration from Preprocessors

### Sass to Native CSS

| Sass Feature | Native CSS Equivalent |
|--------------|----------------------|
| Variables | CSS Custom Properties |
| Nesting | Native nesting with `&` |
| Mixins | No direct equivalent (use custom properties) |
| @extend | Use multiple classes |
| @import | Native @import or cascade layers |
| Color functions | OKLCH + color-mix() |
| Math | calc(), clamp(), min(), max() |

### Migration Steps

1. **Replace variables:**
```scss
// Sass
$primary: #3b82f6;
.button { background: $primary; }

// Native CSS
:root { --color-primary: oklch(0.6 0.2 250); }
.button { background: var(--color-primary); }
```

2. **Convert nesting:**
```scss
// Sass
.card {
  padding: 1rem;
  &:hover { box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
  .title { font-size: 1.25rem; }
}

// Native CSS
.card {
  padding: 1rem;
  &:hover { box-shadow: var(--shadow-md); }
  & .title { font-size: var(--text-lg); }
}
```

3. **Replace color functions:**
```scss
// Sass
$color: #3b82f6;
.light { background: lighten($color, 20%); }
.dark { background: darken($color, 20%); }

// Native CSS
:root { --color: oklch(0.6 0.2 250); }
.light { background: oklch(from var(--color) calc(l + 0.2) c h); }
.dark { background: oklch(from var(--color) calc(l - 0.2) c h); }
```

4. **Replace mixins with custom properties:**
```scss
// Sass mixin
@mixin button-variant($bg, $text) {
  background: $bg;
  color: $text;
}
.primary { @include button-variant(blue, white); }

// Native CSS with custom properties
.button {
  --button-bg: var(--color-primary);
  --button-text: white;
  background: var(--button-bg);
  color: var(--button-text);
}
.button--secondary {
  --button-bg: var(--color-secondary);
}
```

### Keep Build Tools For

- Minification and optimization
- Autoprefixer (for older browser support)
- CSS bundling
- Source maps

### Remove Build Tools For

- Variable compilation
- Nesting compilation
- Color function processing
- Math operations
