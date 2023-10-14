# this is a custom cmp-ghost entry that allows ghost text to work if inside a pair (and not inside a quote)
# sane people (not me) might not like this

mkdir -p ~/.local/share/nvim/site/pack/Sam/start/nvim-cmp/lua/cmp/view/ 
# neovim prefers the file here over packer's i i don't know why but i am very happy it works
cp ./ghost_text_view.lua ~/.local/share/nvim/site/pack/Sam/start/nvim-cmp/lua/cmp/view/
