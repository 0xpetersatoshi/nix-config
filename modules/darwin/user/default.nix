{
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; {
  options.${namespace}.user = {
    name = mkOpt types.str "peter" "The user account name";
  };
}
