if true then
  return {{}} 
end
return {
   -- lazy.nvim
   {
      "Sam-programs/noice.nvim",
      event = "VeryLazy",
      opts = {
         -- add any options here
      },
      dependencies = {
         -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
         "MunifTanjim/nui.nvim",
      }
   }
}
