# CLAUDE.md

Flutter **web** app. The parent business site — `supremolabs.com` — hosting
every other project under a path: `/wealthsync`, `/travelsync`, `/plansync`,
etc. Not a twin of any single app; it's the umbrella all of them sit under.

Layout: Dart, `pubspec.yaml`, `lib/`, `test/`.

## Builds / CI

See parent CLAUDE.md — default repo/branch apply. No self-hosted runner yet;
add one only once this ships to prod like the other four.

## Backend / hosting

Firebase Hosting, project ID `supremolabs` (console:
https://console.firebase.google.com/project/supremolabs/overview). Deploy:
`firebase deploy --only hosting --project supremolabs` (its predeploy builds
with `--no-tree-shake-icons` and runs `tool/stamp_build.sh`, which stamps the
build and mirrors `assets/` under `/b/<stamp>/` so Cloudflare's 4h cache can't
serve a stale icon font or `main.dart.js`; put `flutter` on PATH first).
Firebase and Supabase start in the background (`lib/app/backends.dart`); pages
that need one are wrapped in `BackendGate`.
SPA rewrite (`**` → `/index.html`) is in `firebase.json`. Per-product routing:
each product (`/travelsync`, `/wealthsync`, etc.) is its own dedicated page
within this app, styled to match that product's own site/branding (e.g.
`/travelsync` mirrors travelsync_website's look) — not a deep-link redirect
out. Custom domain `supremolabs.com` is connected via Firebase Hosting (DNS
verified, cert provisioning).

## Design

Dark, record-label world — the home page is Supremo Labs' catalog: every app is
a numbered release (SL 001–SL 011), shown as spines in a crate with one sleeve
pulled face-out in the product's own color (real app screen where one exists,
typographic otherwise; forthcoming releases are blank keyline sleeves), then a
discography list and liner notes. Big Shoulders Display + Hanken Grotesk.
Retired the living-web (mesh) hero in full. Shaped via `/impeccable`; see
`DESIGN.md`.
