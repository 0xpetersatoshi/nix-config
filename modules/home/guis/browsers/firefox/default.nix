{
  config,
  host,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace};
with types; let
  cfg = config.guis.browsers.firefox;
in {
  options.guis.browsers.firefox = {
    enable = mkEnableOption "Enable firefox browser";
  };

  config = mkIf cfg.enable {
    xdg.mimeApps.defaultApplications = {
      "text/html" = ["firefox.desktop"];
      "text/xml" = ["firefox.desktop"];
      "x-scheme-handler/http" = ["firefox.desktop"];
      "x-scheme-handler/https" = ["firefox.desktop"];
    };

    programs.firefox = {
      enable = pkgs.stdenv.isLinux;
      profiles = {
        default = {
          name = "Default";
          id = 0;
          isDefault = true;

          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            onepassword-password-manager
            vimium
            metamask
          ];

          settings = {
            "browser.uidensity" = 0;
            "layers.acceleration.force-enabled" = true;
            "identity.fxaccounts.account.device.name" = "${config.igloo.user.name}@${host}";

            "browser.urlbar.oneOffSearches" = false;
            "browser.search.hiddenOneOffs" = "Google,Yahoo,Bing,Amazon.com,Twitter,Wikipedia (en),YouTube,eBay";

            "browser.urlbar.shortcuts.bookmarks" = false;
            "browser.urlbar.shortcuts.history" = false;
            "browser.urlbar.shortcuts.tabs" = false;

            "extensions.pocket.enabled" = false;
            "browser.urlbar.suggest.engines" = false;
            "browser.urlbar.suggest.openpage" = false;
            "browser.urlbar.suggest.bookmark" = false;
            "browser.urlbar.suggest.addons" = false;
            "browser.urlbar.suggest.pocket" = false;
            "browser.urlbar.suggest.topsites" = false;
            "sidebar.verticalTabs" = true;
            "sidebar.expandOnHover" = true;
            "sidebar.main.tools" = "aichat";

            # Privacy and Security
            "extensions.formautofill.addresses.enabled" = false;
            "extensions.formautofill.creditCards.enabled" = false;
            "signon.rememberSignons" = false;
            "signon.autofillForms" = false;
            "geo.enabled" = false;
            "permissions.default.desktop-notification" = 2;

            # Theme
            "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          };

          search = {
            force = true;
            default = "google";
            order = [
              "google"
              "Perplexity"
              "Kagi"
              "NixOS Options"
              "Nix Packages"
              "GitHub"
              "HackerNews"
            ];

            engines = {
              "google" = {
                urls = [
                  {
                    template = "https://google.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                metaData.hideOneOffButton = true;
              };

              "Perplexity" = {
                definedAliases = ["p"];
                urls = [
                  {
                    template = "https://perplexity.ai/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                metaData.hideOneOffButton = true;
              };

              "Kagi" = {
                definedAliases = ["k"];
                urls = [
                  {
                    template = "https://kagi.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                metaData.hideOneOffButton = true;
              };

              "Nix Packages" = {
                icon = "https://p7.hiclipart.com/preview/55/734/518/nixos-nix-package-manager-linux-unix-like-linux.jpg";
                definedAliases = ["np"];
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "type";
                        value = "packages";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                      {
                        name = "channel";
                        value = "unstable";
                      }
                    ];
                  }
                ];
                metaData.hideOneOffButton = true;
              };

              "NixOS Options" = {
                icon = "https://p7.hiclipart.com/preview/55/734/518/nixos-nix-package-manager-linux-unix-like-linux.jpg";
                definedAliases = ["no"];
                urls = [
                  {
                    template = "https://search.nixos.org/options";
                    params = [
                      {
                        name = "channel";
                        value = "unstable";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                metaData.hideOneOffButton = true;
              };

              "SourceGraph" = {
                icon = "https://sourcegraph.com/.assets/img/sourcegraph-mark.svg";
                definedAliases = ["sg"];

                urls = [
                  {
                    template = "https://sourcegraph.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                metaData.hideOneOffButton = true;
              };

              "GitHub" = {
                icon = "https://github.com/favicon.ico";
                definedAliases = ["gh"];

                urls = [
                  {
                    template = "https://github.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                metaData.hideOneOffButton = true;
              };

              "Home Manager" = {
                icon = "https://p7.hiclipart.com/preview/55/734/518/nixos-nix-package-manager-linux-unix-like-linux.jpg";
                definedAliases = ["hm"];

                urls = [
                  {
                    template = "https://mipmip.github.io/home-manager-option-search/";
                    params = [
                      {
                        name = "query";
                        value = "{searchTerms}&release=master";
                      }
                    ];
                  }
                ];
                metaData.hideOneOffButton = true;
              };

              "HackerNews" = {
                icon = "https://news.ycombinator.com/favicon.ico";
                definedAliases = ["hn"];

                urls = [
                  {
                    template = "https://hn.algolia.com/";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                metaData.hideOneOffButton = true;
              };
            };
          };
        };

        work = {
          name = "Work";
          id = 1;
          isDefault = false;

          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            onepassword-password-manager
            vimium
            metamask
          ];

          settings = {
            "browser.uidensity" = 0;
            "layers.acceleration.force-enabled" = true;
            "identity.fxaccounts.account.device.name" = "${config.igloo.user.name}@${host}";

            "browser.urlbar.oneOffSearches" = false;
            "browser.search.hiddenOneOffs" = "Google,Yahoo,Bing,Amazon.com,Twitter,Wikipedia (en),YouTube,eBay";

            "browser.urlbar.shortcuts.bookmarks" = false;
            "browser.urlbar.shortcuts.history" = false;
            "browser.urlbar.shortcuts.tabs" = false;

            "extensions.pocket.enabled" = false;
            "browser.urlbar.suggest.engines" = false;
            "browser.urlbar.suggest.openpage" = false;
            "browser.urlbar.suggest.bookmark" = false;
            "browser.urlbar.suggest.addons" = false;
            "browser.urlbar.suggest.pocket" = false;
            "browser.urlbar.suggest.topsites" = false;
            "sidebar.verticalTabs" = true;
            "sidebar.expandOnHover" = true;
            "sidebar.main.tools" = "aichat";

            # Privacy and Security
            "extensions.formautofill.addresses.enabled" = false;
            "extensions.formautofill.creditCards.enabled" = false;
            "signon.rememberSignons" = false;
            "signon.autofillForms" = false;
            "geo.enabled" = false;
            "permissions.default.desktop-notification" = 2;

            # Theme
            "extensions.activeThemeID" = "firefox-alpenglow@mozilla.org";
          };

          search = {
            force = true;
            default = "google";
            order = [
              "google"
              "Perplexity"
              "Kagi"
              "NixOS Options"
              "Nix Packages"
              "GitHub"
              "HackerNews"
            ];

            engines = {
              "google" = {
                urls = [
                  {
                    template = "https://google.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                metaData.hideOneOffButton = true;
              };

              "Perplexity" = {
                definedAliases = ["p"];
                urls = [
                  {
                    template = "https://perplexity.ai/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                metaData.hideOneOffButton = true;
              };

              "Kagi" = {
                definedAliases = ["k"];
                urls = [
                  {
                    template = "https://kagi.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                metaData.hideOneOffButton = true;
              };

              "Nix Packages" = {
                icon = "https://p7.hiclipart.com/preview/55/734/518/nixos-nix-package-manager-linux-unix-like-linux.jpg";
                definedAliases = ["np"];
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "type";
                        value = "packages";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                      {
                        name = "channel";
                        value = "unstable";
                      }
                    ];
                  }
                ];
                metaData.hideOneOffButton = true;
              };

              "NixOS Options" = {
                icon = "https://p7.hiclipart.com/preview/55/734/518/nixos-nix-package-manager-linux-unix-like-linux.jpg";
                definedAliases = ["no"];
                urls = [
                  {
                    template = "https://search.nixos.org/options";
                    params = [
                      {
                        name = "channel";
                        value = "unstable";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                metaData.hideOneOffButton = true;
              };

              "SourceGraph" = {
                icon = "https://sourcegraph.com/.assets/img/sourcegraph-mark.svg";
                definedAliases = ["sg"];

                urls = [
                  {
                    template = "https://sourcegraph.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                metaData.hideOneOffButton = true;
              };

              "GitHub" = {
                icon = "https://github.com/favicon.ico";
                definedAliases = ["gh"];

                urls = [
                  {
                    template = "https://github.com/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                metaData.hideOneOffButton = true;
              };

              "Home Manager" = {
                icon = "https://p7.hiclipart.com/preview/55/734/518/nixos-nix-package-manager-linux-unix-like-linux.jpg";
                definedAliases = ["hm"];

                urls = [
                  {
                    template = "https://mipmip.github.io/home-manager-option-search/";
                    params = [
                      {
                        name = "query";
                        value = "{searchTerms}&release=master";
                      }
                    ];
                  }
                ];
                metaData.hideOneOffButton = true;
              };

              "HackerNews" = {
                icon = "https://news.ycombinator.com/favicon.ico";
                definedAliases = ["hn"];

                urls = [
                  {
                    template = "https://hn.algolia.com/";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                metaData.hideOneOffButton = true;
              };
            };
          };
        };
      };
    };
  };
}
