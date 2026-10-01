# Threat Model — NorthPeak Bank Support Bot

## Business scenario

NorthPeak Bank (fictional) has deployed an LLM-based customer support
chatbot, "Nova," on its public website. It answers account and card
questions using a local open-weight model, with an internal-notes section
in the system prompt containing an escalation code used by staff to
verify fraud reports.

## System overview

```mermaid
flowchart LR
    U[Anonymous website visitor] -->|HTTP POST /chat| A[FastAPI wrapper]
    A -->|chat completion| O[Ollama: llama3.1:8b]
    O --> A
    A --> U
    A -.system prompt incl. internal notes.-> O
```

## Trust boundaries

- **Public → App:** Anyone on the internet can send arbitrary text as
  `message`. No authentication, no rate limiting, no input validation in
  the baseline.
- **App → Model:** User input and system instructions are concatenated
  into one message list with no structural enforcement of which parts are
  "trusted."
- **Model → App → Public:** Model output is returned verbatim with no
  output filtering in the baseline.

## Assets

| Asset | Sensitivity |
|---|---|
| Internal escalation code | Confidential (fictional, but modeled as if real) |
| System prompt / internal notes | Internal — reveals prompt engineering, aids further attacks |
| Bank's reputation / regulatory exposure | High — a leaked "internal code" pattern maps to real incidents of chatbots leaking discount codes, internal policies, etc. |

## Threat catalogue (what we test and why)

| ID | Threat | OWASP LLM | Tooling |
|---|---|---|---|
| T1 | Prompt injection to override system instructions | LLM01 | PyRIT (hand-crafted), Garak `promptinject` |
| T2 | Jailbreak via persona/role-play framing | LLM01 | PyRIT, Garak `dan` |
| T3 | Sensitive info disclosure (secret leak) | LLM06 | PyRIT (scored on substring match) |
| T4 | Filter bypass via encoding (base64, leetspeak, etc.) | LLM01 | Garak `encoding` |
| T5 | Training-data / prior-conversation leakage | LLM06 | Garak `leakreplay` |

## Out of scope for this project

- Model-level attacks (weight extraction, fine-tuning poisoning) — that's
  infrastructure/supply-chain territory, not this app's attack surface.
- Denial-of-service / cost-exhaustion attacks — worth a follow-on, not
  covered here.
- Multi-agent / tool-use risks — covered in Project 3 (Secure AI Agent).
