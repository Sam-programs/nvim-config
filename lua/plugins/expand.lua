return {
   {
      "Sam-programs/expand.nvim",
      dependencies = { 'Sam-Programs/indent.nvim' },
      event = 'InsertEnter',
      opts = {
         filetypes = {
            cpp = {
               { '\\w\\+ \\w\\+(.*)', {'<cr>{','}'} },
               { '.*(.*)',            {'{','}'} },
               { '',                  {'{','};'} },
            }
         }
      }
   }
}
