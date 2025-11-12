# Prompt templates for App Store submission (copy & use)

Below are ready-to-use prompt templates (Vietnamese + English) you can paste into an LLM UI or automation system. Each template instructs the model which local files to reference, required outputs, and validation steps.

---

## 1) Orchestrator — run one pipeline phase (JSON output)

System (short):
"You are an App Store submission assistant. Read `ios_foundation/app_store_submission/submission_pipeline.json` and the referenced files. Follow Apple policies in `app_store_policies.json`. Produce machine-readable JSON outputs and validation results. If a policy risk exists, stop and request human review."

User (example):
"Phase: 1 (code_scan). Files to read: `ai_instructions.json`, `submission_pipeline.json`, `privacy_compliance.json`. Inputs: project_path `/path/to/project`.

Deliverables (JSON): {
  "phase": "code_scan",
  "status": "done|failed|blocked",
  "outputs": ["/tmp/code_audit.json"],
  "validation": {"passed": true, "errors": []},
  "policy_flags": ["string"],
  "human_action_required": false
}

Actions to perform:
- Search codebase for network calls and SDK usages (patterns in `privacy_compliance.json`).
- Produce `/tmp/code_audit.json` per schema in `ai_instructions.json`.
- Run validations and include results in `validation` field."

---

## 2) Generate metadata drafts (Vietnamese prompt)

System:
"You are a metadata copywriter that must follow `metadata.json` rules exactly. Ensure outputs meet character limits and flag policy risks."

User:
"App name: 'PocketBudget'. Primary keyword: 'budget'. Audience: 'freelancers, digital nomads'.
Generate:
- 5 `name` options (≤30 chars),
- 5 `subtitle` options (≤30 chars),
- 3 full `description` variants (≤4000 chars each),
- 3 `keywords` field options (≤100 chars each).

Return JSON: {names:[], subtitles:[], descriptions:[], keywords:[], validation:{}}. Validation must include character counts and a 'policy_risks' array."

---

## 3) Create icons from master PNG (English prompt)

System:
"You are an automation assistant that can suggest shell commands. Read `app_icons.json` for required sizes and rules."

User:
"Input file: `/tmp/master-1024.png`. Produce:
- list of ImageMagick commands to generate all required sizes,
- `Contents.json` content for an Xcode asset catalog,
- a validation script that confirms no alpha channel and correct dimensions.
Return: JSON with `commands` (array), `contents_json` (string), `validation_commands` (array)."

---

## 4) Generate `PrivacyInfo.xcprivacy` and App Privacy answers

System:
"Read `privacy_compliance.json` and `ai_instructions.json`. Use code audit `/tmp/code_audit.json` as input."

User:
"From `/tmp/code_audit.json`, produce:
- `PrivacyInfo.xcprivacy` XML string,
- `app_privacy_answers.json` mapping data types to `{linked: bool, tracking: bool, purposes:[string]}`.
Validate: ensure `NSPrivacyTracking` true if any tracking present. Return JSON with `privacy_manifest`, `answers`, `validation`."

---

## 5) Screenshot captions (quick)

User:
"Screenshots: [onboarding.png, dashboard.png, report.png]. Produce 3 caption options per screenshot (<=10 words). Return JSON: {onboarding:[..], dashboard:[..], report:[..]}. Include a one-line note why each caption works."

---

## Output schema recommendations (for all prompts)

Return a top-level JSON object with fields:
- `status`: "done|failed|blocked",
- `outputs`: array of file paths or inline content objects,
- `validation`: {`passed`: bool, `errors`: [string]},
- `policy_flags`: [string],
- `human_action_required`: bool,
- `log`: optional string with short run notes.

---

## Best practices when using these prompts

- Provide absolute `project_path` where code lives if asking the agent to run scans.
- Limit scope per call (one phase/task) to reduce hallucination.
- Ask the AI to include exact shell commands and file contents when you plan to execute them.
- Always require the AI to run the `testing_checklist` from the relevant JSON and include results.
- For any policy flag, require a `human_review` artifact explaining the risk and remediation steps.

---

If you want, I will now:
- create these two files in the repo (done), and
- commit & push them (I can do that next if you want).

Which next step do you want: commit & push, or run an example (e.g., generate metadata drafts for a sample app)?
