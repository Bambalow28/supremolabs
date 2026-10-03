---
name: Supremo Labs
description: An independent label for apps; every product is a catalogued release.
colors:
  ground: "#0B0D10"
  surface: "#13161B"
  hairline: "#262B33"
  divider: "#1C2026"
  ink: "#F2F4F7"
  ink-muted: "#8B93A1"
  studio-signal: "#FFB020"
  studio-signal-hover: "#FFC04D"
  sleeve-ink-light: "#F7F7F5"
  travelsync: "#4B76FA"
  famfi: "#2E5BE8"
  plansync: "#2DD4BF"
  notesync: "#4CAF55"
  workit: "#4A9DFF"
  diamo: "#7A3145"
  stanverse: "#F5F2EC"
typography:
  masthead:
    fontFamily: "Big Shoulders Display"
    fontSize: "fitted to the 1072px measure (set at 200px, scaled down)"
    fontWeight: 800
    lineHeight: 0.86
  display:
    fontFamily: "Big Shoulders Display"
    fontSize: "64px (44px narrow)"
    fontWeight: 700
    lineHeight: 1
  headline:
    fontFamily: "Big Shoulders Display"
    fontSize: "52px (40px narrow)"
    fontWeight: 700
    lineHeight: 1
  title:
    fontFamily: "Big Shoulders Display"
    fontSize: "30px (24px narrow)"
    fontWeight: 700
    lineHeight: 1
  body:
    fontFamily: "Hanken Grotesk"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "Hanken Grotesk"
    fontSize: "12px"
    fontWeight: 600
    letterSpacing: "2.2px"
    fontFeature: "tnum"
rounded:
  none: "0px"
spacing:
  shelf-gap: "2px"
  gutter: "24px"
  measure: "1120px"
components:
  button-outline:
    backgroundColor: "transparent"
    textColor: "{colors.studio-signal}"
    typography: "{typography.label}"
    rounded: "{rounded.none}"
    padding: "15px 22px"
  button-outline-hover:
    backgroundColor: "{colors.studio-signal}"
    textColor: "{colors.ground}"
  sleeve-forthcoming:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink-muted}"
    rounded: "{rounded.none}"
  spine-forthcoming:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink-muted}"
    rounded: "{rounded.none}"
  discography-row:
    backgroundColor: "transparent"
    textColor: "{colors.ink}"
    typography: "{typography.title}"
    padding: "20px 12px"
---

# Design

<!-- impeccable:design-schema 1 -->

## World

**Register:** a record label's catalog. Supremo Labs is the label, every app
is a numbered release, and the hub is the catalog laid on a matte near-black
board. Replaces the living-web world (and the night-operations map and
old-money briefs before it) entirely; a retired look is evidence of what this
site was, never authority over what it is now.

**Mechanism:** the whole catalog stands in one crate. Every release is a
spine in catalog order; one is always pulled face-out as a square sleeve. A
visitor digs the crate, pulls a sleeve, and opens that release. Coherence is
shown by eleven releases sharing one shelf, one numbering, and one sleeve
format, not claimed in copy.

**Taxonomy: catalog order and genre, both from one file.**
`lib/data/products.dart` is the only source. Its list order is the catalog
order, and `catalogNo()` in `lib/home/home_page.dart` derives `SL 001` to
`SL 011` from that index. `Cluster` (Journeys, Money, Everyday, Body, People)
is the release's genre: printed on the sleeve, in the notes credit, and in
the discography's genre column. A new release joins the crate, the numbering,
and the discography by being appended to `products.dart`; nothing on the page
is edited by hand.

**The Catalog Number Rule.** `SL` plus a three-digit index is the only
numbering on the site, always derived from list order and set in tabular
figures. Never type a catalog number, never renumber by reordering for taste.

**The Real Screen or Type Rule.** A sleeve shows a real shipped app screen
(`Product.screen`, today TravelSync, WorkIt) or it sets the
release's name typographically. Never a mock, stand-in, or generated screen.

**The Keyline Means Forthcoming Rule.** Out now is solid; forthcoming is a
keyline. The spine, the sleeve, and the discography swatch all speak this one
language, so status reads before any text does.

