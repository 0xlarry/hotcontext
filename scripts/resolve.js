#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");
const os = require("os");

/**
 * hotcontext Resolver — UserPromptSubmit hook
 *
 * Reads prompt from stdin (JSON), parses +tags, resolves bundles
 * from project and personal scope, outputs plain text to stdout.
 */

// --- Tag Parsing ---

function parseTags(prompt) {
  const matches = prompt.match(/\+([a-zA-Z0-9_-]+)/g);
  if (!matches) return [];
  // Deduplicate, preserve order
  const seen = new Set();
  const tags = [];
  for (const m of matches) {
    const tag = m.slice(1); // remove leading +
    if (!seen.has(tag)) {
      seen.add(tag);
      tags.push(tag);
    }
  }
  return tags;
}

// --- Directory Resolution ---

function getSearchDirs() {
  const dirs = [];

  // Project scope: .claude/hotcontext/ relative to cwd
  const projectDir = path.join(process.cwd(), ".claude", "hotcontext");
  dirs.push({ scope: "PROJECT", dir: projectDir });

  // Personal scope: ~/.claude/hotcontext/
  const personalDir = path.join(os.homedir(), ".claude", "hotcontext");
  dirs.push({ scope: "PERSONAL", dir: personalDir });

  return dirs;
}

function resolveTag(tag, searchDirs) {
  for (const { scope, dir } of searchDirs) {
    const filePath = path.join(dir, `${tag}.md`);
    try {
      if (fs.existsSync(filePath)) {
        return { scope, filePath };
      }
    } catch {
      // Directory doesn't exist or isn't accessible — skip
    }
  }
  return null;
}

// --- Bundle Loading ---

function stripFrontmatter(content) {
  // Strip YAML frontmatter (between --- delimiters at start of file)
  const match = content.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?([\s\S]*)$/);
  if (match) return match[2];
  return content;
}

function loadBundle(filePath) {
  const raw = fs.readFileSync(filePath, "utf-8");
  return stripFrontmatter(raw).trim();
}

// --- Output Formatting ---

function formatOutput(resolved, warnings) {
  const parts = [];

  for (const { tag, content } of resolved) {
    parts.push(`--- hotcontext: ${tag} ---`);
    parts.push(content);
    parts.push("");
  }

  for (const w of warnings) {
    parts.push(w);
  }

  return parts.join("\n").trim();
}

// --- Main ---

async function main() {
  try {
    // Read stdin
    const chunks = [];
    for await (const chunk of process.stdin) {
      chunks.push(chunk);
    }
    const input = JSON.parse(Buffer.concat(chunks).toString());
    const prompt = input.prompt || "";

    const tags = parseTags(prompt);
    if (tags.length === 0) {
      process.exit(0);
    }

    const searchDirs = getSearchDirs();
    const resolved = [];
    const warnings = [];

    for (const tag of tags) {
      const result = resolveTag(tag, searchDirs);
      if (result) {
        try {
          const content = loadBundle(result.filePath);
          resolved.push({ tag, content, scope: result.scope });
        } catch (err) {
          warnings.push(`[hotcontext] Error loading +${tag}: ${err.message}`);
        }
      } else {
        warnings.push(`[hotcontext] No bundle found for +${tag}`);
      }
    }

    const output = formatOutput(resolved, warnings);
    if (output) {
      process.stdout.write(output);
    }
  } catch (err) {
    // Non-fatal — exit cleanly so Claude Code proceeds normally
    process.stderr.write(`[hotcontext] Resolver error: ${err.message}\n`);
  }
}

main();
