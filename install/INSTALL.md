# Installation Guide

This guide creates a fresh `notes` project from the current `typst-site` template and initializes it as a new Git repository.

## Fresh Installation

Run the following commands from the directory containing `typst-site`:

```bash
cd ..
cp -R typst-site notes
cd notes

rm -rf .git
rm -rf coding/ content/ diagnostics/ dist/ docs/ generated/
rm -f pdflayout_old.typ README.md

open scripts/config.py

mkdir -p content/lectures
touch content/lectures/lec1.typ
touch content/lectures/lec1_content.typ

git init
git branch -M main
git add .
git commit -m "Initial commit"
```

## What the commands do

| Command                                                       | Purpose                                           |
| ------------------------------------------------------------- | ------------------------------------------------- |
| `cd ..`                                                       | Move to the parent directory                      |
| `cp -R typst-site notes`                                      | Create a fresh copy of `typst-site` named `notes` |
| `cd notes`                                                    | Enter the new project                             |
| `rm -rf .git`                                                 | Remove the Git history from the template          |
| `rm -rf coding/ content/ diagnostics/ dist/ docs/ generated/` | Remove old project-specific and generated files   |
| `rm -f pdflayout_old.typ README.md`                           | Remove obsolete files                             |
| `open scripts/config.py`                                      | Open the site configuration                       |
| `mkdir -p content/lectures`                                   | Create the initial lecture-content directory      |
| `touch content/lectures/lec1.typ`                             | Create an empty lecture file                      |
| `touch content/lectures/lec1_content.typ`                     | Create an empty lecture content file              |
| `git init`                                                    | Initialize a new Git repository                   |
| `git branch -M main`                                          | Set the main branch to `main`                     |
| `git add .`                                                   | Stage all files                                   |
| `git commit -m "Initial commit"`                              | Create the first commit                           |

## GitHub Setup

After the initial commit, create a **new empty repository** on GitHub.

Do not initialize the GitHub repository with a README, `.gitignore`, or license, since the local repository already has its initial commit.

Then connect the local repository to GitHub:

```bash
git remote add origin <GITHUB-REPO-URL>
git push -u origin main
```

For example:

```bash
git remote add origin https://github.com/USERNAME/notes.git
git push -u origin main
```

Verify the remote:

```bash
git remote -v
```

The repository is now ready for development.
