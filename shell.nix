let
    pkgs = let
        hostpkgs = import <nixpkgs> {};
        pkgsrc = hostpkgs.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "04d5f1e3a87d413181af5d6dd68568228addf1c3";
            hash = "sha256:1nfs8qywmmcms07fvifq4rj1wa67ahrw5pykx4zhbddx49flc0fz";
        };
    in import pkgsrc {};

    clover = pkgs.callPackage ./clover/clover.qcow2.nix {};
in pkgs.mkShell {
    buildInputs = with pkgs; [
        entr
        file
        gitFull
        qemu
        ripgrep
        vim
        unzip
        p7zip
        libguestfs-with-appliance
        (python3.withPackages (p: [

        ]))

        ## for generating the config.iso
        cdrkit
        expect
        netcat
        coreutils
    ];

    OVMF_CODE = "${pkgs.OVMF.fd}/FV/OVMF_CODE.fd";
    OVMF_VARS = "${pkgs.OVMF.fd}/FV/OVMF_VARS.fd";
    CLOVER_QCOW = "${clover.clover-image}";
}
