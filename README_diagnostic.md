# Diagnostics

Build reports and debugging information.

This directory contains reports produced by the project's validation and build
system. These files help identify problems without modifying the source files.

## Contents

Typical diagnostic files include:

- `metadata_report.txt` — summary of discovered source metadata
- `generated_report.txt` — consistency report for generated files
- `link_report.txt` — report of links found and checked in the generated website
- `build_report.txt` — summary of the overall build
- `imports.dot` — Typst import dependency graph

The exact set of files may change as the project develops.

## Purpose

Diagnostics are intended for:

- detecting build problems
- checking metadata consistency
- finding broken links
- inspecting generated-file consistency
- understanding Typst import dependencies
- measuring build performance
- debugging the build pipeline

## Generated files

Files in this directory are generated automatically.

They should **not be edited manually**.

If a diagnostic report shows a problem, fix the corresponding source,
generator, build script, or validation logic and regenerate the report.

## Build reports

The main build summary is generated at the end of a successful build.

For example:

```text
./build.sh
```
