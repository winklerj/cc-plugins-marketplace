# Modern CSS Usage Examples

Concrete examples for common modern CSS scenarios.

## Table of Contents
- [CSS Custom Properties](#css-custom-properties)
- [OKLCH Colors](#oklch-colors)
- [The :has() Selector](#the-has-selector)
- [Cascade Layers](#cascade-layers)
- [Native Nesting](#native-nesting)
- [Container Queries](#container-queries)
- [Fluid Typography and Spacing](#fluid-typography-and-spacing)
- [View Transitions](#view-transitions)
- [Starting Style Animations](#starting-style-animations)
- [Logical Properties](#logical-properties)
- [Complete Component Examples](#complete-component-examples)

## CSS Custom Properties

### Basic Variable Definition

```css
:root {
  /* Color tokens */
  --color-primary: oklch(0.6 0.2 250);
  --color-secondary: oklch(0.55 0.15 320);
  --color-success: oklch(0.65 0.2 145);
  --color-warning: oklch(0.75 0.15 85);
  --color-error: oklch(0.55 0.25 25);

  /* Spacing scale */
  --space-xs: 0.25rem;
  --space-sm: 0.5rem;
  --space-md: 1rem;
  --space-lg: 1.5rem;
  --space-xl: 2rem;

  /* Typography */
  --font-sans: system-ui, -apple-system, sans-serif;
  --font-mono: ui-monospace, monospace;
  --text-sm: 0.875rem;
  --text-base: 1rem;
  --text-lg: 1.25rem;
}
```

### Component-Scoped Variables

```css
.button {
  /* Local overridable defaults */
  --button-bg: var(--color-primary);
  --button-text: white;
  --button-padding-x: var(--space-lg);
  --button-padding-y: var(--space-sm);
  --button-radius: 0.375rem;

  background: var(--button-bg);
  color: var(--button-text);
  padding: var(--button-padding-y) var(--button-padding-x);
  border-radius: var(--button-radius);
}

/* Variant using variable override */
.button--secondary {
  --button-bg: var(--color-secondary);
}

.button--outline {
  --button-bg: transparent;
  --button-text: var(--color-primary);
  border: 2px solid currentColor;
}
```

### Two-Layer Theming System

```css
/* Layer 1: Base constants (don't change) */
:root {
  --blue-50: oklch(0.97 0.01 250);
  --blue-500: oklch(0.6 0.2 250);
  --blue-900: oklch(0.25 0.1 250);

  --gray-50: oklch(0.98 0 0);
  --gray-100: oklch(0.95 0 0);
  --gray-800: oklch(0.3 0 0);
  --gray-900: oklch(0.2 0 0);
}

/* Layer 2: Semantic tokens (change for themes) */
:root {
  --color-bg: var(--gray-50);
  --color-surface: white;
  --color-text: var(--gray-900);
  --color-text-muted: var(--gray-800);
  --color-accent: var(--blue-500);
  --color-accent-hover: var(--blue-900);
}

/* Dark theme overrides semantic layer only */
@media (prefers-color-scheme: dark) {
  :root {
    --color-bg: var(--gray-900);
    --color-surface: var(--gray-800);
    --color-text: var(--gray-50);
    --color-text-muted: var(--gray-100);
  }
}
```

### JavaScript Integration

```css
:root {
  --sidebar-width: 280px;
  --header-height: 64px;
}
```

```javascript
// Read CSS variable
const sidebar = getComputedStyle(document.documentElement)
  .getPropertyValue('--sidebar-width');

// Set CSS variable
document.documentElement.style.setProperty('--sidebar-width', '320px');

// Set on specific element
element.style.setProperty('--button-bg', 'oklch(0.5 0.2 200)');
```

## OKLCH Colors

### Basic OKLCH Syntax

```css
:root {
  /* oklch(Lightness Chroma Hue) */
  --red: oklch(0.6 0.25 25);      /* Hue 25 = red */
  --orange: oklch(0.7 0.2 60);    /* Hue 60 = orange */
  --yellow: oklch(0.85 0.15 95);  /* Hue 95 = yellow */
  --green: oklch(0.65 0.2 145);   /* Hue 145 = green */
  --cyan: oklch(0.7 0.15 195);    /* Hue 195 = cyan */
  --blue: oklch(0.6 0.2 250);     /* Hue 250 = blue */
  --purple: oklch(0.55 0.25 300); /* Hue 300 = purple */
  --pink: oklch(0.7 0.2 350);     /* Hue 350 = pink */

  /* With alpha transparency */
  --overlay: oklch(0 0 0 / 0.5);  /* 50% black */
}
```

### Creating Color Palettes

```css
:root {
  /* Single hue palette - vary lightness */
  --brand-50: oklch(0.97 0.02 250);
  --brand-100: oklch(0.93 0.04 250);
  --brand-200: oklch(0.85 0.08 250);
  --brand-300: oklch(0.75 0.12 250);
  --brand-400: oklch(0.65 0.16 250);
  --brand-500: oklch(0.55 0.2 250);  /* Base */
  --brand-600: oklch(0.48 0.18 250);
  --brand-700: oklch(0.4 0.15 250);
  --brand-800: oklch(0.32 0.12 250);
  --brand-900: oklch(0.25 0.08 250);
}
```

### Color Mixing

```css
:root {
  --primary: oklch(0.6 0.2 250);
  --secondary: oklch(0.55 0.15 320);

  /* Mix colors in OKLCH space */
  --mixed: color-mix(in oklch, var(--primary), var(--secondary));

  /* Mix with percentages */
  --mostly-primary: color-mix(in oklch, var(--primary) 75%, var(--secondary));

  /* Tint (mix with white) */
  --primary-light: color-mix(in oklch, var(--primary), white 40%);

  /* Shade (mix with black) */
  --primary-dark: color-mix(in oklch, var(--primary), black 30%);
}
```

### Relative Color Syntax

```css
:root {
  --base-color: oklch(0.6 0.2 250);

  /* Lighten: increase L */
  --lighter: oklch(from var(--base-color) calc(l + 0.2) c h);

  /* Darken: decrease L */
  --darker: oklch(from var(--base-color) calc(l - 0.2) c h);

  /* Desaturate: decrease C */
  --muted: oklch(from var(--base-color) l calc(c * 0.5) h);

  /* Shift hue */
  --complement: oklch(from var(--base-color) l c calc(h + 180));

  /* Add transparency */
  --transparent: oklch(from var(--base-color) l c h / 0.5);
}
```

### Dark Mode with OKLCH

```css
:root {
  /* Light mode - higher lightness */
  --bg: oklch(0.98 0.01 250);
  --surface: oklch(1 0 0);
  --text: oklch(0.2 0.02 250);
  --text-muted: oklch(0.4 0.02 250);
  --border: oklch(0.85 0.02 250);
}

@media (prefers-color-scheme: dark) {
  :root {
    /* Dark mode - lower lightness, same chroma/hue */
    --bg: oklch(0.15 0.02 250);
    --surface: oklch(0.2 0.02 250);
    --text: oklch(0.95 0.01 250);
    --text-muted: oklch(0.7 0.01 250);
    --border: oklch(0.3 0.02 250);
  }
}
```

## The :has() Selector

### Parent Selection

```css
/* Style parent based on child state */
.form-group:has(input:focus) {
  border-color: var(--color-accent);
}

.form-group:has(input:user-invalid) {
  border-color: var(--color-error);
  background: oklch(0.95 0.05 25);
}

/* Card with image */
.card:has(> img) {
  padding-block-start: 0;
}

.card:has(> img:first-child) {
  border-start-start-radius: var(--radius);
  border-start-end-radius: var(--radius);
  overflow: hidden;
}
```

### Sibling Selection

```css
/* Style previous sibling (not possible before :has()) */
.item:has(+ .item:hover) {
  opacity: 0.7;
}

/* Style label when its input is checked */
label:has(+ input:checked),
label:has(> input:checked) {
  font-weight: bold;
  color: var(--color-accent);
}
```

### Checkbox Hack Without JavaScript

```css
/* Toggle content visibility */
.accordion:has(input[type="checkbox"]:checked) .accordion-content {
  display: block;
}

.accordion:has(input[type="checkbox"]:not(:checked)) .accordion-content {
  display: none;
}

/* Tab system */
.tabs:has(#tab1:checked) .panel-1 { display: block; }
.tabs:has(#tab2:checked) .panel-2 { display: block; }
.tabs:has(#tab3:checked) .panel-3 { display: block; }
```

### Quantity Queries

```css
/* Style based on number of children */
.grid:has(> :nth-child(1):last-child) {
  /* Single item */
  grid-template-columns: 1fr;
}

.grid:has(> :nth-child(2):last-child) {
  /* Two items */
  grid-template-columns: repeat(2, 1fr);
}

.grid:has(> :nth-child(3)) {
  /* Three or more items */
  grid-template-columns: repeat(3, 1fr);
}
```

### Form Validation Styling

```css
/* Complete form validation without JS */
.field:has(input:user-invalid) {
  --field-border: var(--color-error);
  --field-bg: oklch(0.98 0.02 25);
}

.field:has(input:user-valid) {
  --field-border: var(--color-success);
}

.field:has(input:user-invalid) .error-message {
  display: block;
}

.field:has(input:required) .label::after {
  content: " *";
  color: var(--color-error);
}

/* Disable submit until form is valid */
form:has(:user-invalid) button[type="submit"] {
  opacity: 0.5;
  pointer-events: none;
}
```

## Cascade Layers

### Basic Layer Setup

```css
/* Declare layer order - first declared = lowest priority */
@layer reset, base, layout, components, utilities;

@layer reset {
  *, *::before, *::after {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }

  img, picture, video {
    display: block;
    max-inline-size: 100%;
  }
}

@layer base {
  body {
    font-family: var(--font-sans);
    line-height: 1.6;
    color: var(--color-text);
    background: var(--color-bg);
  }

  a {
    color: var(--color-accent);
  }
}

@layer components {
  .button {
    /* Higher priority than base styles */
    display: inline-flex;
    padding: var(--space-sm) var(--space-md);
    background: var(--color-accent);
    color: white;
    border-radius: var(--radius-sm);
  }
}

@layer utilities {
  /* Highest priority in layers */
  .hidden { display: none !important; }
  .flex { display: flex; }
  .grid { display: grid; }
}
```

### Importing Third-Party CSS into Layers

```css
/* Import framework into its own layer */
@import url("normalize.css") layer(reset);
@import url("tailwind-base.css") layer(framework);
@import url("component-library.css") layer(components.external);

/* Your custom styles in higher-priority layer */
@layer app {
  /* These override framework styles regardless of specificity */
  .button {
    border-radius: var(--radius-md);
  }
}
```

### Nested Layers

```css
@layer components {
  @layer buttons {
    .button { /* ... */ }
    .button--primary { /* ... */ }
  }

  @layer cards {
    .card { /* ... */ }
    .card__header { /* ... */ }
  }

  @layer forms {
    .input { /* ... */ }
    .select { /* ... */ }
  }
}

/* Can also reference nested layers directly */
@layer components.buttons {
  .button--ghost { /* ... */ }
}
```

### Layer Priority with !important

```css
/* Normal cascade: utilities > components > base */
/* With !important: REVERSED - base > components > utilities */

@layer base {
  a {
    color: var(--color-accent) !important;
    /* With !important, this has HIGHER priority than utilities */
  }
}

@layer utilities {
  .text-red {
    color: red !important;
    /* Even with !important, lower priority than base !important */
  }
}
```

## Native Nesting

### Basic Nesting Syntax

```css
.card {
  padding: var(--space-md);
  background: var(--color-surface);
  border-radius: var(--radius-md);

  /* Pseudo-classes */
  &:hover {
    box-shadow: var(--shadow-md);
  }

  &:focus-within {
    outline: 2px solid var(--color-accent);
  }

  /* Pseudo-elements */
  &::before {
    content: "";
    position: absolute;
  }

  /* Child selectors */
  & .card-title {
    font-size: var(--text-lg);
    margin-block-end: var(--space-sm);
  }

  & .card-body {
    color: var(--color-text-muted);
  }

  /* Direct child */
  & > img {
    border-radius: var(--radius-md) var(--radius-md) 0 0;
  }
}
```

### Media Query Nesting

```css
.sidebar {
  inline-size: 100%;
  position: fixed;
  inset-inline-start: -100%;
  transition: inset-inline-start 0.3s ease;

  &.open {
    inset-inline-start: 0;
  }

  @media (width >= 768px) {
    position: static;
    inline-size: 280px;
    inset-inline-start: 0;
  }

  @media (width >= 1024px) {
    inline-size: 320px;
  }
}
```

### Container Query Nesting

```css
.widget {
  container-type: inline-size;
  padding: var(--space-sm);

  & .widget-content {
    display: block;
  }

  @container (width >= 300px) {
    padding: var(--space-md);

    & .widget-content {
      display: flex;
      gap: var(--space-md);
    }
  }
}
```

### Important Nesting Rules

```css
/* CORRECT: Parent styles before nested */
.element {
  color: blue;        /* Parent style first */

  &:hover {           /* Then nested */
    color: red;
  }
}

/* INCORRECT: This can cause issues */
.element {
  &:hover {
    color: red;
  }

  color: blue;        /* Parent after nested - avoid */
}

/* CORRECT: Deep nesting (but keep to 2-3 levels) */
.nav {
  & .nav-list {
    & .nav-item {
      /* Maximum recommended depth */
    }
  }
}

/* NOTE: Cannot use Sass-style concatenation */
.button {
  /* &-primary won't work - use full selector */
  &.button-primary {  /* This works */
    background: var(--color-primary);
  }
}
```

## Container Queries

### Basic Container Setup

```css
/* Define container */
.card-grid {
  container-type: inline-size;
  container-name: card-container;
}

/* Or shorthand */
.sidebar {
  container: sidebar / inline-size;
}

/* Query the container */
@container card-container (width >= 400px) {
  .card {
    display: grid;
    grid-template-columns: 200px 1fr;
  }
}

@container sidebar (width >= 250px) {
  .nav-item {
    padding: var(--space-md);
  }
}
```

### Container Query Units

```css
.card {
  container-type: inline-size;

  & .card-title {
    /* cqi = container inline size (width in horizontal writing) */
    font-size: clamp(1rem, 5cqi, 1.5rem);
  }

  & .card-image {
    /* cqw = container width, cqh = container height */
    block-size: 30cqw;
  }
}
```

### Multiple Named Containers

```css
.page {
  container: page / inline-size;
}

.sidebar {
  container: sidebar / inline-size;
}

.main-content {
  container: main / inline-size;
}

/* Query specific containers */
@container page (width >= 1200px) {
  .layout {
    grid-template-columns: 300px 1fr;
  }
}

@container sidebar (width >= 250px) {
  .sidebar-widget {
    padding: var(--space-lg);
  }
}

@container main (width >= 600px) {
  .article {
    columns: 2;
  }
}
```

### Style Queries

```css
.card {
  container-type: inline-size;
  --card-variant: default;
}

.card--featured {
  --card-variant: featured;
}

/* Query custom property values */
@container style(--card-variant: featured) {
  .card-title {
    font-size: var(--text-xl);
    color: var(--color-accent);
  }

  .card-badge {
    display: block;
  }
}
```

## Fluid Typography and Spacing

### Fluid Typography with clamp()

```css
:root {
  /* Fluid type scale */
  --text-xs: clamp(0.75rem, 0.7rem + 0.25vw, 0.875rem);
  --text-sm: clamp(0.875rem, 0.8rem + 0.35vw, 1rem);
  --text-base: clamp(1rem, 0.9rem + 0.5vw, 1.125rem);
  --text-lg: clamp(1.125rem, 1rem + 0.65vw, 1.25rem);
  --text-xl: clamp(1.25rem, 1rem + 1.25vw, 1.75rem);
  --text-2xl: clamp(1.5rem, 1rem + 2.5vw, 2.5rem);
  --text-3xl: clamp(2rem, 1rem + 4vw, 3.5rem);
}

h1 { font-size: var(--text-3xl); }
h2 { font-size: var(--text-2xl); }
h3 { font-size: var(--text-xl); }
p { font-size: var(--text-base); }
```

### Fluid Spacing

```css
:root {
  /* Fluid spacing scale */
  --space-xs: clamp(0.25rem, 0.2rem + 0.25vw, 0.5rem);
  --space-sm: clamp(0.5rem, 0.4rem + 0.5vw, 0.75rem);
  --space-md: clamp(1rem, 0.8rem + 1vw, 1.5rem);
  --space-lg: clamp(1.5rem, 1rem + 2.5vw, 3rem);
  --space-xl: clamp(2rem, 1rem + 5vw, 5rem);
}

section {
  padding-block: var(--space-xl);
  padding-inline: var(--space-md);
}

.stack > * + * {
  margin-block-start: var(--space-md);
}
```

### Constrained Layouts with min() and max()

```css
.container {
  /* Max width with padding respected */
  inline-size: min(100% - 2rem, 1200px);
  margin-inline: auto;
}

.content {
  /* Readable line length */
  max-inline-size: min(65ch, 100%);
}

.sidebar {
  /* Minimum width with flexibility */
  inline-size: max(200px, 20%);
}

.grid-item {
  /* Responsive minimum */
  min-inline-size: max(250px, 30%);
}
```

### Accessibility-Safe Fluid Typography

```css
/* Combine vw with rem for zoom support */
h1 {
  /* rem ensures text scales with browser zoom */
  /* vw provides fluidity */
  font-size: clamp(1.5rem, 1rem + 2.5vw, 3rem);
}

/* For users who increase default font size */
@media (prefers-reduced-motion: no-preference) {
  html {
    scroll-behavior: smooth;
  }
}
```

## View Transitions

### Single Page Application (SPA)

```javascript
// Wrap DOM updates in startViewTransition
document.startViewTransition(() => {
  // Update the DOM
  updateContent(newContent);
});
```

```css
/* Default crossfade animation */
::view-transition-old(root) {
  animation: 250ms ease-out both fade-out;
}

::view-transition-new(root) {
  animation: 250ms ease-in both fade-in;
}

@keyframes fade-out {
  to { opacity: 0; }
}

@keyframes fade-in {
  from { opacity: 0; }
}
```

### Multi-Page Application (MPA)

```css
/* Enable for all navigation */
@view-transition {
  navigation: auto;
}

/* Or selective with types */
@view-transition {
  navigation: auto;
  types: slide, fade;
}
```

### Named View Transitions

```css
/* Give elements unique transition names */
.hero-image {
  view-transition-name: hero;
}

.page-title {
  view-transition-name: title;
}

/* Animate named elements independently */
::view-transition-old(hero) {
  animation: 300ms ease-out both scale-down;
}

::view-transition-new(hero) {
  animation: 300ms ease-in both scale-up;
}

::view-transition-old(title) {
  animation: 200ms ease-out both slide-out-left;
}

::view-transition-new(title) {
  animation: 200ms ease-in 100ms both slide-in-right;
}
```

### Reduced Motion Support

```css
@media (prefers-reduced-motion: reduce) {
  ::view-transition-group(*),
  ::view-transition-old(*),
  ::view-transition-new(*) {
    animation: none !important;
  }
}
```

## Starting Style Animations

### Dialog Animation

```css
dialog {
  opacity: 1;
  transform: translateY(0) scale(1);
  transition:
    opacity 0.3s ease,
    transform 0.3s ease,
    overlay 0.3s ease allow-discrete,
    display 0.3s ease allow-discrete;

  /* Entry animation starting point */
  @starting-style {
    opacity: 0;
    transform: translateY(-20px) scale(0.95);
  }
}

/* Exit animation ending point */
dialog:not([open]) {
  opacity: 0;
  transform: translateY(20px) scale(0.95);
}

/* Backdrop animation */
dialog::backdrop {
  background: oklch(0 0 0 / 0.5);
  opacity: 1;
  transition: opacity 0.3s ease, display 0.3s ease allow-discrete;

  @starting-style {
    opacity: 0;
  }
}

dialog:not([open])::backdrop {
  opacity: 0;
}
```

### Popover Animation

```css
[popover] {
  opacity: 1;
  transform: translateY(0);
  transition:
    opacity 0.2s ease,
    transform 0.2s ease,
    overlay 0.2s ease allow-discrete,
    display 0.2s ease allow-discrete;

  @starting-style {
    opacity: 0;
    transform: translateY(-10px);
  }
}

[popover]:not(:popover-open) {
  opacity: 0;
  transform: translateY(10px);
}
```

### Toast Notification

```css
.toast {
  position: fixed;
  inset-block-end: var(--space-md);
  inset-inline-end: var(--space-md);
  opacity: 1;
  transform: translateX(0);
  transition:
    opacity 0.3s ease,
    transform 0.3s ease,
    display 0.3s ease allow-discrete;

  @starting-style {
    opacity: 0;
    transform: translateX(100%);
  }

  &.hiding {
    opacity: 0;
    transform: translateX(100%);
  }
}
```

## Logical Properties

### Basic Logical Properties

```css
.element {
  /* Block axis (vertical in horizontal writing mode) */
  margin-block: 1rem;           /* margin-top + margin-bottom */
  margin-block-start: 1rem;     /* margin-top */
  margin-block-end: 2rem;       /* margin-bottom */
  padding-block: 1rem 2rem;     /* top | bottom */

  /* Inline axis (horizontal in horizontal writing mode) */
  margin-inline: auto;          /* margin-left + margin-right */
  margin-inline-start: 1rem;    /* margin-left in LTR */
  margin-inline-end: 2rem;      /* margin-right in LTR */
  padding-inline: 1rem;         /* left + right */

  /* Sizing */
  inline-size: 100%;            /* width */
  block-size: auto;             /* height */
  max-inline-size: 1200px;      /* max-width */
  min-block-size: 100dvh;       /* min-height */
}
```

### Logical Position Properties

```css
.overlay {
  position: fixed;
  /* All sides */
  inset: 0;

  /* Or specific */
  inset-block: 0;               /* top + bottom: 0 */
  inset-inline: 0;              /* left + right: 0 */
  inset-block-start: 0;         /* top: 0 */
  inset-inline-end: 1rem;       /* right: 1rem in LTR */
}
```

### Logical Border Radius

```css
.card {
  /* Individual corners */
  border-start-start-radius: 1rem;  /* top-left in LTR */
  border-start-end-radius: 1rem;    /* top-right in LTR */
  border-end-start-radius: 0;       /* bottom-left in LTR */
  border-end-end-radius: 0;         /* bottom-right in LTR */
}
```

### RTL/LTR Support

```css
/* Works automatically for both directions */
.nav {
  padding-inline-start: var(--space-lg);
  border-inline-end: 1px solid var(--color-border);
}

.icon {
  margin-inline-end: var(--space-sm);
}

/* The same CSS works in both directions:
   LTR: padding-left, border-right, margin-right
   RTL: padding-right, border-left, margin-left */
```

## Complete Component Examples

### Modern Card Component

```css
.card {
  container-type: inline-size;
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  overflow: hidden;

  &:hover {
    box-shadow: var(--shadow-md);
  }

  &:has(> img:first-child) {
    & > img:first-child {
      inline-size: 100%;
      block-size: 200px;
      object-fit: cover;
    }
  }

  & .card-content {
    padding: var(--space-md);
  }

  & .card-title {
    font-size: var(--text-lg);
    margin-block-end: var(--space-sm);
  }

  & .card-description {
    color: var(--color-text-muted);
    font-size: var(--text-sm);
  }

  @container (width >= 400px) {
    display: grid;
    grid-template-columns: 200px 1fr;

    &:has(> img:first-child) > img:first-child {
      block-size: 100%;
    }
  }
}
```

### Accessible Button System

```css
@layer components {
  .button {
    --button-bg: var(--color-accent);
    --button-text: white;
    --button-border: transparent;

    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: var(--space-xs);
    padding: var(--space-sm) var(--space-md);
    min-block-size: 44px;
    min-inline-size: 44px;
    font-size: var(--text-base);
    font-weight: 500;
    color: var(--button-text);
    background: var(--button-bg);
    border: 2px solid var(--button-border);
    border-radius: var(--radius-md);
    cursor: pointer;
    transition: all 0.2s ease;

    &:hover:not(:disabled) {
      filter: brightness(1.1);
    }

    &:focus-visible {
      outline: 2px solid var(--color-accent);
      outline-offset: 2px;
    }

    &:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }

    /* Variants */
    &--secondary {
      --button-bg: var(--color-secondary);
    }

    &--outline {
      --button-bg: transparent;
      --button-text: var(--color-accent);
      --button-border: currentColor;
    }

    &--ghost {
      --button-bg: transparent;
      --button-text: var(--color-accent);
    }

    /* Sizes */
    &--sm {
      padding: var(--space-xs) var(--space-sm);
      font-size: var(--text-sm);
      min-block-size: 36px;
    }

    &--lg {
      padding: var(--space-md) var(--space-lg);
      font-size: var(--text-lg);
    }

    /* Icon only */
    &:has(svg:only-child) {
      padding: var(--space-sm);
      aspect-ratio: 1;
    }

    @media (prefers-reduced-motion: reduce) {
      transition: none;
    }
  }
}
```

### Complete Dark Mode Implementation

```css
:root {
  /* Base color tokens */
  --gray-0: oklch(1 0 0);
  --gray-50: oklch(0.98 0 0);
  --gray-100: oklch(0.95 0 0);
  --gray-200: oklch(0.9 0 0);
  --gray-300: oklch(0.8 0 0);
  --gray-700: oklch(0.35 0 0);
  --gray-800: oklch(0.25 0 0);
  --gray-900: oklch(0.15 0 0);
  --gray-950: oklch(0.1 0 0);

  /* Semantic tokens - light mode */
  --color-bg: var(--gray-50);
  --color-surface: var(--gray-0);
  --color-surface-raised: var(--gray-0);
  --color-text: var(--gray-900);
  --color-text-muted: var(--gray-700);
  --color-border: var(--gray-200);
  --color-border-subtle: var(--gray-100);

  color-scheme: light dark;
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-bg: var(--gray-950);
    --color-surface: var(--gray-900);
    --color-surface-raised: var(--gray-800);
    --color-text: var(--gray-50);
    --color-text-muted: var(--gray-300);
    --color-border: var(--gray-700);
    --color-border-subtle: var(--gray-800);
  }
}

/* Manual toggle support */
[data-theme="light"] {
  --color-bg: var(--gray-50);
  --color-surface: var(--gray-0);
  /* ... light values */
}

[data-theme="dark"] {
  --color-bg: var(--gray-950);
  --color-surface: var(--gray-900);
  /* ... dark values */
}
```
