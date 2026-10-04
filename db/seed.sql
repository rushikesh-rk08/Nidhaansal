-- Seed: adult name change, central gazette route. Everything is a DRAFT.
-- Passages were read from the official PDFs on 3 October 2026 but no snapshot
-- has been captured yet, so passage_found is NULL (unchecked).

INSERT INTO procedures VALUES
 ('name-change-adult', 'Change your name legally (adult)', 'identity', NULL),
 ('aadhaar-name-update', 'Update the name on your Aadhaar', 'identity', NULL);

INSERT INTO procedure_links VALUES
 ('name-change-adult', 'aadhaar-name-update', 'leads_to',
  'A gazette notification is what Aadhaar asks for when the first or full name changes.');

INSERT INTO sources (id, issuer, title, url, official, language, access, issued_on, stated_period, supersedes, check_frequency) VALUES
 ('dop-guidelines-adult', 'Department of Publication',
  'Guidelines for change of name for adult (major)',
  'https://cdnbbsr.s3waas.gov.in/s3ea6b2efbdd4255a9f1b3bbc6399b58f4/uploads/2023/06/202312082035285613.pdf',
  1, 'en', 'unchecked', NULL, 'Fee stated for 01/04/2016 to 31/03/2017; payment note dated 04/10/2018', NULL, 'monthly'),
 ('uidai-doc-list', 'UIDAI',
  'List of acceptable documents for enrolment and update',
  'https://uidai.gov.in/images/commdoc/List_of_Supporting_Document_for_Aadhaar_Enrolment_and_Update.pdf',
  1, 'en', 'unchecked', NULL, NULL, NULL, 'monthly'),
 ('uidai-faq-update', 'UIDAI', 'Enrolment and update FAQ',
  'https://uidai.gov.in/en/enrolment-and-update',
  1, 'en', 'unchecked', NULL, NULL, NULL, 'monthly'),
 ('dgps-maharashtra', 'Government of Maharashtra',
  'Directorate of Government Printing, Stationery and Publications',
  'https://dgps.maharashtra.gov.in', 1, 'mr', 'unchecked', NULL, NULL, NULL, 'monthly'),
 ('blog-potools-uidai-sop', 'PO Tools Blog (private)',
  'UIDAI SOP for name update, circular dated 18/09/2026',
  'https://www.potoolsblog.in/2026/09/uidai-sop-for-name-update-in-aadhaar.html',
  0, 'en', 'unchecked', NULL, NULL, NULL, NULL);

INSERT INTO questions VALUES
 ('q-nc-kind', 'name-change-adult', 1,
  'Are you changing your name to a different one, or fixing how it is spelt or ordered on some documents?',
  'Lay your documents side by side. If the name is the same person''s name written differently (initials, spelling, order), it is a correction.'),
 ('q-nc-gazette', 'name-change-adult', 2,
  'Do you want the notice published by the central government or by your state?',
  'Either can work for Aadhaar. The state route differs by state; we currently cover the central route only.');

INSERT INTO question_options VALUES
 ('o-nc-kind-change', 'q-nc-kind', 'A different name'),
 ('o-nc-kind-correct', 'q-nc-kind', 'Fixing spelling or order'),
 ('o-nc-gaz-central', 'q-nc-gazette', 'Central government'),
 ('o-nc-gaz-state', 'q-nc-gazette', 'My state');

INSERT INTO variants VALUES
 ('name-change-adult.central', 'name-change-adult', 'Central gazette route'),
 ('aadhaar-name-update.full', 'aadhaar-name-update', 'First name or full name change');

INSERT INTO variant_conditions VALUES
 ('name-change-adult.central', 'o-nc-kind-change'),
 ('name-change-adult.central', 'o-nc-gaz-central');

