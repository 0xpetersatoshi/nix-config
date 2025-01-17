# Configuring Tabby Config Location

Currently, there is no way to change the config path in tabby. So in order to work around that, perform the following steps:

```bash
mkdir -p ~/.config/tabby
mv ~/Library/Application\ Support/tabby/config.yaml ~/.config/tabby/config.yaml
ln -s ~/.config/tabby/config.yaml ~/Library/Application\ Support/tabby/config.yaml
```
