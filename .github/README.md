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

#### External Config Repos (nvim) — standalone repos, **not** submodules

Some configs are their own Git repository — your Neovim setups. These are **not** tracked by dotfiles. They are independent repos with their own remotes, history, and branches, cloned separately on each machine.

> **Why not submodules?** Dotfiles used to embed them as git submodules, but for an actively-edited, per-machine config that added friction for little gain: every change needed a two-step commit (submodule, then a pointer bump in dotfiles), `dotfiles submodule update` checks out in **detached HEAD**, and `main`/`work` recorded divergent pointers that conflicted on merge. The nvim repos are already versioned and backed up by their own remotes, so they stand alone.

The repos:

| Repo | Cloned to | Invoked via |
| ---- | --------- | ----------- |
| `ryanenash/LazyVim-Starter` | `~/.config/nvim` (work) or `~/.config/nvim-lazy` (personal) | default `nvim` / `NVIM_APPNAME="nvim-lazy"` |
| `ryanenash/kickstart-modular.nvim` | `~/.config/nvim-kickstart` | `NVIM_APPNAME="nvim-kickstart"` |

Each nvim repo uses its **own** `main` (personal) / `work` (work-machine) branch convention — independent of the dotfiles branches that happen to share those names. Work on them directly; there is no pointer to bump in dotfiles afterwards:

```bash
cd ~/.config/nvim
git checkout work            # or main, per machine
git commit -am "Update plugin"
git push                     # the nvim repo is its own source of truth
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
!/.zshrc
!/.p10k.zsh

# The trailing slash lets Git descend into the directory
!/.github/
!/.github/README.md

# Whitelisting is NOT recursive — each tracked path needs its own ! line (see note)
!/.config/
!/.config/ghostty/
!/.config/ghostty/**
```

> **Note on Claude Code:** `~/.claude/` is intentionally **not** whitelisted — settings vary too much between machines, so each keeps its own untracked `~/.claude/settings.json`.

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

5.  **Clone your nvim configs** — they're separate repos (see *External Config Repos* above), not part of dotfiles, so clone them explicitly:

    ```bash
    # LazyVim config — default path on work, or use NVIM_APPNAME on personal
    git clone git@github.com-personal:ryanenash/LazyVim-Starter.git ~/.config/nvim
    # Kickstart config (optional second setup)
    git clone git@github.com-personal:ryanenash/kickstart-modular.nvim.git ~/.config/nvim-kickstart

    # Check out the branch this machine should track (main = personal, work = work)
    git -C ~/.config/nvim checkout work
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

    > **Newly-tracked files:** if a commit starts tracking a file that *already exists* untracked on this machine, the pull aborts with *"untracked working tree files would be overwritten."* Move the local copy aside, pull, then merge any machine-specific tweaks back in:
    >
    > ```bash
    > mv ~/.config/foo/bar ~/.config/foo/bar.bak
    > dotfiles pull
    > # reconcile anything from .bak into the now-synced file, then delete the .bak
    > ```

3.  **Update your nvim configs** — separate repos (see *External Config Repos* above), but the **same two-branch model as dotfiles** (`main` = personal, `work` = work machine). On the **work** machine (each repo on its `work` branch):

    ```bash
    cd ~/.config/nvim
    git fetch && git merge origin/main             # pull personal's nvim baseline into work
    git add -A && git commit -m "…" && git push    # save + publish work's nvim changes
    ```

    On the **personal** machine (on `main`): `git pull`, then `git add`/`commit`/`push`. *(`nvim-kickstart` is personal-only and follows the same pattern.)*

    > Plain `git pull` only syncs your **current** branch (`origin/work`) — use `git merge origin/main` to bring the other side's baseline across, exactly like `dotfiles merge origin/main`.

-----

### 🌿 Two-Branch Model: `main` (personal) + `work` (work machine)

This repo uses two long-lived branches:

  * **`main`** — the shared/personal baseline. The **personal** machine lives on it.
  * **`work`** — `main` *plus* this work machine's specifics (PATHs, work aliases, prompt tweaks, etc.). The **work** machine lives on it.

Each machine stays checked out on its own branch and **never** checks out the other — a `dotfiles checkout <other>` would overwrite your `$HOME` files.

**Personal machine (on `main`):**

```bash
dotfiles pull                                              # get the latest baseline
dotfiles add <files> && dotfiles commit -m "…" && dotfiles push
```

**Work machine (on `work`):**

```bash
dotfiles fetch && dotfiles merge origin/main              # pull baseline updates into work
dotfiles add <files> && dotfiles commit -m "…" && dotfiles push
```

**Rules of thumb:**

  * **Shared/baseline** changes (README, `.gitignore`, a new tracked config) → make them on the **personal** machine (`main`) so they flow to `work` via `merge origin/main`. *(Editing `main` from the work machine means writing to a non-checked-out branch — awkward; prefer doing it on personal.)*
  * **Machine-specific** changes → make them on **`work`**.
  * `merge origin/main` only **conflicts** on files that changed on *both* sides (`.zshrc`, `.p10k.zsh`, `.gitconfig`, `.config/ghostty/config`). Resolve by keeping your work-specific lines and folding in the baseline change, then `dotfiles add <file> && dotfiles commit`.

-----

### ⚠️ Caveats

  * As mentioned, this method requires a carefully managed `.gitignore` in `$HOME` that uses negated patterns (`!`) to select what to track.
  * Also requires a README in $HOME unless one is created in `.github/README.md`, but even then that requires an additional folder in $HOME 
  * Always run `dotfiles` commands from your `$HOME` directory to avoid accidentally running a command in a subdirectory (e.g., another Git project) which could lead to unexpected behavior.

