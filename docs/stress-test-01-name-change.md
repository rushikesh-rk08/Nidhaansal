# Stress test 1: adult name change

Date: 3 October 2026. Status: nothing here is verified. These are drafts read
from official sources on this date, for testing the schema.

## Sources read

| Source | Issuer | Official | Notes |
|---|---|---|---|
| Guidelines for change of name for adult (major) | Department of Publication | yes | PDF, fetched directly |
| List of acceptable documents for enrolment and update | UIDAI | yes | PDF, fetched directly |
| Enrolment and update FAQ | UIDAI | yes | Search excerpt only, page not captured |
| DGPS Maharashtra home page | Govt of Maharashtra | yes | In Marathi; links to Aaple Sarkar and a 2018 user manual |
| Two blogs on a UIDAI circular of 18 Sept 2026 | private | no | Tripwire only |

## What the official sources say (draft claims)

Central Gazette route, adult:
1. Advertise the change in one leading local daily newspaper.
2. Submit a signed undertaking with old name, new name, father's or husband's
   name and address. The guideline asks for an undertaking, not a notarised
   affidavit. Central government employees submit a deed instead.
3. Submit the prescribed proforma in duplicate, signed in the old name with
   two witnesses, plus a soft copy on CD.
4. Two self-attested photographs and a self-attested photo ID copy.
5. Fee Rs 1100, paid through Bharat Kosh. The guideline states this fee with
   a validity period ending 31 March 2017.
6. Submit in person or by post to the Controller of Publications, Delhi.
   The guideline says no other channel, naming agents and advocates, is
   permitted.
7. Documents must be no more than one year old.
8. The published gazette is downloaded from egazette.gov.in; no hard copy.

Aadhaar after the gazette:
9. A change of first name or full name needs a gazette notification.
10. The UIDAI FAQ accepts a gazette from a state or the union government and
    says the address in the gazette should match the Aadhaar address.
11. The UIDAI FAQ says two name updates are allowed with ordinary documents;
    beyond that, a gazette and an exception process. The page is about two
    years old, so the limit is not new in 2026.

## Where the original deck differs from the official text

| Deck | Official source |
|---|---|
| Notarised affidavit on stamp paper | Signed undertaking (central route) |
| Two newspaper ads, English and regional | One leading local daily (central route) |
| "As of 2026, UIDAI caps name updates" | The two-update limit is older than 2026 |
| Gazette as one step | Two routes, central and state, with different rules |

## Where the schema broke

1. Old is not the same as outdated. The fee is stated for a period that ended
   in 2017, but the document was edited in 2018 (payment method) with the fee
   left as it was, and it is still the hosted version. That points to
   "unchanged since", not "outdated", though it is not confirmed. The schema
   had no way to tell these apart. Needed, recorded separately: when the
   source was issued and any period it states; when we last saw it unchanged;
   whether anything replaces it. User-facing labels: "in force, unchanged
   since <date>", "replaced", and "old and not confirmable". Only the last
   needs a warning, or a second kind of evidence: direct confirmation (who
   was asked, how, when).
2. Sources replace each other. The UIDAI list links to a procedure dated
   October 2021; blogs report a newer one. Needed: `supersedes` and
   `superseded_by` on Source.
3. Procedures constrain each other. The Aadhaar rule that the gazette address
   must match affects how the gazette step is done. Needed: links between
   claims across procedures, and `leads_to` between procedures.
4. Negative claims. "No advertisement needed" or "no agent allowed" cannot be
   supported by a passage in the same way as a positive requirement. Needed:
   an evidence kind for "absent from a list the source presents as complete".
5. Access and language. The Maharashtra instructions sit in a 2018 manual and
   behind a login, and the site is in Marathi. Needed on Source: `language`,
   and access value `login-required`. The application form itself, as seen
   by a logged-in person, is evidence and needs a human snapshot.
6. Secondary sources disagree with each other. One blog says the new UIDAI
   procedure replaces one from 2021, another says October 2024. This confirms
   tripwires must never be quoted to users.

## Unresolved

- Whether the Maharashtra state gazette needs a newspaper advertisement. The
  public home page does not say; needs the manual and the live form.
- Whether the UIDAI circular of 18 September 2026 exists and what it changes.
  Not found on uidai.gov.in in this pass.
- The current central gazette fee.
