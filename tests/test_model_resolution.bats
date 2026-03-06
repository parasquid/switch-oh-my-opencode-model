#!/usr/bin/env bats
# =============================================================================
# test_model_resolution.bats - Test model resolution functions
# =============================================================================

# Load test helpers
load test_helper

setup() {
    super_setup
    mock_opencode_cli
    mock_default_opencode_models
    export CONFIG_FILE="$TEST_CONFIG"
    source "$SCRIPT_DIR/switch-model.sh"
    build_model_catalog
}

# =============================================================================
# Test resolve_model() function
# =============================================================================

@test "resolve_model: kimi-zen resolves correctly" {
    result=$(resolve_model "kimi-zen")
    [[ "$result" == "opencode/kimi-k2.5-free" ]]
}

@test "resolve_model: kimi alias resolves correctly" {
    result=$(resolve_model "kimi")
    [[ "$result" == "opencode/kimi-k2.5-free" ]]
}

@test "resolve_model: kimi-k2.5-free resolves correctly" {
    result=$(resolve_model "kimi-k2.5-free")
    [[ "$result" == "opencode/kimi-k2.5-free" ]]
}

@test "resolve_model: kimi-go resolves correctly" {
    result=$(resolve_model "kimi-go")
    [[ "$result" == "opencode-go/kimi-k2.5" ]]
}

@test "resolve_model: glm5-modal resolves correctly" {
    result=$(resolve_model "glm5-modal")
    [[ "$result" == "modal/zai-org/GLM-5-FP8" ]]
}

@test "resolve_model: glm5 alias resolves correctly" {
    result=$(resolve_model "glm5")
    [[ "$result" == "modal/zai-org/GLM-5-FP8" ]]
}

@test "resolve_model: glm5-zen resolves correctly" {
    result=$(resolve_model "glm5-zen")
    [[ "$result" == "opencode/glm-5-free" ]]
}

@test "resolve_model: glm5-go resolves correctly" {
    result=$(resolve_model "glm5-go")
    [[ "$result" == "opencode-go/glm-5" ]]
}

@test "resolve_model: minimax-zen resolves correctly" {
    result=$(resolve_model "minimax-zen")
    [[ "$result" == "opencode/minimax-m2.5-free" ]]
}

@test "resolve_model: minimax alias resolves correctly" {
    result=$(resolve_model "minimax")
    [[ "$result" == "opencode/minimax-m2.5-free" ]]
}

@test "resolve_model: minimax-go resolves correctly" {
    result=$(resolve_model "minimax-go")
    [[ "$result" == "opencode-go/minimax-m2.5" ]]
}

@test "resolve_model: codex-5.3 resolves correctly" {
    result=$(resolve_model "codex-5.3")
    [[ "$result" == "openai/gpt-5.3-codex" ]]
}

@test "resolve_model: codex alias resolves correctly" {
    result=$(resolve_model "codex")
    [[ "$result" == "openai/gpt-5.3-codex" ]]
}

@test "resolve_model: gpt-5.4-thinking resolves correctly" {
    result=$(resolve_model "gpt-5.4-thinking")
    [[ "$result" == "openai/gpt-5.4-thinking" ]]
}

@test "resolve_model: gpt-5.4 alias resolves correctly" {
    result=$(resolve_model "gpt-5.4")
    [[ "$result" == "openai/gpt-5.4-thinking" ]]
}

@test "resolve_model: gpt-5-nano resolves correctly" {
    result=$(resolve_model "gpt-5-nano")
    [[ "$result" == "opencode/gpt-5-nano" ]]
}

@test "resolve_model: big-pickle resolves correctly" {
    result=$(resolve_model "big-pickle")
    [[ "$result" == "opencode/big-pickle" ]]
}

@test "resolve_model: paid opencode models are filtered out" {
    result=$(resolve_model "claude-sonnet-4")
    [[ "$result" == "" ]]
}

@test "resolve_model: raw available model ID resolves correctly" {
    result=$(resolve_model "openai/gpt-5.4")
    [[ "$result" == "openai/gpt-5.4" ]]
}

@test "resolve_model: nvidia-vl resolves correctly" {
    result=$(resolve_model "nvidia-vl")
    [[ "$result" == "openrouter/nvidia/nemotron-nano-12b-v2-vl:free" ]]
}

@test "resolve_model: invalid model returns empty string" {
    result=$(resolve_model "invalid-model")
    [[ "$result" == "" ]]
}