INSERT INTO steps VALUES
 ('nc.central.ad',       'name-change-adult.central', 1, 'Publish a notice of your name change in a newspaper.', 'diy'),
 ('nc.central.papers',   'name-change-adult.central', 2, 'Prepare the undertaking, the printed notice form and your photographs.', 'diy'),
 ('nc.central.pay',      'name-change-adult.central', 3, 'Pay the publication fee online.', 'diy'),
 ('nc.central.submit',   'name-change-adult.central', 4, 'Send or hand in everything to the Department of Publication in Delhi.', 'diy'),
 ('nc.central.download', 'name-change-adult.central', 5, 'Download the published gazette.', 'diy'),
 ('aadhaar.full.update', 'aadhaar-name-update.full',  1, 'Take the gazette and an ID in your old name to an Aadhaar centre.', 'diy');

INSERT INTO step_dependencies VALUES
 ('nc.central.submit', 'nc.central.ad'),
 ('nc.central.submit', 'nc.central.papers'),
 ('nc.central.submit', 'nc.central.pay'),
 ('nc.central.download', 'nc.central.submit');

INSERT INTO claims (id, step_id, type, statement, value_json, risk, currency) VALUES
 ('nc.central.ad.count', 'nc.central.ad', 'requirement',
  'Advertise the change of name in one leading local daily newspaper.', '{"newspapers":1}', 'high', 'unknown'),
 ('nc.central.ad.content', 'nc.central.ad', 'requirement',
  'The advertisement must state your father''s or husband''s name and your residential address.', NULL, 'high', 'unknown'),
 ('nc.central.undertaking', 'nc.central.papers', 'document',
  'Submit a signed undertaking giving your old name, new name, father''s or husband''s name and address.', NULL, 'high', 'unknown'),
 ('nc.central.proforma', 'nc.central.papers', 'document',
  'Submit the prescribed notice form in duplicate, typed, signed in your old name and by two witnesses, with a soft copy in MS Word on CD.', '{"copies":2,"witnesses":2}', 'high', 'unknown'),
 ('nc.central.photos-id', 'nc.central.papers', 'document',
  'Submit two self-attested passport size photographs and a self-attested copy of a photo ID.', '{"photographs":2}', 'high', 'unknown'),
 ('nc.central.match-cert', 'nc.central.papers', 'document',
  'Submit a signed certificate that the printed copy and the soft copy are the same.', NULL, 'high', 'unknown'),
 ('nc.central.fee', 'nc.central.pay', 'fee',
  'The publication charge is Rs 1100.', '{"amount_inr":1100}', 'high', 'old_unconfirmed'),
 ('nc.central.fee.method', 'nc.central.pay', 'requirement',
  'Pay through the Non Tax Receipt Portal, bharatkosh.gov.in.', NULL, 'high', 'unknown'),
 ('nc.central.where', 'nc.central.submit', 'authority',
  'Submit to the Controller of Publications, Department of Publication, Civil Lines, Delhi 110054, in person or by post.', NULL, 'high', 'unknown'),
 ('nc.central.no-agents', 'nc.central.submit', 'prohibition',
  'Applications are accepted only from the applicant in person or by post or courier; agents and advocates are not a permitted channel.', NULL, 'low', 'unknown'),
 ('nc.central.doc-age', 'nc.central.submit', 'deadline',
  'The documents must not be more than one year old.', '{"max_age_days":365}', 'high', 'unknown'),
 ('nc.central.download.site', 'nc.central.download', 'requirement',
  'Download your gazette from egazette.gov.in; no printed copy is issued and the download needs no further stamp.', NULL, 'low', 'unknown'),
 ('aadhaar.full.gazette', 'aadhaar.full.update', 'document',
  'A change of first name or full name on Aadhaar needs a gazette notification.', NULL, 'high', 'unknown'),
 ('aadhaar.full.address-match', 'aadhaar.full.update', 'requirement',
  'The address in the gazette should match the address on your Aadhaar.', NULL, 'high', 'unknown');

