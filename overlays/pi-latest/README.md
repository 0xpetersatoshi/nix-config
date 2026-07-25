# pi-latest overlay

Pins `pi-coding-agent` to a newer version than nixpkgs currently ships.

## Why this exists

- nixpkgs lags behind pi's release cadence (it was on 0.79.1 / 0.80.10 while upstream was at 0.82.1).
- Building 0.82.1+ from GitHub source does **not** work in the Nix sandbox: upstream now generates its model catalog at
  build time by fetching from `models.dev` and provider APIs, and the generated data is gitignored.

So instead of building from source we install the **prebuilt npm tarball** (`@earendil-works/pi-coding-agent`), whose
`dist/` already has the model data baked in by the maintainer before publishing.

## Delete this overlay once nixpkgs catches up

When `nixpkgs#pi-coding-agent` reaches the version you want, remove this directory — otherwise the overlay pins you
_below_ upstream. Check with:

```bash
nix eval --raw nixpkgs#pi-coding-agent.version
```

## Updating to a newer pi version

1. Find the latest published version:

   ```bash
   npm view @earendil-works/pi-coding-agent version
   ```

2. Bump `version` in `default.nix`, then refresh all the hashes.

   **`src` hash** — the npm tarball:

   ```bash
   V=<new-version>
   nix store prefetch-file --json \
     "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-$V.tgz" \
     | nix run nixpkgs#jq -- -r .hash
   ```

   **Sibling `integrity` hashes** — the three workspace packages published alongside the CLI (their `integrity` is
   missing from the shrinkwrap, so we backfill it in `postPatch`):

   ```bash
   for p in pi-ai pi-agent-core pi-tui; do
     printf '%s ' "$p"
     npm view @earendil-works/$p@$V dist.integrity
   done
   ```

   Paste each `sha512-...` value into the matching `.integrity` line in `postPatch`.

   **`npmDepsHash`** — set it to a dummy value, build, and copy the `got:` hash from the mismatch error:

   ```nix
   npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
   ```

   ```bash
   git add overlays/pi-latest/default.nix   # flakes ignore untracked files!
   nix eval --raw ".#nixosConfigurations.<host>.pkgs.pi-coding-agent.version"
   # build fails with: specified: sha256-AAAA... got: sha256-<real>
   ```

   Paste the `got:` value into `npmDepsHash`.

3. Verify and apply:

   ```bash
   nix build ".#nixosConfigurations.<host>.pkgs.pi-coding-agent" \
     && ./result/bin/pi --version
   nh os switch
   ```

## Gotchas

- **`git add` the file before evaluating.** This is a git-tracked flake, so untracked changes to `default.nix` are
  invisible to `nix build` / `nh`.
- If a build fails with `ENOTCACHED` for a `@types/*` package, upstream added a new devDependency that's missing from
  the shrinkwrap. `postPatch` already strips _all_ `devDependencies` (`dist/` is prebuilt, so they're unneeded), so this
  normally self-heals — but if the layout changed, that's the first place to look.
- The in-app "Update Available / run pi update" banner will still appear; it can't tell the package is Nix-managed.
  Ignore it and bump the version here instead.
