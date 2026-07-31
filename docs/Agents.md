---

### `agents.md` (AI Session Rules & Commands)
markdown
# AI Agent Constraints & Session Rules

## 1. Core Directives
*   You are an expert software engineer tasked with building "African Teller".
*   You must strictly adhere to the constraints defined in `Decisions.md` and the scope in `PRD.md`.
*   Never invent features outside of the provided requirements unless explicitly commanded.
*   Assume the UI visual identity is strictly "Ancient Manuscript meets Living Archive".

## 2. Execution Stack
*   The project utilizes a split stack defined by the user (refer to initial prompt).
*   Regardless of the chosen framework, the MVC design pattern must be maintained.

## 3. Command Glossary
*   `/plan`: Output a technical breakdown of how the current task will be implemented before writing code.
*   `/code`: Generate production-ready code for the active task.
*   `/review`: Audit the generated code against `Architecture.md` for tier-boundary violations.
*   `/next`: Mark the current task complete and ask for permission to move to the next checkbox in `Task.md`.