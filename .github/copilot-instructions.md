## Design Context

### Users
ViBi serves young people globally who use social apps at any time of day, primarily in social and personal contexts where they want to express themselves, discover content through people they follow, and engage through anonymous interaction.

Primary jobs to be done:
- Share a profile link quickly.
- Receive anonymous questions and confessions.
- Read, answer, and socialize through follow/friend interactions.
- Share taste-based recommendations (films, TV shows, music) that followers can discover.
- Express themselves visually through a personal drawing canvas on their profile.

### Brand Personality
Expressive. Honest. Social.

Desired emotional outcome:
- Encourage candid expression while still feeling safe and welcoming.
- Make every profile feel like a personal space — not just a feed.
- Keep interactions lively and engaging, never static or lifeless.

### Aesthetic Direction
The product should feel interactive, expressive, and modern, with strong motion and clear feedback.

Direction guidance:
- Keep the web share experience focused on sharing links and receiving anonymous messages.
- Support dynamic per-user background/theme styling (user-selected visual identity per profile).
- Avoid bland, copycat, or low-interaction visual treatment.
- Maintain a social-media-native feel: fast to scan, emotionally direct, and action-oriented.
- Taste and canvas sections should feel like curated personal spaces, not generic lists.

Accessibility target:
- WCAG AAA where possible.

### Design Principles
1. Expression First: Let every profile feel personal through dynamic user-controlled theming, taste sections, and canvas — while preserving readability.
2. Clarity at Speed: Prioritize fast comprehension and action (share, ask, answer, discover) with obvious hierarchy and minimal friction.
3. Honest but Safe: Use confident, candid tone and strong interaction cues while preserving trust and comfort.
4. Interactive by Default: Every key interaction should provide clear visual response (hover, focus, loading, success/error).
5. Inclusive Quality: Aim for WCAG AAA contrast, robust keyboard/focus states, and motion alternatives for sensitive users.
6. Responsive & Adaptive: Use `LayoutBuilder`, `BoxConstraints`, and `MediaQuery` (preferably `MediaQuery.sizeOf(context)`) to build interfaces that adapt to various screen sizes and device types. Prioritize fluid layouts and avoid hardcoded dimensions that compromise the experience on larger or smaller screens.