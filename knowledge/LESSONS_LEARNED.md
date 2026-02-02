# Lessons Learned

> This file preserves non-trivial solutions and insights worth remembering.
> Future agents and developers should consult this before tackling similar problems.

---

## Template

When adding a new lesson, use this format:

```markdown
## [LESSON-ID] Title

**Context:** When this applies
**Problem:** What was challenging
**Solution:** The approach that worked
**Why It Works:** Explanation for future agents
**Code Example:** If applicable
**Tags:** searchable, keywords
```

---

## Lessons

<!-- Add lessons below this line -->

### Example Entry (Delete When Adding Real Lessons)

## [LL-001] Example: Handling Large File Uploads

**Context:** When implementing file upload features that need to handle files > 100MB

**Problem:** Default upload handler caused memory issues and timeouts on large files. Server would crash or requests would timeout after 30 seconds.

**Solution:** Implemented streaming upload with chunked transfer:
1. Use `multipart/form-data` with streaming parser
2. Write chunks directly to disk/cloud storage
3. Process file after upload completes

**Why It Works:** Streaming avoids loading entire file into memory. Chunked transfer allows progress tracking and resumable uploads.

**Code Example:**
```typescript
// Instead of:
const file = await request.file(); // Loads entire file to memory

// Use:
const stream = request.stream();
const writeStream = fs.createWriteStream(tempPath);
await pipeline(stream, writeStream);
```

**Tags:** file-upload, streaming, performance, memory

---

## By Category

### Performance
- [LL-001] Handling Large File Uploads

### Testing
<!-- Add testing lessons here -->

### Architecture
<!-- Add architecture lessons here -->

### Debugging
<!-- Add debugging lessons here -->
