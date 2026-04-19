---
name: create-blueprint
description: Create a new kopye blueprint with blueprint.toml and template files. Use when creating a new project template, scaffolding a blueprint, or setting up a new template structure.
allowed-tools: Read Write Bash Glob Grep AskUserQuestion
---

# Kopye Blueprint Creator

Create a complete, functional blueprint for the kopye CLI tool. This skill helps you scaffold a new blueprint with all necessary files including blueprint.toml, template files, and directory structure.

## Process

### Step 1: Gather Information

Use the AskUserQuestion tool to collect the following information from the user:

1. **Blueprint name** (e.g., "rust-cli", "nextjs-app", "python-fastapi")
   - This will be the directory name and the key in blueprints.toml

2. **Blueprint type/language** (e.g., "Rust", "Node.js", "Python", "Go", "React", "Next.js", etc.)
   - This determines what template files to create

3. **Location** where to create the blueprint
   - Default to current directory if not specified
   - Should create the blueprint as a subdirectory

4. **Include in blueprints.toml?**
   - Ask if they want to update/create blueprints.toml in the parent directory
   - If yes, add an entry for this blueprint

### Step 2: Create Blueprint Structure

Based on the blueprint type, create an appropriate directory structure. Use these common patterns:

#### For Rust Projects
```
rust-cli/
├── blueprint.toml
├── Cargo.toml.tera
├── README.md.tera
├── .gitignore
└── src/
    └── main.rs.tera
```

#### For Node.js/TypeScript Projects
```
node-app/
├── blueprint.toml
├── package.json.tera
├── README.md.tera
├── .gitignore
├── tsconfig.json
└── src/
    └── index.ts.tera
```

#### For Python Projects
```
python-app/
├── blueprint.toml
├── pyproject.toml.tera
├── README.md.tera
├── .gitignore
└── src/
    └── main.py.tera
```

#### For Web Frameworks (React, Next.js, etc.)
```
nextjs-app/
├── blueprint.toml
├── package.json.tera
├── next.config.js.tera
├── README.md.tera
├── .gitignore
├── src/
│   ├── pages/
│   │   └── index.tsx.tera
│   └── components/
│       └── Layout.tsx.tera
└── public/
```

### Step 3: Generate blueprint.toml

Create a blueprint.toml with relevant questions for the project type. Include these common questions:

**Always include:**
```toml
[project_name]
type = "string"
help = "Name of your project"

[description]
type = "string"
help = "Brief description of the project"

[author]
type = "string"
help = "Author name"
```

**Add type-specific questions:**

For Rust:
```toml
[is_binary]
type = "bool"
help = "Is this a binary application (vs library)?"

[edition]
type = "string"
help = "Rust edition"
choices = ["2021", "2024"]
```

For Node.js/TypeScript:
```toml
[package_manager]
type = "string"
help = "Package manager to use"
choices = ["npm", "yarn", "pnpm", "bun"]

[use_typescript]
type = "bool"
help = "Use TypeScript?"
```

For Python:
```toml
[python_version]
type = "string"
help = "Python version"
choices = ["3.9", "3.10", "3.11", "3.12"]

[use_poetry]
type = "bool"
help = "Use Poetry for dependency management?"
```

For Web projects:
```toml
[include_tailwind]
type = "bool"
help = "Include Tailwind CSS?"

[use_typescript]
type = "bool"
help = "Use TypeScript?"

[include_eslint]
type = "bool"
help = "Include ESLint configuration?"
```

**Add feature flags (multiselect):**
```toml
[features]
type = "string"
help = "Select features to include"
choices = ["logging", "testing", "docker", "ci-cd"]
multiselect = true
```

### Step 4: Generate Template Files

Create template files appropriate for the project type. Use Tera syntax for dynamic content.

#### Example: Cargo.toml.tera (Rust)
```toml
[package]
name = "{{ project_name }}"
version = "0.1.0"
edition = "{{ edition }}"
authors = ["{{ author }}"]
description = "{{ description }}"

{% if is_binary %}
[[bin]]
name = "{{ project_name }}"
path = "src/main.rs"
{% else %}
[lib]
name = "{{ project_name }}"
path = "src/lib.rs"
{% endif %}

[dependencies]
{% if "logging" in features %}
log = "0.4"
env_logger = "0.11"
{% endif %}

{% if "testing" in features %}
[dev-dependencies]
criterion = "0.5"
{% endif %}
```

#### Example: package.json.tera (Node.js)
```json
{
  "name": "{{ project_name }}",
  "version": "0.1.0",
  "description": "{{ description }}",
  "author": "{{ author }}",
  {% if use_typescript %}
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  {% else %}
  "main": "src/index.js",
  {% endif %}
  "scripts": {
    {% if use_typescript %}
    "build": "tsc",
    "dev": "tsx watch src/index.ts",
    {% endif %}
    "start": "node {{ use_typescript | ternary('dist/index.js', 'src/index.js') }}"
  },
  "dependencies": {},
  "devDependencies": {
    {% if use_typescript %}
    "typescript": "^5.0.0",
    "tsx": "^4.0.0",
    "@types/node": "^20.0.0"{% if include_eslint %},{% endif %}
    {% endif %}
    {% if include_eslint %}
    "eslint": "^8.0.0",
    "@typescript-eslint/parser": "^7.0.0",
    "@typescript-eslint/eslint-plugin": "^7.0.0"
    {% endif %}
  }
}
```

