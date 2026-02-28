#!/bin/bash
#
# switch-model.sh - Oh-My-OpenCode model switcher
#
# =============================================================================
# MODEL POOL (same options for both selections):
# =============================================================================
#   kimi-zen        - opencode/kimi-k2.5-free
#   kimi-go         - opencode-go/kimi-k2.5
#   kimi-chutes     - chutes/moonshotai/Kimi-K2.5-TEE
#   glm5-modal      - modal/zai-org/GLM-5-FP8
#   glm5-zen        - opencode/glm-5-free
#   glm5-go         - opencode-go/glm-5
#   minimax-zen     - opencode/minimax-m2.5-free
#   minimax-chutes  - chutes/MiniMaxAI/MiniMax-M2.5-TEE
#   minimax-go      - opencode-go/minimax-m2.5
#   codex-5.3       - openai/gpt-5.3-codex
#
# =============================================================================
# UNDERSTANDING THE TWO SELECTIONS:
# =============================================================================
#
# SELECTION 1: Orchestration Model (for Sisyphus-type agents)
# ---------------------------------------------------------------------------
# These agents handle coordination, communication, and delegation:
#   - sisyphus     : Main coder, orchestrates other agents (Claude > Kimi/GLM)
#   - oracle       : Reasoning/consultation (GPT > Gemini > Claude)
#   - explore     : Fast search/grep (Grok > MiniMax > Haiku)
#   - prometheus  : Planning (Claude > GPT > Kimi > Gemini)
#   - metis       : Analysis (Claude > Kimi > GPT > Gemini)
#   - momus       : Review/feedback (GPT > Claude > Gemini)
#   - atlas       : Architecture (Kimi > Claude > GPT)
#
# Categories that use this:
#   - quick              : Fast tasks (Haiku > Gemini > GPT Nano)
#   - writing            : Documentation (Kimi > Gemini > Claude)
#   - unspecified-low    : Low effort (Claude Sonnet > GPT > Gemini)
#   - unspecified-high   : High effort (Claude > GPT > Gemini)
#   - visual-engineering: UI/Frontend (Gemini > GLM > Claude)
#
# RECOMMENDED: kimi-zen, kimi-go, glm5-zen, glm5-go, minimax-zen, minimax-go
#
#
# SELECTION 2: Deep Work Model (for Hephaestus-type agents)
# ---------------------------------------------------------------------------
# These agents handle intensive coding tasks:
#   - hephaestus  : Deep autonomous work (GPT Codex ONLY - per OMO docs)
#
# Categories that use this:
#   - ultrabrain  : Hard logic problems (GPT Codex primary)
#   - deep        : Thorough research (GPT Codex primary, REQUIRES gpt-5.3-codex)
#
# RECOMMENDED: codex-5.3 (but you can use kimi/glm/minimax if quota runs out)
#
# =============================================================================
# ALWAYS EXCLUDED (keep their defaults):
# =============================================================================
#   - librarian         : stays on gpt-5-nano (large context)
#   - multimodal-looker: stays on OpenRouter nvidia (vision)
#
# =============================================================================
# INSTALL:
#   curl -sL https://raw.githubusercontent.com/parasquid/switch-oh-my-opencode-model/main/switch-model.sh -o ~/bin/switch-model.sh
#   chmod +x ~/bin/switch-model.sh
#
# UPDATE:
#   curl -sL https://raw.githubusercontent.com/parasquid/switch-oh-my-opencode-model/main/switch-model.sh -o ~/bin/switch-model.sh
#

CONFIG_FILE="$HOME/.config/opencode/oh-my-opencode.json"

# Model mappings (all available models)
KIMI_ZEN_MODEL="opencode/kimi-k2.5-free"
KIMI_GO_MODEL="opencode-go/kimi-k2.5"
KIMI_CHUTES_MODEL="chutes/moonshotai/Kimi-K2.5-TEE"
GLM5_MODAL_MODEL="modal/zai-org/GLM-5-FP8"
GLM5_ZEN_MODEL="opencode/glm-5-free"
GLM5_GO_MODEL="opencode-go/glm-5"
MINIMAX_ZEN_MODEL="opencode/minimax-m2.5-free"
MINIMAX_CHUTES_MODEL="chutes/MiniMaxAI/MiniMax-M2.5-TEE"
MINIMAX_GO_MODEL="opencode-go/minimax-m2.5"
CODEX_53_MODEL="openai/gpt-5.3-codex"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found at $CONFIG_FILE"
    exit 1
fi

