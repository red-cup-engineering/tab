# Research notes: provenance and scope

These five notes preserve economic, evidence and game-design research. They are
not API documentation or proof that the mechanisms they discuss are implemented
in this repository.

## Provenance

[TAB consolidation commit 91207d2](https://github.com/red-cup-engineering/tab/commit/91207d2d5c8bbe435e303b1481f77aeead2fecf1)
imported these notes into `docs/dev/notes` from the MUD section's `lib/legacy/tab`.
This is their first appearance in this repository's history. The import retained
claims about a JavaScript predication implementation and paths such as
`development/lab/tab/being/scripts/being.mjs`. That tree is not present in the
current TAB source. The import does not establish the current owner or delivery
state of that historical implementation.

Original bodies and references are retained as research context, including
claims such as “now emits”, “shipped” and “already realizes”. These are historical
claims, not verified statements about current Fennel behavior. Referenced notes
and modules absent from this repository remain unresolved historical references;
they must not be silently treated as local files or reconstructed as new APIs.

## Reading guide

- [Predicate richness](economy-is-predicate-richness.md): proposed economic interpretation of predication and exchange.
- [Virtual economies](virtual-economies.md): outside economic research and proposed application to that context.
- [Thick evidence](thick-evidence.md): historical witness/evidence design claims.
- [Progression design](progression-design.md): motivation research and proposed progression interpretation.
- [Engagement ethics](engagement-ethics.md): literature, design proposals and ethical positions.

The original distinction between literature findings and proposals is retained.
Preservation here does not independently validate the literature summaries or
turn a position into an accepted requirement.

## Current implementation boundary

The [TAB README](../../../README.md) documents the Fennel implementation: things
are constructed from models, attributes and behaviors. Its executable source is
in `tab.fnl`, `attributes/` and `behaviors/`; `make test` exercises actual
filesystem loading and MUD users-handler behavior. It does not certify the
JavaScript `being(...).fiber`, EAVT, bilattice, witness or economic claims below.

Before adopting a research proposal, establish its actual source owner, current
requirements, upstream contracts, implementation and receiver acceptance. These
notes alone neither assign that work nor authorize replacing the existing TAB
model. Keep them in the established `docs/dev/notes` location so their import
lineage and cross-references remain discoverable.
