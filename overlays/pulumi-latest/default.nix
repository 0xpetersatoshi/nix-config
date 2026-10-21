{...}: final: prev: {
  pulumi = prev.pulumi.overrideAttrs (_old: rec {
    version = "3.270.0";

    src = prev.fetchFromGitHub {
      owner = "pulumi";
      repo = "pulumi";
      tag = "v${version}";
      hash = "sha256-0Xund8P6mVWggeCKdrb/hzLC2weW18tLry4Rrt/T2W8=";
      name = "pulumi";
    };

    vendorHash = "sha256-6xqslx+Hkp7LplIfK4zC24HA2LP2zF3ttWulhaCF3w4=";

    doCheck = false;
  });

  pulumiPackages = prev.pulumiPackages.overrideScope (
    _finalScope: prevScope: {
      pulumi-go = prevScope.pulumi-go.overrideAttrs (_old: {
        vendorHash = "sha256-BErwEeE77Js2ERyyOmD+CtacyKpEp0B4kbOcRyIdLVg=";
        doCheck = false;
      });
    }
  );
}
