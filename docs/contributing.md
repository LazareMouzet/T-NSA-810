# CONTRIBUTING.md

This project is part of an educational program. Contributions are restricted to members of the project team.
To maintain a clean, navigable, and professional codebase, all contributors are expected to follow these standards.

---

## 1. Branch Naming Convention
We use a **prefix-based** naming system. All branch names should be lowercase, use hyphens as separators, and include the associated ticket number.

**Format:** `category/ticket-id-short-description`

| Prefix | Use Case | Example |
| :--- | :--- | :--- |
| `feat/` | New features or functionality | `feat/PROJ-123-user-authentication` |
| `fix/` | Bug fixes | `fix/PROJ-456-header-mobile-overlap` |
| `docs/` | Documentation changes only | `docs/PROJ-789-api-endpoints` |
| `refactor/` | Code changes that neither fix a bug nor add a feature | `refactor/PROJ-101-clean-utils` |
| `chore/` | Maintenance tasks (dependencies, build configs) | `chore/PROJ-202-update-node-version` |

---

## 2. Commit Message Formatting
We follow the **Conventional Commits** specification. This allows for automated changelog generation and easier history searching.

**Structure:**
`<type>(<scope>): <ticket-id> short summary in present tense`

### Allowed Types:
* `feat`: A new feature.
* `fix`: A bug fix.
* `docs`: Documentation only changes.
* `style`: Changes that do not affect the meaning of the code (white-space, formatting, etc).
* `refactor`: A code change that neither fixes a bug nor adds a feature.
* `perf`: A code change that improves performance.
* `test`: Adding missing tests or correcting existing tests.
* `chore`: Changes to the build process or auxiliary tools/libraries.

**Examples:**
* `feat(auth): PROJ-123 add JWT validation logic`
* `fix(ui): PROJ-456 resolve z-index issue on modal`
* `docs: update installation steps in README`

---

## 3. Ticket Referencing
Every non-trivial commit **must** reference a ticket number (e.g., Jira, Linear, or GitHub Issue).

* **Primary Reference:** Include the ticket ID in the first line (header) of the commit.
* **Closing Tickets:** If a commit or Pull Request completes a task, use keywords in the description: `Closes PROJ-123` or `Fixes #45`.

---

## 4. Folder and File Naming
Consistency in the file system prevents "import confusion" and keeps the project searchable.

* **Directories:** Use `kebab-case` (e.g., `src/user-profile/`).
* **Source Files:** Use `kebab-case` for logic files (e.g., `auth-helper.ts`).
* **Components:** (If applicable) Use `PascalCase` (e.g., `SubmitButton.tsx`).
* **Tests:** Match the file name with a `.test` or `.spec` suffix (e.g., `math-utils.test.ts`).

---

## 5. The Pull Request Process
1.  **Sync:** Ensure your local `main` branch is up to date before branching.
2.  **Branch:** Create a branch following the naming rules above.
3.  **Commit:** Write clean, atomic commits with clear messages.
4.  **Draft:** Open a PR as a "Draft" if you want early feedback or are still working.
5.  **Review:** Tag at least two maintainer for review before merging.