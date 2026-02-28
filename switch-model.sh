#!/bin/bash
#
# switch-model.sh - Oh-My-OpenCode model switcher
#
# =============================================================================
# AVAILABLE MODELS:
# =============================================================================
#   kimi-zen           - opencode/kimi-k2.5-free
#   kimi-go            - opencode-go/kimi-k2.5
#   kimi-chutes        - chutes/moonshotai/Kimi-K2.5-TEE
#   glm5-modal         - modal/zai-org/GLM-5-FP8
#   glm5-zen           - opencode/glm-5-free
#   glm5-go            - opencode-go/glm-5
#   minimax-zen        - opencode/minimax-m2.5-free
#   minimax-chutes     - chutes/MiniMaxAI/MiniMax-M2.5-TEE
#   minimax-go         - opencode-go/minimax-m2.5
#   codex-5.3          - openai/gpt-5.3-codex
#   gpt-5-nano         - opencode/gpt-5-nano
#   nvidia-vl          - openrouter/nvidia/nemotron-nano-12b-v2-vl:free
#
# =============================================================================
# USAGE:
# =============================================================================
#   Global mode (change orchestration + deep work models):
#     switch-model.sh [orchestration_model] [deep_work_model]
#     switch-model.sh kimi-zen codex-5.3
#
#   Fine-grained mode (agent/category specific):
#     switch-model.sh --agent <name> <model> [--fallback <model>]
#     switch-model.sh --category <name> <model> [--fallback <model>]
#
#   Interactive (no args):
#     switch-model.sh
#
#   Help:
#     switch-model.sh --help
#
# =============================================================================
# EXCLUDED IN GLOBAL MODE (but available in fine-grained):
# =============================================================================
#   - librarian         : stays on gpt-5-nano
#   - multimodal-looker: stays on nvidia-vl
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

# Model mappings
KIMI_ZEN="opencode/kimi-k2.5-free"
KIMI_GO="opencode-go/kimi-k2.5"
KIMI_CHUTES="chutes/moonshotai/Kimi-K2.5-TEE"
GLM5_MODAL="modal/zai-org/GLM-5-FP8"
GLM5_ZEN="opencode/glm-5-free"
GLM5_GO="opencode-go/glm-5"
MINIMAX_ZEN="opencode/minimax-m2.5-free"
MINIMAX_CHUTES="chutes/MiniMaxAI/MiniMax-M2.5-TEE"
MINIMAX_GO="opencode-go/minimax-m2.5"
CODEX_53="openai/gpt-5.3-codex"
GPT_NANO="opencode/gpt-5-nano"
NVIDIA_VL="openrouter/nvidia/nemotron-nano-12b-v2-vl:free"

# Valid agents and categories
VALID_AGENTS="sisyphus oracle explore prometheus metis momus atlas hephaestus librarian multimodal-looker"
VALID_CATEGORIES="ultrabrain deep artistry quick writing unspecified-low unspecified-high visual-engineering"

# Global mode defaults (excluded agents)
GLOBAL_EXCLUDED_AGENTS="librarian multimodal-looker"

show_help() {
    cat << HELP
Usage: switch-model.sh [OPTIONS] [ARGS]

OPTIONS:
  -h, --help                 Show this help message
  --agent <name> <model>     Set model for a specific agent
  --category <name> <model>   Set model for a specific category
  --agents-fallback <model>  Set fallback for all agents
  --categories-fallback <model> Set fallback for all categories

ARGUMENTS (Global Mode):
  1) Orchestration model
  2) Deep work model

EXAMPLES:

  # Global mode - change orchestration + deep work at once
  switch-model.sh kimi-zen codex-5.3
  switch-model.sh glm5-go codex-5.3

  # Fine-grained - set specific agent
  switch-model.sh --agent sisyphus kimi-zen
  switch-model.sh --agent hephaestus codex-5.3 --fallback kimi-zen

  # Fine-grained - set specific category
  switch-model.sh --category deep codex-5.3
  switch-model.sh --category ultrabrain codex-5.3 --fallback kimi-zen

  # Set fallback for all
  switch-model.sh --agents-fallback glm5-zen
  switch-model.sh --categories-fallback glm5-zen

  # Interactive mode (no args)
  switch-model.sh

AVAILABLE AGENTS: $VALID_AGENTS
AVAILABLE CATEGORIES: $VALID_CATEGORIES

