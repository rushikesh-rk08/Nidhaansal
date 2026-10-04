# Nidhaansal

Plain steps for government paperwork in India. Every step shows the official
source it came from and when a person last checked it.

The idea: AI does the breadth (reading official sources, drafting, noticing
change), a human makes every decision about what is shown as verified, and the
user gets short, source-linked steps in plain language.

## Status

This is an early working build. The **Progress** tab on the site is the running
record of what works, what is still demo data, and what comes next.

- Three procedures are set up, one route each: adult name change through the
  central gazette, a first-name or full-name change on Aadhaar, and putting a
  vehicle in your name after the owner's death (Maharashtra, still in review).
- The steps shown are demo data. They were approved to test the flow and have
  not yet been checked line by line against the sources. Do not rely on them.
- This public site is a view-only published copy. Approving claims, checking
  sources and AI drafting run in a private workspace.

Nidhaansal is not a government service and issues no document of any kind.

## What is in this repository

| Path | What it is |
|---|---|
| `index.html` | The site: find your steps, review desk, sources, progress |
| `src/` | The page template, the build script, and the data the copy is built from |
| `db/` | The data model as a database, with the rule enforced: only a recorded human decision can mark a claim verified. `test_rule.py` checks it |
| `docs/claim-schema-v0.md` | The claim model and the decisions behind it |
| `docs/stress-test-01-name-change.md` | The first procedure run through the model, and where the model broke |

To rebuild `index.html` from the template and data: `python3 src/build.py`.
To run the rule checks: `python3 db/test_rule.py`.

## The one rule

The AI may draft claims and may put a claim under review. Only a human
decision can make a claim verified, and only verified claims are shown as
current. The AI can add caution but never remove it.
