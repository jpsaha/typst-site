## Effective `TYPST_OG` Decision Table

| Build environment | `GITHUB_ACTIONS` | `TYPST_OG_BUILD` env variable | `IS_GITHUB_ACTIONS` | Effective `TYPST_OG` |
|---|---|---|---|---|
| Local | Not set | Not set | `False` | `TYPST_OG_BUILD` from `config.py` |
| Local | Not set | `true` | `False` | `True` |
| Local | Not set | `false` | `False` | `False` |
| Local | `false` | Not set | `False` | `TYPST_OG_BUILD` from `config.py` |
| Local | `false` | `true` | `False` | `True` |
| Local | `false` | `false` | `False` | `False` |
| GitHub Actions | `true` | Not set | `True` | `TYPST_OG_GITBUILD` from `config.py` |
| GitHub Actions | `true` | `true` | `True` | `TYPST_OG_GITBUILD` from `config.py` |
| GitHub Actions | `true` | `false` | `True` | `TYPST_OG_GITBUILD` from `config.py` |
| GitHub Actions | `TRUE` | Not set | `True` | `TYPST_OG_GITBUILD` from `config.py` |
| GitHub Actions | `True` | Not set | `True` | `TYPST_OG_GITBUILD` from `config.py` |

### Priority

| Priority | Condition | Value used |
|---:|---|---|
| 1 | GitHub Actions | `TYPST_OG_GITBUILD` |
| 2 | Local + `TYPST_OG_BUILD` environment variable exists | Environment variable `TYPST_OG_BUILD` |
| 3 | Normal local build | `TYPST_OG_BUILD` from `config.py` |

### Typical cases

| Case | Command / configuration | Effective `TYPST_OG` | Result |
|---|---|---:|---|
| Normal local build | `./build.sh` | `False` | Skip OG generation |
| Generate OG locally | `TYPST_OG_BUILD=true ./build.sh` | `True` | Generate OG PNGs |
| Disable OG locally | `TYPST_OG_BUILD=false ./build.sh` | `False` | Skip OG generation |
| Normal GitHub build | `TYPST_OG_GITBUILD = False` | `False` | Reuse committed OG PNGs |
| GitHub OG rebuild | `TYPST_OG_GITBUILD = True` | `True` | Generate OG PNGs on GitHub |