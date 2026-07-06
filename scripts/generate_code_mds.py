import os
from pathlib import Path

# Paths
WORKSPACE_DIR = Path("/home/sijibomi/solana/guardian")
DOCS_CODE_DIR = WORKSPACE_DIR / "docs" / "code_reference"

# File types and their markdown syntax languages
LANG_MAPPING = {
    ".dart": "dart",
    ".rs": "rust",
    ".yaml": "yaml",
    ".yml": "yaml",
    ".toml": "toml",
    ".json": "json",
    ".sh": "bash",
    ".py": "python",
    ".txt": "text"
}

def main():
    print("🚀 Starting markdown code generator...")
    
    # Files to parse
    source_dirs = [
        WORKSPACE_DIR / "apps" / "backend" / "src",
        WORKSPACE_DIR / "apps" / "mobile" / "lib",
    ]
    
    # Specific root configuration files to also include
    config_files = [
        WORKSPACE_DIR / "codemagic.yaml",
        WORKSPACE_DIR / "render.yaml",
        WORKSPACE_DIR / "infrastructure" / "docker-compose.yml",
        WORKSPACE_DIR / "apps" / "admin_panel" / ".txt"
    ]
    
    generated_count = 0

    # 1. Parse directories
    for s_dir in source_dirs:
        if not s_dir.exists():
            print(f"⚠️ Source directory {s_dir} does not exist. Skipping.")
            continue
            
        for root, _, files in os.walk(s_dir):
            for file in files:
                file_path = Path(root) / file
                # Skip binary, temporary, or gitkeep files
                if file.startswith(".") or file_path.suffix not in LANG_MAPPING:
                    continue
                
                generate_md_for_file(file_path)
                generated_count += 1

    # 2. Parse individual config files
    for config_file in config_files:
        if config_file.exists():
            generate_md_for_file(config_file)
            generated_count += 1
            
    print(f"🎉 Successfully generated {generated_count} markdown code reference files inside: {DOCS_CODE_DIR}")

def generate_md_for_file(file_path: Path):
    relative_path = file_path.relative_to(WORKSPACE_DIR)
    
    # Read source file content
    try:
        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            code_content = f.read()
    except Exception as e:
        print(f"❌ Failed to read {file_path}: {e}")
        return

    # Determine markdown syntax language
    ext = file_path.suffix
    lang = LANG_MAPPING.get(ext, "text")

    # Define output markdown path under docs/code_reference
    # e.g., apps/mobile/lib/main.dart -> docs/code_reference/apps/mobile/lib/main.dart.md
    md_output_path = DOCS_CODE_DIR / relative_path.with_suffix(file_path.suffix + ".md")
    
    # Create parent directories if they don't exist
    md_output_path.parent.mkdir(parents=True, exist_ok=True)

    # Write the markdown file
    md_content = f"""# {file_path.name}

* **File Path:** `{relative_path}`
* **Type:** `{lang.upper()}`

---

```{lang}
{code_content}
```
"""
    try:
        with open(md_output_path, "w", encoding="utf-8") as f:
            f.write(md_content)
    except Exception as e:
        print(f"❌ Failed to write markdown for {file_path}: {e}")

if __name__ == "__main__":
    main()
