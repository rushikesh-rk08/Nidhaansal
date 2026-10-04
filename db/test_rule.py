"""Builds the database and checks the one rule that matters:
nothing becomes 'verified' without a recorded human decision."""
import os, sqlite3, sys

here = os.path.dirname(os.path.abspath(__file__))
path = os.path.join(here, "nidhaansal.db")
if os.path.exists(path):
    os.remove(path)
db = sqlite3.connect(path)
db.execute("PRAGMA foreign_keys = ON")
db.executescript(open(os.path.join(here, "schema.sql"), encoding="utf-8").read())
db.executescript(open(os.path.join(here, "seed.sql"), encoding="utf-8").read())
db.commit()

results = []
def check(name, ok):
    results.append(ok)
    print(("PASS  " if ok else "FAIL  ") + name)

def refused(sql, args=()):
    try:
        db.execute(sql, args); db.commit(); return False
    except sqlite3.Error:
        db.rollback(); return True

n = db.execute("SELECT count(*) FROM claims").fetchone()[0]
check(f"seed loaded ({n} claims, all draft)",
      n > 0 and db.execute("SELECT count(*) FROM claims WHERE status<>'draft'").fetchone()[0] == 0)
check("every claim has evidence",
      db.execute("SELECT count(*) FROM claims c WHERE NOT EXISTS (SELECT 1 FROM evidence e WHERE e.claim_id=c.id)").fetchone()[0] == 0)
check("no draft is visible to users",
      db.execute("SELECT count(*) FROM user_visible_claims").fetchone()[0] == 0)

C = "nc.central.ad.count"
check("cannot verify without a human record",
      refused("UPDATE claims SET status='verified' WHERE id=?", (C,)))
check("cannot insert a claim as verified",
      refused("INSERT INTO claims (id, step_id, type, statement, risk, status) VALUES ('x','nc.central.ad','fee','x','high','verified')"))
check("'ai' cannot be a reviewer",
      refused("INSERT INTO verifications (claim_id, reviewer, decided_at, decision) VALUES (?, 'AI', '2026-10-03', 'approve')", (C,)))

db.execute("INSERT INTO verifications (claim_id, reviewer, decided_at, decision) VALUES (?, 'Test Reviewer', '2026-10-03', 'reject')", (C,))
db.commit()
check("a rejection does not allow verifying",
      refused("UPDATE claims SET status='verified' WHERE id=?", (C,)))

db.execute("INSERT INTO verifications (claim_id, reviewer, decided_at, decision) VALUES (?, 'Test Reviewer', '2026-10-03', 'approve')", (C,))
db.execute("UPDATE claims SET status='verified' WHERE id=?", (C,))
db.commit()
check("a human approval allows verifying",
      db.execute("SELECT status FROM claims WHERE id=?", (C,)).fetchone()[0] == "verified")
check("verified claim is visible to users",
      db.execute("SELECT count(*) FROM user_visible_claims WHERE id=?", (C,)).fetchone()[0] == 1)

db.execute("INSERT INTO signals (kind, detail, raised_at) VALUES ('user-report','Counter asked for two ads','2026-10-03')")
sid = db.execute("SELECT last_insert_rowid()").fetchone()[0]
db.execute("INSERT INTO signal_claims VALUES (?, ?)", (sid, C))
db.commit()
check("a signal moves a verified claim to under_review",
      db.execute("SELECT status FROM claims WHERE id=?", (C,)).fetchone()[0] == "under_review")
check("a signal leaves the statement untouched",
      db.execute("SELECT statement FROM claims WHERE id=?", (C,)).fetchone()[0].startswith("Advertise the change"))

# leave the database clean: test records removed, everything back to draft
db.execute("DELETE FROM signal_claims WHERE signal_id=?", (sid,))
db.execute("DELETE FROM signals WHERE id=?", (sid,))
db.execute("DELETE FROM verifications")
db.execute("UPDATE claims SET status='draft'")
db.commit()
check("database reset to all drafts",
      db.execute("SELECT count(*) FROM claims WHERE status<>'draft'").fetchone()[0] == 0)

print(f"\n{sum(results)} of {len(results)} checks passed")
sys.exit(0 if all(results) else 1)
