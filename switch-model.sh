#!/bin/bash
#
# switch-model.sh - Oh-My-OpenCode model switcher
#
# =============================================================================
# AVAILABLE MODELS:
# =============================================================================
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
#   mkdir -p "$HOME/bin"
#   curl -fsSL "https://raw.githubusercontent.com/parasquid/switch-oh-my-opencode-model/main/switch-model.sh" -o "$HOME/bin/switch-model.sh"
#   chmod +x "$HOME/bin/switch-model.sh"
#
# UPDATE:
#   mkdir -p "$HOME/bin"
#   curl -fsSL "https://raw.githubusercontent.com/parasquid/switch-oh-my-opencode-model/main/switch-model.sh" -o "$HOME/bin/switch-model.sh"
#   chmod +x "$HOME/bin/switch-model.sh"
#

CONFIG_FILE="${CONFIG_FILE:-$HOME/.config/opencode/oh-my-opencode.json}"
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    SWITCH_MODEL_SOURCED=1
else
    SWITCH_MODEL_SOURCED=0
fi
# =============================================================================
# AGENT AND CATEGORY DEFINITIONS - Single Source of Truth
# =============================================================================
readonly VALID_AGENTS="sisyphus oracle explore prometheus metis momus atlas hephaestus librarian multimodal-looker"
readonly VALID_CATEGORIES="ultrabrain deep artistry quick writing unspecified-low unspecified-high visual-engineering"
readonly ORCH_AGENTS="sisyphus oracle explore prometheus metis momus atlas"
readonly DEEP_AGENTS="hephaestus"
readonly GLOBAL_EXCLUDED_AGENTS="librarian multimodal-looker"
readonly ORCH_CATEGORIES="quick writing unspecified-low unspecified-high visual-engineering"
readonly DEEP_CATEGORIES="ultrabrain deep"


ensure_config_exists() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Config file not found. Creating default at $CONFIG_FILE..."
        mkdir -p "$(dirname "$CONFIG_FILE")"
        
        python3 << PYTHON
import json
import os

config = {
    "agents": {
        "sisyphus": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
        "oracle": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
        "explore": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
        "prometheus": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
        "metis": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
        "momus": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
        "atlas": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
        "hephaestus": {"model": "openai/gpt-5.3-codex", "fallback": ""},
        "librarian": {"model": "opencode/gpt-5-nano", "fallback": ""},
        "multimodal-looker": {"model": "openrouter/nvidia/nemotron-nano-12b-v2-vl:free", "fallback": ""}
    },
    "categories": {
        "ultrabrain": {"model": "openai/gpt-5.3-codex", "fallback": "opencode/kimi-k2.5-free"},
        "deep": {"model": "openai/gpt-5.3-codex", "fallback": "opencode/kimi-k2.5-free"},
        "artistry": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
        "quick": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
        "writing": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
        "unspecified-low": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
        "unspecified-high": {"model": "opencode/kimi-k2.5-free", "fallback": ""},
        "visual-engineering": {"model": "opencode/kimi-k2.5-free", "fallback": ""}
    }
}

os.makedirs(os.path.dirname('$CONFIG_FILE'), exist_ok=True)
with open('$CONFIG_FILE', 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')

print("Default config created!")
PYTHON
    fi
}

# Ensure config exists
ensure_config_exists

# Model mappings
KIMI_ZEN="opencode/kimi-k2.5-free"
KIMI_GO="opencode-go/kimi-k2.5"
GLM5_MODAL="modal/zai-org/GLM-5-FP8"
GLM5_ZEN="opencode/glm-5-free"
GLM5_GO="opencode-go/glm-5"
MINIMAX_ZEN="opencode/minimax-m2.5-free"
MINIMAX_GO="opencode-go/minimax-m2.5"
CODEX_53="openai/gpt-5.3-codex"
GPT_54_THINKING="openai/gpt-5.4-thinking"
GPT_NANO="opencode/gpt-5-nano"
NVIDIA_VL="openrouter/nvidia/nemotron-nano-12b-v2-vl:free"