INSERT INTO claim_links VALUES
 ('aadhaar.full.address-match', 'nc.central.papers',
  'Use your Aadhaar address in the undertaking and notice, or update the Aadhaar address first.');

INSERT INTO evidence (claim_id, kind, source_id, locator, passage) VALUES
 ('nc.central.ad.count', 'passage', 'dop-guidelines-adult', 'para 1',
  'Change of name should be advertised in one of the daily local leading newspapers'),
 ('nc.central.ad.content', 'passage', 'dop-guidelines-adult', 'para 1',
  'stating therein Father’s/ Husband’s name along with residential address and forward it in original to this department'),
 ('nc.central.undertaking', 'passage', 'dop-guidelines-adult', 'para 2',
  'An undertaking duly signed by the applicant showing therein his/her old and new name along with full details of father’s/ husband’s name with residential address'),
 ('nc.central.proforma', 'passage', 'dop-guidelines-adult', 'para 3',
  'signed by the individual in his/her old name, with two witnesses in duplicate should be submitted along with soft copy (CD MS Word)'),
 ('nc.central.photos-id', 'passage', 'dop-guidelines-adult', 'list item (v)',
  'Two self attested passport size photographs and photocopy of ID proof (self attested).'),
 ('nc.central.match-cert', 'passage', 'dop-guidelines-adult', 'list item (vi)',
  'A certificate duly signed by the applicant declaring therein that the contents of the hard copy and the soft copy are similar.'),
 ('nc.central.fee', 'passage', 'dop-guidelines-adult', 'para 5',
  'The printing charges for publication of change of name is Rs 1100/- only w.e.f. 01/04/2016 to 31/03/2017.'),
 ('nc.central.fee.method', 'passage', 'dop-guidelines-adult', 'para 5',
  'The amount will have to be submitted through NTRP (Non Tax Receipt Portal), i.e. www.bharatkosh.gov.in. from 01/10/2018 onwards'),
 ('nc.central.where', 'passage', 'dop-guidelines-adult', 'para 6',
  'addressed to the Controller of Publications, Department of Publication, Civil Lines, Delhi 110054 should either be submitted personally or be sent by post to this department'),
 ('nc.central.no-agents', 'passage', 'dop-guidelines-adult', 'para 10',
  'No other channel is permissible viz Agents, Advocates, etc.'),
 ('nc.central.doc-age', 'passage', 'dop-guidelines-adult', 'para 6',
  'The documents must not be older than one year.'),
 ('nc.central.download.site', 'passage', 'dop-guidelines-adult', 'step 7',
  'THIS FURTHER NEEDS NO CERTIFICATION FROM THE DEPARTMENT.'),
 ('aadhaar.full.gazette', 'passage', 'uidai-doc-list', 'List IV, item 18',
  'For change in first name or change in full name: Gazette notification'),
 ('aadhaar.full.address-match', 'passage', 'uidai-faq-update', 'How can I change my first name or full name?',
  'In Gazette, address details should match with your Aadhaar.');

INSERT INTO claim_conflicts VALUES
 ('nc.central.ad.count', NULL,
  'Many agent sites state two advertisements, one English and one regional. Not official.'),
 ('nc.central.undertaking', NULL,
  'Agent sites commonly describe a notarised affidavit on stamp paper. The guideline asks for a signed undertaking.'),
 ('nc.central.fee', NULL,
  'The stated fee period ended 31/03/2017, but the document was edited in 2018 with the fee unchanged. Needs direct confirmation.');

INSERT INTO signals (kind, detail, raised_at) VALUES
 ('secondary-report',
  'Blogs report a UIDAI circular dated 18/09/2026 replacing the name-update procedure. Not found on uidai.gov.in. They disagree on which earlier procedure it replaces.',
  '2026-10-03');
INSERT INTO signal_claims VALUES (1, 'aadhaar.full.gazette'), (1, 'aadhaar.full.address-match');
