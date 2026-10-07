---
name: elementor-page-building
description: Elementor layout rules for morntag client sites. Use when building or editing an Elementor page, container, template, Theme Builder part or Loop item (in the editor, as template JSON, or via WP-CLI), when converting a design or HTML mockup to Elementor, or when reviewing an Elementor page for structure, spacing, global-style or DOM-size problems.
---

# Elementor page building

Build pages that inherit the site's design system, keep the DOM small and stay editable by non-developers. Rules tagged **[E]** are Elementor's own (help centre / blog), **[C]** community consensus, **[M]** morntag convention. Source URLs, WP-CLI recipes and the template-JSON conventions live in [`REFERENCE.md`](REFERENCE.md).

Vocabulary: a page is a tree of **containers** (flex or grid) holding **widgets**. Sections, Columns and Inner Sections are legacy; new work uses containers only (or V4 atomic elements where the site has them enabled).

## 1. Read the site before building

Completion criterion: you can name the site's globals, Theme Style coverage, layout defaults and existing templates before placing the first container. A page styled with local values on a site that has a design system is a defect.

1. **Design System** (Site Settings): list Global Colors (Primary, Secondary, Text, Accent + custom) and Global Fonts (Primary, Secondary, Text, Accent + custom) with their names. **[E]**
2. **Theme Style**: note what h1–h6, p, a, buttons, form fields and images already inherit. A complete Theme Style means widgets need no local typography at all. **[E]**
3. **Layout**: content width (default 1140 px), default container padding, default gap (20 px), breakpoints. Build with these values. **[E]**
4. **Editor V4 active?** If so, list Variables and global Classes in the Design System panel and reuse them (`btn`, `btn-primary`, container presets …). **[E]**
5. **Templates and Theme Builder parts**: saved containers/pages, header, footer, single, archive, loop items, global widgets/components. Reuse before creating. **[E]**
6. **One or two well-built existing pages**: mirror their structure, naming and section rhythm. **[M]**
7. **Active features** (Elementor → Settings → Features): Grid Container, Nested Elements, Optimized Markup, Atomic elements. They decide which elements exist. **[E]**

On a wp-local site read all of this with `wpl cli` (recipes in `REFERENCE.md`); otherwise through the editor UI. If none of it is readable, ask before building.

## 2. Structure: minimum containers

- Every container is a DOM node; use the fewest that produce the layout. A nested container holding a single element is a smell: put the widget in the parent. **[E]**
- Nest a container only for: a different direction than the parent; a group sharing a background, border, hover or motion effect; a group saved or moved as one unit; responsive reordering of a group; a clickable container (`<a>` tag) that needs a button inside. **[E]**
- Flatten chains: a container whose only child is another container collapses into one. **[E]**
- Top-level containers are **Boxed** (respect content width); nested containers are **Full Width**. Boxed renders two divs, full width one. **[E]**
- Set **Direction** first, then **Justify** (main axis) and **Align** (cross axis). Stretch only works on items without a fixed width. **[E]**
- A heading above a row of cards is one container with **Wrap** on and % item widths, not an inner wrapper. **[E]**
- **Grid container** for symmetric repeating layouts (card grids, logo walls); **flex container** for asymmetric or one-directional layouts. A grid cell holds one element; nest only when a cell needs more. **[E]**
- Min-height lives on nested elements; parents stay without it (100vh heroes excepted). **[E]**
- Horizontal margin belongs on a child container; on a top-level container it causes horizontal scroll. **[E]**
- Positioning is flow-based; absolute/fixed is reserved for badges and decorative shapes. **[E]**
- Every top-level container gets a semantic **HTML tag** (`section`, `header`, `nav`, `footer`, `aside`, `article`); exactly one `h1` per page, no skipped heading levels. **[E]**
- Target well under ~800 DOM nodes (Lighthouse warns at 818, errors at 1 400). **[E]**

## 3. Spacing: gap, padding, margin

