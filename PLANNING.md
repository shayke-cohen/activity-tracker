# Planning Process

> This document describes when and how to plan features before implementation.

---

## When Planning is Required

| Change Type | Planning Required? | Approval Needed? |
|-------------|-------------------|------------------|
| New feature | ✅ Full spec | ✅ Yes |
| Major refactor | ✅ Technical design | ✅ Yes |
| Bug fix | ❌ No | ❌ No |
| Minor enhancement | ⚠️ Lightweight | Optional |
| Breaking change | ✅ Full spec + migration | ✅ Yes |

---

## Planning Phases

### Phase 1: Discovery
- [ ] Understand the problem/opportunity
- [ ] Research existing solutions
- [ ] Identify affected components
- [ ] List unknowns and risks

### Phase 2: Specification
- [ ] Create feature specification (`docs/design/NNNN-feature-name.md`)
- [ ] Define acceptance criteria
- [ ] Create wireframes/mockups (if UI)
- [ ] Document API contracts (if backend)

### Phase 3: Technical Design
- [ ] Create technical design document
- [ ] Sequence diagrams for complex flows
- [ ] Data model changes
- [ ] Migration strategy (if needed)

### Phase 4: Approval
- [ ] Post plan as GitHub issue comment
- [ ] Request review from stakeholders
- [ ] Address feedback
- [ ] Get explicit approval before implementation

---

## File Naming Convention

Design documents go in `docs/design/`:
- `NNNN-feature-name.md` - Feature specification
- `NNNN-feature-name-technical.md` - Technical design
- `NNNN-feature-name-wireframes/` - Wireframe images

Where `NNNN` is the GitHub issue number.

---

## Templates

- [Feature Specification Template](./design/TEMPLATE-feature-spec.md)
- [Technical Design Template](./design/TEMPLATE-technical-design.md)

---

## Wireframe Tools

### ASCII Art (for quick sketches in markdown)

```
┌─────────────────────────────────┐
│  [Logo]    [Nav]    [Profile]   │
├─────────────────────────────────┤
│  ┌─────┐  ┌─────────────────┐   │
│  │ Nav │  │                 │   │
│  │     │  │   Main Content  │   │
│  │     │  │                 │   │
│  └─────┘  └─────────────────┘   │
└─────────────────────────────────┘
```

### Recommended Tools
- **Excalidraw** - Free, collaborative, hand-drawn style
- **Figma** - Professional design, free tier
- **tldraw** - Simple, embeddable
- **Mermaid** - For flowcharts and diagrams in markdown

### File Format
- Export as PNG/SVG
- Store in `docs/design/NNNN-feature-name/`
- Reference in spec with relative paths

---

## Diagram Types Guide

| Diagram Type | When to Use | Tool |
|--------------|-------------|------|
| **Flowchart** | User flows, decision logic | Mermaid |
| **Sequence** | API calls, component interaction | Mermaid |
| **ERD** | Data models, relationships | Mermaid |
| **State Machine** | Status transitions | Mermaid |
| **Wireframe** | UI layout | ASCII/Excalidraw |
| **Mockup** | Visual design | Figma |
| **Architecture** | System overview | Mermaid/Excalidraw |