resolve_model() {
    case "$1" in
        kimi-zen|kimi|kimi-k2.5|kimi-k2.5-free)     echo "$KIMI_ZEN_MODEL" ;;
        kimi-go|kimi-k2.5-go)                        echo "$KIMI_GO_MODEL" ;;
        kimi-chutes|kimi-chutes-k2.5)                echo "$KIMI_CHUTES_MODEL" ;;
        glm5-modal|glm-5-modal|glm5)                 echo "$GLM5_MODAL_MODEL" ;;
        glm5-zen|glm-5-zen)                         echo "$GLM5_ZEN_MODEL" ;;
        glm5-go|glm-5-go)                           echo "$GLM5_GO_MODEL" ;;
        minimax-zen|minimax|minimax-m2.5|minimax-m2.5-free) echo "$MINIMAX_ZEN_MODEL" ;;
        minimax-chutes|minimax-m2.5-chutes)         echo "$MINIMAX_CHUTES_MODEL" ;;
        minimax-go|minimax-m2.5-go)                 echo "$MINIMAX_GO_MODEL" ;;
        codex-5.3|codex|gpt-5.3-codex)              echo "$CODEX_53_MODEL" ;;
        *) echo "" ;;
    esac
}

print_menu() {
    echo "  1) kimi-zen        - $KIMI_ZEN_MODEL"
    echo "  2) kimi-go         - $KIMI_GO_MODEL"
    echo "  3) kimi-chutes     - $KIMI_CHUTES_MODEL"
    echo "  4) glm5-modal      - $GLM5_MODAL_MODEL"
    echo "  5) glm5-zen        - $GLM5_ZEN_MODEL"
    echo "  6) glm5-go         - $GLM5_GO_MODEL"
    echo "  7) minimax-zen     - $MINIMAX_ZEN_MODEL"
    echo "  8) minimax-chutes  - $MINIMAX_CHUTES_MODEL"
    echo "  9) minimax-go       - $MINIMAX_GO_MODEL"
    echo " 10) codex-5.3      - $CODEX_53_MODEL"
}

# Interactive mode
if [ -z "$1" ]; then
    echo "=== Oh-My-OpenCode Model Switcher ==="
    echo ""
    echo "======================================================================"
    echo "SELECTION 1: Orchestration Model (Sisyphus-type agents)"
    echo "======================================================================"
    echo "For: sisyphus, oracle, explore, prometheus, metis, momus, atlas"
    echo "Categories: quick, writing, unspecified-low, unspecified-high, visual-engineering"
    echo ""
    echo "Recommended: kimi-zen, kimi-go, glm5-zen, glm5-go, minimax-zen, minimax-go"
    echo ""
    print_menu
    echo ""
    echo -n "Select orchestration model (1-10): "
    read -r main_choice
    
    case "$main_choice" in
        1) MAIN_MODEL="$KIMI_ZEN_MODEL" ; MAIN_NAME="kimi-zen" ;;
        2) MAIN_MODEL="$KIMI_GO_MODEL" ; MAIN_NAME="kimi-go" ;;
        3) MAIN_MODEL="$KIMI_CHUTES_MODEL" ; MAIN_NAME="kimi-chutes" ;;
        4) MAIN_MODEL="$GLM5_MODAL_MODEL" ; MAIN_NAME="glm5-modal" ;;
        5) MAIN_MODEL="$GLM5_ZEN_MODEL" ; MAIN_NAME="glm5-zen" ;;
        6) MAIN_MODEL="$GLM5_GO_MODEL" ; MAIN_NAME="glm5-go" ;;
        7) MAIN_MODEL="$MINIMAX_ZEN_MODEL" ; MAIN_NAME="minimax-zen" ;;
        8) MAIN_MODEL="$MINIMAX_CHUTES_MODEL" ; MAIN_NAME="minimax-chutes" ;;
        9) MAIN_MODEL="$MINIMAX_GO_MODEL" ; MAIN_NAME="minimax-go" ;;
       10) MAIN_MODEL="$CODEX_53_MODEL" ; MAIN_NAME="codex-5.3" ;;
        *) echo "Error: Invalid choice '$main_choice'"; exit 1 ;;
    esac
    
    echo ""
    echo "======================================================================"
    echo "SELECTION 2: Deep Work Model (Hephaestus-type agents)"
    echo "======================================================================"
    echo "For: hephaestus"
    echo "Categories: ultrabrain, deep"
    echo ""
    echo "Recommended: codex-5.3 (but you can use any if quota runs out)"
    echo ""
    print_menu
    echo ""
    echo -n "Select deep work model (1-10): "
    read -r gpt_choice
    
    case "$gpt_choice" in
        1) GPT_MODEL="$KIMI_ZEN_MODEL" ; GPT_NAME="kimi-zen" ;;
        2) GPT_MODEL="$KIMI_GO_MODEL" ; GPT_NAME="kimi-go" ;;
        3) GPT_MODEL="$KIMI_CHUTES_MODEL" ; GPT_NAME="kimi-chutes" ;;
        4) GPT_MODEL="$GLM5_MODAL_MODEL" ; GPT_NAME="glm5-modal" ;;
        5) GPT_MODEL="$GLM5_ZEN_MODEL" ; GPT_NAME="glm5-zen" ;;
        6) GPT_MODEL="$GLM5_GO_MODEL" ; GPT_NAME="glm5-go" ;;
        7) GPT_MODEL="$MINIMAX_ZEN_MODEL" ; GPT_NAME="minimax-zen" ;;
        8) GPT_MODEL="$MINIMAX_CHUTES_MODEL" ; GPT_NAME="minimax-chutes" ;;
        9) GPT_MODEL="$MINIMAX_GO_MODEL" ; GPT_NAME="minimax-go" ;;
       10) GPT_MODEL="$CODEX_53_MODEL" ; GPT_NAME="codex-5.3" ;;
        *) echo "Error: Invalid choice '$gpt_choice'"; exit 1 ;;
    esac
    
    echo ""
    echo "Orchestration model: $MAIN_NAME"
    echo "Deep work model: $GPT_NAME"
    echo ""
    
