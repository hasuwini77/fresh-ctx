---
name: fresh-ctx
description: Write a handoff so the user can continue in a fresh chat. Use when the user says "fresh ctx", "handoff", "new chat" or "clear and continue", and offer it on your own when the conversation has become long (many big files, long outputs, or dozens of turns).
---

# fresh-ctx (chat version)

Long chats get worse: slower, pricier, more forgetful. Move the work to a new chat.

1. Write the handoff as **one markdown code block** so it copies in one click. Under ~60 lines. Facts, not story:
   - **Goal**: what "done" looks like
   - **Done so far**: finished items, with file names
   - **Current state**: what's half-done, last result of any test or build
   - **Next steps**: numbered, concrete
   - **Key files / data**: what matters and why
   - **Gotchas and decisions**: dead ends tried, constraints, choices the user made
   - End the block with: "Continue from this handoff. Don't redo finished work."
2. Then say: "Copy the block, start a **new chat**, paste it as the first message." Re-attach any files the next steps need.

When you notice the chat is getting long, offer this once: "This chat is getting long — want a fresh-ctx handoff?"
