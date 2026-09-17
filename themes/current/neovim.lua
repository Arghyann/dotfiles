return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg = "#14090e",
        dark_bg = "#0d0509",
        darker_bg = "#080306",
        lighter_bg = "#241018",

        fg = "#d4b8be",
        dark_fg = "#7e5e65",
        light_fg = "#c4a4aa",
        bright_fg = "#ebd4d9",
        muted = "#5c2430",

        red = "#ff3b56",
        yellow = "#f5b867",
        orange = "#f77852",
        green = "#e6495f",
        cyan = "#e07085",
        blue = "#c7384c",
        magenta = "#ba3247",
        brown = "#8f4450",

        bright_red = "#ff5c72",
        bright_yellow = "#ffd08a",
        bright_green = "#f55b70",
        bright_cyan = "#f78aa0",
        bright_blue = "#e0485d",
        bright_magenta = "#d64057",

        accent = "#ff3b56",
        cursor = "#ebd4d9",
        foreground = "#d4b8be",
        background = "#14090e",
        selection = "#3d1520",
        selection_foreground = "#ebd4d9",
        selection_background = "#3d1520",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
