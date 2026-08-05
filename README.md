# 🧮 Typst Mathematics Lecture Portal

An automated, dual-target academic portal built entirely with **Typst**. This repository hosts interactive, browser-viewable lecture notes alongside downloadable, print-ready A4 PDFs. It features automated indexing, a built-in search engine, local rendering fallbacks, and multi-theme (Dark/Light) UI environments.

---

## 🚀 Quick Start & Local Development

### 📋 Prerequisites
Ensure you have the following installed on your local machine:
- **Typst CLI** (v0.12.x or later)
- **Node.js** (v20+ to run the local Pagefind search indexer)

### 🛠️ How to Compile Natively
To build the website layout, extract lecture metadata, and update the search index on your machine, execute the automation build script from the root folder:
```bash
chmod +x ./build.sh
./build.sh
```
This script populates an isolated `./dist/` directory containing all public assets. (*Note: `./dist/` is blocked by `.gitignore` to keep your Git commits clean.*)

### 🌐 Previewing Locally
Modern browsers restrict font and MathML requests when opening static HTML files directly via `file:///`. To test your math notes with fully functioning equations locally, spin up a lightweight local server environment:

**Using Python:**
```bash
cd dist
python3 -m http.server 8000
```
Then navigate to `http://localhost:8000` in your web browser.

---

## 📂 Project Architecture

```text
math-course-site/
├── .github/workflows/
│   └── deploy.yml     # Cloud CI/CD engine targeting GitHub Pages
├── src/
│   ├── template.typ   # Core layout definitions (Theorems, Exercises, Navigation)
│   ├── style.css      # Variables, layout, and automatic Dark Mode rules
│   ├── lec1.typ       # Lecture Note source 1
│   └── lec2.typ       # Lecture Note source 2
├── .gitignore         # Blocks localized build outputs from staging
└── build.sh           # Master pipeline compiler script
```

---

## 📝 How to Add New Lecture Notes

The compile pipeline is fully automated. To add a new module (e.g., Lecture 3):

1. Create a new file inside the source directory named exactly **`src/lec3.typ`**.
2. **Crucial Step:** Write a custom title metadata comment on **Line 1** so the dashboard can index it:
   ```typst
   // Title: Vector Spaces & Inner Products
   #import "template.typ": theorem, definition, exercise, html-nav-header
   ```
3. Use the pre-configured layout blocks for clean formatting:
   - `#definition(title: "Name")[...]`
   - `#theorem(title: "Name")[...]`
   - `#exercise(title: "Name", solution: [...])[...]` *(The solution collapses into an interactive accordion on the web!)*

4. Run `./build.sh` or push directly to GitHub to see it go live instantly.

---

## 🤖 Continuous Deployment (CI/CD)

This repository utilizes **GitHub Actions** to automate publishing. Every time code is pushed to the `main` branch, the cloud runner:
1. Provisions a clean Linux environment.
2. Installs the official Typst compiler toolchain.
3. Sets up a Node runtime environment.
4. Executes `./build.sh` to generate the lecture assets.
5. Indexes content using **Pagefind Search**.
6. Deploys the static results directly to your private **GitHub Pages** subdomain.

---

## 🎨 Modifying Themes and Layout
- To change colors, typography, or adjust the system-level dark mode variables, modify **`src/style.css`**.
- To adjust the structural aesthetics of theorems, proofs, or change top header sizes, modify **`src/template.typ`**.
