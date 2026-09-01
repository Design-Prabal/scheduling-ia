# Scheduling IA

UX architecture and interaction model for a multi-vertical scheduling product.

| Page | Route |
|---|---|
| Scheduling IA Strategy — 26-section document | `/` |
| **IA options — all four, switchable** | `/ia-options` |
| Appointments Workspace — the recommended option alone | `/prototype` |

`/ia-options` carries the four IA alternatives from §9 as working builds. The
switcher on the right edge rebuilds navigation and configuration for real:

1. **Appointments-first** — verticals as siblings, staff duplicated per vertical
2. **Vertical-first** — no unified calendar; each vertical owns its own
3. **Hybrid catalogue** — verticals behind one parent node
4. **Adaptive** — conditional verticals, shared objects extracted *(recommended)*

Any screen of any option is directly linkable, e.g. `/ia-options/#/v2/services/calendar`.

Pages carry `noindex, nofollow`.
