# MarkdownTextEditor

## Project Overview

MarkdownTextEditor is a SwiftUI-powered Markdown editing application designed for intuitive document creation and preview.

## Markdown Linting Setup

### Prerequisites

- Node.js (v14 or later)
- npm (Node Package Manager)

### Installation

1. Install markdownlint-cli globally:

```bash
npm install -g markdownlint-cli
```

OR

2. Install as a dev dependency in the project:

```bash
npm init -y
npm install --save-dev markdownlint-cli
```

### Configuration

The project includes a `.markdownlint.yml` configuration file with comprehensive linting rules.

### Usage

#### Global Installation

To lint all Markdown files in the project:

```bash
markdownlint .
```

To lint and automatically fix issues:

```bash
markdownlint . --fix
```

#### Local Installation (npm script)

Add to `package.json`:

```json
{
  "scripts": {
    "lint:md": "markdownlint .",
    "lint:md:fix": "markdownlint . --fix"
  }
}
```

Then run:

```bash
npm run lint:md
# or
npm run lint:md:fix
```

### Linting Rules

Key linting rules include:

- No trailing spaces
- Consistent heading styles
- No multiple blank lines
- Proper list indentation
- No bare URLs
- Fenced code blocks must specify a language
- No hard tabs
- Headings surrounded by blank lines
- Single newline at file end
- Line length limited to 80 characters

### CI/CD Integration

Add to your CI pipeline to enforce Markdown quality:

```yaml
# Example GitHub Actions workflow
name: Markdown Lint
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
      - run: npm install -g markdownlint-cli
      - run: markdownlint .
```

### Customization

Modify `.markdownlint.yml` to adjust rules according to your project's specific needs.

## Troubleshooting

- Ensure Node.js and npm are installed
- Check markdownlint-cli version compatibility
- Verify `.markdownlint.yml` syntax

## Contributing

1. Lint your Markdown files before submitting a PR
2. Fix any linting issues
3. Maintain consistent documentation quality