readonly DYNAMIC_PROVIDERS="opencode opencode-go openai"
readonly STATIC_MODEL_IDS="$GLM5_MODAL $NVIDIA_VL"
readonly LEGACY_MODEL_ORDER="$KIMI_ZEN $KIMI_GO $GLM5_MODAL $GLM5_ZEN $GLM5_GO $MINIMAX_ZEN $MINIMAX_GO $CODEX_53 $GPT_54_THINKING $GPT_NANO $NVIDIA_VL"

declare -a MODEL_MENU_IDS=()
declare -a MODEL_MENU_ALIASES=()
declare -A MODEL_ALIAS_TO_ID=()
declare -A MODEL_ID_TO_ALIAS=()

# Validation uses consolidated readonly variables from top of script

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
  - Dynamic at runtime: all available opencode, opencode-go, and openai models
  - Static: glm5-modal, nvidia-vl
  - Hidden automatically: unavailable provider models, ollama-cloud catalog

NOTE: In global mode, librarian and multimodal-looker are EXCLUDED (keep defaults).
      Use fine-grained mode to modify them.
HELP
}

normalize_alias() {
    local value="$1"

    value=$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]' | tr './:_' '-' | tr -cd 'a-z0-9-')
    while [[ "$value" == *--* ]]; do
        value=${value//--/-}
    done

    value=${value#-}
    value=${value%-}
    printf '%s\n' "$value"
}

get_known_alias_for_model() {
    case "$1" in
        "$KIMI_ZEN") echo "kimi-zen" ;;
        "$KIMI_GO") echo "kimi-go" ;;
        "$GLM5_MODAL") echo "glm5-modal" ;;
        "$GLM5_ZEN") echo "glm5-zen" ;;
        "$GLM5_GO") echo "glm5-go" ;;
        "$MINIMAX_ZEN") echo "minimax-zen" ;;
        "$MINIMAX_GO") echo "minimax-go" ;;
        "$CODEX_53") echo "codex-5.3" ;;
        "$GPT_54_THINKING") echo "gpt-5.4-thinking" ;;
        "$GPT_NANO") echo "gpt-5-nano" ;;
        "$NVIDIA_VL") echo "nvidia-vl" ;;
        *) echo "" ;;
    esac
}

get_known_model_id_for_alias() {
    case "$1" in
        kimi-zen|kimi|kimi-k2.5|kimi-k2.5-free) echo "$KIMI_ZEN" ;;
        kimi-go|kimi-k2.5-go) echo "$KIMI_GO" ;;
        glm5-modal|glm-5-modal|glm5) echo "$GLM5_MODAL" ;;
        glm5-zen|glm-5-zen) echo "$GLM5_ZEN" ;;
        glm5-go|glm-5-go) echo "$GLM5_GO" ;;
        minimax-zen|minimax|minimax-m2.5|minimax-m2.5-free) echo "$MINIMAX_ZEN" ;;
        minimax-go|minimax-m2.5-go) echo "$MINIMAX_GO" ;;
        codex-5.3|codex|gpt-5.3-codex) echo "$CODEX_53" ;;
        gpt-5.4-thinking|gpt-5.4|gpt-5.4-think) echo "$GPT_54_THINKING" ;;
        gpt-5-nano|gpt-nano|nano) echo "$GPT_NANO" ;;
        nvidia-vl|nvidia|nemotron) echo "$NVIDIA_VL" ;;
        *) echo "" ;;
    esac
}

derive_dynamic_alias() {
    local model_id="$1"
    local provider="${model_id%%/*}"
    local model_name="${model_id#*/}"
    local known_alias

    known_alias=$(get_known_alias_for_model "$model_id")
    if [ -n "$known_alias" ]; then
        printf '%s\n' "$known_alias"
        return
    fi

    case "$provider" in
        opencode-go)
            printf '%s-go\n' "$(normalize_alias "$model_name")"
            ;;
        opencode)
            printf '%s\n' "$(normalize_alias "$model_name")"
            ;;
        openai)
            printf '%s\n' "$(normalize_alias "$model_name")"
            ;;
        *)
            printf '%s\n' "$(normalize_alias "$model_name")"
            ;;
    esac
}

