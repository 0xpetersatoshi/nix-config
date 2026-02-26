{...}: final: prev: {
  harlequin = prev.harlequin.overridePythonAttrs (oldAttrs: {
    pythonRelaxDeps = (oldAttrs.pythonRelaxDeps or []) ++ ["tomlkit"];
  });
}
