---
name: browser-routing
description: Choose how to control a browser. Use when a task needs to open a page, click through a web app, inspect the console or network, take a screenshot, or check a UI. Playwright CLI is the default browser tool in this repository. Playwright Test runs through the shell in the repository.
---

# Browser routing

Use one browser path for the task.

1. Use `playwright-cli` for interactive browser work, screenshots, console or network inspection, tracing, video, and request routing. Follow the bundled `playwright-cli` skill.
2. Repeatable browser tests stay in the project repository and run through its test command.
3. If another browser tool is available in the current environment, use it when the user names it or when the task requires that browser's capabilities.

The MCP examples in this repository do not install a browser server.
