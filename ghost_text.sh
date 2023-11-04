# this script is not done yet and i disbaled it for performance as of rn
#
# this is a script that emulates inline ghost text for cmp
# it doesn't cover semantics tokens like "unpack"
# it also adds () pairs and ; to ghost text

mkdir -p ~/.config/nvim/lua/cmp/view/ 
ln ~/.config/nvim/ghost_text_view.lua ~/.config/nvim/lua/cmp/view/ghost_text_view.lua -sf