- Space between siblings comes from the container **Gap**; space inside a container from its **Padding**; **Margin** is the rare outside nudge (negative margin + z-index for overlaps). **[E]**
- The **Spacer widget** is the one hard ban: it adds markup and breaks responsive flow. Any gap it would create is a gap or padding value instead. **[E]**
- Vertical section rhythm = identical top/bottom padding on every top-level container, not margin on first/last widgets. **[M]**
- Use one spacing scale and stick to it (the site's existing scale, else 8/16/24/32/48/64/96 px or the rem equivalents). **[C]**
- Item widths plus gaps sum to ≤ 100 % when wrapping (three cards: 32 % each, 2 % gap). **[E]**
- Empty containers, empty widgets and stacked `<br>` in Text Editor are spacing bugs. **[M]**

## 4. Styling: globals first

- Every colour and typography control that shows the **globe icon** points at a Global. One change in Site Settings must restyle the whole site. **[E]**
- Headings and paragraphs inherit **Theme Style**: set the HTML tag (h2, h3 …) on Heading widgets and leave typography untouched. The tag is structure/SEO; the look comes from Theme Style. **[E]**
- Buttons inherit Theme Style → Buttons (or, in V4, the site's `btn`/`btn-primary`-style classes). Inline-styled buttons are a defect. **[E]**
- A value that will be reused but has no Global yet becomes a new named Global (`Surface`, `Border`, `Muted text`); only true one-offs stay local. **[E]**
- When setting up a site, fill every Theme Style field so it is the guaranteed fallback. **[E]**
- V4: style through Variables + global Classes and leave the local class empty whenever a class exists. Build order: variables → a few base classes (base + modifier) → container presets → components. **[E]/[C]**
- Custom CSS goes in the Custom CSS panel (element/page/site) with a comment saying why, only for what flex/grid settings cannot do. Target `.e-con`, `.elementor-widget-*`, `.elementor-button`; the old wrappers (`.elementor-inner`, `.elementor-column-wrap`, `.elementor-button-wrapper`) no longer exist. **[E]**
- Before saving, hover controls for the **reset icon** to catch accidental local overrides. **[E]**
- Typefaces stay within the Global Fonts (one or two families, few weights). **[E]/[C]**

## 5. Responsive

- Values cascade **desktop → tablet → mobile**. Set desktop, then override only what breaks on smaller breakpoints. **[E]**
- Repeated items: desktop row + space-between + gap → tablet Wrap on, justify centre, ~45 % widths, px gaps → mobile direction column / item size Grow. **[E]**
- Reorder on mobile with direction *Column reversed* or per-breakpoint order of one element, never a duplicated element hidden per device (hidden elements still load). **[E]/[C]**
- Units: % for widths, vh/vw for full-screen heroes, rem/em for type and spacing where the site already does so; px gaps are fine on tablet/mobile. **[E]**
- Mobile pass: container padding keeps text off the viewport edges, font sizes per breakpoint where Theme Style doesn't cover it, touch targets ≥ 44 px, motion effects and video backgrounds off. **[E]**
- Finish by walking every breakpoint in Responsive Mode; regenerate CSS (Tools → Regenerate CSS) if changes don't show. **[E]**

## 6. Widgets

- Native Elementor / Elementor Pro widgets first; third-party addons only when the site already uses them. **[C]**
- One widget that does the job (Image Box, Icon Box, Icon List) beats a stack of widgets in a container, as long as its styling still comes from globals. **[C]**
- Nested Tabs / Accordion / Carousel / Mega Menu over the legacy versions. **[E]**
- Any post, CPT or product listing is a **Loop Grid** with a Loop Item template, with pagination set. **[E]**
- Heading widget for headings (right tag), Text Editor for paragraphs and inline lists. **[M]**
- HTML widget only for embeds that have no widget. **[M]**
- Images: a fitting image size (not "Full" by default), alt text, optimised/WebP, lazy below the fold. **[E]**
- Content that lives in a field (ACF, JetEngine, post data) is bound with Dynamic Tags, not pasted. **[M]**
- Element caching: on for static containers, off for elements with dynamic tags or shortcodes. **[E]**

## 7. Templates and Theme Builder

- Structural, condition-driven layouts (header, footer, single, archive, 404, search) are Theme Builder parts; build header and footer together. Set Display Conditions deliberately and check for conflicts. **[E]**
- Repeatable page layouts are a Single Page template with a Post Content widget; those pages use the *Default* page layout. **[E]**
- Reusable blocks inserted by hand: **Save as Template**. Blocks that must stay in sync everywhere: Global Widget / V4 Component; unlink only for a true one-off. **[E]**
- Name templates by kind and purpose: `Section – Hero (image left)`, `Loop Item – Referenz card`. **[M]**

## 8. Structure panel

- Rename every container: `Hero`, `Hero / Text`, `Hero / CTA row`, `Referenzen / Grid`. Widgets keep their default name unless ambiguous. **[E]/[M]**
- Structure markers (absolute positioning, custom CSS, motion effects, display conditions) each need a reason you can state. **[E]**

## 9. Hand-over checklist

Done means every line holds:

- [ ] Containers only; no Spacer widgets, no empty containers.
- [ ] No single-child nested containers; nested containers full width inside a boxed parent.
- [ ] Every colour/font control on a Global or inheriting Theme Style; no stray hex codes or fonts.
- [ ] Heading tags correct (one h1, no skipped levels); no per-widget typography.
- [ ] Spacing from gap/padding on the site scale; consistent section padding.
- [ ] Semantic tags on top-level containers; alt text on every image; descriptive button/link text.
- [ ] Tablet and mobile walked; no duplicated hide-per-device elements.
- [ ] Every container named in the Structure panel.
- [ ] Custom CSS only where unavoidable, commented, targeting current selectors.
- [ ] Dynamic Tags / Loop Grid for field-driven content; element caching sane.
- [ ] Lighthouse DOM-size audit green.