make_unique_alias() {
    local alias="$1"
    local model_id="$2"
    local provider="$3"
    local base_alias="$alias"
    local counter=2

    if [ -z "$base_alias" ]; then
        base_alias=$(normalize_alias "$model_id")
    fi

    if [ -n "${MODEL_ALIAS_TO_ID[$base_alias]}" ] && [ "${MODEL_ALIAS_TO_ID[$base_alias]}" != "$model_id" ]; then
        case "$provider" in
            opencode)
                if [[ "$base_alias" != *-zen ]]; then
                    base_alias="${base_alias}-zen"
                fi
                ;;
            opencode-go)
                if [[ "$base_alias" != *-go ]]; then
                    base_alias="${base_alias}-go"
                fi
                ;;
            openai)
                if [[ "$base_alias" != openai-* ]]; then
                    base_alias="openai-${base_alias}"
                fi
                ;;
        esac
    fi

    alias="$base_alias"
    while [ -n "${MODEL_ALIAS_TO_ID[$alias]}" ] && [ "${MODEL_ALIAS_TO_ID[$alias]}" != "$model_id" ]; do
        alias="${base_alias}-${counter}"
        counter=$((counter + 1))
    done

    printf '%s\n' "$alias"
}

register_model_option() {
    local model_id="$1"
    local alias="$2"
    local provider="${model_id%%/*}"

    [ -z "$model_id" ] && return

    if [ -n "${MODEL_ID_TO_ALIAS[$model_id]}" ]; then
        return
    fi

    if [ -z "$alias" ]; then
        alias=$(derive_dynamic_alias "$model_id")
    fi

    alias=$(make_unique_alias "$alias" "$model_id" "$provider")

    MODEL_MENU_IDS+=("$model_id")
    MODEL_MENU_ALIASES+=("$alias")
    MODEL_ALIAS_TO_ID["$alias"]="$model_id"
    MODEL_ID_TO_ALIAS["$model_id"]="$alias"
}

extract_free_opencode_model_ids() {
    python3 -c '
import json
import sys

def all_zero(value):
    if isinstance(value, dict):
        return all(all_zero(v) for v in value.values())
    if isinstance(value, list):
        return all(all_zero(v) for v in value)
    if isinstance(value, (int, float)):
        return value == 0
    return True

current_model = None
json_lines = []
depth = 0

for raw_line in sys.stdin:
    line = raw_line.rstrip("\n")
    stripped = line.strip()

    if not stripped:
        continue

    if depth == 0 and stripped.startswith("opencode/"):
        current_model = stripped
        json_lines = []
        continue

    if current_model is None:
        continue

    json_lines.append(line)
    depth += line.count("{") - line.count("}")

    if depth == 0 and json_lines:
        try:
            obj = json.loads("\n".join(json_lines))
        except json.JSONDecodeError:
            current_model = None
            json_lines = []
            continue

        if all_zero(obj.get("cost", {})):
            print(current_model)

        current_model = None
        json_lines = []
'
}

probe_provider_models() {
    local provider="$1"

    if ! command -v opencode >/dev/null 2>&1; then
        return 1
    fi

    if [ "$provider" = "opencode" ]; then
        opencode models "$provider" --verbose 2>/dev/null | extract_free_opencode_model_ids
        return
    fi

    opencode models "$provider" 2>/dev/null
}

