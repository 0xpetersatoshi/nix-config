# Chromium

Most of this module was taken from [this](https://gist.github.com/SilentQQS/b23c28889cb957088ecf382400ad4325) github gist.

## Chrome Extensions

This module uses the [Chromium Web Store](https://github.com/NeverDecaf/chromium-web-store) to manage extensions.

> [!hint]
> Ensure that `chrome://flags/#extension-mime-request-handling` is set to "Always prompt for install"

You need to manually add the Chrome store extension id to the module in the `extensions` array before you can install
the extension from the Chrome web store. The extension id can be extracted from the extension's url.
