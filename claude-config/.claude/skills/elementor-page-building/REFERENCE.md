# Elementor page building: reference

Companion to [`SKILL.md`](SKILL.md): WP-CLI recipes for reading a site's design system, the template-JSON conventions, and the sources behind each rule.

## Reading a site with WP-CLI (wp-local)

Elementor stores Site Settings in the active **kit**, a post of type `elementor_library`.

```bash
KIT=$(wpl cli <site> option get elementor_active_kit)
wpl cli <site> post meta get $KIT _elementor_page_settings --format=json
```

Keys in `_elementor_page_settings`:

| Key | Holds |
|-----|-------|
| `system_colors`, `custom_colors` | Global Colors (`_id`, `title`, `color`) |
| `system_typography`, `custom_typography` | Global Fonts (`_id`, `title`, `typography_*`) |
| `container_width`, `container_padding`, `space_between_widgets` | Layout defaults (content width, padding, gap) |
| `viewport_tablet`, `viewport_mobile`, `active_breakpoints` | Breakpoints |
| `body_*`, `h1_*` … `h6_*`, `button_*`, `link_*`, `field_*` | Theme Style |

Other useful lookups:

```bash
# Saved templates and Theme Builder parts (type in _elementor_template_type: page, container, header, footer, single, archive, loop-item …)
wpl cli <site> post list --post_type=elementor_library --post_status=publish --fields=ID,post_title --format=table
wpl cli <site> post meta get <id> _elementor_template_type

# Feature flags: active | inactive | default
wpl cli <site> option get elementor_experiment-container
wpl cli <site> option get elementor_experiment-nested-elements
wpl cli <site> option get elementor_experiment-e_optimized_markup
wpl cli <site> option get elementor_experiment-e_atomic_elements

# Page data and housekeeping
wpl cli <site> post meta get <page_id> _elementor_data --format=json
wpl cli <site> elementor flush-css        # after writing _elementor_data
wpl cli <site> elementor library sync
```

## Template JSON conventions

When generating or editing `_elementor_data` or a template export file:

- Element shape: `{"id": "<7–8 hex chars>", "elType": "container" | "widget", "settings": {...}, "elements": [...], "widgetType": "<name>"}` (`widgetType` on widgets only). Every `id` must be unique on the page; duplicates break the editor.
- Container settings that matter: `content_width` (`"boxed"` default, `"full"` for nested), `flex_direction` (`row`, `column`, `row-reverse`, `column-reversed`), `flex_justify_content`, `flex_align_items`, `flex_wrap`, `flex_gap` (`{"size": 24, "unit": "px", "column": "24", "row": "24", "isLinked": true}`), `padding`, `min_height`, `html_tag`, `container_type: "grid"` with `grid_columns_grid`, `grid_rows_grid`, `grid_gaps`.
- Widget names: `heading`, `text-editor`, `button`, `image`, `image-box`, `icon-box`, `icon-list`, `video`, `nested-tabs`, `nested-accordion`, `loop-grid`, `template`, `form`, `theme-post-content`, `post-title` etc.
- **Globals:** reference them under `"__globals__"` in `settings`, e.g. `"__globals__": {"title_color": "globals/colors?id=primary", "typography_typography": "globals/typography?id=primary"}`, and leave the matching local keys unset. System IDs are `primary`, `secondary`, `text`, `accent`; custom globals use the `_id` from the kit.
- **Responsive:** `_tablet` / `_mobile` suffixes (`padding_tablet`, `flex_direction_mobile`, `_element_width_tablet`). Add a suffixed key only when the value differs from desktop.
- Item sizing: `_element_width: "initial"` + `_element_custom_width`, or `_flex_size: "grow"`.
- After writing: set `_elementor_edit_mode = builder`, `_elementor_template_type` (page / container / …), `_elementor_version`, then `elementor flush-css`, open the page once in the editor, check the Structure panel, save.
- Review signals in JSON: a `container` whose `elements` is a single `container`; any `"widgetType": "spacer"`; any `"elType": "section"` or `"column"`; `style=` attributes inside `text-editor` `editor` HTML; hex values where a `__globals__` entry should be.

## Sources

Elementor (official):

- How many containers per page: https://elementor.com/help/how-many-containers-page/
- Reduce DOM size (containers vs sections, boxed/full width): https://elementor.com/blog/elementor-performance-tip-reduce-your-dom-size-to-make-your-website-faster/
- Container layout tab (direction, justify, align, gap, wrap): https://elementor.com/help/container-layout-tab-settings/
- Container size behaviour (margins, HTML tag): https://elementor.com/help/set-flexbox-container-size-behavior/
- Spacing identical elements / responsive pattern: https://elementor.com/help/spacing-identical-elements-in-a-container/
- Padding and margin instead of spacers: https://elementor.com/help/create-space-with-padding-and-margin/
- Most common Elementor mistakes: https://elementor.com/blog/most-common-mistakes-users-make-with-elementor/
- Grid container: https://elementor.com/help/what-is-a-grid-container/
- Advanced tab / absolute positioning: https://elementor.com/help/container-advanced-tab-settings/
- Theme Style and design system interplay: https://elementor.com/help/how-elementors-theme-style-and-design-system-options-work-together/
- Theme Style settings: https://elementor.com/help/theme-style-global-settings/
- Layout settings: https://elementor.com/help/global-layout-settings/
- Globals-first workflow: https://elementor.com/blog/use-element/
- Heading widget / HTML tag: https://elementor.com/help/heading-widget/
- Editor V4 classes, variables, defaults: https://elementor.com/help/classes-in-elementor-2/ , https://elementor.com/help/variables/ , https://elementor.com/help/how-to-define-default-styles-for-atomic-elements-in-elementor/ , https://elementor.com/products/website-builder/v4-faq/
- Responsive inheritance and mobile fixes: https://elementor.com/help/inherited-responsive-values/ , https://elementor.com/help/how-to-resolve-common-mobile-layout-issues-in-elementor/ , https://elementor.com/blog/elementor-responsive-webdesign-principles/
- Performance features: https://elementor.com/help/what-are-performance-experiments/ , https://elementor.com/help/what-is-the-optimized-dom/ , https://developers.elementor.com/elementor-3-25-developers-update/ , https://elementor.com/help/element-caching-help/
- Accessibility: https://elementor.com/help/make-your-website-accessible/ , https://elementor.com/help/best-practices-for-website-accessibility/
- Nested elements: https://elementor.com/help/tabs-with-nested-containers/
- Loop Grid: https://elementor.com/help/loop-grid/
- Theme Builder and templates: https://elementor.com/help/the-elementor-theme-builder/ , https://elementor.com/help/considerations-for-theme-builder-compatibility/ , https://elementor.com/help/reusing-containers/ , https://elementor.com/help/global-widget-pro/
- Structure/Navigator naming: https://elementor.com/help/navigator/

Community:

- Crocoblock on flexbox containers: https://crocoblock.com/blog/elementor-flexbox-container/
- The Plus Addons on DOM size and the V4 design system: https://theplusaddons.com/blog/how-to-reduce-dom-size-in-elementor , https://theplusaddons.com/blog/elementor-v4-design-system/
- Kitpixel, common Elementor mistakes: https://kitpixel.com/12-common-elementor-mistakes-and-how-to-fix-them-for-better-performance-seo-ux/

Research tip: elementor.com/help pages serve only navigation to fetchers; `https://elementor.com/help/wp-json/wp/v2/posts?slug=<slug>&_fields=title,link,content` returns the article body.
