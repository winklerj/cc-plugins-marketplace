# Modern CSS Reference

Complete reference documentation for modern CSS features, syntax, and browser support.

## Table of Contents
- [CSS Custom Properties](#css-custom-properties)
- [OKLCH Color Space](#oklch-color-space)
- [The :has() Selector](#the-has-selector)
- [Cascade Layers](#cascade-layers)
- [Native CSS Nesting](#native-css-nesting)
- [Container Queries](#container-queries)
- [View Transitions API](#view-transitions-api)
- [@starting-style Rule](#starting-style-rule)
- [Logical Properties](#logical-properties)
- [Math Functions](#math-functions)
- [Device and Preference Queries](#device-and-preference-queries)
- [Additional Modern Features](#additional-modern-features)
- [Browser Support Summary](#browser-support-summary)

## CSS Custom Properties

### Syntax

```css
/* Definition */
--property-name: value;

/* Usage */
property: var(--property-name);
property: var(--property-name, fallback);
property: var(--property-name, var(--other-property, final-fallback));
```

### Scoping

| Scope | Selector | Inheritance |
|-------|----------|-------------|
| Global | `:root` | Available everywhere |
| Component | `.component` | Available to descendants |
| Element | `#specific` | Limited to element |

### @property Registration

```css
@property --gradient-angle {
  syntax: "<angle>";
  initial-value: 0deg;
  inherits: false;
}
```

**syntax values:**
- `<length>`, `<number>`, `<percentage>`
- `<color>`, `<image>`, `<angle>`
- `<time>`, `<resolution>`
- `<transform-function>`, `<transform-list>`
- `<custom-ident>`, `<string>`, `<url>`
- `*` (any value)
- `<type>+` (space-separated list)
- `<type>#` (comma-separated list)
- `<type1> | <type2>` (either type)

### Naming Conventions

**Triptych notation:** `namespace-valueType-variableName`

```css
:root {
  /* Namespace: color */
  --color-primary-base: oklch(0.6 0.2 250);
  --color-primary-light: oklch(0.8 0.15 250);

  /* Namespace: spacing */
  --spacing-size-sm: 0.5rem;
  --spacing-size-md: 1rem;

  /* Namespace: font */
  --font-size-base: 1rem;
  --font-weight-bold: 700;
}
```

### JavaScript API

```javascript
// Get computed value
getComputedStyle(element).getPropertyValue('--property');

// Set value on element
element.style.setProperty('--property', 'value');

// Remove value
element.style.removeProperty('--property');

// Get from :root
getComputedStyle(document.documentElement).getPropertyValue('--property');
```

### Browser Support
- **Chrome**: 49+ (March 2016)
- **Firefox**: 31+ (July 2014)
- **Safari**: 9.1+ (March 2016)
- **Edge**: 15+ (April 2017)
- **Global**: ~97%

---

## OKLCH Color Space

### Syntax

```css
/* Basic */
oklch(L C H)
oklch(Lightness Chroma Hue)

/* With alpha */
oklch(L C H / alpha)
oklch(0.6 0.2 250 / 0.5)

/* Using percentages for L */
oklch(60% 0.2 250)
```

### Parameters

| Parameter | Range | Description |
|-----------|-------|-------------|
| L (Lightness) | 0-1 or 0%-100% | Perceived brightness. 0 = black, 1 = white |
| C (Chroma) | 0-0.37 | Color intensity. 0 = gray, higher = more saturated |
| H (Hue) | 0-360 | Color wheel angle |
| alpha | 0-1 | Transparency. 0 = invisible, 1 = opaque |

### Hue Reference

| Hue | Color |
|-----|-------|
| 0-30 | Red |
| 30-60 | Orange |
| 60-110 | Yellow |
| 110-170 | Green |
| 170-220 | Cyan |
| 220-280 | Blue |
| 280-330 | Purple/Violet |
| 330-360 | Magenta/Pink |

### color-mix()

```css
/* Basic mixing (50/50) */
color-mix(in oklch, color1, color2)

/* Percentage mixing */
color-mix(in oklch, color1 75%, color2)    /* 75% color1, 25% color2 */
color-mix(in oklch, color1, color2 30%)    /* 70% color1, 30% color2 */
color-mix(in oklch, color1 60%, color2 40%) /* explicit both */

/* Tints and shades */
color-mix(in oklch, var(--color), white 30%)  /* tint */
color-mix(in oklch, var(--color), black 30%)  /* shade */
```

### Relative Color Syntax

```css
/* From existing color, modify components */
oklch(from var(--base) L C H)

/* Modify lightness */
oklch(from var(--color) calc(l + 0.1) c h)      /* lighten */
oklch(from var(--color) calc(l * 0.8) c h)      /* darken */

/* Modify chroma */
oklch(from var(--color) l calc(c * 1.5) h)      /* more saturated */
oklch(from var(--color) l calc(c * 0.5) h)      /* less saturated */

/* Modify hue */
oklch(from var(--color) l c calc(h + 30))       /* shift hue */
oklch(from var(--color) l c calc(h + 180))      /* complementary */

/* Add transparency */
oklch(from var(--color) l c h / 0.5)
```

### Browser Support
- **Chrome**: 111+ (March 2023)
- **Firefox**: 113+ (May 2023)
- **Safari**: 15.4+ (March 2022)
- **Edge**: 111+ (March 2023)
- **Global**: ~92%

---

## The :has() Selector

### Syntax

```css
/* Has descendant */
parent:has(descendant) { }

/* Has direct child */
parent:has(> child) { }

/* Has following sibling */
element:has(+ sibling) { }

/* Has any following sibling */
element:has(~ sibling) { }

/* Multiple conditions (OR) */
element:has(selector1, selector2) { }

/* Multiple conditions (AND) */
element:has(selector1):has(selector2) { }

/* Negation */
element:not(:has(selector)) { }
```

### Use Cases

| Pattern | Selector | Purpose |
|---------|----------|---------|
| Parent styling | `.card:has(img)` | Style card if it contains image |
| Previous sibling | `li:has(+ li:hover)` | Style item before hovered item |
| Form validation | `form:has(:invalid)` | Style form with invalid inputs |
| State detection | `.menu:has(:focus-within)` | Detect focus inside menu |
| Quantity queries | `ul:has(> li:nth-child(5))` | Style if 5+ items |

### Performance Considerations

```css
/* SLOWER: Forces evaluation of entire subtree */
.page:has(.deeply .nested .element) { }

/* FASTER: Direct child, limited scope */
.card:has(> .header) { }

/* FASTER: Combined with other selectors */
.form-group:has(> input:invalid) .error { }
```

### Browser Support
- **Chrome**: 105+ (August 2022)
- **Firefox**: 121+ (December 2023)
- **Safari**: 15.4+ (March 2022)
- **Edge**: 105+ (August 2022)
- **Global**: ~92%

---

## Cascade Layers

### Syntax

```css
/* Declare layer order */
@layer layer1, layer2, layer3;

/* Define layer content */
@layer layerName {
  /* styles */
}

/* Anonymous layer (lowest priority) */
@layer {
  /* styles */
}

/* Nested layers */
@layer outer {
  @layer inner {
    /* styles */
  }
}

/* Reference nested layer */
@layer outer.inner {
  /* styles */
}

/* Import into layer */
@import url("file.css") layer(layerName);
```

### Layer Priority

```
Lowest Priority
    |
    v
  Unlayered styles (always win in normal cascade)
    ^
    |
  Last declared layer
    ^
    |
  ...
    ^
    |
  First declared layer
    |
Highest Priority (for !important - REVERSED)
```

### Recommended Layer Order

```css
@layer reset, base, layout, components, utilities;
```

| Layer | Purpose | Examples |
|-------|---------|----------|
| reset | Browser normalization | Box-sizing, margins |
| base | Element defaults | Typography, links |
| layout | Page structure | Grid, containers |
| components | UI components | Buttons, cards |
| utilities | Overrides | .hidden, .flex |

### !important Behavior

```css
/* Normal: utilities > components */
/* !important: REVERSED - components > utilities */

@layer components {
  .button { color: blue !important; }  /* WINS with !important */
}

@layer utilities {
  .text-red { color: red !important; } /* Loses to components !important */
}
```

### Browser Support
- **Chrome**: 99+ (March 2022)
- **Firefox**: 97+ (February 2022)
- **Safari**: 15.4+ (March 2022)
- **Edge**: 99+ (March 2022)
- **Global**: ~93%

---

## Native CSS Nesting

### Syntax

```css
/* Nesting requires & in most cases */
.parent {
  /* Direct property */
  color: blue;

  /* Nested with & */
  &:hover { }
  &::before { }
  & .child { }
  & > .direct-child { }
  &.modifier { }

  /* Media queries nest without & */
  @media (width >= 768px) { }

  /* Container queries nest without & */
  @container (width >= 400px) { }

  /* Layer nesting */
  @layer components { }

  /* Supports nesting */
  @supports (display: grid) { }
}
```

### Rules and Limitations

| Rule | Example | Notes |
|------|---------|-------|
| & required for selectors | `& .child` | Cannot write `.child` alone |
| No suffix concatenation | `&-modifier` | Does NOT work (use `&.parent-modifier`) |
| Parent styles first | See below | Declare parent properties before nesting |
| Max depth: 2-3 | | Deeper nesting hurts readability |

```css
/* CORRECT order */
.element {
  color: blue;        /* Parent styles first */

  &:hover {           /* Nested after */
    color: red;
  }
}

/* NOT recommended */
.element {
  &:hover { color: red; }
  color: blue;        /* Parent after nesting */
}
```

### Specificity

Nested selectors use `:is()` semantics:

```css
/* This nesting... */
.foo {
  & .bar { }
}

/* ...is equivalent to: */
:is(.foo) .bar { }
```

### Browser Support
- **Chrome**: 120+ (December 2023)
- **Firefox**: 117+ (August 2023)
- **Safari**: 17.2+ (December 2023)
- **Edge**: 120+ (December 2023)
- **Global**: ~90%

---

## Container Queries

### Syntax

```css
/* Define container */
.container {
  container-type: inline-size;
  container-name: optional-name;
}

/* Shorthand */
.container {
  container: name / inline-size;
}

/* Query container */
@container (width >= 400px) { }
@container name (width >= 400px) { }
@container (inline-size >= 400px) { }
```

### Container Types

| Type | Description |
|------|-------------|
| `inline-size` | Query inline dimension (width in horizontal writing) |
| `size` | Query both dimensions |
| `normal` | Not a query container (default) |

### Container Query Units

| Unit | Description |
|------|-------------|
| `cqw` | 1% of container width |
| `cqh` | 1% of container height |
| `cqi` | 1% of container inline size |
| `cqb` | 1% of container block size |
| `cqmin` | Smaller of cqi/cqb |
| `cqmax` | Larger of cqi/cqb |

### Style Queries

```css
/* Query custom property values */
@container style(--theme: dark) {
  .element { }
}

/* Query computed styles */
@container style(font-style: italic) {
  .element { }
}
```

### Browser Support
- **Chrome**: 105+ (August 2022)
- **Firefox**: 110+ (February 2023)
- **Safari**: 16+ (September 2022)
- **Edge**: 105+ (August 2022)
- **Global**: ~91%

---

## View Transitions API

### SPA Syntax (JavaScript)

```javascript
// Basic usage
document.startViewTransition(() => {
  updateDOM();
});

// With promises
document.startViewTransition(async () => {
  await fetchNewContent();
  updateDOM();
});

// Check support
if (document.startViewTransition) {
  document.startViewTransition(() => updateDOM());
} else {
  updateDOM();
}
```

### MPA Syntax (CSS)

```css
/* Enable for navigation */
@view-transition {
  navigation: auto;
}

/* With types */
@view-transition {
  navigation: auto;
  types: slide-in, slide-out;
}
```

### CSS Pseudo-Elements

| Pseudo-element | Description |
|----------------|-------------|
| `::view-transition` | Root overlay |
| `::view-transition-group(name)` | Wrapper for old/new |
| `::view-transition-image-pair(name)` | Container for images |
| `::view-transition-old(name)` | Snapshot of old state |
| `::view-transition-new(name)` | Live new state |

### Named Transitions

```css
/* Give element unique name */
.element {
  view-transition-name: unique-name;
}

/* Auto-generate unique names */
.list-item {
  view-transition-name: match-element;
}

/* Animate specific elements */
::view-transition-old(unique-name) {
  animation: slide-out 0.3s ease;
}

::view-transition-new(unique-name) {
  animation: slide-in 0.3s ease;
}
```

### Browser Support
- **Chrome**: 111+ (SPA), 126+ (MPA)
- **Firefox**: Not supported (as of late 2024)
- **Safari**: 18+ (SPA only)
- **Edge**: 111+ (SPA), 126+ (MPA)
- **Global**: ~75% (SPA)

---

## @starting-style Rule

### Syntax

```css
/* Nested syntax (recommended) */
.element {
  opacity: 1;
  transition: opacity 0.3s;

  @starting-style {
    opacity: 0;
  }
}

/* Standalone syntax */
@starting-style {
  .element {
    opacity: 0;
  }
}
```

### Required for display: none Animation

```css
dialog {
  /* Final "open" state */
  opacity: 1;
  transform: scale(1);

  /* Transition including display */
  transition:
    opacity 0.3s,
    transform 0.3s,
    display 0.3s allow-discrete,
    overlay 0.3s allow-discrete;

  /* Initial appearance state */
  @starting-style {
    opacity: 0;
    transform: scale(0.9);
  }
}

/* Closed/hidden state */
dialog:not([open]) {
  opacity: 0;
  transform: scale(0.9);
}
```

### transition-behavior

```css
.element {
  /* Required for animating display/overlay */
  transition-behavior: allow-discrete;

  /* Or in shorthand */
  transition: opacity 0.3s allow-discrete;
}
```

### Browser Support
- **Chrome**: 117+ (September 2023)
- **Firefox**: 129+ (August 2024)
- **Safari**: 17.5+ (May 2024)
- **Edge**: 117+ (September 2023)
- **Global**: ~86%

---

## Logical Properties

### Property Mapping

| Physical | Logical (horizontal-tb) |
|----------|------------------------|
| `width` | `inline-size` |
| `height` | `block-size` |
| `min-width` | `min-inline-size` |
| `max-height` | `max-block-size` |
| `margin-left` | `margin-inline-start` |
| `margin-right` | `margin-inline-end` |
| `margin-top` | `margin-block-start` |
| `margin-bottom` | `margin-block-end` |
| `padding-left` | `padding-inline-start` |
| `padding-right` | `padding-inline-end` |
| `top` | `inset-block-start` |
| `right` | `inset-inline-end` |
| `bottom` | `inset-block-end` |
| `left` | `inset-inline-start` |
| `border-top` | `border-block-start` |
| `border-left` | `border-inline-start` |
| `border-top-left-radius` | `border-start-start-radius` |
| `border-top-right-radius` | `border-start-end-radius` |
| `border-bottom-left-radius` | `border-end-start-radius` |
| `border-bottom-right-radius` | `border-end-end-radius` |

### Shorthand Properties

```css
.element {
  /* Inline axis (left/right in LTR) */
  margin-inline: 1rem;              /* both */
  margin-inline: 1rem 2rem;         /* start | end */
  padding-inline: 1rem;

  /* Block axis (top/bottom) */
  margin-block: 1rem;               /* both */
  margin-block: 1rem 2rem;          /* start | end */
  padding-block: 1rem;

  /* Inset (positioning) */
  inset: 0;                         /* all sides */
  inset-inline: 0;                  /* left/right */
  inset-block: 0;                   /* top/bottom */
}
```

### Browser Support
- **Chrome**: 87+ (November 2020)
- **Firefox**: 66+ (March 2019)
- **Safari**: 14.1+ (April 2021)
- **Edge**: 87+ (November 2020)
- **Global**: ~95%

---

## Math Functions

### clamp()

```css
/* clamp(MIN, PREFERRED, MAX) */
font-size: clamp(1rem, 2.5vw + 0.5rem, 2rem);

/* Value will be:
   - At least 1rem (minimum)
   - Ideally 2.5vw + 0.5rem (preferred)
   - At most 2rem (maximum)
*/
```

### min()

```css
/* Returns smallest value */
width: min(100%, 1200px);        /* Smaller of the two */
width: min(50vw, 600px, 100%);   /* Smallest of all */
```

### max()

```css
/* Returns largest value */
width: max(300px, 50%);          /* Larger of the two */
padding: max(1rem, 5%);          /* Larger of the two */
```

### Nesting Math Functions

```css
/* Can nest functions */
width: min(max(300px, 30%), 100% - 2rem);

/* With calc() */
padding: clamp(1rem, calc(1rem + 2vw), 3rem);
```

### Common Patterns

```css
/* Fluid typography */
font-size: clamp(1rem, 0.5rem + 2vw, 2rem);

/* Responsive container */
width: min(100% - 2rem, 1200px);

/* Minimum spacing */
gap: max(1rem, 2vw);

/* Content width */
max-width: min(65ch, 100%);
```

### Browser Support
- **Chrome**: 79+ (December 2019)
- **Firefox**: 75+ (April 2020)
- **Safari**: 13.1+ (March 2020)
- **Edge**: 79+ (January 2020)
- **Global**: ~96%

---

## Device and Preference Queries

### Motion Preference

```css
/* Respect reduced motion preference */
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

/* Only animate when no preference */
@media (prefers-reduced-motion: no-preference) {
  .element {
    transition: transform 0.3s ease;
  }
}
```

### Color Scheme Preference

```css
@media (prefers-color-scheme: dark) {
  :root {
    --color-bg: oklch(0.15 0.01 250);
    --color-text: oklch(0.95 0.01 250);
  }
}

@media (prefers-color-scheme: light) {
  :root {
    --color-bg: oklch(0.98 0.01 250);
    --color-text: oklch(0.15 0.01 250);
  }
}
```

### Pointer and Hover Capabilities

```css
/* Touch devices */
@media (pointer: coarse) {
  .button {
    min-height: 48px;
    min-width: 48px;
  }
}

/* Mouse/trackpad */
@media (pointer: fine) {
  .button {
    min-height: 32px;
  }
}

/* Devices that support hover */
@media (hover: hover) {
  .button:hover {
    background: var(--color-hover);
  }
}

/* Touch devices without hover */
@media (hover: none) {
  .button:active {
    background: var(--color-active);
  }
}

/* Any input supports hover */
@media (any-hover: hover) {
  .interactive:hover {
    outline: 2px solid var(--color-focus);
  }
}
```

### Contrast Preference

```css
@media (prefers-contrast: more) {
  :root {
    --color-border: black;
    --color-text: black;
  }
}

@media (prefers-contrast: less) {
  :root {
    --color-border: oklch(0.7 0 0);
  }
}
```

### Transparency Preference

```css
@media (prefers-reduced-transparency: reduce) {
  .overlay {
    background: var(--color-surface);  /* Solid instead of transparent */
  }
}
```

### Character-Based Breakpoints

```css
/* Content-driven breakpoints */
@media (min-width: 65ch) {
  .article {
    max-width: 65ch;
  }
}

@media (min-width: 100ch) {
  .layout {
    display: grid;
    grid-template-columns: 1fr 65ch 1fr;
  }
}
```

---

## Additional Modern Features

### currentColor

```css
/* Inherits computed color value */
.icon {
  fill: currentColor;        /* Inherits text color */
  border: 1px solid currentColor;
}

.button {
  color: var(--button-text);
  border-color: currentColor;
  background: color-mix(in oklch, currentColor, transparent 90%);
}
```

### accent-color

```css
/* Style form controls */
:root {
  accent-color: var(--color-accent);
}

/* Per-element */
input[type="checkbox"] {
  accent-color: var(--color-success);
}
```

### CSS Masks

```css
.masked-element {
  mask-image: url('mask.svg');
  mask-size: cover;
  mask-repeat: no-repeat;

  /* Webkit prefix still needed */
  -webkit-mask-image: url('mask.svg');
  -webkit-mask-size: cover;
}

/* Gradient mask */
.fade-out {
  mask-image: linear-gradient(to bottom, black, transparent);
  -webkit-mask-image: linear-gradient(to bottom, black, transparent);
}
```

### mix-blend-mode

```css
/* Blend with background */
.overlay-text {
  mix-blend-mode: multiply;  /* Good for light backgrounds */
}

@media (prefers-color-scheme: dark) {
  .overlay-text {
    mix-blend-mode: screen;  /* Good for dark backgrounds */
  }
}

/* Common blend modes */
.element {
  mix-blend-mode: multiply;     /* Darkens */
  mix-blend-mode: screen;       /* Lightens */
  mix-blend-mode: overlay;      /* Contrast */
  mix-blend-mode: difference;   /* Inverts */
}
```

### scroll-behavior

```css
/* Smooth scrolling */
html {
  scroll-behavior: smooth;
}

/* Respect motion preference */
@media (prefers-reduced-motion: reduce) {
  html {
    scroll-behavior: auto;
  }
}
```

### scroll-snap

```css
/* Container */
.carousel {
  scroll-snap-type: x mandatory;
  overflow-x: auto;
}

/* Children */
.carousel-item {
  scroll-snap-align: start;
  scroll-snap-stop: always;
}
```

### text-wrap: balance

```css
/* Balance text across lines */
h1, h2, h3 {
  text-wrap: balance;
}

/* Pretty wrap (avoids orphans) */
p {
  text-wrap: pretty;
}
```

---

## Browser Support Summary

| Feature | Chrome | Firefox | Safari | Global |
|---------|--------|---------|--------|--------|
| CSS Custom Properties | 49+ | 31+ | 9.1+ | ~97% |
| OKLCH Colors | 111+ | 113+ | 15.4+ | ~92% |
| :has() Selector | 105+ | 121+ | 15.4+ | ~92% |
| Cascade Layers | 99+ | 97+ | 15.4+ | ~93% |
| Native Nesting | 120+ | 117+ | 17.2+ | ~90% |
| Container Queries | 105+ | 110+ | 16+ | ~91% |
| View Transitions (SPA) | 111+ | - | 18+ | ~75% |
| @starting-style | 117+ | 129+ | 17.5+ | ~86% |
| Logical Properties | 87+ | 66+ | 14.1+ | ~95% |
| clamp()/min()/max() | 79+ | 75+ | 13.1+ | ~96% |

### Feature Detection

```css
/* Feature queries */
@supports (container-type: inline-size) {
  /* Container query styles */
}

@supports selector(:has(*)) {
  /* :has() styles */
}

@supports (color: oklch(0 0 0)) {
  /* OKLCH styles */
}

@supports (view-transition-name: test) {
  /* View transition styles */
}

/* Combine with not */
@supports not (container-type: inline-size) {
  /* Fallback styles */
}
```

### Progressive Enhancement Strategy

```css
/* 1. Base styles work everywhere */
.element {
  display: flex;
  gap: 1rem;
}

/* 2. Enhance with modern features */
@supports (container-type: inline-size) {
  .element {
    container-type: inline-size;
  }

  @container (width >= 400px) {
    .element {
      display: grid;
    }
  }
}

/* 3. Use @layer for cascade control */
@layer base, enhanced;

@layer base {
  /* Baseline styles */
}

@layer enhanced {
  @supports (color: oklch(0 0 0)) {
    /* OKLCH colors */
  }
}
```
