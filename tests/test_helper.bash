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
    export TEST_BIN_DIR="$TEST_TMPDIR/bin"
    export OPENCODE_MOCK_DIR="$TEST_TMPDIR/opencode-mock"
    mkdir -p "$TEST_BIN_DIR" "$OPENCODE_MOCK_DIR"
    export TEST_CONFIG="$TEST_TMPDIR/test-config.json"
    export CONFIG_FILE="$TEST_TMPDIR/oh-my-opencode.json"
    export PATH="$TEST_BIN_DIR:$PATH"
    
    # Detect CI mode
    export CI_MODE="${CI:-false}"
    if [ "$CI_MODE" = "true" ] || [ -n "$GITHUB_ACTIONS" ]; then
        export CI_MODE="true"
    fi
}

# Load bats-core assertions
setup() {
    super_setup
    mock_opencode_cli
    mock_default_opencode_models
}

teardown() {
    # Clean up test files
    rm -rf "$TEST_TMPDIR"
}

mock_opencode_cli() {
    cat > "$TEST_BIN_DIR/opencode" << 'EOF'
#!/bin/bash
set -euo pipefail

if [ "$#" -ge 2 ] && [ "$1" = "models" ]; then
    provider="$2"
    mock_dir="${OPENCODE_MOCK_DIR:?}"
    suffix=""
    if [ "$#" -ge 3 ] && [ "$3" = "--verbose" ]; then
        suffix="-verbose"
    fi
    status_file="$mock_dir/models-${provider}${suffix}.status"
    output_file="$mock_dir/models-${provider}${suffix}.txt"
    stderr_file="$mock_dir/models-${provider}${suffix}.stderr"
    status=0

    if [ ! -f "$status_file" ] && [ -n "$suffix" ]; then
        status_file="$mock_dir/models-${provider}.status"
        output_file="$mock_dir/models-${provider}.txt"
        stderr_file="$mock_dir/models-${provider}.stderr"
    fi

    if [ -f "$status_file" ]; then
        status=$(cat "$status_file")
    fi

    if [ -f "$stderr_file" ]; then
        cat "$stderr_file" >&2
    fi

    if [ -f "$output_file" ]; then
        cat "$output_file"
    fi

    exit "$status"
fi

echo "Unsupported mock opencode command: $*" >&2
exit 64
EOF
    chmod +x "$TEST_BIN_DIR/opencode"
}

set_mock_provider_models() {
    local provider="$1"
    local output_file="$OPENCODE_MOCK_DIR/models-${provider}.txt"
    local status_file="$OPENCODE_MOCK_DIR/models-${provider}.status"
    local stderr_file="$OPENCODE_MOCK_DIR/models-${provider}.stderr"

    cat > "$output_file"
    printf '0\n' > "$status_file"
    : > "$stderr_file"
}

set_mock_provider_verbose_models() {
    local provider="$1"
    local output_file="$OPENCODE_MOCK_DIR/models-${provider}-verbose.txt"
    local status_file="$OPENCODE_MOCK_DIR/models-${provider}-verbose.status"
    local stderr_file="$OPENCODE_MOCK_DIR/models-${provider}-verbose.stderr"

    cat > "$output_file"
    printf '0\n' > "$status_file"
    : > "$stderr_file"
}

set_mock_provider_failure() {
    local provider="$1"
    local message="${2:-Provider not available}"

    : > "$OPENCODE_MOCK_DIR/models-${provider}.txt"
    printf '1\n' > "$OPENCODE_MOCK_DIR/models-${provider}.status"
    printf '%s\n' "$message" > "$OPENCODE_MOCK_DIR/models-${provider}.stderr"
}

mock_default_opencode_models() {
    set_mock_provider_models opencode << 'EOF'
opencode/kimi-k2.5-free
opencode/glm-5-free
opencode/minimax-m2.5-free
opencode/gpt-5-nano
opencode/big-pickle
EOF

    set_mock_provider_verbose_models opencode << 'EOF'
opencode/kimi-k2.5-free
{
  "cost": {"input": 0, "output": 0, "cache": {"read": 0, "write": 0}}
}
opencode/glm-5-free
{
  "cost": {"input": 0, "output": 0, "cache": {"read": 0, "write": 0}}
}
opencode/minimax-m2.5-free
{
  "cost": {"input": 0, "output": 0, "cache": {"read": 0, "write": 0}}
}
opencode/gpt-5-nano
{
  "cost": {"input": 0, "output": 0, "cache": {"read": 0, "write": 0}}
}
opencode/big-pickle
{
  "cost": {"input": 0, "output": 0, "cache": {"read": 0, "write": 0}}
}
opencode/claude-sonnet-4
{
  "cost": {"input": 3, "output": 15, "cache": {"read": 0.3, "write": 3.75}}
}
EOF

    set_mock_provider_models opencode-go << 'EOF'
opencode-go/kimi-k2.5
opencode-go/glm-5
opencode-go/minimax-m2.5
EOF

    set_mock_provider_models openai << 'EOF'
openai/gpt-5.3-codex
openai/gpt-5.4-thinking
openai/gpt-5.4
EOF
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

# Provide automated input for interactive mode
# Usage: auto_input [model_number] [fallback_number]
auto_input() {
    local model_num="${1:-1}"  # Default to 1 (kimi-zen)
    local fallback_num="${2:-}"  # Empty means skip fallback
    
    if [ -n "$fallback_num" ]; then
        echo -e "${model_num}\n${fallback_num}"
    else
        echo -e "${model_num}\n"
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
