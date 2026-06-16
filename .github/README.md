## Managing Dotfiles with a Bare Git Repository

This method allows you to version control your configuration files (dotfiles) directly in your `$HOME` directory. An alternative to using symlinks while providing full Git functionality.

### ⚙️ Initial Setup

These one-time commands set up the dotfiles repository on your main machine.

1.  **Create a bare Git repository.** A bare repository has no working directory, so its internal Git files can be stored neatly in a hidden folder.

    ```bash
    git init --bare $HOME/.dotfiles
    ```

2.  **Define an alias.** This makes it easy to interact with your dotfiles repo without affecting other Git repositories on your system. Add this line to your `.zshrc`, `.bashrc`, or other shell configuration file:

    ```bash
    alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
    ```

    *After adding the alias, you'll need to restart your shell or run `source ~/.zshrc`.*

3.  **Configure the repository.** This command tells your dotfiles repo to ignore untracked files. This is essential to prevent `dotfiles status` from showing every single file in your home directory.

    ```bash
    dotfiles config --local status.showUntrackedFiles no
    ```

4.  **Set the remote**. Create a new repo on GitHub with no README/License etc. then set the remote to this new repo.

    ```bash
    dotfiles remote add origin git@github.com:ryanenash/dotfiles.git
    ```

-----

### 🚀 Daily Workflow

#### Tracking Standalone Files

This is for individual files like `.zshrc` or `.gitconfig`.

1.  **Add the file(s)** you want to track. The path is relative to `$HOME`.

    ```bash
    dotfiles add .zshrc .gitconfig
    ```

2.  **Commit your changes.**

    ```bash
    dotfiles commit -m "feat: Track zsh and git configs"
    ```

3.  **Push to your remote.**

    ```bash
    dotfiles push
    ```

-----

#### Tracking External Repositories (Submodules)

This is the correct way to include a folder that is its own Git repository, such as your forked Neovim configuration. This keeps its commit history separate but linked to your main dotfiles repo.

1.  **Add the repository as a submodule.** This command will clone the repository to the specified path and create a `.gitmodules` file.

    ```bash
    dotfiles submodule add git@github.com:ryanenash/kickstart-modular.nvim.git .config/nvim-kickstart
    ```

2.  **Commit the submodule link.** This saves the reference in your main dotfiles repo.

    ```bash
    dotfiles add .gitmodules .config/nvim-kickstart
    dotfiles commit -m "feat: Add nvim configuration as a submodule"
    ```

3.  **Updating the Submodule.** When you make changes inside the `~/.config/nvim-kickstart/` folder, you commit them to the submodule's repository first. Then, you create a *new commit* in your main dotfiles repo to update its pointer to the submodule's new state.

    ```bash
    # 1. Go into the submodule's directory
    cd ~/.config/nvim-kickstart

    # 2. Make your changes, then commit them as usual
    git commit -am "Update nvim plugin"

    # 3. Go back to your home directory
    cd ~

    # 4. Your dotfiles repo now sees that the submodule has new commits.
    #    Add the updated submodule link to the staging area.
    dotfiles add .config/nvim-kickstart

    # 5. Commit the updated pointer.
    dotfiles commit -m "chore: Update nvim configuration"
    ```

    > **Note:** each submodule is on its own branch — `nvim-lazy` tracks `work`, `nvim-kickstart` tracks `master`. Always commit/push from inside the submodule on its branch *before* bumping the pointer in the parent repo.

4.  **Submodules do NOT auto-update.** `dotfiles pull` only updates the *recorded pointer* — it does not change the submodule's checked-out files. Worse, a plain `dotfiles submodule update` checks the submodule out in **detached HEAD** at the recorded commit, dropping you off its branch (`work`/`master`). To pull a submodule's latest commits on another machine *and stay on its branch*, pull from inside it directly:

    ```bash
    cd ~/.config/nvim-lazy
    git pull origin work        # nvim-kickstart uses 'master'
    ```

-----

### 💡 The `.gitignore` Strategy

