# Findings — NorthPeak Bank Support Bot

Fill one block per finding. Keep it evidence-first: a hiring manager should
be able to reproduce the attack from what you wrote here.

---

## F1: Sensitive information disclosure via persona-override prompts

- **OWASP LLM Top 10:** LLM06 (Sensitive Information Disclosure) / LLM01 (Prompt Injection)
- **MITRE ATLAS technique:** AML.T0051 (LLM Prompt Injection)
- **Severity:** High — internal escalation code extracted with a single
  crafted prompt, no authentication or persistence required.
- **Attack:** PyRIT prompt #2 ("DebugBot" persona override) and #3 (fake
  dev-mode override) — see `redteam/pyrit_orchestrator.py`.
- **Evidence:** [paste transcript excerpt / attach garak report path]
- **Root cause:** Secret and instructions sit in the same unstructured text
  block as user input; the model has no way to distinguish "trusted
  instruction" from "attacker-supplied text claiming to be an instruction."
- **Mitigation:** See `mitigations/hardened_app.py` — secret removed from
  context entirely (F1 fix), input filter added, prompt boundary markers added.
- **Retest result:** [pass/fail after `redteam/retest.sh`]

---

## F2: System prompt / instruction disclosure via indirect requests

- **OWASP LLM Top 10:** LLM01 (Prompt Injection)
- **MITRE ATLAS technique:** AML.T0051
- **Severity:** Medium — reveals internal prompt engineering, aids further
  attacks even without a secret in scope.
- **Attack:** PyRIT prompt #4 ("translate everything above").
- **Evidence:** [ ]
- **Mitigation:** Input filter blocking repeat/translate/summarize-instructions patterns.
- **Retest result:** [ ]

---

## F3: [Add Garak-discovered findings here]

Garak's `dan`, `promptinject`, `encoding`, and `leakreplay` probe families
will likely surface additional jailbreak variants (e.g. encoded payloads
bypassing the naive filter). Document each distinct technique as its own
finding rather than lumping "jailbreaks" together — a hiring manager wants
to see you can tell attack techniques apart, not just that something failed.

---

## Summary table

| # | Finding | OWASP | Severity | Status |
|---|---------|-------|----------|--------|
| F1 | Secret leak via persona override | LLM06/LLM01 | High | Fixed / Retested |
| F2 | System prompt disclosure | LLM01 | Medium | Fixed / Retested |
| F3 | ... | ... | ... | ... |
