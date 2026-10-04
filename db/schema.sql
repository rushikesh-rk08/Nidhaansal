-- Nidhaansal data model, version 1 (SQLite)
-- Rule enforced here: a claim can become 'verified' only if a named human
-- has recorded an approving verification for it. Nothing else can publish.

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------- procedures
CREATE TABLE procedures (
  id          TEXT PRIMARY KEY,            -- e.g. name-change-adult
  title       TEXT NOT NULL,               -- plain-language name
  domain      TEXT NOT NULL,               -- identity, vehicle, property, ...
  owner       TEXT                         -- reviewer responsible
);

-- Everyday phrases people use for this need. Reviewed content.
CREATE TABLE procedure_phrases (
  procedure_id TEXT NOT NULL REFERENCES procedures(id),
  language     TEXT NOT NULL,
  phrase       TEXT NOT NULL
);

-- One procedure often needs the output of another (proof of succession,
-- a gazette notification). This is the chain shown to the user up front.
CREATE TABLE procedure_links (
  from_procedure TEXT NOT NULL REFERENCES procedures(id),
  to_procedure   TEXT NOT NULL REFERENCES procedures(id),
  kind           TEXT NOT NULL CHECK (kind IN ('requires', 'leads_to')),
  note           TEXT
);

-- ------------------------------------------------- fixed questions & variants
-- A short fixed list of questions per procedure decides the path.
CREATE TABLE questions (
  id            TEXT PRIMARY KEY,
  procedure_id  TEXT NOT NULL REFERENCES procedures(id),
  position      INTEGER NOT NULL,
  plain_wording TEXT NOT NULL,   -- asked in terms of the person's situation
  how_to_find_out TEXT           -- help when the answer is "I don't know"
);

CREATE TABLE question_options (
  id          TEXT PRIMARY KEY,
  question_id TEXT NOT NULL REFERENCES questions(id),
  label       TEXT NOT NULL
);

CREATE TABLE variants (
  id           TEXT PRIMARY KEY,           -- e.g. name-change-adult.central
  procedure_id TEXT NOT NULL REFERENCES procedures(id),
  title        TEXT NOT NULL
);

-- A variant applies when all its listed options were chosen.
CREATE TABLE variant_conditions (
  variant_id TEXT NOT NULL REFERENCES variants(id),
  option_id  TEXT NOT NULL REFERENCES question_options(id)
);

-- --------------------------------------------------------------------- steps
CREATE TABLE steps (
  id         TEXT PRIMARY KEY,
  variant_id TEXT NOT NULL REFERENCES variants(id),
  position   INTEGER NOT NULL,
  action     TEXT NOT NULL,                -- plain-language instruction
  guidance   TEXT CHECK (guidance IN ('diy', 'escalate'))
);

CREATE TABLE step_dependencies (
  step_id    TEXT NOT NULL REFERENCES steps(id),
  depends_on TEXT NOT NULL REFERENCES steps(id)
);

-- Unofficial experience from the counter. Never mixed with claims.
CREATE TABLE practice_notes (
  id          INTEGER PRIMARY KEY,
  step_id     TEXT NOT NULL REFERENCES steps(id),
  office      TEXT,
  observed_on TEXT,
  note        TEXT NOT NULL,
  reported_by TEXT
);

-- -------------------------------------------------------------------- claims
CREATE TABLE claims (
  id         TEXT PRIMARY KEY,
  step_id    TEXT NOT NULL REFERENCES steps(id),
  type       TEXT NOT NULL CHECK (type IN
              ('requirement','document','fee','authority','deadline',
               'eligibility','sequence','route','guidance','prohibition')),
  statement  TEXT NOT NULL,                -- one plain sentence
  value_json TEXT,                         -- structured value where one exists
  risk       TEXT NOT NULL CHECK (risk IN ('high','low')),
  status     TEXT NOT NULL DEFAULT 'draft' CHECK (status IN
              ('draft','verified','under_review','retired')),
  -- Age and validity are separate facts (old is not the same as outdated):
  currency   TEXT NOT NULL DEFAULT 'unknown' CHECK (currency IN
              ('in_force_unchanged','replaced','old_unconfirmed','unknown')),
  expires_on TEXT,                         -- re-check by this date regardless
  drafted_by TEXT NOT NULL DEFAULT 'ai'    -- 'ai' or a person's name
);

-- A claim in one procedure can constrain a step in another
-- (the gazette address must match the Aadhaar address).
CREATE TABLE claim_links (
  claim_id        TEXT NOT NULL REFERENCES claims(id),
  affects_step_id TEXT NOT NULL REFERENCES steps(id),
  note            TEXT
);

-- Other accounts that say something different, kept so the reviewer sees why
-- users may have heard otherwise. Never shown as fact.
CREATE TABLE claim_conflicts (
  claim_id  TEXT NOT NULL REFERENCES claims(id),
  source_id TEXT REFERENCES sources(id),
  note      TEXT NOT NULL
);

