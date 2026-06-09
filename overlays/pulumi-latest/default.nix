{...}: final: prev: {
  pulumi = prev.pulumi.overrideAttrs (_old: rec {
    version = "3.245.0";

    src = prev.fetchFromGitHub {
      owner = "pulumi";
      repo = "pulumi";
      tag = "v${version}";
      hash = "sha256-Ic/278hL7X5SRdCN3yqc0frWeEUXb/OoJX3kyQL2imo=";
      name = "pulumi";
    };

    vendorHash = "sha256-udY87BsJaTOeiqWl0SgIJ6vSw182UbruV5rmnjYNzXE=";

    doCheck = false;
  });

  pulumiPackages = prev.pulumiPackages.overrideScope (
    _finalScope: prevScope: {
      pulumi-go = prevScope.pulumi-go.overrideAttrs (_old: {
        vendorHash = "sha256-LzbP5wqa3DzHJZB/fnyRtHTW0LAUPPE0Hik4YGzR55g=";
      });
    }
  );
}
