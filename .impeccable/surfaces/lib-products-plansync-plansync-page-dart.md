---
version: 1
slug: "lib-products-plansync-plansync-page-dart"
primary_target: "lib/products/plansync/plansync_page.dart"
related_targets: []
---

Scope: the `/plansync` route on supremolabs.com. Visitor mode: Persuade.

Audience: someone who found another Supremo app and is scanning the lineup,
plus credibility checkers. Job: understand what PlanSync is in one viewport
and decide whether to ask for the beta. Action: request TestFlight access by
email — PlanSync has no App Store listing yet, and the page says so rather
than implying one.

Proof/content: no screenshots and no store listing exist. The page proves the
product by rendering its artifacts as live Flutter — flight row, day rail,
expense tape, pinned places, attachment list — from a labelled sample trip
(Lisbon). Nothing here is a real itinerary, and the page says that at its foot.

Direction: the trip folder. One sheet per thing PlanSync replaces, punched and
filed under one tab, so the pitch is "these six things live together" rather
than a feature list. Memorable moment: the sheets settle into the folder once,
in filing order, and nothing else on the page animates on its own.

Constraints: body adopts PlanSync's own world, chrome stays Supremo (see
DESIGN.md "Product pages"). No new pubspec dependencies.

Unresolved: the email address on the CTA is the owner's personal one — swap it
for a studio address when supremolabs.com has mail. Whether this route should
link to a PlanSync site of its own once one exists.
