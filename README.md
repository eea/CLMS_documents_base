## Base Repository for DOCS in the EEA Technical Library

The `clms-docs-base` serves as the foundational repository for managing and integrating documentation resources within the EEA Technical Library. It provides a structured approach to organizing, updating, and publishing technical documentation across projects.

## How to Add Documentation to Your Project

Follow these steps to integrate the documentation from this repository into your project:

```bash
# Link this repository as a remote
git remote add clms-docs-base git@github.com:eea/CLMS_documents_base.git

# Add the DOCS folder from this repository to your project
git subtree add --prefix=DOCS clms-docs-base main --squash
```

After running these commands, you'll have a `DOCS` folder in your project containing all the documentation resources from this repository.

## Setting Up Git Shortcuts

Make managing your documentation easier by setting up helpful git shortcuts.
Run the appropriate setup script based on your operating system:

```bash
# On macOS or Linux:
./DOCS/_meta/scripts/linux/setup-docs-aliases.sh

# On Windows (PowerShell):
./DOCS/_meta/scripts/win/setup-docs-aliases.ps1
```

This script will create convenient git aliases to simplify working with your documentation.

## Handy Git Aliases

Once the setup is complete, you'll have access to these useful git commands:

- **`git docs-update`**: Syncs your local documentation with updates from the base repository.
- **`git docs-publish`**: Pushes your documentation changes to the repository.
- **`git docs-preview`**: Generates a local preview of your documentation.

These shortcuts make it easy to keep your documentation up-to-date, share changes, and review your work.

## What's Inside the DOCS Folder?

The `DOCS` folder is organized into several key subdirectories:

- **templates**: Ready-to-use templates for creating new documents.
- **theme**: Contains styling elements, reference templates, and design assets.
- **includes**: Supporting files required for proper rendering and styling.

When working on your documentation, make sure to use the `includes` and `theme` directories as outlined in the user manual. Avoid moving these directories to ensure your `.qmd` files render correctly in the final technical library.
