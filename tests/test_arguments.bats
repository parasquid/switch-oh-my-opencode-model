#!/usr/bin/env bats
# =============================================================================
# test_arguments.bats - Test CLI argument parsing
# =============================================================================

# Load test helpers
load test_helper

# =============================================================================
# Test Global Mode Arguments
# =============================================================================

@test "global mode: valid two args succeeds" {
    run bash "$SCRIPT_DIR/switch-model.sh" kimi-zen codex-5.3
    [ "$status" -eq 0 ]
    [[ "$output" == *"Updated"* ]]
}

@test "global mode: glm5-go codex-5.3 succeeds" {
    run bash "$SCRIPT_DIR/switch-model.sh" glm5-go codex-5.3
    [ "$status" -eq 0 ]
    [[ "$output" == *"Updated"* ]]
}

@test "global mode: only one arg shows error" {
    run bash "$SCRIPT_DIR/switch-model.sh" kimi-zen
    [ "$status" -ne 0 ]
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

@test "agent mode: missing model goes interactive (or auto-selects in CI)" {
    if is_ci_mode; then
        # In CI, provide automated input
        run bash -c "auto_input 5 | $SCRIPT_DIR/switch-model.sh --agent sisyphus"
    else
        # Mock the read by providing input via pipe
        run bash -c "echo '1' | $SCRIPT_DIR/switch-model.sh --agent sisyphus"
    fi
    [ "$status" -eq 0 ]
    # Should show interactive prompt or update message
    [[ "$output" == *"Set Agent: sisyphus"* ]] || [[ "$output" == *"Updated agent"* ]]
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

@test "category mode: missing model goes interactive (or auto-selects in CI)" {
    if is_ci_mode; then
        # In CI, provide automated input
        run bash -c "auto_input 3 | $SCRIPT_DIR/switch-model.sh --category quick"
    else
        # Mock the read by providing input via pipe
        run bash -c "echo '1' | $SCRIPT_DIR/switch-model.sh --category quick"
    fi
    [ "$status" -eq 0 ]
    # Should show interactive prompt or update message
    [[ "$output" == *"Set Category: quick"* ]] || [[ "$output" == *"Updated category"* ]]
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

@test "interactive: no args shows interactive prompts (or auto-selects in CI)" {
    if is_ci_mode; then
        # In CI, provide automated input (1 for orch, 1 for deep)
        run bash -c "auto_input 1 1 | $SCRIPT_DIR/switch-model.sh"
    else
        # Provide input via pipe
        run bash -c "echo -e '1\n1' | $SCRIPT_DIR/switch-model.sh"
    fi
    [ "$status" -eq 0 ]
    # Should show prompts or update messages
    [[ "$output" == *"Orchestration Model"* ]] || [[ "$output" == *"Updated"* ]]
}