build_model_catalog() {
    local output
    local model_id
    local preferred_id
    local -A dynamic_ids=()

    MODEL_MENU_IDS=()
    MODEL_MENU_ALIASES=()
    unset MODEL_ALIAS_TO_ID MODEL_ID_TO_ALIAS
    declare -gA MODEL_ALIAS_TO_ID=()
    declare -gA MODEL_ID_TO_ALIAS=()

    for provider in $DYNAMIC_PROVIDERS; do
        if output=$(probe_provider_models "$provider"); then
            while IFS= read -r model_id; do
                if [ -n "$model_id" ]; then
                    dynamic_ids["$model_id"]=1
                fi
            done < <(printf '%s\n' "$output" | sort -u)
        fi
    done

    for preferred_id in $LEGACY_MODEL_ORDER; do
        if [ -n "${dynamic_ids[$preferred_id]}" ] || [[ " $STATIC_MODEL_IDS " == *" $preferred_id "* ]]; then
            register_model_option "$preferred_id" "$(get_known_alias_for_model "$preferred_id")"
        fi
    done

    while IFS= read -r model_id; do
        [ -z "$model_id" ] && continue
        register_model_option "$model_id" ""
    done < <(printf '%s\n' "${!dynamic_ids[@]}" | sort)
}

resolve_model() {
    local input="$1"
    local known_id

    [ -z "$input" ] && {
        echo ""
        return
    }

    if [ -n "${MODEL_ALIAS_TO_ID[$input]}" ]; then
        echo "${MODEL_ALIAS_TO_ID[$input]}"
        return
    fi

    if [ -n "${MODEL_ID_TO_ALIAS[$input]}" ]; then
        echo "$input"
        return
    fi

    known_id=$(get_known_model_id_for_alias "$input")
    if [ -n "$known_id" ] && [ -n "${MODEL_ID_TO_ALIAS[$known_id]}" ]; then
        echo "$known_id"
        return
    fi

    echo ""
}

get_model_name() {
    local model_id="$1"
    local known_alias

    if [ -n "${MODEL_ID_TO_ALIAS[$model_id]}" ]; then
        echo "${MODEL_ID_TO_ALIAS[$model_id]}"
        return
    fi

    known_alias=$(get_known_alias_for_model "$model_id")
    if [ -n "$known_alias" ]; then
        echo "$known_alias"
        return
    fi

    echo "$model_id"
}

print_model_menu() {
    local index

    for index in "${!MODEL_MENU_IDS[@]}"; do
        printf ' %2d) %-18s - %s\n' "$((index + 1))" "${MODEL_MENU_ALIASES[$index]}" "${MODEL_MENU_IDS[$index]}"
    done
}

get_model_by_number() {
    local choice="$1"
    local index

    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo ""
        return
    fi

    index=$((choice - 1))
    if [ "$index" -lt 0 ] || [ "$index" -ge "${#MODEL_MENU_IDS[@]}" ]; then
        echo ""
        return
    fi

    echo "${MODEL_MENU_IDS[$index]}"
}

warn_if_model_unavailable() {
    local model_id="$1"
    local context_label="$2"

    if [ -n "$model_id" ] && [ -z "${MODEL_ID_TO_ALIAS[$model_id]}" ]; then
        echo "Warning: current ${context_label} model $(get_model_name "$model_id") ($model_id) is now unavailable."
    fi
}

if [ "$SWITCH_MODEL_SOURCED" = "1" ]; then
    return 0 2>/dev/null || exit 0
fi

# Verify config exists (should be created by ensure_config_exists)
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Failed to create config file at $CONFIG_FILE"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found at $CONFIG_FILE"
    exit 1
fi

build_model_catalog

# Parse arguments
MODE=""
AGENT_NAME=""
CATEGORY_NAME=""
FALLBACK_MODEL=""