**Color strategy: a quiet board, loud sleeves.** Cool graphite ground and
white ink carry the page; each shipped release floods its sleeve and spine in
its own `Product.accent`; the studio's amber is reserved for the studio's own
actions (the liner-notes link) and chrome off product routes.

- Ground `#0B0D10`, surface (forthcoming sleeves and spines) `#13161B`,
  hairline keylines `#262B33`, row dividers `#1C2026`.
- Ink `#F2F4F7`; muted ink `#8B93A1` for body copy, labels, and every
  forthcoming mark.
- Studio signal `#FFB020`, hover `#FFC04D`.
- Release colors: TravelSync `#4B76FA`, FamFi `#2E5BE8`, PlanSync
  `#2DD4BF`, NoteSync `#4CAF55`, WorkIt `#4A9DFF`, Diamo `#7A3145`,
  Stanverse `#F5F2EC`.

**The lineInk Rule.** `lineInk()` (`lib/theme/sl_theme.dart`) is mandatory
wherever an accent becomes type or a line on the graphite ground: the notes'
Open action, the discography's hover name and OUT NOW state, the chrome.
WealthSync's slate and Diamo's plum sit at luminance .11 and .07 and fail
4.5:1 as type on the ground; `lineInk()` lifts any accent below .20 until it
clears. The raw accent is used only as a flood (sleeve, spine, the 14px
discography swatch), where it is the release's own surface, not type.

**The Legible Sleeve Rule.** Ink printed on a flooded sleeve or a filled
button is whichever of ground `#0B0D10` or `#F7F7F5` clears 4.5:1 against
that flood, since the catalog number and genre on a sleeve are 12px labels.
Choose by contrast, not by a luminance guess.

## Type

- **Display: Big Shoulders Display.** Condensed, label-masthead weight; every
  name and heading on the hub. Line height 1.0 by default.
  - Masthead `SUPREMO LABS`, w800, height .86, fitted edge to edge across the
    measure with `FittedBox`, so it always fills the 1120 column exactly.
  - Section headings (`Discography`, `Liner notes`) 64px, 44px narrow.
  - The label statement under the masthead 34px, 26px narrow.
  - Pulled-release name in the notes 52px, 40px narrow.
  - Discography names 30px, 24px narrow.
  - On objects, sizes scale with the object: spine names at 52% of the spine
    width (16 to 26px, w700, +0.6 tracking, uppercase); sleeve names at 13% of
    the sleeve (w800, height .9, uppercase); the FORTHCOMING stamp at 10%
    (w800, +2 tracking); the ghost name on a screenless sleeve at 46% (w900).
- **Body: Hanken Grotesk** 400, height 1.5, muted ink by default. Taglines
  18/16px in the notes, 15px in rows; the liner note itself 22/19px in ink at
  height 1.45, capped at 600px wide; footer links 13px.
- **Label: Hanken Grotesk** 12px w600, +2.2 tracking, tabular figures
  (`SLType.label`), uppercase by content. Catalog numbers, genre credits,
  OUT NOW / FORTHCOMING, button text. `SLType.eyebrow` is the same face
  without tabular figures, used only by the chrome's signage.

**The Fitted Masthead Rule.** The label name is sized by the measure, not by
a number: it fills the column edge to edge at every width and is the page's
one header in the accessibility tree.

**The Signage Rule.** Labels are printed on an object: a spine, a sleeve's
corners, a row's state, a button, the nav wordmark. Section headings carry
their own weight and never get a kicker above them.

## The crate: `lib/home/home_page.dart`

The first viewport is the masthead, one line counting out-now against
forthcoming from data, then the crate with its pulled sleeve and notes.

- **Shelf geometry is solved from the measure.** Eleven items on a bottom
  edge, 2px apart. On wide layouts a spine is `(width - 480) / 10 - 2`,
  clamped 30 to 56px, and the pulled sleeve takes the remaining width,
  clamped between 300px and 46% of the viewport height (itself clamped 300 to
  540), so the notes and Open action land in a laptop's first viewport. Below
  700px wide, spines are 34px, the sleeve is 84% of the width, and the shelf
  scrolls horizontally, following the pick.