elif [ -n "$2" ]; then
    MAIN_MODEL=$(resolve_model "$1")
    GPT_MODEL=$(resolve_model "$2")
    MAIN_NAME="$1"
    GPT_NAME="$2"
    
    if [ -z "$MAIN_MODEL" ]; then
        echo "Error: Unknown model '$1'"
        exit 1
    fi
    if [ -z "$GPT_MODEL" ]; then
        echo "Error: Unknown model '$2'"
        exit 1
    fi
else
    echo "Usage: $0 <orchestration_model> <deep_work_model>"
    echo "   or: $0 (interactive)"
    echo ""
    echo "Examples:"
    echo "  $0 kimi-zen codex-5.3"
    echo "  $0 glm5-go codex-5.3"
    echo "  $0 minimax-zen codex-5.3"
    echo ""
    echo "See script comments for full documentation."
    exit 1
fi

echo "Applying..."
echo "  Orchestration: $MAIN_NAME ($MAIN_MODEL)"
echo "  Deep Work: $GPT_NAME ($GPT_MODEL)"
echo ""

# Backup config
cp "$CONFIG_FILE" "$CONFIG_FILE.bak.$(date +%Y%m%d_%H%M%S)"

python3 << PYTHON
import json

with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)

main_model = '$MAIN_MODEL'
gpt_model = '$GPT_MODEL'

# Orchestration model applies to: sisyphus-type agents
orchestration_agents = ['sisyphus', 'oracle', 'explore', 'prometheus', 'metis', 'momus', 'atlas']
for agent in orchestration_agents:
    if agent in config['agents']:
        config['agents'][agent]['model'] = main_model

# Orchestration model applies to these categories
orchestration_categories = ['quick', 'writing', 'unspecified-low', 'unspecified-high', 'visual-engineering']
for category in orchestration_categories:
    if category in config['categories']:
        config['categories'][category]['model'] = main_model

# Deep work model applies to: hephaestus
config['agents']['hephaestus']['model'] = gpt_model

# Deep work model applies to these categories
deep_categories = ['ultrabrain', 'deep']
for category in deep_categories:
    if category in config['categories']:
        config['categories'][category]['model'] = gpt_model

# librarian and multimodal-looker stay unchanged

with open('$CONFIG_FILE', 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')

print("Config updated successfully!")
print("")
print("Orchestration model applied to:")
print("  Agents: sisyphus, oracle, explore, prometheus, metis, momus, atlas")
print("  Categories: quick, writing, unspecified-low, unspecified-high, visual-engineering")
print("")
print("Deep work model applied to:")
print("  Agents: hephaestus")
print("  Categories: ultrabrain, deep")
PYTHON

if [ $? -ne 0 ]; then
    echo "Error: Failed to update config."
    exit 1
fi

echo ""
echo "Backup saved to: $CONFIG_FILE.bak.*"
echo "Please restart OpenCode to apply changes."