#### Example: main.rs.tera (Rust)
```rust
{% if "logging" in features %}
use log::{info, warn, error};

{% endif %}
fn main() {
    {% if "logging" in features %}
    env_logger::init();
    info!("Starting {{ project_name }}");
    {% endif %}

    println!("Hello from {{ project_name }}!");

    {% if is_binary %}
    // Binary-specific code
    run_app();
    {% endif %}
}

{% if is_binary %}
fn run_app() {
    // Your application logic here
}
{% endif %}

{% if "testing" in features %}
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_basic() {
        assert_eq!(2 + 2, 4);
    }
}
{% endif %}
```

#### Example: README.md.tera
```markdown
# {{ project_name }}

{{ description }}

## Author

{{ author }}

## Installation

{% if package_manager is defined %}
{{ package_manager }} install
{% elif edition is defined %}
cargo build
{% endif %}

## Usage

{% if is_binary is defined and is_binary %}
cargo run
{% elif package_manager is defined %}
{{ package_manager }} start
{% endif %}

## Features

{% if features is defined %}
{% for feature in features %}
- {{ feature }}
{% endfor %}
{% endif %}

## License

MIT
```

### Step 5: Create Static Files

Create common static files that don't need templating:

#### .gitignore (varies by type)
```
# For Rust
target/
Cargo.lock

# For Node.js
node_modules/
dist/
.env

# For Python
__pycache__/
*.py[cod]
.venv/
```

#### Optional: Docker support
If "docker" is in features, create:

**Dockerfile.tera**
```dockerfile
FROM {{ image_base }}

WORKDIR /app

COPY . .

{% if package_manager is defined %}
RUN {{ package_manager }} install
{% elif edition is defined %}
RUN cargo build --release
{% endif %}

CMD ["{{ start_command }}"]
```

#### Optional: CI/CD support
If "ci-cd" is in features, create:

**.github/workflows/ci.yml.tera**
```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      {% if edition is defined %}
      - uses: actions-rs/toolchain@v1
        with:
          toolchain: stable
      - run: cargo test
      {% elif package_manager is defined %}
      - uses: actions/setup-node@v3
      - run: {{ package_manager }} install
      - run: {{ package_manager }} test
      {% endif %}
```

### Step 6: Update blueprints.toml (if requested)

If the user wants to add this blueprint to blueprints.toml:

1. Check if blueprints.toml exists in the parent directory
2. If it exists, read it and add the new entry
3. If it doesn't exist, create it with the new entry

```toml
[{{ blueprint_name }}]
path = "./{{ blueprint_name }}"
```

Use proper TOML formatting and preserve existing entries.

### Step 7: Summary

After creating all files, provide a summary:

```
Created blueprint: {{ blueprint_name }}

Files created:
- {{ blueprint_name }}/blueprint.toml ({{ num_questions }} questions)
- {{ blueprint_name }}/{{ main_file }}.tera
- {{ blueprint_name }}/README.md.tera
- {{ blueprint_name }}/.gitignore
[... list all files ...]

Next steps:
1. Review the generated files and customize as needed
2. Test the blueprint locally:
   kopye copy ./ {{ blueprint_name }} test-output

3. Add more template files to {{ blueprint_name }}/ as needed
4. Commit to your blueprints repository
```

## Quality Guidelines

### blueprint.toml Quality
- Include 3-7 meaningful questions
- Use clear, descriptive help text
- Add conditional questions with depends_on when appropriate
- Include at least one multiselect for features/options
- Group related questions together

### Template File Quality
- Use Tera syntax correctly
- Include conditional blocks for optional features
- Use filters appropriately (upper, lower, trim)
- Ensure variables match question names exactly
- Add helpful comments in templates

### File Organization
- Follow language-specific conventions
- Use appropriate file extensions (.rs, .ts, .py, etc.)
- Include .tera extension on template files
- Create logical directory structure (src/, tests/, etc.)
- Include common static files (.gitignore, README)

### Best Practices
- Make templates usable with minimal customization
- Include sensible defaults in conditionals
- Add both binary and library patterns where applicable
- Support multiple package managers/tools where relevant
- Include testing setup if common for the language
- Add CI/CD templates for professional projects

## Error Handling

If something goes wrong:
- Check if directory already exists before creating
- Validate blueprint name (no spaces, valid directory name)
- Ensure parent directory exists
- Handle blueprints.toml parsing errors gracefully
- Provide clear error messages

## Advanced Features

### Smart Defaults
Based on the blueprint type, automatically include:
- Appropriate .gitignore patterns
- Common dependencies for the ecosystem
- Standard directory structures
- Conventional configuration files

### Template Suggestions
Suggest additional files the user might want:
- "Would you like to include Docker support?"
- "Add GitHub Actions CI/CD workflow?"
- "Include a license file?"

### Validation
After creation, optionally validate:
- TOML syntax is correct
- Tera templates compile
- File structure is complete
- All referenced variables exist in blueprint.toml

## Examples of Blueprint Types to Support

- **Rust**: binary, library, workspace, CLI app, web server
- **Node.js**: Express app, CLI tool, library, TypeScript project
- **Python**: FastAPI, Django, Flask, CLI tool, library
- **Web**: React, Next.js, Vue, Svelte, static site
- **Go**: CLI app, web server, library
- **Java**: Spring Boot, CLI app, library
- **Other**: Docker setup, Kubernetes manifests, Terraform modules
