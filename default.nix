{
  pkgs ? import (<nixpkgs>) {}
}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    # sbcl
    sqlite
    sqlitebrowser
    emacs
  ];

  shellHook = ''
    export MY_LIBRARY_PATH=${pkgs.sqlite.out}/lib:${pkgs.openssl.out}/lib;
  '';
}
