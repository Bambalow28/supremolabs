# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Two audiences, weighted equally:
- **Prospective app users** — someone who found one product (e.g. wealthsync
  on the App Store) and lands on supremolabs.com to see what else the studio
  makes, then routes to that product's own app/site or store listing.
- **Credibility checkers** — recruiters, partners, press, or App Store
  reviewers confirming Supremo Labs is a real, legitimate company behind the
  apps.

## Product Purpose

The parent business site for Supremo Labs, hosting/linking every product
under a path: `supremolabs.com/wealthsync`, `/travelsync`, `/plansync`, etc.
Success = a visitor understands the studio and its lineup, and reaches the
right product's app/site or store listing without friction.

## Positioning

A cohesive suite, not a scattered app list — one studio building a connected
set of life/productivity tools (travel, wealth, planning, notes, and more).
The pitch is coherence and quality across the lineup, not portfolio breadth
for its own sake.

## Operating Context

- Product routes are `supremolabs.com/<project>` — each route either
  deep-links out to that product's own hosted app/site (travelsync_website,
  wealthsync_website) or to its App Store listing, or shows a summary page
  when the product has no dedicated site of its own yet.
  Each product keeps its own backend; supremolabs.com does not proxy or own
  product data.
- **travelsync** is furthest along externally: live App Store listing,
  privacy policy, and its own website already shipped. Any legal/compliance
  copy on supremolabs.com must not conflict with or duplicate what's already
  live there — link out rather than re-publish.
- Current lineup (subject to change as new apps ship or get renamed):
  travelsync, wealthsync, plansync, notesync, hoopsync, jarvis, juwa_wealth,
  dressmeup, diamo.

## Capabilities and Constraints

- Flutter web app, no backend of its own decided yet (hosting approach TBD —
  see supremolabs/CLAUDE.md).
- Undecided: whether product pages embed live previews of each app or stay
  pure link-outs; whether supremolabs.com owns a shared privacy
  policy/terms page that per-product sites can point to, or each product
  keeps its own indefinitely.

## Brand Commitments

None yet. No logo, tagline, or legal copy exists for Supremo Labs itself —
treat as a blank slate. Flag logo and legal pages (privacy/terms for the hub
site) as outstanding work rather than inventing placeholders.

## Evidence on Hand

None. No real screenshots, copy, or assets supplied yet for this site —
future work must not fabricate testimonials, metrics, or screenshots; use
labeled placeholders until the user supplies real assets.

## Product Principles

1. Coherence over breadth — the suite should read as one studio's taste, not
   nine unrelated experiments bolted together.
2. Route, don't duplicate — product data, legal copy, and functionality live
   in each product's own app/site; the hub links out rather than re-hosting.
3. Credibility reads in restraint — for the "is this a real company" audience,
   understatement and polish do more work than claims or badges.
4. Every product route must resolve to something real (a live site, store
   listing, or an honest "coming soon") — never a dead link.
