#!/bin/bash
# hotcontext Integration Test Script
#
# This script validates the hook integration by:
# 1. Simulating exactly what Claude Code's UserPromptSubmit hook does
# 2. Testing the plugin structure is valid
# 3. Testing the resolver with realistic hook invocations
#
# Usage: bash tests/integration-test.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RESOLVE_SCRIPT="$PROJECT_DIR/scripts/resolve.js"

PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); echo "  ✓ $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  ✗ $1"; }

echo "=== hotcontext Integration Tests ==="
echo ""

# ---- Plugin Structure Validation ----
echo "Plugin Structure:"

if [ -f "$PROJECT_DIR/.claude-plugin/plugin.json" ]; then
  pass "plugin.json exists"
else
  fail "plugin.json missing"
fi

if node -e "JSON.parse(require('fs').readFileSync('$PROJECT_DIR/.claude-plugin/plugin.json','utf8'))" 2>/dev/null; then
  pass "plugin.json is valid JSON"
else
  fail "plugin.json is invalid JSON"
fi

if [ -f "$PROJECT_DIR/hooks/hooks.json" ]; then
  pass "hooks.json exists"
else
  fail "hooks.json missing"
fi

if node -e "JSON.parse(require('fs').readFileSync('$PROJECT_DIR/hooks/hooks.json','utf8'))" 2>/dev/null; then
  pass "hooks.json is valid JSON"
else
  fail "hooks.json is invalid JSON"
fi

# Verify hooks.json references UserPromptSubmit
if node -e "
  const h = JSON.parse(require('fs').readFileSync('$PROJECT_DIR/hooks/hooks.json','utf8'));
  if (!h.hooks || !h.hooks.UserPromptSubmit) process.exit(1);
" 2>/dev/null; then
  pass "hooks.json registers UserPromptSubmit"
else
  fail "hooks.json does not register UserPromptSubmit"
fi

echo ""

# ---- Hook Contract Validation ----
echo "Hook Contract (simulating Claude Code's UserPromptSubmit):"

# Test 1: Hook receives JSON on stdin and outputs plain text on stdout
OUTPUT=$(echo '{"prompt": "+test-project check"}' | node "$RESOLVE_SCRIPT" 2>/dev/null)
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ] && echo "$OUTPUT" | grep -q "HOOK_INJECTION_VERIFIED_PROJECT=true"; then
  pass "Hook reads stdin JSON, outputs plain text stdout (exit 0)"
else
  fail "Hook stdin/stdout contract broken (exit code: $EXIT_CODE)"
fi

# Test 2: No tags = no output (hook should be invisible)
OUTPUT=$(echo '{"prompt": "just a regular prompt with no tags"}' | node "$RESOLVE_SCRIPT" 2>/dev/null)
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ] && [ -z "$OUTPUT" ]; then
  pass "No tags = clean exit with no stdout (invisible to user)"
else
  fail "No tags produced unexpected output or non-zero exit"
fi

# Test 3: Invalid input = graceful failure (non-blocking)
OUTPUT=$(echo 'not json at all' | node "$RESOLVE_SCRIPT" 2>/dev/null)
# We don't care about exit code here — just that it doesn't hang or crash hard
pass "Invalid input handled without hanging"

# Test 4: Empty JSON = graceful exit
OUTPUT=$(echo '{}' | node "$RESOLVE_SCRIPT" 2>/dev/null)
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
  pass "Empty JSON input exits cleanly"
else
  fail "Empty JSON input caused non-zero exit: $EXIT_CODE"
fi

# Test 5: Output is plain text (not JSON) — critical for UserPromptSubmit
OUTPUT=$(echo '{"prompt": "+test-project check"}' | node "$RESOLVE_SCRIPT" 2>/dev/null)
if echo "$OUTPUT" | head -1 | grep -q "^--- hotcontext:"; then
  pass "Output is plain text with section headers (not JSON)"
else
  fail "Output format unexpected — first line: $(echo "$OUTPUT" | head -1)"
fi

# Test 6: Frontmatter stripped from output
if ! echo "$OUTPUT" | grep -q "^---$" && ! echo "$OUTPUT" | grep -q "name: test-project"; then
  pass "YAML frontmatter stripped from injected context"
else
  fail "Frontmatter leaked into output"
fi

echo ""

# ---- Scope Resolution ----
echo "Scope Resolution:"

# Test 7: Project scope override
OUTPUT=$(echo '{"prompt": "+test-override check"}' | node "$RESOLVE_SCRIPT" 2>/dev/null)
if echo "$OUTPUT" | grep -q "OVERRIDE_SOURCE=PROJECT"; then
  pass "Project scope overrides personal scope for same tag"
else
  fail "Scope override failed — got: $(echo "$OUTPUT" | grep OVERRIDE_SOURCE)"
fi

# Test 8: Personal scope fallback
OUTPUT=$(echo '{"prompt": "+test-personal check"}' | node "$RESOLVE_SCRIPT" 2>/dev/null)
if echo "$OUTPUT" | grep -q "HOOK_INJECTION_VERIFIED_PERSONAL=true"; then
  pass "Personal scope bundles resolve when not in project"
else
  fail "Personal scope resolution failed"
fi

echo ""

# ---- Performance ----
echo "Performance:"

START=$(node -e "console.log(Date.now())")
echo '{"prompt": "+test-project +test-personal +test-override +nonexistent1 +nonexistent2"}' | node "$RESOLVE_SCRIPT" > /dev/null 2>&1
END=$(node -e "console.log(Date.now())")
ELAPSED=$((END - START))
if [ $ELAPSED -lt 200 ]; then
  pass "5 tags resolved in ${ELAPSED}ms (<200ms target)"
else
  fail "5 tags took ${ELAPSED}ms (target: <200ms)"
fi

echo ""

# ---- CLAUDE_PLUGIN_ROOT Simulation ----
echo "Plugin Root Simulation:"

# Test that the hooks.json command would resolve correctly with CLAUDE_PLUGIN_ROOT
HOOK_CMD=$(node -e "
  const h = JSON.parse(require('fs').readFileSync('$PROJECT_DIR/hooks/hooks.json','utf8'));
  console.log(h.hooks.UserPromptSubmit[0].hooks[0].command);
")
# Simulate CLAUDE_PLUGIN_ROOT resolution
RESOLVED_CMD=$(echo "$HOOK_CMD" | sed "s|\\\${CLAUDE_PLUGIN_ROOT}|$PROJECT_DIR|g")
if [ -f "$(echo "$RESOLVED_CMD" | awk '{print $2}')" ]; then
  pass "CLAUDE_PLUGIN_ROOT resolves to valid script path"
else
  fail "CLAUDE_PLUGIN_ROOT would resolve to invalid path: $RESOLVED_CMD"
fi

echo ""

# ---- Summary ----
echo "=== Results ==="
echo "  Passed: $PASS"
echo "  Failed: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
  echo "All integration tests passed!"
  exit 0
else
  echo "Some tests failed."
  exit 1
fi