-- ------------------------------------------------------- sources & snapshots
CREATE TABLE sources (
  id              TEXT PRIMARY KEY,
  issuer          TEXT NOT NULL,
  title           TEXT NOT NULL,
  url             TEXT,
  official        INTEGER NOT NULL CHECK (official IN (0,1)),
  language        TEXT NOT NULL DEFAULT 'en',
  access          TEXT NOT NULL CHECK (access IN
                   ('fetch-allowed','human-snapshot-only','login-required',
                    'document-on-request','unchecked')),
  issued_on       TEXT,          -- when the source says it was issued
  stated_period   TEXT,          -- any validity period the source states
  supersedes      TEXT REFERENCES sources(id),
  check_frequency TEXT
);

CREATE TABLE snapshots (
  id           INTEGER PRIMARY KEY,
  source_id    TEXT NOT NULL REFERENCES sources(id),
  captured_at  TEXT NOT NULL,
  captured_by  TEXT NOT NULL,    -- 'fetcher' or a person's name
  content_hash TEXT NOT NULL,
  file_path    TEXT NOT NULL
);

-- ------------------------------------------------------------------ evidence
CREATE TABLE evidence (
  id          INTEGER PRIMARY KEY,
  claim_id    TEXT NOT NULL REFERENCES claims(id),
  kind        TEXT NOT NULL CHECK (kind IN
               ('passage',              -- words in an official source
                'absence',              -- not in a list the source presents as complete
                'direct_confirmation')),-- a person asked the office
  source_id   TEXT REFERENCES sources(id),
  snapshot_id INTEGER REFERENCES snapshots(id),
  locator     TEXT,              -- page / paragraph
  passage     TEXT,              -- verbatim, filled from the snapshot
  passage_found INTEGER,         -- mechanical check: 1, 0 or NULL (unchecked)
  confirmed_by  TEXT,            -- for direct_confirmation
  confirmed_how TEXT,
  confirmed_on  TEXT
);

-- ------------------------------------------------------------- verifications
-- A human decision. The only thing that can make a claim 'verified'.
CREATE TABLE verifications (
  id         INTEGER PRIMARY KEY,
  claim_id   TEXT NOT NULL REFERENCES claims(id),
  reviewer   TEXT NOT NULL CHECK (reviewer <> '' AND lower(reviewer) <> 'ai'),
  decided_at TEXT NOT NULL,
  decision   TEXT NOT NULL CHECK (decision IN ('approve','edit','reject')),
  note       TEXT,
  second_reviewer TEXT
);

-- ------------------------------------------------------------------- signals
-- Anything suggesting a claim may be out of date. Opens a review; never
-- changes content.
CREATE TABLE signals (
  id          INTEGER PRIMARY KEY,
  kind        TEXT NOT NULL CHECK (kind IN
               ('snapshot-diff','secondary-report','user-report','expiry',
                'reviewer-knowledge')),
  detail      TEXT NOT NULL,
  raised_at   TEXT NOT NULL,
  ai_proposal TEXT,              -- shown to the reviewer only
  resolved_at TEXT
);

CREATE TABLE signal_claims (
  signal_id INTEGER NOT NULL REFERENCES signals(id),
  claim_id  TEXT NOT NULL REFERENCES claims(id)
);

-- ------------------------------------------------------------------ glossary
-- Terms reviewed once per language; translations reuse them unchanged.
CREATE TABLE glossary (
  term        TEXT NOT NULL,
  language    TEXT NOT NULL,
  rendering   TEXT NOT NULL,
  explanation TEXT,
  reviewed_by TEXT,
  PRIMARY KEY (term, language)
);

-- ------------------------------------------------------- the rule, enforced
CREATE TRIGGER claims_no_insert_as_verified
BEFORE INSERT ON claims
WHEN NEW.status = 'verified'
BEGIN
  SELECT RAISE(ABORT, 'A claim cannot be created as verified. A human must review it.');
END;

CREATE TRIGGER claims_verified_needs_human
BEFORE UPDATE OF status ON claims
WHEN NEW.status = 'verified'
 AND NOT EXISTS (
   SELECT 1 FROM verifications v
   WHERE v.claim_id = NEW.id AND v.decision IN ('approve','edit')
 )
BEGIN
  SELECT RAISE(ABORT, 'Only a recorded human verification can make a claim verified.');
END;

-- A signal moves its claims to under_review automatically (adds caution).
CREATE TRIGGER signal_puts_claim_under_review
AFTER INSERT ON signal_claims
BEGIN
  UPDATE claims SET status = 'under_review'
  WHERE id = NEW.claim_id AND status = 'verified';
END;

-- What a user may be shown.
CREATE VIEW user_visible_claims AS
SELECT c.*,
       (SELECT max(decided_at) FROM verifications v
         WHERE v.claim_id = c.id AND v.decision IN ('approve','edit')) AS last_checked
FROM claims c
WHERE c.status IN ('verified','under_review');
