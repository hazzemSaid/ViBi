# Vibi — Design Context

> This document is the authoritative design reference for all contributors and
> AI agents working on Vibi's UI. It defines who the users are, what the brand
> feels like, and the rules that govern every design and implementation decision.
> It MUST be read before creating, modifying, or reviewing any UI component,
> screen, or web page.

---

## 1. Users

Vibi serves young people globally who use social apps at any time of day,
primarily in personal and social contexts where self-expression, discovery, and
anonymous interaction are the core activities.

### Primary Jobs to Be Done

| Job | Context |
|---|---|
| Share a profile link | Quick, low-friction — often done on mobile in seconds |
| Receive anonymous questions and confessions | Passive; the profile must invite it |
| Read, answer, and socialise | Active session; content and interactions are the reward |
| Discover taste-based recommendations | Films, TV shows, music; discovery through people they follow |
| Express themselves visually | Personal drawing canvas on their profile; creative, not functional |

### Emotional State at Point of Use

Users arrive in a social headspace — curious, expressive, sometimes vulnerable.
Design decisions MUST account for this: interactions should feel inviting and
low-stakes, never clinical or transactional.

---

## 2. Brand Personality

**Expressive. Honest. Social.**

| Dimension | Direction |
|---|---|
| Voice | Candid, warm, direct — never corporate or distant |
| Tone in UI copy | Confident and brief; avoid hedging language |
| Visual character | Personal, dynamic, motion-forward |
| Trust signal | Safety and comfort are never sacrificed for edge |

### Desired Emotional Outcomes

- Encourage candid expression while still feeling safe and welcoming.
- Make every profile feel like a personal space — not a generic feed.
- Keep interactions lively and engaging, never static or lifeless.

---

## 3. Design Principles

These six principles are binding. Every design and implementation decision MUST
be defensible against at least one of them. Conflicts between principles are
resolved in the order listed.

### 1 · Expression First

Every profile MUST feel personal. User-controlled theming (`public_theme_key`,
`link_button_style`, `public_font_family`), taste sections, and the drawing
canvas are primary product surfaces — not decorative extras. Readability MUST
be preserved regardless of the theme the user selects.

Implementation rules:
- Theme tokens MUST drive colour, typography, and button shape; components must
  never hard-code these values.
- Taste and canvas sections MUST render as curated personal spaces, not generic
  lists or placeholder tiles.
- A blank or empty canvas/taste section MUST offer a clear invitation to add
  content rather than displaying an empty state with no affordance.

### 2 · Clarity at Speed

Users scan fast and act faster. Hierarchy MUST be obvious at a glance. Primary
actions (share, ask a question, answer, follow) MUST be immediately reachable
with no navigation friction.

Implementation rules:
- Primary actions MUST be above the fold on every key screen.
- Information hierarchy: name → avatar → primary action → content — in that
  visual weight order for profile views.
- Loading states MUST be skeleton-based (not spinners) for content that has a
  known shape; spinners are reserved for actions with unknown result shapes.

### 3 · Honest but Safe

The UI must signal openness and candour without making any user feel exposed or
unsafe. Anonymous question prompts must be inviting, not ambiguous.

Implementation rules:
- Anonymous interaction entry points MUST carry a visible, unambiguous label
  indicating anonymity (e.g. "Ask anonymously").
- Error states and moderation feedback MUST use plain, non-alarming language.
- Destructive actions (delete, block, report) MUST require a confirmation step
  with a clear consequence statement.

### 4 · Interactive by Default

Every key interaction MUST provide a clear, immediate visual response. Static
or unresponsive UI is a product defect.

Implementation rules:
- All tappable/clickable elements MUST have distinct hover, focus, pressed, and
  disabled states — defined in the shared design token system.
- Loading states MUST appear within 150 ms of triggering an async action.
- Success and error feedback MUST be inline where possible; full-screen
  interruptions (modals, dialogs) are reserved for destructive or irreversible
  actions.
- On web: focus rings MUST be visible and styled (not browser-default outlines
  on non-keyboard-navigable elements). On Flutter: `InkWell` / `GestureDetector`
  ripple and splash states MUST be configured, not suppressed.

### 5 · Inclusive Quality

Accessibility is not a post-launch audit item — it is a design constraint from
the first wireframe.

Implementation rules:
- Colour contrast MUST meet WCAG AAA (7:1 normal text, 4.5:1 large text) where
  technically achievable. WCAG AA (4.5:1 / 3:1) is the hard floor — no
  exceptions without documented design approval.
- All interactive elements MUST have accessible labels (`Semantics` widget in
  Flutter; `aria-label` / `aria-describedby` in Jaspr/HTML).
- Motion MUST respect `prefers-reduced-motion`. Animated elements MUST have a
  static fallback that preserves meaning.
- Tap targets on mobile MUST be at minimum 44 × 44 dp (Flutter) / 44 × 44 px
  (web). Targets smaller than this require explicit sign-off.
- Keyboard navigation on web MUST cover all interactive elements in a logical
  tab order. Focus trapping in modals is required.

### 6 · Responsive & Adaptive