- **Spine.** A shipped release is a spine flooded in its accent; a forthcoming
  one is surface with a hairline keyline that brightens to muted ink on hover.
  Name and catalog number run down the spine (rotated a quarter turn), 18px in
  from each end.
- **Sleeve.** Square. Catalog number top-left and genre top-right at 5.5%
  inset; the name under them at 13% of the sleeve. Then one of three bodies:
  - *Out now with a screen:* the real screen, 42% of the sleeve wide, 8% in
    from the right, its top at 31% so the sleeve's bottom edge crops it:
    rising out of the sleeve. Corners round at 3.5% of the sleeve, the device
    screen's own shape.
  - *Out now without a screen:* the name set at 46% of the sleeve in w900,
    16% of the way from flood to ink, bleeding off the bottom-left edge.
  - *Forthcoming:* a blank keyline sleeve with a `FORTHCOMING` stamp: 2px
    muted-ink frame, tilted -0.14 rad, centered.
- **Notes under the shelf.** The pulled release's credit (`SL 001 · Journeys
  · iOS`), its name, its tagline, and on the far side an outlined Open action
  in `lineInk(accent)`; forthcoming releases show a `FORTHCOMING` label in the
  action's place. Stacked on narrow layouts.
- **Accessibility.** Every shelf item is a `Semantics` button: a spine reads
  "Show SL 00n, Name", the pulled sleeve reads "Open Name" or "Name,
  forthcoming". The discography below repeats every release as a focusable
  row, so the crate is never the only route to a product.

## Motion: one dig, one reveal, one sweep

Nothing on the hub moves unprompted. Every animation answers an input or a
scroll.

- **Crate dig (460ms, `Curves.easeOutQuart`):** the picked spine widens into
  its sleeve while the previous sleeve closes back to a spine; on narrow
  layouts the shelf scrolls to the pick on the same timing. Tapping the
  already-pulled sleeve opens the release.
- **Spine lift:** a hovered spine rises 12px out of the crate on the dig
  timing.
- **Screen rise (320ms, easeOutQuart):** hovering a pulled sleeve raises its
  screen from 31% to 26%.
- **Notes swap (280ms `AnimatedSwitcher`):** the notes cross-fade to the new
  release.
- **Hover states (180ms `Curves.easeOut`):** the Open action fills, a
  discography row warms, its arrow slides.
- **Entrance (`FadeSlideIn`, 620ms, easeOutCubic):** fires on visibility,
  via the Scaffold's `ScrollNotificationObserver`, when the widget's top
  crosses 88% of the viewport; masthead, discography heading, and liner notes.
- **Travel (`_LineSweep`, `lib/app/router.dart`):** the destination's own
  color wipes across the viewport and off the far side, revealing the arriving
  page. 620ms out, 520ms back.
- Reduced motion (`MediaQuery.disableAnimations`): the dig, the notes swap,
  the entrance, and the sweep all complete instantly; picking still works.

## Chrome: carries the current page's color, and stays out of the way

The nav band paints in the **current route's own color**:
`currentLineColor()` in `lib/app/site_shell.dart` resolves to the product's
accent on a product route (or a sub-route under it), and the studio's amber
everywhere else (hub, `/about`). The nav's own background is transparent: it
paints no rectangle of its own, so whatever the route's body puts behind it
(flat ground or a gradient) shows straight through rather than a fixed bar
sitting over every world.

**There is no vertical rail.** A scroll-progress line pinned to every page
went out with the transit world it belonged to; a rail beside the catalog
would be chrome asserting a metaphor the page does not hold.

ABOUT only lives in the nav on the root page; it's the hub's link, not a
persistent utility. A product route's nav gets a `trailing` slot in its
place instead (`SiteShell(trailing:)`), used today only by TravelSync's
decorative header search field
(`lib/products/travelsync/widgets/header_search_field.dart`); every other
product route leaves it empty.

The footer lists every product with a route, each with a small dot in its
`lineInk` color, the current one lit, over `© SUPREMO LABS` and
`SUPREMOLABS.COM`. The bottom of a page is a junction, not a dead end.

## Nested routes: sections with their own address

A product's marketing sections are addressable, bookmarkable sub-routes
(e.g. `/travelsync/features`, `/famfi/personal`, `/plansync/itinerary`,
`/notesync/folders`) rather than separate pages; each product page accepts
an `initialSection` and scrolls to that section's `GlobalKey` on load
(`scrollToSection()` in `site_shell.dart`). The sub-routes are bookmarkable
but not visibly listed anywhere on the page itself.

## Composition

- One measure: every section sits in `SLPage`, 1120px max, 24px gutters, and
  a hairline `SLRule` divides crate, discography, and liner notes.
- Generous section spacing: discography 80px above / 88px below (56 narrow),
  liner notes 88 / 96 (56 / 64 narrow).
- **No product card grid, and no bento of screenshots.** The catalog appears
  twice and only twice: as a crate, then as a discography.
- **Discography is the catalog as a label lists it.** One list, in catalog
  order, not grouped: catalog number (96px column), 14px square swatch (solid
  accent when out, 1.4px muted keyline when forthcoming), name over tagline,
  genre (150px column), status (OUT NOW with an arrow in `lineInk`, or
  FORTHCOMING). Rows are ruled by 1px dividers under a hairline; hovering a
  shipped row warms it to 8% of its `lineInk` color and turns the name that
  color. Forthcoming rows are quieter at every level and are not hover targets.
- **Forthcoming releases keep their catalog place.** The catalog is only true
  if it is complete, but nothing forthcoming is dressed as something you can
  open.
- **Liner notes:** a square portrait slot (240px, 160px narrow) beside the
  note. Until the user supplies a real photo it is a hairline keyline labeled
  `PORTRAIT / TO BE SUPPLIED`, never a stock or generated face. The note links
  to `/about` with the outlined action in studio amber.
- **Square corners throughout.** Sleeves, spines, swatches, stamps, buttons,
  and the portrait slot are sharp; the only rounding is the app screen's own
  device corner inside a sleeve.
- **Flat.** No shadows, gradients, or glassmorphism on the hub. Depth is the
  spine lifting out of the crate and the screen rising from the sleeve.

## Product pages (`/travelsync`, `/famfi`, `/plansync`, `/notesync`, `/workit`)

Everything above governs the **studio chrome, hub, and about page**. A
product route splits in two:

- **Chrome: carries the product's color.** Nav and footer paint in that
  product's own ground and accent (see "Chrome" above).
- **Body: always the product.** Between nav and footer the page keeps that
  product's own shipped design language: its palette, its typefaces, its
  components. travelsync/wealthsync port their own sites' look, plansync is
  a trip folder on a desk, notesync ports the app's own note-list UI. These
  bodies are entirely out of scope for the studio's catalog world; no hub
  component renders inside them.

Two of the four bodies are ports of the product's own site
(travelsync_website, wealthsync_website). `/plansync` was designed here
because the product has no site; it's a trip folder of documents.
`/notesync` also has no site of its own, but ports the app's own UI
(rounded note tiles, folder cards, the "Notes" wordmark) rather than
inventing a new metaphor, since the app's screens are already the product's
visual identity. `/workit` follows the same no-site-of-its-own path as
NoteSync: it ports the app's own calibrated-instrument palette (mirrored
from `WorkItColors.dark()`), but its spine is now the app's five real
screens (`assets/workit/`, cropped at the device's own screen edge from
workit/marketing/) in a horizontal rail, each captioned in the color that
screen actually uses. Drawn instruments survive only where a still image
cannot make the claim: the live rest-timer session card and the Form
Checker score that builds itself; the invented training-load bar chart was
retired once the real Today screen could show it. It also hosts `/workit/privacy` and
`/workit/terms`. WorkIt has no site of its own to host them on, and the
App Store requires a reachable URL for both, so they live here as plain
legibility-first documents (system stack, no plate colors) rather than as
placeholders or dead links. Each carries its direction contract in the
opening comment of its page file.
