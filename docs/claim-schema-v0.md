# Claim schema, version 0

Purpose: one structure that can hold any administrative procedure, where every
statement shown to a user is traceable to an official source and to the person
who verified it.

Rule the schema enforces: the AI may create and change drafts and may put
things under review. Only a human verification record can make a claim
`verified`. Only verified claims are shown as current.

---

## Entities

### Procedure
What the person is trying to get done.

| Field | Meaning |
|---|---|
| id | e.g. `name-change-adult` |
| title | Plain-language name |
| domain | identity, vehicle, property, certificate, employment, ... |
| owner | The reviewer responsible for this procedure |
| variants | List of Variant ids |

### Variant
The same procedure differs by place and by case. A variant is one concrete path.

| Field | Meaning |
|---|---|
| id | e.g. `name-change-adult.central-gazette` |
| conditions | Machine-readable conditions: jurisdiction, case type, applicant type |
| steps | Ordered list of Step ids |
| route_note | When to pick this variant over a sibling (itself a claim) |

### Step
One action the person takes. A step has no facts of its own; it is a container
for claims.

| Field | Meaning |
|---|---|
| id | e.g. `...central-gazette.newspaper-ad` |
| action | Plain-language instruction |
| depends_on | Steps that must be done first |
| guidance | `diy` or `escalate`, plus the reason (itself a claim) |
| claims | List of Claim ids |

### Claim
The atomic unit of verification. One checkable fact.

| Field | Meaning |
|---|---|
| id | Stable identifier |
| type | `requirement`, `document`, `fee`, `authority`, `deadline`, `eligibility`, `sequence`, `route`, `guidance` |
| statement | The fact in one plain sentence |
| value | Structured value where one exists (amount, count, days) |
| risk | `high` (fee, document, eligibility, deadline) or `low` |
| status | `draft`, `verified`, `under_review`, `retired` |
| evidence | One or more Evidence records |
| verification | Latest Verification record, empty while draft |
| expires_on | Date by which it must be re-checked even if nothing changed |
| conflicts | Other sources that say something different, with notes |

### Source
An official place a fact can come from.

| Field | Meaning |
|---|---|
| id | e.g. `dop-guidelines-adult` |
| issuer | Department or authority |
| url | Address |
| official | true only for the issuing authority's own publication |
| access | `fetch-allowed`, `human-snapshot-only`, `document-on-request` |
| check_frequency | How often it is re-captured |

### Snapshot
A saved copy of a source at a moment in time. Evidence points at snapshots,
not at live pages, so a claim never silently loses its basis.

| Field | Meaning |
|---|---|
| source_id | Which source |
| captured_at | Date and time |
| captured_by | `fetcher` or a person's name |
| content_hash | Fingerprint used for change detection |
| file | Stored copy |

### Evidence
The exact passage that supports a claim.

| Field | Meaning |
|---|---|
| snapshot | Which snapshot |
| locator | Page and paragraph |
| passage | The supporting words, verbatim |
| passage_found | Mechanical check: is the passage present word for word |

### Verification
A human decision. The only thing that can verify.

| Field | Meaning |
|---|---|
| reviewer | Named person |
| decided_at | Date and time |
| decision | `approve`, `edit`, `reject` |
| note | Reasoning, especially for edits |
| second_reviewer | Required for high-risk claims once there are two reviewers |

### Signal
Anything suggesting a claim may be out of date. Signals open reviews; they
never change content.

| Field | Meaning |
|---|---|
| kind | `snapshot-diff`, `secondary-report`, `user-report`, `expiry` |
| detail | What was seen and where |
| affected_claims | Claims moved to `under_review` |
| ai_proposal | Suggested new wording, shown to the reviewer only |

---

## Status lifecycle

```
draft --(human approves)--> verified --(any signal)--> under_review
                                ^                            |
                                +------(human decides)-------+
                                                             |
                                                        retired
```

What "verified" means: our reviewer compared the statement with the official
source and confirmed they match. It is not an official endorsement, and the
product issues no certificate or document of any kind. The user still completes
the procedure with the government office or portal.

What the user sees:
- `verified`: the statement, its source, "checked on <date> by <reviewer>"
- `under_review`: the last verified statement, marked "under review since
  <date>, the official source may have changed", with the source link
- `draft`, `retired`: not shown

---

## Worked example: one claim

This is the claim the original deck got wrong. It is still a draft because the
passage was read from a search excerpt, not from a captured snapshot.

```yaml
claim:
  id: name-change-adult.central-gazette.newspaper-ad.count
  type: requirement
  statement: Publish the change of name in one daily local leading newspaper.
  value: { newspapers: 1 }
  risk: high
  status: draft
  evidence:
    - snapshot: dop-guidelines-adult@(not yet captured)
      locator: "Guidelines for change of name for adult (major)"
      passage: "Change of name should be advertised in one of the daily local leading newspapers"
      passage_found: unchecked
  verification: null
  expires_on: null
  conflicts:
    - note: >
        Many agent sites state two advertisements, one English and one
        regional. Not an official source. Recorded so the reviewer sees why
        users may have heard otherwise.
    - note: >
        State gazettes have their own rules. Maharashtra is a separate variant
        and secondary sources disagree on whether it needs an advertisement.
```

---

## Decisions (3 October 2026)

1. Counter practice lives in a `practice_note` on a step, separate from claims
   and labelled as unofficial. It is fed by structured user reports: office,
   date, what was asked that differs. Each report also raises a Signal.
   A free-form question-and-answer community is planned for later, inside
   this platform. Implication for now: reports, and later questions, attach to
   a procedure or step, and anything unverified is stored and displayed
   separately from verified claims.
2. Translations are covered by the review of the original, on two conditions:
   numbers, dates and amounts carry over unchanged, and document and authority
   names come from a glossary reviewed once per language. The original
   statement is always available alongside the translation.
3. Variant conditions are a short fixed list of questions with fixed answer
   choices per procedure. No free-form logic.

## Original open questions (now decided above)

1. Counter practice: where does "the office actually asks for X" live? Proposed:
   a separate `practice_note` on a step, sourced from user reports, clearly
   labelled as not official.
2. Translations: is a translated statement verified separately, or does the
   verification of the original cover it?
3. Conditions language: how expressive do variant conditions need to be before
   they become hard for a reviewer to read?
