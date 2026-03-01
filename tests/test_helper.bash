#!/bin/bash
# =============================================================================
# test_helper.bash - Shared test utilities for switch-model.sh tests
# =============================================================================

# Get directories based on test file location
FIXTURES_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/fixtures" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"

# Super setup - export paths for all tests
super_setup() {
    export FIXTURES_DIR
    export TEST_TMPDIR="${BATS_TEST_TMPDIR:-/tmp/bats-switch-model-$$}"
    mkdir -p "$TEST_TMPDIR"
    export TEST_CONFIG="$TEST_TMPDIR/test-config.json"
    export CONFIG_FILE="$TEST_TMPDIR/oh-my-opencode.json"
    
    # Detect CI mode
    export CI_MODE="${CI:-false}
    if [ "$CI_MODE" = "true" ] || [ -n "$GITHUB_ACTIONS" ]; then
        export CI_MODE="true"
    fi
}

# Load bats-core assertions
setup() {
    super_setup
}

teardown() {
    # Clean up test files
    rm -rf "$TEST_TMPDIR"
}

# Check if running in CI mode
is_ci_mode() {
    [ "$CI_MODE" = "true" ]
}

# Skip test if in CI mode (for interactive tests)
skip_if_ci() {
    if is_ci_mode; then
        skip "Skipping interactive test in CI mode"
    fi
}

# Get a random valid model number (1-12)
get_random_model_number() {
    echo "$(( (RANDOM % 12) + 1 ))"
}

# Provide automated input for interactive mode
# Usage: auto_input [model_number] [fallback_number]
auto_input() {
    local model_num="${1:-1}"  # Default to 1 (kimi-zen)
    local fallback_num="${2:-}"  # Empty means skip fallback
    
    if [ -n "$fallback_num" ]; then
        echo -e "${model_num}\n${fallback_num}"
    else
        echo "${model_num}"
    fi
}

# Create a test config file with known state
create_test_config() {
    cat > "$CONFIG_FILE" << 'EOF'
{
  "agents": {
    "sisyphus": {"model": "opencode/kimi-k2.5-free"},
    "oracle": {"model": "opencode/kimi-k2.5-free"},
    "explore": {"model": "opencode/minimax-m2.5-free"},
    "prometheus": {"model": "opencode/kimi-k2.5-free"},
    "metis": {"model": "opencode/kimi-k2.5-free"},
    "momus": {"model": "opencode/kimi-k2.5-free"},
    "atlas": {"model": "opencode/kimi-k2.5-free"},
    "hephaestus": {"model": "openai/gpt-5.3-codex"},
    "librarian": {"model": "opencode/gpt-5-nano"},
    "multimodal-looker": {"model": "openrouter/nvidia/nemotron-nano-12b-v2-vl:free"}
  },
  "categories": {
    "ultrabrain": {"model": "openai/gpt-5.3-codex"},
    "deep": {"model": "openai/gpt-5.3-codex"},
    "artistry": {"model": "opencode/kimi-k2.5-free"},
    "quick": {"model": "opencode/kimi-k2.5-free"},
    "writing": {"model": "opencode/kimi-k2.5-free"},
    "unspecified-low": {"model": "opencode/kimi-k2.5-free"},
    "unspecified-high": {"model": "opencode/kimi-k2.5-free"},
    "visual-engineering": {"model": "opencode/kimi-k2.5-free"}
  }
}
EOF
}

# Get the model for a specific agent from config
get_agent_model() {
    local agent_name="$1"
    local config_file="${2:-$CONFIG_FILE}"
    python3 -c "
import json
with open('$config_file') as f:
    print(json.load(f)['agents'].get('$agent_name', {}).get('model', ''))
" 2>/dev/null
}

# Get the model for a specific category from config
get_category_model() {
    local category_name="$1"
    local config_file="${2:-$CONFIG_FILE}"
    python3 -c "
import json
with open('$config_file') as f:
    print(json.load(f)['categories'].get('$category_name', {}).get('model', ''))
" 2>/dev/null
}

# Get the fallback model for an agent
get_agent_fallback() {
    local agent_name="$1"
    local config_file="${2:-$CONFIG_FILE}"
    python3 -c "
import json
with open('$config_file') as f:
    print(json.load(f)['agents'].get('$agent_name', {}).get('fallback', ''))
" 2>/dev/null
}

# Create a minimal config
create_minimal_config() {
    local file="$1"
    cat > "$file" << 'EOF'
{
  "agents": {
    "sisyphus": {"model": "opencode/kimi-k2.5-free"},
    "hephaestus": {"model": "openai/gpt-5.3-codex"},
    "librarian": {"model": "opencode/gpt-5-nano"},
    "multimodal-looker": {"model": "openrouter/nvidia/nemotron-nano-12b-v2-vl:free"}
  },
  "categories": {
    "ultrabrain": {"model": "openai/gpt-5.3-codex"},
    "deep": {"model": "openai/gpt-5.3-codex"},
    "quick": {"model": "opencode/kimi-k2.5-free"}
  }
}
EOF
}

# Check if backup file was created
get_latest_backup() {
    local config_file="$1"
    local backup_dir
    backup_dir=$(dirname "$config_file")
    ls -t "$backup_dir"/"$config_file".bak.* 2>/dev/null | head -1
}

# Mock read for interactive tests
mock_read() {
    local input="$1"
    echo "$input"
}