@test "resolve_model: empty input returns empty string" {
    result=$(resolve_model "")
    [[ "$result" == "" ]]
}

# =============================================================================
# Test get_model_name() function (reverse mapping)
# =============================================================================

@test "get_model_name: opencode/kimi-k2.5-free maps to kimi-zen" {
    result=$(get_model_name "opencode/kimi-k2.5-free")
    [[ "$result" == "kimi-zen" ]]
}

@test "get_model_name: opencode-go/kimi-k2.5 maps to kimi-go" {
    result=$(get_model_name "opencode-go/kimi-k2.5")
    [[ "$result" == "kimi-go" ]]
}

@test "get_model_name: modal/zai-org/GLM-5-FP8 maps to glm5-modal" {
    result=$(get_model_name "modal/zai-org/GLM-5-FP8")
    [[ "$result" == "glm5-modal" ]]
}

@test "get_model_name: opencode/glm-5-free maps to glm5-zen" {
    result=$(get_model_name "opencode/glm-5-free")
    [[ "$result" == "glm5-zen" ]]
}

@test "get_model_name: opencode-go/glm-5 maps to glm5-go" {
    result=$(get_model_name "opencode-go/glm-5")
    [[ "$result" == "glm5-go" ]]
}

@test "get_model_name: opencode/minimax-m2.5-free maps to minimax-zen" {
    result=$(get_model_name "opencode/minimax-m2.5-free")
    [[ "$result" == "minimax-zen" ]]
}

@test "get_model_name: opencode-go/minimax-m2.5 maps to minimax-go" {
    result=$(get_model_name "opencode-go/minimax-m2.5")
    [[ "$result" == "minimax-go" ]]
}

@test "get_model_name: openai/gpt-5.3-codex maps to codex-5.3" {
    result=$(get_model_name "openai/gpt-5.3-codex")
    [[ "$result" == "codex-5.3" ]]
}

@test "get_model_name: openai/gpt-5.4-thinking maps to gpt-5.4-thinking" {
    result=$(get_model_name "openai/gpt-5.4-thinking")
    [[ "$result" == "gpt-5.4-thinking" ]]
}

@test "get_model_name: opencode/gpt-5-nano maps to gpt-5-nano" {
    result=$(get_model_name "opencode/gpt-5-nano")
    [[ "$result" == "gpt-5-nano" ]]
}

@test "get_model_name: opencode/big-pickle maps to big-pickle" {
    result=$(get_model_name "opencode/big-pickle")
    [[ "$result" == "big-pickle" ]]
}

@test "get_model_name: openrouter/nvidia/nemotron-nano-12b-v2-vl:free maps to nvidia-vl" {
    result=$(get_model_name "openrouter/nvidia/nemotron-nano-12b-v2-vl:free")
    [[ "$result" == "nvidia-vl" ]]
}

@test "get_model_name: unknown ID returns the ID itself" {
    result=$(get_model_name "unknown/model")
    [[ "$result" == "unknown/model" ]]
}

# =============================================================================
# Test menu ordering helpers
# =============================================================================

@test "get_model_by_number: valid selection returns matching menu entry" {
    result=$(get_model_by_number "8")
    [[ "$result" == "${MODEL_MENU_IDS[7]}" ]]
}

@test "get_model_by_number: 0 returns empty (invalid)" {
    result=$(get_model_by_number "0")
    [[ "$result" == "" ]]
}

@test "get_model_by_number: out of range returns empty (invalid)" {
    result=$(get_model_by_number "14")
    [[ "$result" == "" ]]
}

@test "get_model_by_number: abc returns empty (invalid)" {
    result=$(get_model_by_number "abc")
    [[ "$result" == "" ]]
}

@test "build_model_catalog: failing provider is omitted" {
    set_mock_provider_failure opencode-go "Provider not connected"
    build_model_catalog

    result=$(resolve_model "kimi-go")
    [[ "$result" == "" ]]
    [[ "${#MODEL_MENU_IDS[@]}" -ge 1 ]]
}

@test "build_model_catalog: verbose cost filter keeps only zero-cost opencode models" {
    build_model_catalog

    result=$(resolve_model "claude-sonnet-4")
    [[ "$result" == "" ]]
    result=$(resolve_model "gpt-5-nano")
    [[ "$result" == "opencode/gpt-5-nano" ]]
}
