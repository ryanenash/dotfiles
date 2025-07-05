# Dotfiles 

## Method

I store my dotfiles by creating a git alias and linking other repos as submodules 

```
git init --bare $HOME/.dotfiles
echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> $HOME/.zshrc
dotfiles config --local status.showUntrackedFiles no
```

This creates a repo at $HOME/.dotfiles, sets its working directory to $HOME, and adds a git alias named dotfiles 

I can then add files with `dotfiles add .zshrc`, which evaluates to `$HOME/.zshrc`

I have some folders for programs like Neovim that track changes in their own repos, e.g. nvim-kickstart located at $HOME/.config/nvim-kickstart/

I link to these folders and add them as submodules 

`dotfiles submodule add git@github.com:ryanenash/kickstart-modular.nvim.git .config/nvim-kickstart`

This tracks my Neovim config folder `nvim-kickstart` which itself is a repo by adding to the `.gitmodules` folder in $HOME 

To commit this change I run:
`dotfiles add .gitmodules .config/nvim-kickstart`

`dotfiles commit -m "feat: Add nvim configuration as a submodule"`

Now if any changes are made to the `$HOME/.config/nvim-kickstart/` folder git will track them

I can see if any changes have been made to them with `git status`

If so I just need to add a commit to bring in these changes: `dotfiles add .config/nvim-kickstart`

Then push with `dotfiles push`

For files not in their own git repos it is as simple as doing: `dotfiles add file`, with the root dir being $HOME and so in this case evaluating to $HOME/file

## Caveats 

Requires a .gitignore in $HOME that uses negative selectors to track stuff I don't want in my dotfiles, e.g. `.cache` or `.local`
Also requires a README in $HOME unless one is created in `.github/README.md`, but even then that requires an additional folder in $HOME 



```
