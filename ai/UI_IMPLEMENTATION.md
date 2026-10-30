# Roommate Finder — UI Implementation Instructions

## Objective

Build the Roommate Finder Flutter application's UI based on the existing project requirements, the provided architecture reference image, and the design screenshots in `ai/design/`.

Prioritize simple, readable, maintainable code. Do not introduce unnecessary complexity.

## 1. Inspect Before Coding

Before modifying anything:

1. Inspect the existing Flutter project and its dependencies.
2. Read the existing project specification.
3. Inspect every relevant design screenshot in `ai/design/`.
4. Study the provided architecture reference image.
5. Compare the current code with the intended folder structure.
6. Present a brief implementation plan before making major structural changes.

Do not overwrite or restructure working code without a clear reason.

## 2. Architecture Reference

Use the provided Clean Architecture folder structure as the organizational reference.

The intended organization is:

* `lib/core/config/`
* `lib/core/errors/`
* `lib/core/network/`
* `lib/core/resources/`
* `lib/features/<feature>/data/`
* `lib/features/<feature>/domain/`
* `lib/features/<feature>/presentation/`
* `lib/main.dart`

Feature-specific layers may contain:

* Data: datasources, models, repositories.
* Domain: entities, repository contracts, use cases.
* Presentation: views, reusable feature widgets, and state management when needed.

Create files according to actual requirements. Do not create empty classes, fake repositories, unused abstractions, or unnecessary layers just to reproduce the folder tree.

Keep the code organized by feature rather than placing the entire application's UI inside `core`.

## 3. Current Scope: UI First

Initially focus on:

* App foundation.
* Light, Dark, and System themes.
* Colors, typography, spacing, and reusable design elements.
* Navigation and the main application shell.
* Authentication screens.
* Housing discovery and listing screens.
* Favorites.
* Listing creation and editing UI.
* Application screens.
* Notifications UI.
* Chat list and direct chat UI.
* Profile and profile editing UI.

Implement screens according to the actual designs and project requirements. Follow a sensible order, starting with the shared foundation and then implementing features.

Use lightweight mock data where required.

UI controls should behave appropriately where practical, but do not build a real backend.

## 4. Product Restrictions

The application is English-only and LTR-only.

Support Light, Dark, and System themes.

There is one user type. The same user may search for housing and publish listings.

Do not add features outside the project requirements, including payments, booking, ratings, AI matching, social feeds, group chat, or a separate settings screen.

Do not introduce a separate profile-completion flow or notification settings.

## 5. Keep Implementation Simple

For the initial UI work:

* Do not integrate Firebase or external APIs.
* Do not implement authentication against a real backend.
* Do not add persistent storage.
* Do not introduce BLoC, Cubit, Riverpod, Provider, or GetX unless explicitly approved for a later implementation step.
* Do not create repositories and use cases that have no actual purpose yet.
* Do not add dependencies without a demonstrated need.
* Reuse existing project code whenever reasonable.
* Avoid giant files, duplicated widgets, and unnecessary abstractions.

The architecture reference defines the intended organization; it does not require implementing unused architectural layers prematurely.

## 6. Design Fidelity

Treat the provided Figma screenshots as the visual reference.

Match the layout, colors, typography, spacing, component shapes, navigation, and screen relationships as closely as reasonably possible.

Do not replace the provided designs with an independently invented design system.

If an element is unclear or not shown, make the smallest reasonable assumption and document it.

## 7. Verification

After implementing the agreed scope:

1. Run `flutter analyze`.
2. Resolve errors introduced by the implementation.
3. Run the application when possible.
4. Check Light, Dark, and System themes.
5. Check navigation and obvious overflow issues.
6. Report any missing designs, assumptions, or unresolved issues.

## 8. Working Rules

Work incrementally. Preserve useful code. Avoid unnecessary rewrites.

Before a major implementation step, explain what you intend to build.

Do not move to Firebase or later backend work until the UI implementation has been reviewed and approved.

Do not invent additional features or architectural requirements.

At the end, report the implemented screens, files changed, dependencies added, verification results, and remaining work. Stop and wait for review before starting a substantially new stage.