AVAILABLE MODELS:
  kimi-zen, kimi-go, kimi-chutes, glm5-modal, glm5-zen, glm5-go,
  minimax-zen, minimax-chutes, minimax-go, codex-5.3, gpt-5-nano, nvidia-vl

NOTE: In global mode, librarian and multimodal-looker are EXCLUDED (keep defaults).
      Use fine-grained mode to modify them.
HELP
    exit 0
}

resolve_model() {
    case "$1" in
        kimi-zen|kimi|kimi-k2.5|kimi-k2.5-free)     echo "$KIMI_ZEN" ;;
        kimi-go|kimi-k2.5-go)                        echo "$KIMI_GO" ;;
        kimi-chutes|kimi-chutes-k2.5)                echo "$KIMI_CHUTES" ;;
        glm5-modal|glm-5-modal|glm5)                echo "$GLM5_MODAL" ;;
        glm5-zen|glm-5-zen)                         echo "$GLM5_ZEN" ;;
        glm5-go|glm-5-go)                           echo "$GLM5_GO" ;;
        minimax-zen|minimax|minimax-m2.5|minimax-m2.5-free) echo "$MINIMAX_ZEN" ;;
        minimax-chutes|minimax-m2.5-chutes)          echo "$MINIMAX_CHUTES" ;;
        minimax-go|minimax-m2.5-go)                  echo "$MINIMAX_GO" ;;
        codex-5.3|codex|gpt-5.3-codex)              echo "$CODEX_53" ;;
        gpt-5-nano|gpt-nano|nano)                   echo "$GPT_NANO" ;;
        nvidia-vl|nvidia|nemotron)                   echo "$NVIDIA_VL" ;;
        *) echo "" ;;
    esac
}

get_model_name() {
    case "$1" in
        "$KIMI_ZEN") echo "kimi-zen" ;;
        "$KIMI_GO") echo "kimi-go" ;;
        "$KIMI_CHUTES") echo "kimi-chutes" ;;
        "$GLM5_MODAL") echo "glm5-modal" ;;
        "$GLM5_ZEN") echo "glm5-zen" ;;
        "$GLM5_GO") echo "glm5-go" ;;
        "$MINIMAX_ZEN") echo "minimax-zen" ;;
        "$MINIMAX_CHUTES") echo "minimax-chutes" ;;
        "$MINIMAX_GO") echo "minimax-go" ;;
        "$CODEX_53") echo "codex-5.3" ;;
        "$GPT_NANO") echo "gpt-5-nano" ;;
        "$NVIDIA_VL") echo "nvidia-vl" ;;
        *) echo "$1" ;;
    esac
}

print_model_menu() {
    echo "  1) kimi-zen        - $KIMI_ZEN"
    echo "  2) kimi-go         - $KIMI_GO"
    echo "  3) kimi-chutes     - $KIMI_CHUTES"
    echo "  4) glm5-modal      - $GLM5_MODAL"
    echo "  5) glm5-zen        - $GLM5_ZEN"
    echo "  6) glm5-go         - $GLM5_GO"
    echo "  7) minimax-zen     - $MINIMAX_ZEN"
    echo "  8) minimax-chutes  - $MINIMAX_CHUTES"
    echo "  9) minimax-go      - $MINIMAX_GO"
    echo " 10) codex-5.3      - $CODEX_53"
    echo " 11) gpt-5-nano     - $GPT_NANO"
    echo " 12) nvidia-vl       - $NVIDIA_VL"
}

get_model_by_number() {
    case "$1" in
        1) echo "$KIMI_ZEN" ;;
        2) echo "$KIMI_GO" ;;
        3) echo "$KIMI_CHUTES" ;;
        4) echo "$GLM5_MODAL" ;;
        5) echo "$GLM5_ZEN" ;;
        6) echo "$GLM5_GO" ;;
        7) echo "$MINIMAX_ZEN" ;;
        8) echo "$MINIMAX_CHUTES" ;;
        9) echo "$MINIMAX_GO" ;;
       10) echo "$CODEX_53" ;;
       11) echo "$GPT_NANO" ;;
       12) echo "$NVIDIA_VL" ;;
       *) echo "" ;;
    esac
}

# Check if config exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found at $CONFIG_FILE"
    exit 1
fi

# Parse arguments
MODE=""
AGENT_NAME=""
CATEGORY_NAME=""
FALLBACK_MODEL=""

