# dotfiles

This repo uses [`stow`](https://www.gnu.org/software/stow/) to manage dotfiles.

## Usage

To link all the dotfiles in the [.config](./.config/) directory, run:

```bash
stow -t ~/.config .config
```

To link home level dotfiles, from the root of the repo, run:

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
