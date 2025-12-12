# Modern CSS Plugin for Claude Code

A comprehensive Claude Code plugin for modern vanilla CSS development - helping you build responsive, maintainable web interfaces without preprocessors or frameworks.

## Overview

Modern CSS has evolved dramatically, incorporating features that previously required preprocessors like Sass or build tools. This plugin provides Claude Code with deep expertise in native CSS capabilities, enabling it to help you write clean, performant, and maintainable stylesheets.

## Features

This plugin covers all major modern CSS features:

- **CSS Custom Properties**: Variables, theming, and JavaScript integration
- **OKLCH Color Space**: Perceptually uniform colors for consistent design systems
- **:has() Selector**: Parent selection, sibling styling, and state-based styling
- **Cascade Layers**: Specificity management with `@layer`
- **Native Nesting**: Sass-like nesting without preprocessors
- **Container Queries**: Component-level responsive design
- **View Transitions API**: Smooth page and state transitions
- **@starting-style**: Animate from `display: none`
- **Logical Properties**: Writing-mode aware layouts for internationalization
- **clamp()/min()/max()**: Fluid typography and responsive values
- **Device and Preference Queries**: Accessibility and capability detection

## Installation

```bash
# Clone or copy to your Claude Code plugins directory
cp -r plugins/modern-css ~/.claude/plugins/
```

## Skill Activation

The skill activates when you mention:
- CSS styling or stylesheets
- Responsive design or breakpoints
- Theming or dark mode
- CSS variables or custom properties
- Animations or transitions
- Modern CSS features
- Container queries or media queries
- Color systems or OKLCH

## What the Skill Provides

### Design Guidance
- Token architecture (primitive vs. semantic)
- Two-layer theming systems
- Mobile-first responsive strategies
- Component-level vs. page-level queries

### Code Examples
- Complete component patterns
- Form validation with `:has()`
- Dialog/popover animations with `@starting-style`
- View transitions for navigation
- Dark mode implementation

### Best Practices
- Progressive enhancement with `@supports`
- Accessibility requirements (motion, contrast, touch targets)
- Performance optimization
- Migration from Sass/preprocessors

## Example Usage

```
User: "I need to implement dark mode for my site"
Claude: [Activates vanilla-css skill]
        I'll help you implement a modern dark mode system using CSS custom properties
        and OKLCH colors...
        [Provides two-layer token architecture and media query setup]

User: "How do I make my cards responsive without media queries?"
Claude: [Activates vanilla-css skill]
        You can use container queries for component-level responsiveness...
        [Provides container query patterns and fluid layout examples]

User: "I want to animate a dialog opening from hidden state"
Claude: [Activates vanilla-css skill]
        You can use @starting-style combined with transition-behavior: allow-discrete...
        [Provides complete dialog animation pattern]
```

## Key Concepts

### No Build Step Required
All features work natively in modern browsers. No Sass, PostCSS, or build tools needed.

### Progressive Enhancement
Use `@supports` for feature detection and provide fallbacks:

```css
@supports (container-type: inline-size) {
  .card {
    container-type: inline-size;
  }
}
```

### OKLCH for Colors
Perceptually uniform color space for consistent design systems:

```css
:root {
  --color-primary: oklch(0.6 0.2 250);
  --color-primary-light: oklch(0.8 0.15 250);
}
```

### Container Queries for Components
Responsive design at the component level:

```css
.card {
  container-type: inline-size;
}

@container (width >= 400px) {
  .card { grid-template-columns: 200px 1fr; }
}
```

### Cascade Layers for Specificity
Manage CSS cascade without specificity wars:

```css
@layer reset, base, components, utilities;

@layer components {
  .button { /* styles */ }
}
```

## Directory Structure

```
modern-css/
├── README.md                    # This file
└── skills/
    └── vanilla-css/
        ├── SKILL.md             # Main skill definition
        ├── examples.md          # Concrete usage examples
        ├── reference.md         # Complete feature reference
        └── workflows.md         # Workflow patterns
```

## Browser Support

| Feature | Chrome | Firefox | Safari | Global |
|---------|--------|---------|--------|--------|
| CSS Custom Properties | 49+ | 31+ | 9.1+ | ~97% |
| OKLCH Colors | 111+ | 113+ | 15.4+ | ~92% |
| :has() Selector | 105+ | 121+ | 15.4+ | ~92% |
| Cascade Layers | 99+ | 97+ | 15.4+ | ~93% |
| Native Nesting | 120+ | 117+ | 17.2+ | ~90% |
| Container Queries | 105+ | 110+ | 16+ | ~91% |
| View Transitions | 111+ | - | 18+ | ~75% |
| @starting-style | 117+ | 129+ | 17.5+ | ~86% |
| Logical Properties | 87+ | 66+ | 14.1+ | ~95% |
| clamp()/min()/max() | 79+ | 75+ | 13.1+ | ~96% |

## Accessibility Built-In

The skill emphasizes accessibility throughout:

- `prefers-reduced-motion` for animations
- `prefers-color-scheme` for dark mode
- `prefers-contrast` for high contrast support
- Minimum touch target sizes (44x44px)
- WCAG color contrast guidance
- `rem`-based typography for text scaling

## Migration from Preprocessors

The skill includes guidance for migrating from Sass/Less:

| Sass Feature | Native CSS Equivalent |
|--------------|----------------------|
| Variables | CSS Custom Properties |
| Nesting | Native nesting with `&` |
| Color functions | OKLCH + color-mix() |
| Math | calc(), clamp(), min(), max() |
| @import | Native @import + @layer |

## Resources

- [CSS-Tricks Modern CSS Guide](https://css-tricks.com)
- [MDN CSS Reference](https://developer.mozilla.org/en-US/docs/Web/CSS)
- [Can I Use](https://caniuse.com) - Browser support tables
- [OKLCH Color Picker](https://oklch.com)
- [Claude Code Documentation](https://docs.claude.com/claude-code)

## Contributing

Contributions are welcome! Please submit issues or pull requests to improve this plugin.

## License

Apache-2.0

## Author

Created with Claude Code

## Acknowledgments

- MDN Web Docs for comprehensive CSS documentation
- CSS Working Group for ongoing CSS specification work
- Anthropic for Claude Code