# Handle --help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
fi

# Check for flag-based args (fine-grained mode)
if [[ "$1" == "--"* ]]; then
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --agent)
                MODE="agent"
                AGENT_NAME="$2"
                shift 2
                ;;
            --category)
                MODE="category"
                CATEGORY_NAME="$2"
                shift 2
                ;;
            --agents-fallback)
                MODE="agents-fallback"
                shift
                ;;
            --categories-fallback)
                MODE="categories-fallback"
                shift
                ;;
            --fallback)
                FALLBACK_MODEL="$2"
                shift 2
                ;;
            -*)
                echo "Error: Unknown option $1"
                show_help
                ;;
            *)
                if [ -z "$MODEL_ARG" ]; then
                    MODEL_ARG="$1"
                elif [ -z "$MODEL_ARG2" ]; then
                    MODEL_ARG2="$1"
                fi
                shift
                ;;
        esac
    done
    
    # Validate
    if [ "$MODE" = "agent" ] && [ -z "$AGENT_NAME" ]; then
        echo "Error: --agent requires <name>"
        exit 1
    fi
    if [ "$MODE" = "category" ] && [ -z "$CATEGORY_NAME" ]; then
        echo "Error: --category requires <name>"
        exit 1
    fi
    
else
    # Global mode or interactive
    if [ -n "$1" ] && [ -n "$2" ]; then
        MODE="global"
        ORCHESTRATION_ARG="$1"
        DEEP_ARG="$2"
    elif [ -n "$1" ] || [ -n "$2" ]; then
        echo "Error: Global mode requires both orchestration and deep work models"
        show_help
    fi
fi

