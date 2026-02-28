#!/usr/bin/env bats
# =============================================================================
# test_arguments.bats - Test CLI argument parsing for switch-model.sh
# =============================================================================

# Load test helpers
load test_helper

# Setup - create test config and export required paths
setup() {
    super_setup
    
    # Override CONFIG_FILE to use our test config
    export CONFIG_FILE="$TEST_CONFIG"
    
    # Create test config with required structure
    cat > "$TEST_CONFIG" << 'EOF'
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

teardown() {
    rm -rf "$TEST_TMPDIR"
}

# =============================================================================
# Test Global Mode Arguments
# =============================================================================

@test "global mode: valid two args succeeds" {
    run bash "$SCRIPT_DIR/switch-model.sh" kimi-zen codex-5.3
    [ "$status" -eq 0 ]
    # Should update orchestration agents
    [[ "$output" == *"Orchestration: kimi-zen"* ]]
    # Should update deep work agent
    [[ "$output" == *"Deep Work: codex-5.3"* ]]
}

@test "global mode: glm5-go codex-5.3 succeeds" {
    run bash "$SCRIPT_DIR/switch-model.sh" glm5-go codex-5.3
    [ "$status" -eq 0 ]
    [[ "$output" == *"Orchestration: glm5-go"* ]]
    [[ "$output" == *"Deep Work: codex-5.3"* ]]
}

@test "global mode: only one arg shows error" {
    run bash "$SCRIPT_DIR/switch-model.sh" kimi-zen
    [ "$status" -ne 0 ]
    [[ "$output" == *"Error"* ]]
    [[ "$output" == *"Global mode requires both"* ]]
}

@test "global mode: unknown model shows error with Unknown model" {
    run bash "$SCRIPT_DIR/switch-model.sh" invalid-model codex-5.3
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unknown model"* ]]
}

@test "global mode: second unknown model shows error" {
    run bash "$SCRIPT_DIR/switch-model.sh" kimi-zen invalid-model
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unknown model"* ]]
}

# =============================================================================
# Test Fine-Grained Mode --agent
# =============================================================================

@test "agent mode: --agent sisyphus kimi-zen succeeds" {
    run bash "$SCRIPT_DIR/switch-model.sh" --agent sisyphus kimi-zen
    [ "$status" -eq 0 ]
    [[ "$output" == *"Updated agent: sisyphus -> kimi-zen"* ]]
}

@test "agent mode: --agent hephaestus codex-5.3 succeeds" {
    run bash "$SCRIPT_DIR/switch-model.sh" --agent hephaestus codex-5.3
    [ "$status" -eq 0 ]
    [[ "$output" == *"Updated agent: hephaestus -> codex-5.3"* ]]
}

@test "agent mode: invalid agent shows error Invalid agent" {
    run bash "$SCRIPT_DIR/switch-model.sh" --agent invalid-agent kimi-zen
    [ "$status" -ne 0 ]
    [[ "$output" == *"Invalid agent"* ]]
    [[ "$output" == *"Valid agents"* ]]
}

@test "agent mode: missing model goes interactive" {
    # Mock the read by providing input via pipe
    run bash -c "echo '1' | $SCRIPT_DIR/switch-model.sh --agent sisyphus"
    [ "$status" -eq 0 ]
    # Should show interactive prompt
    [[ "$output" == *"Set Agent: sisyphus"* ]]
    [[ "$output" == *"Select model"* ]]
}

@test "agent mode: --agent without name shows error" {
    run bash "$SCRIPT_DIR/switch-model.sh" --agent
    [ "$status" -ne 0 ]
    [[ "$output" == *"--agent requires"* ]]
}

# =============================================================================
# Test Fine-Grained Mode --category
# =============================================================================

@test "category mode: --category ultrabrain codex-5.3 succeeds" {
    run bash "$SCRIPT_DIR/switch-model.sh" --category ultrabrain codex-5.3
    [ "$status" -eq 0 ]
    [[ "$output" == *"Updated category: ultrabrain -> codex-5.3"* ]]
}

@test "category mode: --category deep kimi-zen succeeds" {
    run bash "$SCRIPT_DIR/switch-model.sh" --category deep kimi-zen
    [ "$status" -eq 0 ]
    [[ "$output" == *"Updated category: deep -> kimi-zen"* ]]
}

@test "category mode: invalid category shows error Invalid category" {
    run bash "$SCRIPT_DIR/switch-model.sh" --category invalid-category kimi-zen
    [ "$status" -ne 0 ]
    [[ "$output" == *"Invalid category"* ]]
    [[ "$output" == *"Valid categories"* ]]
}

@test "category mode: --category without name shows error" {
    run bash "$SCRIPT_DIR/switch-model.sh" --category
    [ "$status" -ne 0 ]
    [[ "$output" == *"--category requires"* ]]
}

@test "category mode: missing model goes interactive" {
    run bash -c "echo '1' | $SCRIPT_DIR/switch-model.sh --category quick"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Set Category: quick"* ]]
    [[ "$output" == *"Select model"* ]]
}

# =============================================================================
# Test --fallback flag
# =============================================================================

@test "fallback: --agent with --fallback succeeds" {
    run bash "$SCRIPT_DIR/switch-model.sh" --agent sisyphus kimi-zen --fallback codex-5.3
    [ "$status" -eq 0 ]
    [[ "$output" == *"Updated agent: sisyphus -> kimi-zen"* ]]
    [[ "$output" == *"Fallback"* ]]
}

@test "fallback: --category with --fallback succeeds" {
    run bash "$SCRIPT_DIR/switch-model.sh" --category ultrabrain codex-5.3 --fallback kimi-zen
    [ "$status" -eq 0 ]
    [[ "$output" == *"Updated category: ultrabrain -> codex-5.3"* ]]
    [[ "$output" == *"Fallback"* ]]
}

@test "fallback: invalid fallback model shows error" {
    run bash "$SCRIPT_DIR/switch-model.sh" --agent sisyphus kimi-zen --fallback invalid-model
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unknown model"* ]]
}

# =============================================================================
# Test --agents-fallback and --categories-fallback
# =============================================================================

@test "agents-fallback: --agents-fallback with model succeeds" {
    run bash "$SCRIPT_DIR/switch-model.sh" --agents-fallback kimi-zen
    [ "$status" -eq 0 ]
    [[ "$output" == *"Updated fallback for all agents"* ]]
}

@test "categories-fallback: --categories-fallback with model succeeds" {
    run bash "$SCRIPT_DIR/switch-model.sh" --categories-fallback codex-5.3
    [ "$status" -eq 0 ]
    [[ "$output" == *"Updated fallback for all categories"* ]]
}

@test "agents-fallback: invalid model shows error" {
    run bash "$SCRIPT_DIR/switch-model.sh" --agents-fallback invalid-model
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unknown model"* ]]
}

@test "categories-fallback: invalid model shows error" {
    run bash "$SCRIPT_DIR/switch-model.sh" --categories-fallback invalid-model
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unknown model"* ]]
}

# =============================================================================
# Test --help
# =============================================================================

@test "help: --help shows help and exits 0" {
    run bash "$SCRIPT_DIR/switch-model.sh" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"OPTIONS"* ]]
    [[ "$output" == *"Global mode"* ]]
    [[ "$output" == *"Fine-grained"* ]]
}

@test "help: -h shows help and exits 0" {
    run bash "$SCRIPT_DIR/switch-model.sh" -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
}

# =============================================================================
# Test Unknown Options
# =============================================================================

@test "unknown option: shows error and help" {
    run bash "$SCRIPT_DIR/switch-model.sh" --unknown-option kimi-zen
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unknown option"* ]]
}

# =============================================================================
# Test Interactive Mode (no args)
# =============================================================================

@test "interactive: no args shows interactive prompts" {
    run bash -c "echo -e '1\n1' | $SCRIPT_DIR/switch-model.sh"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Orchestration Model"* ]]
    [[ "$output" == *"Deep Work Model"* ]]
}
