## 2026-10-19
- v0.1.0: plugin (PostToolUse/UserPromptSubmit watch at 35%, fresh-ctx skill + save.sh, SessionStart clear|startup reload) + chat-app skill zip. Synthetic hook tests + live headless loop (fire → save → reload) pass. Installed locally via local marketplace.
- v0.2.1: mod (`hooks/register.ts`) auto-runs /clear + submits the handoff at turn end; real window read from `session.measure`; growth guard stops handoff loops. Live tmux runs: mid-task cut (BETA) finished step 3 in the fresh window; GAMMA = 1 handoff, no loop.
- v0.2.4: subagent calls ignored; skill + save.sh auto-allowed via `tool.check`; growth guard scoped to handoff-started sessions. Live tmux run in default permission mode: no prompt, 2 sessions, 1 handoff, no loop.
- Published public: github.com/hasuwini77/fresh-ctx (main + tags v0.1.0, v0.2.1, v0.2.4); clean-config GitHub install verified.
- v0.3.0: trigger at 150k tokens or 35% (first wins); re-nudge every 50k; handoff lists background jobs (verified live they survive /clear and notify the fresh window).
- v0.4.0: default token trigger 150k → 250k (150k fired at 15% of a 1M window; ~64k of each window is system prompt, so the first window only had ~86k of room). Hook tested: 200k silent, 260k nudges, 35% backstop still fires on a 200k window.
