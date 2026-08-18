# Design

<!-- impeccable:design-schema 1 -->

## World

**Register:** a private members' club / merchant bank lobby, not a SaaS
landing page. Brief-pinned: dark mode, premium, old-money. The scene: someone
who found one app on the App Store, now standing in the studio's foyer —
quiet confidence, nothing shouting for attention, everything precisely made.

**Color strategy:** Restrained — deep neutral ground plus one metallic
accent, no competing hues. Old money reads through material and restraint,
not color variety.

- Ground: `#15130F` (near-black, warm — not pure black/blue-black)
- Surface (cards/panels): `#1D1A15`, hairline border `#3A362C` at low opacity
- Ink: `#EDE7DA` (warm off-white, not pure white)
- Muted ink: `#A8A08C`
- Accent (brass/bronze): `#B08D57`, hover/pressed `#C7A66E`
- Divider hairlines: `#2A271F`

## Type

- Display (headlines, product names): **Fraunces** — old-world serif with
  optical-size charm, restrained italics for emphasis instead of bold color.
- Body/UI (nav, labels, buttons, copy): **Inter** — quiet, legible, gets out
  of the serif's way.
- No more than two weights per face on screen at once. Tracking opens up
  slightly on all-caps labels (eyebrow text, nav); never on body copy.

## Composition

- Generous whitespace, low information density — a members' club doesn't
  crowd the room. Hairline rules divide sections instead of colored bands or
  shadows.
- Product cards: flat surface + hairline border, no drop shadows, no glass,
  no gradients. A thin brass rule on hover is the only "chrome."
- Motion: restrained per brief — 150-250ms ease, opacity/position only, no
  bounce, no parallax, no autoplay. Motion confirms an action; it never
  performs.

## Components

- **Nav:** wordmark left, minimal text links right, transparent over hero,
  solidifies to ground color on scroll.
- **Product card:** eyebrow (category, e.g. "Travel"), Fraunces product name,
  one-line copy in muted ink, "Coming soon" as a quiet brass label, not a
  button — nothing on the page overpromises a link that doesn't work yet.
- **Section rule:** a single hairline with generous vertical space above and
  below marks every section boundary — the page's only structural device.

## Prohibited

- No gradients, glassmorphism, neon glow, or generic rounded icon tiles —
  none of these belong to this world.
- No stock "SaaS hero illustration" imagery.
- No color beyond ground/ink/brass — a second accent hue breaks the
  restrained strategy.
