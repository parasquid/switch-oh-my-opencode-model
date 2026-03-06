# switch-oh-my-opencode-model

A model switcher script for [Oh-My-OpenCode](https://github.com/code-yeongyu/oh-my-opencode) that lets you easily switch between different AI models for your coding agents.

## Features

- **Two selection modes**: 
  - **Global Mode**: Change orchestration + deep work models at once
  - **Fine-grained Mode**: Set individual agents or categories
- **Fallback support**: Set fallback models for agents and categories
- **Interactive menu**: Easy selection if you don't want CLI arguments
- **Multiple providers support**: Works with OpenCode Zen, OpenCode Go, Modal, OpenAI, and OpenRouter
- **Automatic backup**: Creates timestamped backups before making changes
- **Always-excluded in global mode**: librarian and multimodal-looker keep their defaults (but can be changed in fine-grained mode)

## Installation

### One-liner (recommended)

```bash
mkdir -p "$HOME/bin" && curl -fsSL "https://raw.githubusercontent.com/parasquid/switch-oh-my-opencode-model/main/switch-model.sh" -o "$HOME/bin/switch-model.sh" && chmod +x "$HOME/bin/switch-model.sh"
```

### Manual

1. Download the script:
   ```bash
   mkdir -p "$HOME/bin"
   curl -fsSL "https://raw.githubusercontent.com/parasquid/switch-oh-my-opencode-model/main/switch-model.sh" -o "$HOME/bin/switch-model.sh"
   ```

2. Make it executable:
   ```bash
   chmod +x "$HOME/bin/switch-model.sh"
   ```

3. Add `$HOME/bin` to your PATH if needed:
   ```bash
   export PATH="$HOME/bin:$PATH"  # Add to your ~/.bashrc or ~/.zshrc
   ```

## Usage

### Interactive Mode

Simply run the script without arguments:

```bash
switch-model.sh
```

You'll be prompted to select:
1. **Orchestration Model** - for Sisyphus-type agents
2. **Deep Work Model** - for Hephaestus-type agents

The prompt now shows the current model name and model ID for each selection.

Press Enter to keep the current selection.

---

### Global Mode (Quick Switch)

Change orchestration + deep work models at once:

```bash
switch-model.sh <orchestration_model> <deep_work_model>
```

Examples:
```bash
switch-model.sh kimi-zen codex-5.3
switch-model.sh glm5-go codex-5.3
switch-model.sh minimax-zen codex-5.3
```

---

### Fine-Grained Mode (Agent/Category Specific)

Set specific agents or categories:

```bash
# Set specific agent
switch-model.sh --agent sisyphus kimi-zen
switch-model.sh --agent hephaestus codex-5.3

# Set specific agent with fallback
switch-model.sh --agent sisyphus kimi-zen --fallback glm5-zen

# Set specific category
switch-model.sh --category deep codex-5.3
switch-model.sh --category ultrabrain codex-5.3

# Set specific category with fallback
switch-model.sh --category deep codex-5.3 --fallback kimi-zen

# Set fallback for all agents
switch-model.sh --agents-fallback kimi-zen

# Set fallback for all categories
switch-model.sh --categories-fallback kimi-zen
```

---

### Help

```bash
switch-model.sh --help
```

## Available Models

| Option | Model ID | Provider |
|--------|----------|----------|
| kimi-zen | opencode/kimi-k2.5-free | OpenCode Zen |
| kimi-go | opencode-go/kimi-k2.5 | OpenCode Go |
| glm5-modal | modal/zai-org/GLM-5-FP8 | Modal |
| glm5-zen | opencode/glm-5-free | OpenCode Zen |
| glm5-go | opencode-go/glm-5 | OpenCode Go |
| minimax-zen | opencode/minimax-m2.5-free | OpenCode Zen |
| minimax-go | opencode-go/minimax-m2.5 | OpenCode Go |
| codex-5.3 | openai/gpt-5.3-codex | OpenAI |
| gpt-5.4-thinking | openai/gpt-5.4-thinking | OpenAI |
| gpt-5-nano | opencode/gpt-5-nano | OpenCode Zen |
| nvidia-vl | openrouter/nvidia/nemotron-nano-12b-v2-vl:free | OpenRouter |

## Understanding the Two Selections

### Selection 1: Orchestration Model (Sisyphus-type agents)

These agents handle coordination, communication, and delegation:

| Agent | Description |
|-------|-------------|
| sisyphus | Main coder, orchestrates other agents |
| oracle | Reasoning/consultation |
| explore | Fast search/grep |
| prometheus | Planning |
| metis | Analysis |
| momus | Review/feedback |
| atlas | Architecture |

**Categories using orchestration model:**
- `quick` - Fast tasks
- `writing` - Documentation
- `unspecified-low` - Low effort tasks
- `unspecified-high` - High effort tasks
- `visual-engineering` - UI/Frontend work

**Recommended models:** kimi-zen, kimi-go, glm5-zen, glm5-go, minimax-zen, minimax-go

---

### Selection 2: Deep Work Model (Hephaestus-type agents)

These agents handle intensive coding tasks:

| Agent | Description |
|-------|-------------|
| hephaestus | Deep autonomous work |

**Categories using deep work model:**
- `ultrabrain` - Hard logic problems
- `deep` - Thorough research

**Recommended models:** codex-5.3, gpt-5.4-thinking (but you can use any model if quota runs out)

> **Note:** Per OMO documentation, Hephaestus is designed exclusively for GPT/Codex models. However, if your Codex quota runs out, you can use kimi/glm/minimax as fallback.

---

## Excluded in Global Mode

These agents are **not affected** in global mode (but can be changed in fine-grained mode):

| Agent | Default Model | Reason |
|-------|--------------|--------|
| librarian | gpt-5-nano | Large context for documentation |
| multimodal-looker | nvidia-vl | Vision tasks |

## Updating

To update to the latest version:

```bash
mkdir -p "$HOME/bin" && curl -fsSL "https://raw.githubusercontent.com/parasquid/switch-oh-my-opencode-model/main/switch-model.sh" -o "$HOME/bin/switch-model.sh" && chmod +x "$HOME/bin/switch-model.sh"
```

Or if you cloned the repo:

```bash
cd ~/Documents/parasquid/switch-oh-my-opencode-model
git pull origin main
```

## Configuration

### Config File Location

By default, the script uses:
```
~/.config/opencode/oh-my-opencode.json
```

You can override this with the `CONFIG_FILE` environment variable:
```bash
CONFIG_FILE=/custom/path/config.json switch-model.sh kimi-zen codex-5.3
```

### Auto-Creation

If the config file doesn't exist, the script automatically creates one with sensible defaults for all agents and categories. No manual setup required!

---

## Testing

This project includes comprehensive bats-core unit tests.

### Running Tests

```bash
# Run all tests
bats tests/

# Run specific test file
bats tests/test_model_resolution.bats

# Run with verbose output
bats -v tests/
```

### Test Coverage

- **Model Resolution**: 45 tests for all 11 models and aliases
- **Argument Parsing**: 26 tests for CLI arguments and modes
- **Config Operations**: 15 tests for backup and modifications

### Installing bats-core

```bash
# macOS
brew install bats-core

# Linux (npm)
npm install -g bats

# Ubuntu/Debian
sudo apt-get install bats
```

---

## Requirements

- Bash
- Python 3 (for JSON parsing)
- Oh-My-OpenCode installed and configured
- `curl` (for install/update commands)
- `bats-core` (optional, for running tests)

## Known Issues

### OMO v3.9.0 Duplicate Agent Display Bug

**Symptom:** The UI shows duplicate entries for agents, such as "Prometheus" and "Prometheus (Plan Builder)".

**Root cause:** OMO commit `df02c73` changed name remapping and retained both original keys and display names.

**Workaround:** Pin to OMO `v3.8.5` by specifying the exact version in your configuration:
```json
"plugin": ["oh-my-opencode@3.8.5"]
```

**Related Issues:**
- https://github.com/code-yeongyu/oh-my-opencode/issues/2163
- https://github.com/code-yeongyu/oh-my-opencode/issues/2180

**Evidence:**
- Upstream regression fix commit that retained both key and display-name mappings: https://github.com/code-yeongyu/oh-my-opencode/commit/df02c73a547b4cea22e49ab0428474e832f5297f
- User reports demonstrating duplicate agent entries in the selector: https://github.com/code-yeongyu/oh-my-opencode/issues/2163 and https://github.com/code-yeongyu/oh-my-opencode/issues/2180

## License

GNU GPL v3.0

## Credits

- [Oh-My-OpenCode](https://github.com/code-yeongyu/oh-my-opencode) - The amazing multi-model agent orchestration system
- Model requirements based on [OMO documentation](https://github.com/code-yeongyu/oh-my-opencode/blob/dev/src/shared/model-requirements.ts)