# Handle --help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Check for flag-based args (fine-grained mode)
if [[ "$1" == "--"* ]]; then
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --agent)
                if [ $# -lt 2 ]; then
                    echo "Error: --agent requires <name>"
                    exit 1
                fi
                MODE="agent"
                AGENT_NAME="$2"
                shift 2
                ;;
            --category)
                if [ $# -lt 2 ]; then
                    echo "Error: --category requires <name>"
                    exit 1
                fi
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
                if [ $# -lt 2 ]; then
                    echo "Error: --fallback requires <model>"
                    exit 1
                fi
                FALLBACK_MODEL="$2"
                shift 2
                ;;
            -*)
                echo "Error: Unknown option $1"
                show_help
                exit 1
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
        exit 1
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
        CURRENT_ORCHESTRATION=$(python3 -c "
import json
with open('$CONFIG_FILE') as f:
    print(json.load(f)['agents'].get('sisyphus', {}).get('model', ''))
")
        CURRENT_ORCHESTRATION_NAME=$(get_model_name "$CURRENT_ORCHESTRATION")
        echo "Current: $CURRENT_ORCHESTRATION_NAME ($CURRENT_ORCHESTRATION)"
        warn_if_model_unavailable "$CURRENT_ORCHESTRATION" "orchestration"
        echo ""
        print_model_menu
        echo ""
        echo -n "Select orchestration model (1-${#MODEL_MENU_IDS[@]}) [default: current]: "
        read -r choice
        
        if [ -n "$choice" ]; then
            ORCHESTRATION=$(get_model_by_number "$choice")
            if [ -z "$ORCHESTRATION" ]; then
                echo "Error: Invalid selection '$choice'"
                exit 1
            fi
            ORCHESTRATION_NAME=$(get_model_name "$ORCHESTRATION")
        else
            ORCHESTRATION="$CURRENT_ORCHESTRATION"
            ORCHESTRATION_NAME="$CURRENT_ORCHESTRATION_NAME"
        fi
        
        echo ""
        echo "======================================================================"
        echo "SELECTION 2: Deep Work Model (Hephaestus-type agents)"
        echo "======================================================================"
        echo "For: hephaestus"
        echo "Categories: ultrabrain, deep"
        echo ""
        CURRENT_DEEP_WORK=$(python3 -c "
import json
with open('$CONFIG_FILE') as f:
    print(json.load(f)['agents'].get('hephaestus', {}).get('model', ''))
")
        CURRENT_DEEP_NAME=$(get_model_name "$CURRENT_DEEP_WORK")
        echo "Current: $CURRENT_DEEP_NAME ($CURRENT_DEEP_WORK)"
        warn_if_model_unavailable "$CURRENT_DEEP_WORK" "deep work"
        echo ""
        print_model_menu
        echo ""
        echo -n "Select deep work model (1-${#MODEL_MENU_IDS[@]}) [default: current]: "
        read -r choice
        
        if [ -n "$choice" ]; then
            DEEP_WORK=$(get_model_by_number "$choice")
            if [ -z "$DEEP_WORK" ]; then
                echo "Error: Invalid selection '$choice'"
                exit 1
            fi
            DEEP_NAME=$(get_model_name "$DEEP_WORK")
        else
            DEEP_WORK="$CURRENT_DEEP_WORK"
            DEEP_NAME="$CURRENT_DEEP_NAME"
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
orch_agents = "$ORCH_AGENTS".split()
for agent in orch_agents:
    if agent in config['agents']:
        config['agents'][agent]['model'] = orchestration

# Categories for orchestration
orch_cats = "$ORCH_CATEGORIES".split()
for cat in orch_cats:
    if cat in config['categories']:
        config['categories'][cat]['model'] = orchestration

# Hephaestus for deep work
config['agents']['hephaestus']['model'] = deep_work

# Categories for deep work
deep_cats = "$DEEP_CATEGORIES".split()
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
        echo "Current: $(get_model_name "$current") ($current)"
        warn_if_model_unavailable "$current" "agent"
        print_model_menu
        echo ""
        echo -n "Select model (1-${#MODEL_MENU_IDS[@]}) [default: current]: "
        read -r choice
        
        if [ -n "$choice" ]; then
            SELECTED_MODEL=$(get_model_by_number "$choice")
            if [ -z "$SELECTED_MODEL" ]; then
                echo "Error: Invalid selection '$choice'"
                exit 1
            fi
            SELECTED_NAME=$(get_model_name "$SELECTED_MODEL")
        else
            SELECTED_MODEL="$current"
            SELECTED_NAME=$(get_model_name "$SELECTED_MODEL")
        fi
        
        # Fallback
        if [ -n "$FALLBACK_MODEL" ]; then
            FALLBACK=$(resolve_model "$FALLBACK_MODEL")
            if [ -z "$FALLBACK" ]; then
                echo "Error: Unknown model '$FALLBACK_MODEL'"
                exit 1
            fi
        else
            echo ""
            echo -n "Set fallback model? (1-${#MODEL_MENU_IDS[@]}) or enter to skip: "
            read -r fb_choice
            if [ -n "$fb_choice" ]; then
                FALLBACK=$(get_model_by_number "$fb_choice")
                if [ -z "$FALLBACK" ]; then
                    echo "Error: Invalid selection '$fb_choice'"
                    exit 1
                fi
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
            if [ -z "$FALLBACK" ]; then
                echo "Error: Unknown model '$FALLBACK_MODEL'"
                exit 1
            fi
        fi
    fi
    
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak.$(date +%Y%m%d_%H%M%S)"
    
    python3 << PYTHON
import json
with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)

fallback = '$FALLBACK'
config['agents']['$AGENT_NAME']['model'] = '$SELECTED_MODEL'
if fallback:
    config['agents']['$AGENT_NAME']['fallback'] = fallback

with open('$CONFIG_FILE', 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')

print("Updated agent: $AGENT_NAME -> $SELECTED_NAME")
if fallback:
    print(f"Fallback: {fallback}")
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
        echo "Current: $(get_model_name "$current") ($current)"
        warn_if_model_unavailable "$current" "category"
        print_model_menu
        echo ""
        echo -n "Select model (1-${#MODEL_MENU_IDS[@]}) [default: current]: "
        read -r choice
        
        if [ -n "$choice" ]; then
            SELECTED_MODEL=$(get_model_by_number "$choice")
            if [ -z "$SELECTED_MODEL" ]; then
                echo "Error: Invalid selection '$choice'"
                exit 1
            fi
            SELECTED_NAME=$(get_model_name "$SELECTED_MODEL")
        else
            SELECTED_MODEL="$current"
            SELECTED_NAME=$(get_model_name "$SELECTED_MODEL")
        fi
        
        # Fallback
        if [ -n "$FALLBACK_MODEL" ]; then
            FALLBACK=$(resolve_model "$FALLBACK_MODEL")
            if [ -z "$FALLBACK" ]; then
                echo "Error: Unknown model '$FALLBACK_MODEL'"
                exit 1
            fi
        else
            echo ""
            echo -n "Set fallback model? (1-${#MODEL_MENU_IDS[@]}) or enter to skip: "
            read -r fb_choice
            if [ -n "$fb_choice" ]; then
                FALLBACK=$(get_model_by_number "$fb_choice")
                if [ -z "$FALLBACK" ]; then
                    echo "Error: Invalid selection '$fb_choice'"
                    exit 1
                fi
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
            if [ -z "$FALLBACK" ]; then
                echo "Error: Unknown model '$FALLBACK_MODEL'"
                exit 1
            fi
        fi
    fi
    
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak.$(date +%Y%m%d_%H%M%S)"
    
    python3 << PYTHON
import json
with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)

fallback = '$FALLBACK'
config['categories']['$CATEGORY_NAME']['model'] = '$SELECTED_MODEL'
if fallback:
    config['categories']['$CATEGORY_NAME']['fallback'] = fallback

with open('$CONFIG_FILE', 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')

print("Updated category: $CATEGORY_NAME -> $SELECTED_NAME")
if fallback:
    print(f"Fallback: {fallback}")
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
        if [ -z "$FALLBACK" ]; then
            echo "Error: Invalid selection '$choice'"
            exit 1
        fi
    else
        FALLBACK=$(resolve_model "$MODEL_ARG")
        if [ -z "$FALLBACK" ]; then
            echo "Error: Unknown model '$MODEL_ARG'"
            exit 1
        fi
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
        if [ -z "$FALLBACK" ]; then
            echo "Error: Invalid selection '$choice'"
            exit 1
        fi
    else
        FALLBACK=$(resolve_model "$MODEL_ARG")
        if [ -z "$FALLBACK" ]; then
            echo "Error: Unknown model '$MODEL_ARG'"
            exit 1
        fi
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
