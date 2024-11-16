# dotfiles

This repo uses [`stow`](https://www.gnu.org/software/stow/) to manage dotfiles.

## Usage

From the root of the repo, run:

```bash
stow .
```

Optionally, you can run with the `-n` flag to preview changes before committing:

```bash
stow -nv .
```

To remove symlinks, run:

```bash
stow -D .
```
