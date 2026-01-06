{ pkgs }: {
  deps = [
    pkgs.postgresql
    pkgs.metasploit
    pkgs.bashInteractive
    pkgs.nodePackages.bash-language-server
    pkgs.man
  ];
}