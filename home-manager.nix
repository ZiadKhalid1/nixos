{ pkgs, ... }: {
    programs.mcfly.enable = true;
    programs.bash.enable = true;


    programs.git = {
        enable = true;
        delta.enable = true;
        userEmail = "ziadk1433@gmail.com";
        userName = "Ziad Khaled";
    };

    home.stateVersion = "24.11";
}
