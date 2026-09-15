---
version: 1
slug: "lib-products-notesync-notesync-page-dart"
primary_target: "lib/products/notesync/notesync_page.dart"
related_targets: []
---

Scope: the `/notesync` route on supremolabs.com. Visitor mode: Persuade.

Audience: someone scanning the studio lineup, plus credibility checkers. Job:
understand NoteSync in one viewport. Action: request TestFlight access by
email — no App Store listing exists yet, and the page says so.

Proof/content: no screenshots exist. The page is itself the product's output —
notes, folders, dates and reminders written onto a ruled page, from a labelled
sample. The local-only storage model is stated plainly, benefit and cost both:
no account and no server, and a wiped phone takes the notes with it.

Direction: a page from the pad. Fixed 34px baseline, faint rules, one green
margin rule; anything dated or filed hangs in the margin, anything written
starts past it. There is not a single card on the page. Memorable moment: the
request line is a real checkbox that draws its tick on hover.

Constraints: body adopts NoteSync's own world — navy, green accent, and the
app's deliberate one-family Helvetica setting, where size and weight carry the
entire hierarchy. Chrome stays Supremo (see DESIGN.md "Product pages"). No new
pubspec dependencies.

Unresolved: the email address on the CTA is the owner's personal one — swap it
for a studio address when supremolabs.com has mail.
