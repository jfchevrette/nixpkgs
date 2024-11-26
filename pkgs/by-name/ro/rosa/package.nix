{ lib, buildGoModule, fetchFromGitHub, installShellFiles, testers, rosa, nix-update-script }:

buildGoModule rec {
  pname = "rosa";
  version = "1.2.48";

  src = fetchFromGitHub {
    owner = "openshift";
    repo = "rosa";
    rev = "v${version}";
    hash = "sha256-qJKzJrCZKhaqoRxloTUqaRsR4/X/hoMxmDQCTNccTqk=";
  };
  vendorHash = null;

  ldflags = [ "-s" "-w" ];

  __darwinAllowLocalNetworking = true;

  postPatch = ''
    # e2e tests require network access
    rm -r tests/e2e
  '';

  preCheck = ''
    # remove tests that require network access
    rm cmd/list/rhRegion/cmd_test.go
    rm cmd/describe/cluster/cmd_test.go
  '';

  nativeBuildInputs = [ installShellFiles ];
  postInstall = ''
    installShellCompletion --cmd rosa \
      --bash <($out/bin/rosa completion bash) \
      --fish <($out/bin/rosa completion fish) \
      --zsh <($out/bin/rosa completion zsh)
  '';

  passthru = {
    tests.version = testers.testVersion {
      package = rosa;
      command = "rosa version --client";
    };
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "CLI for the Red Hat OpenShift Service on AWS";
    license = licenses.asl20;
    homepage = "https://github.com/openshift/rosa";
    maintainers = with maintainers; [ jfchevrette ];
  };
}
