#!/bin/bash
# =============================================================================
# functions.sh - Extracted functions from switch-model.sh for testing
# =============================================================================

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

resolve_model() {
    case "$1" in
        kimi-zen|kimi|kimi-k2.5|kimi-k2.5-free)     echo "$KIMI_ZEN" ;;
        kimi-go|kimi-k2.5-go)                        echo "$KIMI_GO" ;;
        glm5-modal|glm-5-modal|glm5)                echo "$GLM5_MODAL" ;;
        glm5-zen|glm-5-zen)                         echo "$GLM5_ZEN" ;;
        glm5-go|glm-5-go)                           echo "$GLM5_GO" ;;
        minimax-zen|minimax|minimax-m2.5|minimax-m2.5-free) echo "$MINIMAX_ZEN" ;;
        minimax-go|minimax-m2.5-go)                  echo "$MINIMAX_GO" ;;
        codex-5.3|codex|gpt-5.3-codex)              echo "$CODEX_53" ;;
        gpt-5.4-thinking|gpt-5.4|gpt-5.4-think)     echo "$GPT_54_THINKING" ;;
        gpt-5-nano|gpt-nano|nano)                   echo "$GPT_NANO" ;;
        nvidia-vl|nvidia|nemotron)                   echo "$NVIDIA_VL" ;;
        *) echo "" ;;
    esac
}

get_model_name() {
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
        *) echo "$1" ;;
    esac
}

print_model_menu() {
    echo "  1) kimi-zen           - $KIMI_ZEN"
    echo "  2) kimi-go            - $KIMI_GO"
    echo "  3) glm5-modal         - $GLM5_MODAL"
    echo "  4) glm5-zen           - $GLM5_ZEN"
    echo "  5) glm5-go            - $GLM5_GO"
    echo "  6) minimax-zen        - $MINIMAX_ZEN"
    echo "  7) minimax-go         - $MINIMAX_GO"
    echo "  8) codex-5.3          - $CODEX_53"
    echo "  9) gpt-5.4-thinking   - $GPT_54_THINKING"
    echo " 10) gpt-5-nano         - $GPT_NANO"
    echo " 11) nvidia-vl          - $NVIDIA_VL"
}

get_model_by_number() {
    case "$1" in
        1) echo "$KIMI_ZEN" ;;
        2) echo "$KIMI_GO" ;;
        3) echo "$GLM5_MODAL" ;;
        4) echo "$GLM5_ZEN" ;;
        5) echo "$GLM5_GO" ;;
        6) echo "$MINIMAX_ZEN" ;;
        7) echo "$MINIMAX_GO" ;;
        8) echo "$CODEX_53" ;;
        9) echo "$GPT_54_THINKING" ;;
        10) echo "$GPT_NANO" ;;
        11) echo "$NVIDIA_VL" ;;
        *) echo "" ;;
    esac
}
