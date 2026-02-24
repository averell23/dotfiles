{ ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;

    settings = {
      user = {
        name = "Daniel Hahn";
        email = "daniel.hahn@betterplace.org";
      };

      alias = {
        st = "status";
        ci = "commit";
        br = "branch";
        cl = "clone";
        co = "checkout";
        lg = "log";
        killorig = ''clean -f "*.orig *.BACKUP.* *_BACKUP_* *.BASE.* *_BASE_* *.LOCAL.* *_LOCAL_* *.REMOTE.* *_REMOTE_*"'';
        pp = ''!git pull $1 $2 && git push $1 $2'';
      };

      merge.tool = "opendiff";

      core = {
        excludesfile = "~/.gitexcludes";
        editor = "vim";
      };

      color = {
        ui = "auto";
        branch = {
          current = "blue reverse";
          local = "blue";
          remote = "green";
        };
        diff = {
          meta = "yellow bold";
          frag = "magenta bold";
          old = "red bold";
          new = "green bold";
        };
        status = {
          added = "yellow";
          changed = "green";
          untracked = "cyan";
        };
      };

      github.user = "averell23";

      push = {
        default = "simple";
        autoSetupRemote = true;
      };

      credential.helper = "osxkeychain";
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}
