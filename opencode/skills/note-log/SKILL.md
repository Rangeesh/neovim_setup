---
name: note-log
description: Extract conceptual learnings from the current conversation and log them as dated entries to ~/notes in both daily and topic files
---

## Purpose

You are a learning log tool. Review the current conversation and extract conceptual learnings the user picked up during the discussion. Write them to `~/notes` as concise, readable log entries.

The user will write their own deeper notes later. Your job is to capture the raw material — what was learned, not the code that was written.

## What to extract

- Conceptual explanations: what something is, how it works, why it exists
- Comparisons and trade-offs between tools, libraries, or approaches
- Historical context: why things are the way they are (e.g. legacy naming, deprecations)
- Common patterns and best practices
- Gotchas, surprising behaviors, and common sources of confusion
- Terminology and pronunciation

## What to ignore

- Code snippets and implementation-specific details from the user's project
- File paths, variable names, and project-specific references
- Debugging steps and error resolution specific to a session
- Conversation meta-discussion ("can you explain...", "I didn't understand...")
- Anything the agent said that was wrong or corrected later

## File structure

```
~/notes/
├── daily/
│   └── YYYY-MM-DD.md        # chronological log for the day
├── topics/
│   ├── python.md             # broad topic file with subsections
│   ├── pytorch.md
│   └── ...
```

## Writing rules

### Daily file: `~/notes/daily/YYYY-MM-DD.md`

- If the file does not exist, create it with a level-1 header: `# YYYY-MM-DD`
- If it already exists, read it first and append new sections below existing content
- Each distinct learning topic is a `##` section
- Use concise bullet points under each section
- Do NOT duplicate a section that already exists in today's file

Format:

```markdown
# 2026-03-07

## Pillow (PIL)
- PIL = Python Imaging Library, pronounced "P-I-L"
- Original PIL unmaintained since 2011; Pillow is the active fork
- Install: `pip install Pillow`, import: `from PIL import Image` — name kept for backward compat
- Best for: basic image ops (open, resize, crop, rotate, save, format conversion)
- Not for: computer vision (OpenCV), ML pipelines (NumPy/torch tensors)

## Base64 Data URIs
- Pattern: resize image → save to BytesIO buffer → base64 encode → wrap in data URI string
- Data URIs embed binary data inline as strings for APIs or HTML
```

### Topic files: `~/notes/topics/<topic>.md`

- Use broad topic names for filenames from the seed list below; create new ones when nothing fits
- If the file does not exist, create it with a level-1 header: `# Topic Name`
- If it already exists, read it first and append new sections below existing content
- Each entry is a dated subsection: `## YYYY-MM-DD — Subtopic Name`
- Use concise bullet points
- Do NOT duplicate a section that already exists in the topic file

Format:

```markdown
# Python

## 2026-03-07 — Pillow (PIL)
- PIL = Python Imaging Library, pronounced "P-I-L"
- Original PIL unmaintained since 2011; Pillow is the active fork
- Install: `pip install Pillow`, import: `from PIL import Image` — name kept for backward compat
- Best for: basic image ops (open, resize, crop, rotate, save, format conversion)
- Not for: computer vision (OpenCV), ML pipelines (NumPy/torch tensors)
```

### Content in both files is duplicated

Each file should be independently readable. The daily file and topic file contain the same bullet points for a given learning. The only difference is the section header format.

## Seed topic list

Use these broad categories as filenames. If a learning doesn't fit any of these, create a new topic file.

| Filename          | Covers                                                                 |
|-------------------|------------------------------------------------------------------------|
| `python.md`       | Python language, stdlib, libraries (Pillow, requests, etc.)            |
| `pytorch.md`      | PyTorch framework, tensors, training loops, autograd, etc.             |
| `ml.md`           | Deep learning concepts, architectures, FP8 training, quantization     |
| `classical-ml.md` | Non-deep ML: sklearn, decision trees, SVMs, feature engineering, etc.  |
| `rl.md`           | Reinforcement learning: policies, environments, reward shaping, etc.   |
| `llm.md`          | Large language models: transformers, prompting, fine-tuning, RLHF      |
| `inference.md`    | Inference engines and serving: vLLM, TensorRT, ONNX, batching, etc.   |
| `tools.md`        | Developer tools, CLI utilities, build systems, git, editors            |
| `systems.md`      | OS, networking, infrastructure, hardware, GPUs, CUDA                   |
| `web.md`          | Web dev, APIs, frontend/backend, protocols, data URIs                  |
| `math.md`         | Linear algebra, statistics, optimization, probability                  |

## Steps

1. Review the full conversation and identify distinct conceptual learnings
2. Group them by topic — determine the broad category (filename) and subtopic (section header) for each
3. Get today's date
4. Read existing `~/notes/daily/YYYY-MM-DD.md` if it exists, to avoid duplicating sections
5. Read existing topic files that you plan to append to, to avoid duplicating sections
6. Append entries to the daily file (create it if needed)
7. Append entries to each relevant topic file (create them if needed)
8. Report back: list what was logged and which files were written/updated