# ============ GLOBAL MODE ============
if [ "$MODE" = "global" ] || [ -z "$MODE" ]; then
    # Resolve or interactive
    if [ "$MODE" = "global" ]; then
        ORCHESTRATION=$(resolve_model "$ORCHESTRATION_ARG")
        DEEP_WORK=$(resolve_model "$DEEP_ARG")
        
        if [ -z "$ORCHESTRATION" ]; then
            echo "Error: Unknown model '$ORCHESTRATION_ARG'"
            exit 1
        fi
        if [ -z "$DEEP_WORK" ]; then
            echo "Error: Unknown model '$DEEP_ARG'"
            exit 1
        fi
        
        ORCHESTRATION_NAME="$ORCHESTRATION_ARG"
        DEEP_NAME="$DEEP_ARG"
    else
        # Interactive mode
        echo "=== Oh-My-OpenCode Model Switcher ==="
        echo ""
        echo "======================================================================"
        echo "SELECTION 1: Orchestration Model (Sisyphus-type agents)"
        echo "======================================================================"
        echo "For: sisyphus, oracle, explore, prometheus, metis, momus, atlas"
        echo "Categories: quick, writing, unspecified-low, unspecified-high, visual-engineering"
        echo "NOTE: librarian, multimodal-looker are EXCLUDED (use fine-grained mode)"
        echo ""
        print_model_menu
        echo ""
        echo -n "Select orchestration model (1-12) [default: current]: "
        read -r choice
        
        if [ -n "$choice" ]; then
            ORCHESTRATION=$(get_model_by_number "$choice")
            ORCHESTRATION_NAME=$(get_model_name "$ORCHESTRATION")
        else
            # Keep current - need to read from config
            ORCHESTRATION=$(python3 -c "
import json
with open('$CONFIG_FILE') as f:
    print(json.load(f)['agents'].get('sisyphus', {}).get('model', ''))
")
            ORCHESTRATION_NAME=$(get_model_name "$ORCHESTRATION")
        fi
        
        echo ""
        echo "======================================================================"
        echo "SELECTION 2: Deep Work Model (Hephaestus-type agents)"
        echo "======================================================================"
        echo "For: hephaestus"
        echo "Categories: ultrabrain, deep"
        echo ""
        print_model_menu
        echo ""
        echo -n "Select deep work model (1-12) [default: current]: "
        read -r choice
        
        if [ -n "$choice" ]; then
            DEEP_WORK=$(get_model_by_number "$choice")
            DEEP_NAME=$(get_model_name "$DEEP_WORK")
        else
            DEEP_WORK=$(python3 -c "
import json
with open('$CONFIG_FILE') as f:
    print(json.load(f)['agents'].get('hephaestus', {}).get('model', ''))
")
            DEEP_NAME=$(get_model_name "$DEEP_WORK")
        fi
        
        echo ""
        echo "Orchestration: $ORCHESTRATION_NAME"
        echo "Deep Work: $DEEP_NAME"
    fi

    echo ""
    echo "Applying..."
    
    # Backup
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak.$(date +%Y%m%d_%H%M%S)"
    
    # Apply using Python
    python3 << PYTHON
import json

with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)

orchestration = '$ORCHESTRATION'
deep_work = '$DEEP_WORK'

# Agents for orchestration
orch_agents = ['sisyphus', 'oracle', 'explore', 'prometheus', 'metis', 'momus', 'atlas']
for agent in orch_agents:
    if agent in config['agents']:
        config['agents'][agent]['model'] = orchestration

# Categories for orchestration
orch_cats = ['quick', 'writing', 'unspecified-low', 'unspecified-high', 'visual-engineering']
for cat in orch_cats:
    if cat in config['categories']:
        config['categories'][cat]['model'] = orchestration

# Hephaestus for deep work
config['agents']['hephaestus']['model'] = deep_work

# Categories for deep work
deep_cats = ['ultrabrain', 'deep']
for cat in deep_cats:
    if cat in config['categories']:
        config['categories'][cat]['model'] = deep_work

# librarian and multimodal-looker EXCLUDED in global mode

with open('$CONFIG_FILE', 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')

print("Config updated!")
print(f"Orchestration: $ORCHESTRATION_NAME")
print(f"Deep Work: $DEEP_NAME")
print("")
print("NOTE: librarian and multimodal-looker unchanged in global mode")
PYTHON

    echo ""
    echo "Backup saved to: $CONFIG_FILE.bak.*"
    echo "Restart OpenCode to apply changes."
    exit 0
fi

# ============ FINE-GRAINED MODE ============
if [ "$MODE" = "agent" ]; then
    # Validate agent
    if ! echo "$VALID_AGENTS" | grep -qw "$AGENT_NAME"; then
        echo "Error: Invalid agent '$AGENT_NAME'"
        echo "Valid agents: $VALID_AGENTS"
        exit 1
    fi
    
    # Interactive or resolve model
    if [ -z "$MODEL_ARG" ]; then
        echo "=== Set Agent: $AGENT_NAME ==="
        current=$(python3 -c "
import json
with open('$CONFIG_FILE') as f:
    print(json.load(f)['agents'].get('$AGENT_NAME', {}).get('model', ''))
")
        echo "Current: $current"
        print_model_menu
        echo ""
        echo -n "Select model (1-12) [default: current]: "
        read -r choice
        
        if [ -n "$choice" ]; then
            SELECTED_MODEL=$(get_model_by_number "$choice")
            SELECTED_NAME=$(get_model_name "$SELECTED_MODEL")
        else
            SELECTED_MODEL="$current"
            SELECTED_NAME=$(get_model_name "$SELECTED_MODEL")
        fi
        
        # Fallback
        if [ -n "$FALLBACK_MODEL" ]; then
            FALLBACK=$(resolve_model "$FALLBACK_MODEL")
        else
            echo ""
            echo -n "Set fallback model? (1-12) or enter to skip: "
            read -r fb_choice
            if [ -n "$fb_choice" ]; then
                FALLBACK=$(get_model_by_number "$fb_choice")
            fi
        fi
    else
        SELECTED_MODEL=$(resolve_model "$MODEL_ARG")
        SELECTED_NAME="$MODEL_ARG"
        if [ -z "$SELECTED_MODEL" ]; then
            echo "Error: Unknown model '$MODEL_ARG'"
            exit 1
        fi
        if [ -n "$FALLBACK_MODEL" ]; then
            FALLBACK=$(resolve_model "$FALLBACK_MODEL")
        fi
    fi
    
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak.$(date +%Y%m%d_%H%M%S)"
    
    python3 << PYTHON
import json
with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)

config['agents']['$AGENT_NAME']['model'] = '$SELECTED_MODEL'
$([ -n "$FALLBACK" ] && echo "config['agents']['$AGENT_NAME']['fallback'] = '$FALLBACK'")

with open('$CONFIG_FILE', 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')

print("Updated agent: $AGENT_NAME -> $SELECTED_NAME")
$([ -n "$FALLBACK" ] && echo "Fallback: $FALLBACK")
PYTHON

    echo "Restart OpenCode to apply changes."
    exit 0
fi

if [ "$MODE" = "category" ]; then
    # Validate category
    if ! echo "$VALID_CATEGORIES" | grep -qw "$CATEGORY_NAME"; then
        echo "Error: Invalid category '$CATEGORY_NAME'"
        echo "Valid categories: $VALID_CATEGORIES"
        exit 1
    fi
    
    # Interactive or resolve model
    if [ -z "$MODEL_ARG" ]; then
        echo "=== Set Category: $CATEGORY_NAME ==="
        current=$(python3 -c "
import json
with open('$CONFIG_FILE') as f:
    print(json.load(f)['categories'].get('$CATEGORY_NAME', {}).get('model', ''))
")
        echo "Current: $current"
        print_model_menu
        echo ""
        echo -n "Select model (1-12) [default: current]: "
        read -r choice
        
        if [ -n "$choice" ]; then
            SELECTED_MODEL=$(get_model_by_number "$choice")
            SELECTED_NAME=$(get_model_name "$SELECTED_MODEL")
        else
            SELECTED_MODEL="$current"
            SELECTED_NAME=$(get_model_name "$SELECTED_MODEL")
        fi
        
        # Fallback
        if [ -n "$FALLBACK_MODEL" ]; then
            FALLBACK=$(resolve_model "$FALLBACK_MODEL")
        else
            echo ""
            echo -n "Set fallback model? (1-12) or enter to skip: "
            read -r fb_choice
            if [ -n "$fb_choice" ]; then
                FALLBACK=$(get_model_by_number "$fb_choice")
            fi
        fi
    else
        SELECTED_MODEL=$(resolve_model "$MODEL_ARG")
        SELECTED_NAME="$MODEL_ARG"
        if [ -z "$SELECTED_MODEL" ]; then
            echo "Error: Unknown model '$MODEL_ARG'"
            exit 1
        fi
        if [ -n "$FALLBACK_MODEL" ]; then
            FALLBACK=$(resolve_model "$FALLBACK_MODEL")
        fi
    fi
    
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak.$(date +%Y%m%d_%H%M%S)"
    
    python3 << PYTHON
import json
with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)

config['categories']['$CATEGORY_NAME']['model'] = '$SELECTED_MODEL'
$([ -n "$FALLBACK" ] && echo "config['categories']['$CATEGORY_NAME']['fallback'] = '$FALLBACK'")

with open('$CONFIG_FILE', 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')

print("Updated category: $CATEGORY_NAME -> $SELECTED_NAME")
$([ -n "$FALLBACK" ] && echo "Fallback: $FALLBACK")
PYTHON

    echo "Restart OpenCode to apply changes."
    exit 0
fi

if [ "$MODE" = "agents-fallback" ]; then
    if [ -z "$MODEL_ARG" ]; then
        print_model_menu
        echo ""
        echo -n "Select fallback for all agents: "
        read -r choice
        FALLBACK=$(get_model_by_number "$choice")
    else
        FALLBACK=$(resolve_model "$MODEL_ARG")
    fi
    
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak.$(date +%Y%m%d_%H%M%S)"
    
    python3 << PYTHON
import json
with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)

for agent in config['agents']:
    if 'fallback' in config['agents'][agent]:
        config['agents'][agent]['fallback'] = '$FALLBACK'

with open('$CONFIG_FILE', 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')

print("Updated fallback for all agents: $FALLBACK")
PYTHON

    echo "Restart OpenCode to apply changes."
    exit 0
fi

if [ "$MODE" = "categories-fallback" ]; then
    if [ -z "$MODEL_ARG" ]; then
        print_model_menu
        echo ""
        echo -n "Select fallback for all categories: "
        read -r choice
        FALLBACK=$(get_model_by_number "$choice")
    else
        FALLBACK=$(resolve_model "$MODEL_ARG")
    fi
    
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak.$(date +%Y%m%d_%H%M%S)"
    
    python3 << PYTHON
import json
with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)

for cat in config['categories']:
    if 'fallback' in config['categories'][cat]:
        config['categories'][cat]['fallback'] = '$FALLBACK'

with open('$CONFIG_FILE', 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')

print("Updated fallback for all categories: $FALLBACK")
PYTHON

    echo "Restart OpenCode to apply changes."
    exit 0
fi
