# this is a script that emulates inline for cmp
# it doesn't cover semantics tokens and i am not bothered to make it effient enough to handle that for now
# i plan to optimize it at some point because even with 20 characters it's slow

mkdir -p ~/.config/nvim/lua/cmp/view/ 
cp ./ghost_text_view.lua ~/.config/nvim/lua/cmp/view/
