#!/usr/bin/env bats
# =============================================================================
# test_model_resolution.bats - Test model resolution functions
# =============================================================================

# Load test helpers
load test_helper

# Load the switch-model.sh functions (need to handle the config check)
# We create a wrapper that sources functions but skips config check

setup() {
    super_setup
    # Source the actual script functions
    source "$FIXTURES_DIR/functions.sh"
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

@test "resolve_model: gpt-5-nano resolves correctly" {
    result=$(resolve_model "gpt-5-nano")
    [[ "$result" == "opencode/gpt-5-nano" ]]
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

@test "get_model_name: opencode/gpt-5-nano maps to gpt-5-nano" {
    result=$(get_model_name "opencode/gpt-5-nano")
    [[ "$result" == "gpt-5-nano" ]]
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
# Test get_model_by_number() function
# =============================================================================

@test "get_model_by_number: 1 returns kimi-zen" {
    result=$(get_model_by_number "1")
    [[ "$result" == "opencode/kimi-k2.5-free" ]]
}

@test "get_model_by_number: 2 returns kimi-go" {
    result=$(get_model_by_number "2")
    [[ "$result" == "opencode-go/kimi-k2.5" ]]
}

@test "get_model_by_number: 3 returns glm5-modal" {
    result=$(get_model_by_number "3")
    [[ "$result" == "modal/zai-org/GLM-5-FP8" ]]
}

@test "get_model_by_number: 4 returns glm5-zen" {
    result=$(get_model_by_number "4")
    [[ "$result" == "opencode/glm-5-free" ]]
}

@test "get_model_by_number: 5 returns glm5-go" {
    result=$(get_model_by_number "5")
    [[ "$result" == "opencode-go/glm-5" ]]
}

@test "get_model_by_number: 6 returns minimax-zen" {
    result=$(get_model_by_number "6")
    [[ "$result" == "opencode/minimax-m2.5-free" ]]
}

@test "get_model_by_number: 7 returns minimax-go" {
    result=$(get_model_by_number "7")
    [[ "$result" == "opencode-go/minimax-m2.5" ]]
}

@test "get_model_by_number: 8 returns codex-5.3" {
    result=$(get_model_by_number "8")
    [[ "$result" == "openai/gpt-5.3-codex" ]]
}

@test "get_model_by_number: 9 returns gpt-5-nano" {
    result=$(get_model_by_number "9")
    [[ "$result" == "opencode/gpt-5-nano" ]]
}

@test "get_model_by_number: 10 returns nvidia-vl" {
    result=$(get_model_by_number "10")
    [[ "$result" == "openrouter/nvidia/nemotron-nano-12b-v2-vl:free" ]]
}

@test "get_model_by_number: 0 returns empty (invalid)" {
    result=$(get_model_by_number "0")
    [[ "$result" == "" ]]
}

@test "get_model_by_number: 11 returns empty (invalid)" {
    result=$(get_model_by_number "11")
    [[ "$result" == "" ]]
}

@test "get_model_by_number: abc returns empty (invalid)" {
    result=$(get_model_by_number "abc")
    [[ "$result" == "" ]]
}
