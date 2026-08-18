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
`flutter build web --release && firebase deploy --only hosting --project supremolabs`.
SPA rewrite (`**` → `/index.html`) is in `firebase.json`. Per-product routing:
each product (`/travelsync`, `/wealthsync`, etc.) is its own dedicated page
within this app, styled to match that product's own site/branding (e.g.
`/travelsync` mirrors travelsync_website's look) — not a deep-link redirect
out. Custom domain `supremolabs.com` is connected via Firebase Hosting (DNS
verified, cert provisioning).

## Design

Dark mode, premium, old-money aesthetic — deep neutrals, muted metallics,
serif display type, restrained motion. Shaped via `/impeccable`; see
`DESIGN.md` once impeccable's `init`/`new-work` pass has run.
