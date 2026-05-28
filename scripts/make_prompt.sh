#!/bin/bash

# 1. Parameter and Flag Routing Check
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 <ai_name> [topic]" >&2
    echo "Supported AI names: gemini, claude, chatgpt" >&2
    exit 1
fi

# Assign and normalize AI name selection flag
ai_name=$(echo "$1" | tr '[:upper:]' '[:lower:]')

# 2. Assign Platform Scale Variables Based on AI Model Routing
case "$ai_name" in
    claude)
        default_temperature="0.5"
        default_top_p="0.7"
        default_max_tokens="8192"
        default_model="claude-3-5-sonnet-latest"
        ;;
    gemini)
        default_temperature="0.7"
        default_top_p="0.95"
        default_max_tokens="4096"
        default_model="gemini-1.5-pro-latest"
        ;;
    chatgpt)
        default_temperature="0.7"
        default_top_p="0.9"
        default_max_tokens="4096"
        default_model="gpt-4o"
        ;;
    *)
        echo "Error: Unsupported AI platform '$ai_name'." >&2
        echo "Please use: gemini, claude, or chatgpt" >&2
        exit 4
        ;;
esac

# 3. Interactive Fallback for Parameter Topic
input_topic="$2"
if [[ -z "$input_topic" ]]; then
    read -r -p "Enter the target topic name: " input_topic
fi

# 4. Sanitization of Topic String
sanitized_topic=$(echo "$input_topic" | tr -cd '[:alnum:][:space:]_-')
topic=$(echo "$sanitized_topic" | tr -s '[:space:]' '-' | tr ' ' '-' | tr -s '-' | tr '[:upper:]' '[:lower:]')

if [[ -z "$topic" ]]; then
    echo "Error: Topic contains invalid characters only." >&2
    exit 3
fi

# 5. Convert Hyphens to Title Case Spaces (Universal Fix)
# Replaced sed with awk to guarantee cross-platform macOS/Linux compatibility without GNU bugs
formatted_title=$(echo "$topic" | tr '-' ' ' | awk '{
    for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));
    print
}')

# File-system Environment Setups
parent_dir="prompts"
target_dir="$parent_dir/$ai_name"
current_date="$(date +%Y%m%d)"
history_file="$parent_dir/.generation_history.md"

# 6. Writable Check 
if [[ -d "$parent_dir" ]]; then
    if [[ ! -w "$parent_dir" ]]; then
        echo "Error: Target directory '$parent_dir' is not writable." >&2
        exit 1
    fi
else
    if [[ ! -w "." ]]; then
        echo "Error: Current working directory is not writable. Cannot create '$parent_dir'." >&2
        exit 1
    fi
fi

# 7. Target Directory Creation
if ! mkdir -p "$target_dir"; then
    echo "Error: Directory creation failed." >&2
    exit 2
fi

# 8. Same-Day Duplicate Check
existing_match=$(find "$target_dir" -maxdepth 1 -name "${topic}-${current_date}-*.adoc" -print -quit)

if [[ -n "$existing_match" ]]; then
    echo "Warning: A prompt for '$topic' was already generated today for $ai_name:" >&2
    echo "  -> $existing_match" >&2
    read -r -p "Do you still want to create a duplicate version? (y/N): " confirm_dup
    if [[ ! "$confirm_dup" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled. Exiting without changes."
        exit 0
    fi
fi

# 9. Unique Filename Loop
while :; do
    printf -v filename "%s/%s-%s-%s-%04d.adoc" "$target_dir" "$topic" "$current_date" "$(date +%H%M%S)" $((RANDOM % 10000))
    [[ ! -e "$filename" ]] && break
done

# 10. File Initialization with Platform-Scaled Variables
cat << EOF > "$filename"
= Prompt: $formatted_title
:author: AI Assistant ($ai_name)
:date: $(date +%Y-%m-%d)
:description: System prompt and configuration template for $formatted_title.
:toc:
// AI Model Configurations
:model-version: $default_model
:temperature: $default_temperature
:top-p: $default_top_p
:max-tokens: $default_max_tokens
:system-version: 1.0.0

== Model Metadata
[horizontal]
*Model Name*:: $ai_name ({model-version})
*Temperature*:: {temperature}
*Top P*:: {top-p}
*Max Tokens*:: {max-tokens}

== System Role
You are an expert research assistant specialized in $formatted_title.

== Context & Constraints
* Objective: Define the core goal.
* Constraints: List boundaries and limitations here.
* Style/Tone: Professional, direct, and concise.

== Instructions
1. Step one of the execution process.
2. Step two of the execution process.

== Expected Output Format
Describe or show a template of how the AI should format its final response.
EOF

# 11. Strict Permissions Enforced
chmod 600 "$filename"

# 12. Scale Metric Computations (Size and Cross-Platform MD5 Hash)
file_size=$(wc -c < "$filename" | tr -d '[:space:]')

if command -v md5sum >/dev/null 2>&1; then
    file_hash=$(md5sum "$filename" | awk '{print $1}')
elif command -v md5 >/dev/null 2>&1; then
    file_hash=$(md5 -q "$filename")
else
    file_hash="unknown"
fi

# 13. Log Creation to Hidden History File with Scale Metadata
if [[ ! -f "$history_file" ]]; then
    echo "# Prompt Generation History" > "$history_file"
fi
echo "- [$(date '+%Y-%m-%d %H:%M:%S')] Created \`$filename\` ($ai_name) | Topic: *$formatted_title* | Size: \`${file_size}B\` | MD5: \`${file_hash}\`" >> "$history_file"

# 14. Path Confirmation
echo "$filename"

# 15. Automatic Text Editor Hand-off
EDITOR="${EDITOR:-nano}"
if command -v "$EDITOR" >/dev/null 2>&1; then
    exec "$EDITOR" "$filename"
else
    echo "Warning: Defined editor '$EDITOR' not found. File created successfully." >&2
fi
