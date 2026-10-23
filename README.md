# Study Plan Optimizer (TA1 + TA2)

Needs Python 3.10+ and Ollama.

    ollama pull qwen2.5:3b
    ollama pull nomic-embed-text     (TA2 only)

Run: `run_ta1.bat` (http://127.0.0.1:5000) or `run_ta2.bat` (http://127.0.0.1:5001).
In VS Code: `python -m venv venv`, `venv\Scripts\Activate.ps1`, `pip install -r requirements.txt`, then `cd ta1` or `cd ta2` and `python app.py`.

## TA1 - agent with 2 tools
Tools: `check_exam_readiness` (>=80% Highly, 60-79% Moderately, <60% Needs more preparation) and `hours_needed_per_day`.
Ollama's tool calling lets the model choose; Python always does the maths and runs any tool the model skipped (`python_fallback`).

## TA2 - everything in TA1 plus
| Feature | File | Where to see it on the page |
|---|---|---|
| Short-term memory (RAM, per conversation) | memory.py | Behind the scenes > memory |
| Long-term memory (SQLite preferences) | memory.py | My preferences |
| RAG over study tips (nomic-embed-text, cosine similarity) | rag.py, study_tips.txt | Behind the scenes > study tips |
| **Unit 3 - syllabus + topics covered per subject in SQLite** | subjects.py | Add or manage subjects + topic checkboxes |
| **Unit 3 - RAG over the syllabus; topic counts come from the document** | subjects.py, rag.py | 'Study these next' + Behind the scenes |
| **Unit 4 - Ambitious vs Realistic negotiation (alternating offers, capped rounds)** | negotiation.py | Behind the scenes > negotiation (summary in the result) |
| **Unit 4 - Readiness agent reports final feasibility** | negotiation.py | Result tiles ('Can you finish?') |
| Supervisor + specialists + hop limit (6) | agents.py | Behind the scenes > agent steps |
| Guardrails | guardrails.py | try days = 0, empty syllabus, Ollama stopped |

Supervisor flow: calculation_agent -> negotiation -> readiness_agent -> planning_agent -> END (4 hops, limit 6).

**The page is built for students:** it shows readiness, daily hours, whether you can finish, and your plan. The technical evidence (negotiation transcript, retrieved topics/tips, memory, agent steps) is under **Behind the scenes** - open it for the jury demo.

## Unit 3 - how it works
1. Paste a syllabus (one topic per line). Numbering/bullets are stripped, "Heading:" lines are skipped, duplicates removed.
2. Each topic is saved in SQLite (`ta2/data/preferences.db`) and embedded with nomic-embed-text (the RAG index).
3. Tick finished topics. **Total and covered counts are read from the database, not typed**, and they survive restarts.
4. The planning agent retrieves the pending topics most relevant to your question ("what should I study next?").

## Unit 4 - how the negotiation works (rule-based, no LLM)
- **Ambitious agent**: opens with the hours/day needed to finish everything (max 16). Concedes half the gap each turn but never goes below 75% of its opening offer (its floor).
- **Realistic agent**: opens with your saved hours/day (default 4). Concedes half the gap each turn but **never above 10 h/day** (burnout ceiling).
- Offers alternate: Ambitious offers -> Realistic accepts or counters -> Ambitious accepts or concedes. Offers within 0.5 h/day = agreement.
- **Readiness agent** then compares agreed hours x days with the hours needed: FEASIBLE or "only X% - need N more days".

## Honest limitations
- Negotiation and supervisor are rule-based on purpose (predictable, testable); the LLM only writes the plan text.
- One topic per line is required for syllabus parsing; the topic count is the number of lines, not understood by the model.
- Tested with a scripted fake Ollama; check real `qwen2.5:3b` behaviour on your machine. `.bat` files were not run on Windows.