A well-configured `.gitignore` is critical for this method to work without issues. The best strategy is to **ignore everything by default**, then create exceptions for the specific files and folders you want to track.

This file must be located at `~/.gitignore`.

**Example `~/.gitignore`:**

```gitignore
# 1. Ignore everything
*

# 2. But DO NOT ignore the files and folders listed below
!/.gitignore
!/.gitconfig
!/.gitmodules
!/.zshrc

# The trailing slash is important for directories
!/.config/
!/.github/

# Claude Code: track settings only, never history/sessions/local overrides
!/.claude/
!/.claude/settings.json
```

> **⚠️ Whitelisting is not recursive.** Un-ignoring a directory (e.g. `!/.config/`) only lets Git *descend* into it — the `*` rule still ignores everything *inside*. To track a file in a new subfolder you must whitelist the path explicitly, e.g.:
>
> ```gitignore
> !/.config/ghostty/
> !/.config/ghostty/config
> ```
>
> Files that are *already tracked* keep working regardless (Git only applies ignore rules to *untracked* files). So if `dotfiles add` complains a path "is ignored", either add the `!` lines above or use `dotfiles add -f <path>`.

-----

### 🖥️ Cloning to a New Machine

Here’s how to deploy your dotfiles on a new computer.

1.  **Clone your bare repository.**

    ```bash
    git clone --bare git@github.com:YourUsername/dotfiles.git $HOME/.dotfiles
    ```

2.  **Define the `dotfiles` alias** in your new shell's `.zshrc` or `.bashrc` and restart the shell.

    ```bash
    alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
    ```

3.  **Checkout your files.** This command will place all the tracked files into your `$HOME` directory (make sure there is at least one file in $HOME beforehand)

    ```bash
    dotfiles checkout
    ```

    *Note: If the command fails because of conflicting default files (like a default `.bashrc`), you may need to move or delete them before running `checkout` again.*

4.  **Set the `showUntrackedFiles` flag.**

    ```bash
    dotfiles config --local status.showUntrackedFiles no
    ```

5.  **Initialize your submodules.** This command reads your `.gitmodules` file and clones all your submodules (like your Neovim config) into the correct locations.

    ```bash
    dotfiles submodule update --init --recursive
    ```

-----

### 🔄 Syncing an Already-Set-Up Machine

Pulling changes onto a machine that *already* has the dotfiles checked out (e.g. picking up on the work Mac what you pushed from home).

1.  **Deal with local changes first.** `dotfiles pull` will refuse to overwrite uncommitted edits to tracked files. Check what's dirty:

    ```bash
    dotfiles status -s
    ```

    Then either **commit** them (preferred, so they're backed up):

    ```bash
    dotfiles add <files> && dotfiles commit -m "WIP from work mac"
    ```

    …or **stash** them if you just want them out of the way temporarily:

    ```bash
    dotfiles stash
    ```

2.  **Pull the parent repo.**

    ```bash
    dotfiles pull
    ```

    If you committed and the same file changed on both ends, Git will report a **merge conflict**. Open the conflicted file, resolve the `<<<<<<<`/`=======`/`>>>>>>>` markers, then `dotfiles add <file>` and `dotfiles commit`. (If you stashed in step 1, run `dotfiles stash pop` now and resolve any conflict the same way.)

3.  **Update the submodules** — remember they don't move on their own (see the Submodule note above). Pull each on its branch:

    ```bash
    cd ~/.config/nvim-lazy && git pull origin work
    cd ~/.config/nvim-kickstart && git pull origin master
    ```

-----

### ⚠️ Caveats

  * As mentioned, this method requires a carefully managed `.gitignore` in `$HOME` that uses negated patterns (`!`) to select what to track.
  * Also requires a README in $HOME unless one is created in `.github/README.md`, but even then that requires an additional folder in $HOME 
  * Always run `dotfiles` commands from your `$HOME` directory to avoid accidentally running a command in a subdirectory (e.g., another Git project) which could lead to unexpected behavior.

