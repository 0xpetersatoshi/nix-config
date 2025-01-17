# Brew

## Install

Install brew with:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Generate Brewfile

```bash
brew bundle dump --file=~/.config/brew/Brewfile
```

## Install from Brewfile

```bash
brew bundle install
```

## Resources

- [Homebrew](https://brew.sh/)
- [Brew Bundle](https://gist.github.com/ChristopherA/a579274536aab36ea9966f301ff14f3f)
