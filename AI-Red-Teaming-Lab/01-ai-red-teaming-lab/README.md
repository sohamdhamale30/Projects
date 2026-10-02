# Project 1: Automated AI Red-Teaming Lab

Attack a locally-hosted chatbot with Garak + PyRIT, automate the scan in
CI, document findings against OWASP LLM Top 10 / MITRE ATLAS, fix the
vulnerable system, and prove the fix with a retest.

> **Safety note.** This runs entirely on your own machine against a bot you
> built and own, using a fictional bank and a fake, planted secret. Don't
> point this tooling at systems you don't control.

## Business scenario

NorthPeak Bank (fictional) has a public LLM chatbot with an internal
escalation code embedded in its system prompt. See [THREAT_MODEL.md](THREAT_MODEL.md)
for the full architecture and threat catalogue.

## Setup

```bash
# 1. Install Ollama and pull the model
curl -fsSL https://ollama.com/install.sh | sh   # or the macOS/Windows installer
ollama pull llama3.1:8b
ollama serve

# 2. In a new terminal, run the vulnerable target
cd target
pip install -r requirements.txt
uvicorn app:app --reload --port 8000

# 3. In a new terminal, install the attack tooling
pip install garak pyrit-core
```

## Methodology

1. **Broad sweep with Garak** — run the general-purpose probe families
   (`encoding`, `promptinject`, `leakreplay`, `dan`) against the target's
   REST API:
   ```bash
   cd redteam
   chmod +x garak_scan.sh retest.sh
   ./garak_scan.sh
   ```
2. **Targeted attack chain with PyRIT** — hand-craft and score a multi-turn
   attack against the specific secret-leak scenario:
   ```bash
   python pyrit_orchestrator.py
   ```
3. **Document findings** in [findings/FINDINGS_TEMPLATE.md](findings/FINDINGS_TEMPLATE.md),
   mapped to OWASP LLM Top 10 and MITRE ATLAS.
4. **Fix** — apply the hardened target in `mitigations/hardened_app.py`
   (run it on port 8001 alongside the original).
5. **Retest** — rerun the identical probe set against the hardened target
   and compare pass rates:
   ```bash
   uvicorn hardened_app:app --port 8001    # from mitigations/
   cd ../redteam && ./retest.sh
   ```
6. **Automate** — `.github/workflows/redteam-ci.yml` reruns the scan on
   every push to `target/` or `redteam/` and fails the build if any probe
   finds a successful attack, so a future prompt regression is caught by
   CI instead of manual review.

## Notes on the tooling versions

Both Garak and PyRIT change their APIs fairly often. If a command in this
README doesn't match what's installed, check `garak --help` and the PyRIT
docs for your installed version rather than assuming this README is
current — that's a normal part of working with fast-moving security
tooling, and worth mentioning as a limitation in your writeup.

## What's in this folder

| File | Purpose |
|---|---|
| `THREAT_MODEL.md` | Business scenario, architecture diagram, threat catalogue |
| `target/app.py` | Vulnerable target chatbot |
| `redteam/garak_scan.sh` | Broad automated probe run |
| `redteam/pyrit_orchestrator.py` | Targeted, scored attack chain |
| `redteam/retest.sh` | Rerun probes against the hardened target |
| `mitigations/hardened_app.py` | Fixed version with controls mapped to findings |
| `findings/FINDINGS_TEMPLATE.md` | Findings log, OWASP/ATLAS-mapped |
| `.github/workflows/redteam-ci.yml` | CI automation |

## Portfolio checklist

- [ ] Run the baseline scan, fill in `FINDINGS_TEMPLATE.md` with real transcripts
- [ ] Push to a repo and confirm the CI workflow runs and fails on the vulnerable target
- [ ] Apply mitigations, retest, confirm CI passes
- [ ] Record a 3-minute demo: baseline attack succeeding → fix → retest failing to reproduce it
- [ ] Write a one-page executive summary in plain business language (what was found, what it would have cost the bank, what was fixed)
- [ ] In the summary, be explicit about what you built vs. where Garak/PyRIT/the model did the work, and what still needs human validation (e.g. the regex-based input filter is a first layer, not a complete fix)
