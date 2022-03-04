
# Installation

Here you will find instructions to download and use Deck.

## Downloading sources using git

Log-in with your FMRIB credentials to [GitLab](https://git.fmrib.ox.ac.uk) (if you are in the analysis group, you have an account by default).

Make sure you [add your SSH](https://git.fmrib.ox.ac.uk/help/ssh/README) key to your account settings (Top-right icon > Profile Settings > SSH Keys).
This is so GitLab recognizes your computer when you try to download the code, or indeed for any other remote action from your computer. Note that you should have one key per machine (and _not_ per account); so if you want to use Deck on the Jalapeno cluster, you will need to add a the key from your jalapeno acount as well.

Once your account is set up, open a terminal and go to the folder where you would like to download the sources, e.g. `~/Documents/MATLAB`.
You **do not** need to create a folder specifically to download the sources right now, this folder will be created automatically:
```
git clone git@git.fmrib.ox.ac.uk:jhadida/deck.git <"folder_name"|default:"deck">
```

Note that you can also download the latest sources as a zip-file, in which case you simply need to uncompress it where you like.
The downside is that you won't be able to easily update to the latest versions, or to contribute.

## Using Deck in Matlab

Deck is a Matlab [package](https://uk.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html), which is the equivalent of a namespace or module in other languages. Packages are great to "hide" the functions behind a common prefix, and to organise them into submodules when there are a lot of them. This is useful mainly to avoid [name collisions](https://en.wikipedia.org/wiki/Name_collision) with Matlab's toolboxes or built-ins, and with other packages.

> Tip: if you will be using Deck on a regular basis, you might want to include the following commands in your [`startup.m`](https://uk.mathworks.com/help/matlab/ref/startup.html) file.

In order to use Deck in Matlab:

1. Add the folder which _contains_ the directory `+dk` to the Matlab path. If you downloaded the sources to folder `/path/to/deck` this can be done by typing `addpath('/path/to/deck');` from the Matlab console. Note that you **should not** use `genpath` in this command.
2. Once the source folder is on your Matlab path, simply type `dk_startup`. You should see a message saying:
```
[Deck] Starting up from folder "/path/to/deck".
```

You should now be able to call all of Deck's functions with a _dot-syntax_. As a simple test, try:
```
>> dk.println('Hello')
Hello
```

## Upgrading to a newer version

If you downloaded the sources using git, say to the folder `/path/to/deck`, you can upgrade to the version `version_name` directly from the command-line:
```
cd "/path/to/deck"
git fetch --all
git checkout tag/<version_name>
```

Alternatively, if you would like to download the latest release, you can do:
```
cd "/path/to/deck"
git fetch --all
git checkout latest
```

# Bugs & Contributions

Please [open an issue](https://git.fmrib.ox.ac.uk/jhadida/deck/issues) on the GitLab page for any bug that you may find.

Contributions are welcome from anyone, but you need to be added as a member to the project in order to push your contribution to the repository.
Send me a message if you would like to contribute.
