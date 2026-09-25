<p align="center">
  <img src="docs/icon.png" width="128" alt="Supremo Labs app icon">
</p>

<h1 align="center">Supremo Labs</h1>

<p align="center">The studio site for every Supremo Labs app, at <a href="https://supremolabs.com">supremolabs.com</a>.</p>

<p align="center"><sub>Flutter web · Firebase Hosting</sub></p>

The home page works like a record label's catalog: every app is a numbered release (SL 001 onward) shown as a
spine in a crate, followed by a discography and liner notes. Each product also gets its own page at
`supremolabs.com/<product>`, styled like that product's own brand.

## What's here

- **Catalog home.** The full lineup, with one sleeve pulled face-out in that product's own colour.
- **Product pages.** `/workit`, `/travelsync`, `/wealthsync`, `/plansync`, `/notesync`, `/stanverse`, `/diamo`…
- **Legal.** Privacy and terms pages for products that don't have a site of their own.
- **WorkIt desk.** Admin tools, including the Challenges review.

## Stack

- **Flutter web** with `go_router` and Google Fonts (Big Shoulders Display, Hanken Grotesk).
- **Firebase Hosting** (project `supremolabs`) with an SPA rewrite in `firebase.json`.
- Design direction lives in [DESIGN.md](DESIGN.md).

## Develop

```bash
flutter pub get
flutter run -d chrome
```

Deploy with `flutter build web --release && firebase deploy --only hosting --project supremolabs`.
`.github/workflows/deploy.yml` does the same in CI.