Vibi is used across a wide range of device sizes. No layout may assume a fixed
screen width.

Implementation rules:
- Flutter: use `LayoutBuilder`, `BoxConstraints`, and `MediaQuery.sizeOf(context)`
  for adaptive layouts. `MediaQuery.of(context).size` is discouraged (causes
  unnecessary rebuilds). Hard-coded pixel dimensions for layout are prohibited.
- Jaspr/web: use Tailwind responsive prefixes (`sm:`, `md:`, `lg:`) and CSS
  `clamp()` for fluid type. Fixed-width containers wider than `min(100%, 680px)`
  are prohibited for content columns.
- The public profile page (`/u/:username`) MUST be fully functional and
  visually correct at viewport widths from 320 px (small mobile) to 1440 px
  (desktop).
- Test breakpoints: 320 px, 375 px, 390 px, 768 px, 1024 px, 1280 px, 1440 px.

---

## 4. Aesthetic Direction

### Overall Feel

Interactive, expressive, and modern. Strong motion. Immediate feedback.
Social-media-native: fast to scan, emotionally direct, action-oriented.

### What to Avoid

- Bland or generic card-grid layouts with no visual identity.
- Copy-paste visual treatment from dominant social platforms.
- Static or low-interaction components where motion would add clarity.
- Per-user theming that is cosmetic only — it must affect real structural
  tokens (background, accent, button shape, font), not just a tint overlay.

### Motion

- Transitions between states MUST reinforce spatial relationships (e.g. slide
  in from the direction of origin, not arbitrary fade).
- Page/route transitions MUST complete within 300 ms.
- Content reveal animations (profile load, feed expansion) MUST be
  staggered — not all-at-once.
- Decorative or looping animations MUST be pausable and MUST respect
  `prefers-reduced-motion`.

### Theming System

User-selected visual identity is a first-class product feature, not a skin.

| Token | Source column | Controls |
|---|---|---|
| Background colour | `backgroundcolor` (no underscore) | Page background, card surfaces |
| Theme key | `public_theme_key` | Full theme preset (colour palette, illustration set) |
| Button style | `link_button_style` | `pill` / `rounded` / `square` |
| Font | `public_font_family` | Heading and body typeface on profile |

Rules:
- All theme tokens MUST be applied via CSS variables (web) or Flutter
  `ThemeData` / token constants (mobile). Hard-coded values that override
  theme tokens in components are prohibited.
- Any new component that renders on the public profile page MUST be verified
  against all three `link_button_style` variants and at least two contrasting
  theme presets before merge.

### Surface-Specific Guidance

**Public profile page (`/u/:username`)**
- Focus is share link + anonymous message CTA. These two actions MUST be
  immediately visible without scrolling on mobile.
- The triple-avatar card layout is the canonical profile header — do not
  replace it with a single avatar unless a new design is approved.
- Taste and canvas sections MUST feel curated, not listed. Use appropriate
  visual treatment (artwork thumbnails, styled tiles) rather than plain text
  rows.

**Flutter app (authenticated)**
- Feed and answer flows MUST prioritise content density while maintaining
  readable line lengths (45–75 characters per line for answer bodies).
- Anonymous question inbox MUST visually distinguish unread/new items from
  read ones at a glance.

**Web share experience**
- Optimised for quick link sharing and anonymous message submission.
- Must be statically renderable for SEO and open-graph preview fidelity.

---

## 5. Copy & Tone Guidelines

- Use second-person ("you", "your") throughout.
- Be brief: labels ≤ 3 words, CTAs ≤ 4 words, error messages ≤ 12 words.
- Never use passive voice for action labels.
- Anonymity-related copy MUST be explicit and unambiguous — never implied.
- Empty states MUST include an invitation, not just a description
  (e.g. "Ask me anything" not "No questions yet").

---

## 6. Implementation Notes

### Flutter

- Prefer `MediaQuery.sizeOf(context)` over `MediaQuery.of(context).size`.
- `InkWell` / `GestureDetector` ripple states MUST NOT be suppressed with
  `splashColor: Colors.transparent` unless a custom interaction animation
  replaces them.
- Hive boxes containing key material or sensitive profile data MUST be
  encrypted.
- All screens MUST support both light and dark system themes unless a
  user-selected profile theme explicitly overrides the surface colour.

### Jaspr / Web

- CSS variable block is the single source of truth for theme tokens. Inline
  `style` overrides of theme variables in component markup are prohibited.
- Tailwind utility classes handle layout and spacing; the CSS variable block
  handles colour, typography scale, and component-specific tokens.
- All public-facing pages MUST include correct Open Graph meta tags
  (`og:title`, `og:description`, `og:image`) populated from live profile data.
- The TMDB attribution notice MUST appear in the About screen before any
  release: TMDB logo + "This product uses the TMDB API but is not endorsed or
  certified by TMDB."

---

## Change Log

- **v1.0.0** — Initial Vibi design context document. Incorporates brand
  personality, six binding design principles, theming system specification,
  surface-specific guidance, copy tone guidelines, and implementation notes
  for Flutter and Jaspr. RATIFICATION_DATE = 2026-05-01