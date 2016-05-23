# Relic Package Manager
This project allows you to download and install programs onto your IBM i system from GitHub (soon to be any Git repo)

Basic Package Manager for IBM i, tested on:

+ 7.1
+ 7.2
+ 7.3

Currently, it **only supports GitHub**. This is because my hosted system doesn't have a version of Git, once my request has gone through to get it installed, you'll be able to use any Git repo.

**If you want to get your RPG project on GitHub** then please let me know on [Gitter](https://gitter.im/WorksOfBarry) or by [emailing me](mailto:mrliamallan@live.co.uk) as I am more than willing to help. :-)

You can follow [development here](https://trello.com/b/BEOD7bA7/relic-package-manager).

### How to install

The current way of installing

1. You'll need to get the source from this repo into a source member or IFS file - FTP / Copy+Paste via Rational Developer for i. I've been using `#RELIC` as my development library, but the choice is your.
2. `CRTSQLRPGI OBJ(#RELIC/RELIC) SRCFILE(#RELIC/QRPGLESRC) SRCMBR(RELIC) COMMIT(*NONE) OPTION(*EVENTF) RPGPPOPT(*LVL2) REPLACE(*YES) DBGVIEW(*SOURCE)` to compile.
3. **You will** also need a command over the RELIC program. `RELICGET.CMD` exists within this repo, you should be able to copy the source from that and create it using `CRTCMD`.
3. Should hopefully be installed. 

**[You can find a video guide to install Relic here](https://www.youtube.com/watch?v=1mK3JG4690Q&feature=youtu.be)**

**OR**

1. Do a `git clone https://github.com/Club-Seiden/RelicPackageManager.git /home/[USER]/Relic/` where `[USER]` is your user profile name (you also have to create the Relic directory). 
2. Compile RELIC.RPGLE from the IFS (I use #RELIC as the library, you can use any) using `CRTSQLRPGI` with `COMMIT(*NONE)`.
3. You'll need to copy RELICGET.CMD as well, and use it with `CRTCMD` over the RELIC *PGM you created.

If you're getting `error: SSL certificate problem: unable to get local issuer certificate while accessing`.. while attemping to clone, put `GIT_SSL_NO_VERIFY=true` infront of `git clone` and it should clone successfully.

### How to use

1. Find a GitHub repo you want to install onto your system, for example [FFEDIT](https://github.com/RelicPackages/FFEDIT).
2. There are three paramters to the RELIC program. The link to a ZIP of the repository, a subfolder within the ZIP (otherwise, leave blank) and what library to use/install into. 

Examples
```
CALL RELIC PARM('https://github.com/Club-Seiden/TOP/archive/master.zip' 'TOP-master' 'SOMELIB')
CALL RELIC PARM('https://github.com/RelicPackages/RPGMAIL/archive/master.zip' 'RPGMAIL-master' 'RPGMAIL')
```

This new ZIP functionality should allow the package manager to work with other hosting sites like BitBucket. **[You can find a video guide to install Packages here](https://www.youtube.com/watch?v=uQFq-hbO-Y0&feature=youtu.be)** (Old-method)

### How to create a build file.

1. Create a `build.txt` file in your repo.
2. A build file contains 1 section. `build:` is the commands to run after all directories and sources have been made from the ZIP file.

You can find examples in any repo in the [RelicPackages organisation](https://github.com/RelicPackages). You'll file that `files:` and `dirs:` is no longer needed with the new method of building a packaged (with a ZIP file).