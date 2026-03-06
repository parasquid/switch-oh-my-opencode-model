#!/usr/bin/env bats
# =============================================================================
# test_config_operations.bats - Test config file operations for switch-model.sh
# =============================================================================

# Load test helpers
load test_helper

# Setup - create test config and export required paths
setup() {
    super_setup
    mock_opencode_cli
    mock_default_opencode_models
    
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
# Test Global Mode Config Operations
# =============================================================================

@test "global mode: backup file is created before modification" {
    # Get the config directory
    TEST_CONFIG_DIR=$(dirname "$CONFIG_FILE")
    
    # Run global mode
    run bash "$SCRIPT_DIR/switch-model.sh" kimi-zen codex-5.3
    [ "$status" -eq 0 ]
    
    # Check that backup file exists
    BACKUP_FILE=$(ls -t "$TEST_CONFIG_DIR"/"$(basename "$CONFIG_FILE")".bak.* 2>/dev/null | head -1)
    [ -n "$BACKUP_FILE" ]
    [ -f "$BACKUP_FILE" ]
}

@test "global mode: orch-agents (sisyphus, oracle, explore, prometheus, metis, momus, atlas) get updated" {
    run bash "$SCRIPT_DIR/switch-model.sh" kimi-zen codex-5.3
    [ "$status" -eq 0 ]
    
    # Verify each orch agent gets the orchestration model
    [ "$(get_agent_model sisyphus)" = "opencode/kimi-k2.5-free" ]
    [ "$(get_agent_model oracle)" = "opencode/kimi-k2.5-free" ]
    [ "$(get_agent_model explore)" = "opencode/kimi-k2.5-free" ]
    [ "$(get_agent_model prometheus)" = "opencode/kimi-k2.5-free" ]
    [ "$(get_agent_model metis)" = "opencode/kimi-k2.5-free" ]
    [ "$(get_agent_model momus)" = "opencode/kimi-k2.5-free" ]
    [ "$(get_agent_model atlas)" = "opencode/kimi-k2.5-free" ]
}

@test "global mode: orch-categories (quick, writing, unspecified-low, unspecified-high, visual-engineering) get updated" {
    run bash "$SCRIPT_DIR/switch-model.sh" kimi-zen codex-5.3
    [ "$status" -eq 0 ]
    
    # Verify each orch category gets the orchestration model
    [ "$(get_category_model quick)" = "opencode/kimi-k2.5-free" ]
    [ "$(get_category_model writing)" = "opencode/kimi-k2.5-free" ]
    [ "$(get_category_model unspecified-low)" = "opencode/kimi-k2.5-free" ]
    [ "$(get_category_model unspecified-high)" = "opencode/kimi-k2.5-free" ]
    [ "$(get_category_model visual-engineering)" = "opencode/kimi-k2.5-free" ]
}

@test "global mode: hephaestus gets updated to deep-work model" {
    run bash "$SCRIPT_DIR/switch-model.sh" kimi-zen codex-5.3
    [ "$status" -eq 0 ]
    
    # Verify hephaestus gets the deep work model
    [ "$(get_agent_model hephaestus)" = "openai/gpt-5.3-codex" ]
}

@test "global mode: deep-categories (ultrabrain, deep) get updated" {
    run bash "$SCRIPT_DIR/switch-model.sh" kimi-zen codex-5.3
    [ "$status" -eq 0 ]
    
    # Verify deep categories get the deep work model
    [ "$(get_category_model ultrabrain)" = "openai/gpt-5.3-codex" ]
    [ "$(get_category_model deep)" = "openai/gpt-5.3-codex" ]
}

@test "global mode: librarian is EXCLUDED (NOT updated in global mode)" {
    # Store original value
    ORIGINAL_LIBRARIAN=$(get_agent_model librarian)
    [ "$ORIGINAL_LIBRARIAN" = "opencode/gpt-5-nano" ]
    
    run bash "$SCRIPT_DIR/switch-model.sh" kimi-zen codex-5.3
    [ "$status" -eq 0 ]
    
    # Verify librarian is unchanged
    [ "$(get_agent_model librarian)" = "$ORIGINAL_LIBRARIAN" ]
    [ "$(get_agent_model librarian)" = "opencode/gpt-5-nano" ]
}

@test "global mode: multimodal-looker is EXCLUDED (NOT updated in global mode)" {
    # Store original value
    ORIGINAL_MULTIMODAL=$(get_agent_model multimodal-looker)
    [ "$ORIGINAL_MULTIMODAL" = "openrouter/nvidia/nemotron-nano-12b-v2-vl:free" ]
    
    run bash "$SCRIPT_DIR/switch-model.sh" kimi-zen codex-5.3
    [ "$status" -eq 0 ]
    
    # Verify multimodal-looker is unchanged
    [ "$(get_agent_model multimodal-looker)" = "$ORIGINAL_MULTIMODAL" ]
    [ "$(get_agent_model multimodal-looker)" = "openrouter/nvidia/nemotron-nano-12b-v2-vl:free" ]
}

# =============================================================================
# Test Fine-Grained Mode --agent Config Operations
# =============================================================================

@test "agent mode: updating specific agent model succeeds" {
    run bash "$SCRIPT_DIR/switch-model.sh" --agent sisyphus kimi-zen
    [ "$status" -eq 0 ]
    
    # Verify only sisyphus is updated
    [ "$(get_agent_model sisyphus)" = "opencode/kimi-k2.5-free" ]
    
    # Verify others are unchanged
    [ "$(get_agent_model oracle)" = "opencode/kimi-k2.5-free" ]
    [ "$(get_agent_model hephaestus)" = "openai/gpt-5.3-codex" ]
}

@test "agent mode: setting fallback model succeeds" {
    run bash "$SCRIPT_DIR/switch-model.sh" --agent sisyphus kimi-zen --fallback codex-5.3
    [ "$status" -eq 0 ]
    
    # Verify model is updated
    [ "$(get_agent_model sisyphus)" = "opencode/kimi-k2.5-free" ]
    
    # Verify fallback is set using python
    FALLBACK=$(python3 -c "
import json
with open('$TEST_CONFIG') as f:
    print(json.load(f)['agents'].get('sisyphus', {}).get('fallback', ''))
")
    [ "$FALLBACK" = "openai/gpt-5.3-codex" ]
}

@test "agent mode: librarian CAN be modified in fine-grained mode" {
    # Verify initial value
    [ "$(get_agent_model librarian)" = "opencode/gpt-5-nano" ]
    
    run bash "$SCRIPT_DIR/switch-model.sh" --agent librarian kimi-zen
    [ "$status" -eq 0 ]
    
    # Verify librarian is updated
    [ "$(get_agent_model librarian)" = "opencode/kimi-k2.5-free" ]
}

@test "agent mode: multimodal-looker CAN be modified in fine-grained mode" {
    # Verify initial value
    [ "$(get_agent_model multimodal-looker)" = "openrouter/nvidia/nemotron-nano-12b-v2-vl:free" ]
    
    run bash "$SCRIPT_DIR/switch-model.sh" --agent multimodal-looker kimi-zen
    [ "$status" -eq 0 ]
    
    # Verify multimodal-looker is updated
    [ "$(get_agent_model multimodal-looker)" = "opencode/kimi-k2.5-free" ]
}

# =============================================================================
# Test Fine-Grained Mode --category Config Operations
# =============================================================================

@test "category mode: updating specific category model succeeds" {
    run bash "$SCRIPT_DIR/switch-model.sh" --category quick kimi-zen
    [ "$status" -eq 0 ]
    
    # Verify only quick is updated
    [ "$(get_category_model quick)" = "opencode/kimi-k2.5-free" ]
    
    # Verify others are unchanged
    [ "$(get_category_model writing)" = "opencode/kimi-k2.5-free" ]
    [ "$(get_category_model ultrabrain)" = "openai/gpt-5.3-codex" ]
}

@test "category mode: setting fallback model succeeds" {
    run bash "$SCRIPT_DIR/switch-model.sh" --category quick kimi-zen --fallback codex-5.3
    [ "$status" -eq 0 ]
    
    # Verify model is updated
    [ "$(get_category_model quick)" = "opencode/kimi-k2.5-free" ]
    
    # Verify fallback is set using python
    FALLBACK=$(python3 -c "
import json
with open('$TEST_CONFIG') as f:
    print(json.load(f)['categories'].get('quick', {}).get('fallback', ''))
")
    [ "$FALLBACK" = "openai/gpt-5.3-codex" ]
}

# =============================================================================
# Test --agents-fallback Config Operations
# =============================================================================

@test "agents-fallback: setting fallback for all agents succeeds" {
    # First add fallback fields to all agents
    cat > "$TEST_CONFIG" << 'EOF'
{
  "agents": {
    "sisyphus": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
    "oracle": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
    "explore": {"model": "opencode/minimax-m2.5-free", "fallback": ""},
    "prometheus": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
    "metis": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
    "momus": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
    "atlas": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
    "hephaestus": {"model": "openai/gpt-5.3-codex", "fallback": ""},
    "librarian": {"model": "opencode/gpt-5-nano", "fallback": ""},
    "multimodal-looker": {"model": "openrouter/nvidia/nemotron-nano-12b-v2-vl:free", "fallback": ""}
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
    
    run bash "$SCRIPT_DIR/switch-model.sh" --agents-fallback codex-5.3
    [ "$status" -eq 0 ]
    
    # Verify fallback is set for all agents
    SISYPHUS_FALLBACK=$(python3 -c "
import json
with open('$TEST_CONFIG') as f:
    print(json.load(f)['agents'].get('sisyphus', {}).get('fallback', ''))
")
    ORACLE_FALLBACK=$(python3 -c "
import json
with open('$TEST_CONFIG') as f:
    print(json.load(f)['agents'].get('oracle', {}).get('fallback', ''))
")
    HEPHAESTUS_FALLBACK=$(python3 -c "
import json
with open('$TEST_CONFIG') as f:
    print(json.load(f)['agents'].get('hephaestus', {}).get('fallback', ''))
")
    LIBRARIAN_FALLBACK=$(python3 -c "
import json
with open('$TEST_CONFIG') as f:
    print(json.load(f)['agents'].get('librarian', {}).get('fallback', ''))
")
    
    [ "$SISYPHUS_FALLBACK" = "openai/gpt-5.3-codex" ]
    [ "$ORACLE_FALLBACK" = "openai/gpt-5.3-codex" ]
    [ "$HEPHAESTUS_FALLBACK" = "openai/gpt-5.3-codex" ]
    [ "$LIBRARIAN_FALLBACK" = "openai/gpt-5.3-codex" ]
}

# =============================================================================
# Test --categories-fallback Config Operations
# =============================================================================

@test "categories-fallback: setting fallback for all categories succeeds" {
    # First add fallback fields to all categories
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
    "ultrabrain": {"model": "openai/gpt-5.3-codex", "fallback": ""},
    "deep": {"model": "openai/gpt-5.3-codex", "fallback": ""},
    "artistry": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
    "quick": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
    "writing": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
    "unspecified-low": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
    "unspecified-high": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
    "visual-engineering": {"model": "opencode/kimi-k2.5-free", "fallback": ""}
  }
}
EOF
    
    run bash "$SCRIPT_DIR/switch-model.sh" --categories-fallback kimi-zen
    [ "$status" -eq 0 ]
    
    # Verify fallback is set for all categories
    QUICK_FALLBACK=$(python3 -c "
import json
with open('$TEST_CONFIG') as f:
    print(json.load(f)['categories'].get('quick', {}).get('fallback', ''))
")
    ULTRABRAIN_FALLBACK=$(python3 -c "
import json
with open('$TEST_CONFIG') as f:
    print(json.load(f)['categories'].get('ultrabrain', {}).get('fallback', ''))
")
    DEEP_FALLBACK=$(python3 -c "
import json
with open('$TEST_CONFIG') as f:
    print(json.load(f)['categories'].get('deep', {}).get('fallback', ''))
")
    WRITING_FALLBACK=$(python3 -c "
import json
with open('$TEST_CONFIG') as f:
    print(json.load(f)['categories'].get('writing', {}).get('fallback', ''))
")
    
    [ "$QUICK_FALLBACK" = "opencode/kimi-k2.5-free" ]
    [ "$ULTRABRAIN_FALLBACK" = "opencode/kimi-k2.5-free" ]
    [ "$DEEP_FALLBACK" = "opencode/kimi-k2.5-free" ]
    [ "$WRITING_FALLBACK" = "opencode/kimi-k2.5-free" ]
}
