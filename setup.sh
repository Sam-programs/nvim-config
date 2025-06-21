#!/usr/bin/sh
#thankfully the developers of ripgrep left package manager commands in the README 
echo "Applying Configurations"
mv ~/.config/nvim/ ~/.config/nvim.old/ -f
cp . ~/.config/nvim/ -rf
echo "Checking for RipGrep"
for cmd in pacman apt-get nix-env dnf emerge guix zypper yum;do
   command -v rg   >/dev/null 2>&1 && 
   echo "RipGrep Found!" && break

   command -v $cmd >/dev/null 2>&1 ||
   continue 
   echo "Installing RipGrep"
   case "$cmd" in
      "pacman") sudo pacman -S ripgrep --noconfirm > /dev/null
         ;;
      "apt-get") sudo apt-get install ripgrep
      ;;
      "nix-env") nix-env --install ripgrep
      ;;
      "dnf") sudo dnf install ripgrep
      ;;
      "emerge") sudo emerge sys-apps/ripgrep
      ;;
      "guix") sudo guix install ripgrep
      ;;
      "zypper") sudo zypper install ripgrep
      ;;
      "yum") sudo yum install -y yum-utils
             sudo yum-config-manager --add-repo=https://copr.fedorainfracloud.org/coprs/carlwgeorge/ripgrep/repo/epel-7/carlwgeorge-ripgrep-epel-7.repo
             sudo yum install ripgrep
      ;;
   esac
   break 
done

command -v rg   >/dev/null 2>&1 ||
echo "RipGrep Not Found Telescope's Grep Won't Work"

echo "Installing Neovim Plugins"
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
echo "Done"
