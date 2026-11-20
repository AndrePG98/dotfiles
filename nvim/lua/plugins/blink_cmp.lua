local blink = { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
        -- Snippet Engine
        {
            'L3MON4D3/LuaSnip',
            version = '2.*',
            build = (function()
                -- Build Step is needed for regex support in snippets.
                -- This step is not supported in many windows environments.
                -- Remove the below condition to re-enable on windows.
                -- if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
                --     return
                -- end
                return 'make install_jsregexp'
            end)(),
            dependencies = {
                {
                    'rafamadriz/friendly-snippets',
                    lazy = true,
                    config = function()
                        require('luasnip.loaders.from_vscode').lazy_load()
                    end,
                },
            },
            opts = {},
        },
        'folke/lazydev.nvim',
        'onsails/lspkind.nvim',
        {
            'mikavilpas/blink-ripgrep.nvim',
            version = '*', -- use the latest stable version
        },
        {
            'fang2hou/blink-copilot',
        },
        {
            'becknik/blink-cmp-luasnip-choice',
        },
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
        keymap = {
            -- 'default' (recommended) for mappings similar to built-in completions
            --   <c-y> to accept ([y]es) the completion.
            --    This will auto-import if your LSP supports it.
            --    This will expand snippets if the LSP sent a snippet.
            -- 'super-tab' for tab to accept
            -- 'enter' for enter to accept
            -- 'none' for no mappings
            --
            -- For an understanding of why the 'default' preset is recommended,
            -- you will need to read `:help ins-completion`
            --
            -- No, but seriously. Please read `:help ins-completion`, it is really good!
            --
            -- All presets have the following mappings:
            -- <tab>/<s-tab>: move to right/left of your snippet expansion
            -- <c-space>: Open menu or open docs if already open
            -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
            -- <c-e>: Hide menu
            -- <c-k>: Toggle signature help
            --
            -- See :h blink-cmp-config-keymap for defining your own keymap
            preset = 'default',
            ['<TAB>'] = { 'select_next', 'fallback' },
            ['<S-TAB>'] = { 'select_prev', 'fallback' },
            ['<CR>'] = {
                'select_and_accept',
                'fallback',
            },
            ['<C-c>'] = { 'show', 'show_documentation', 'hide_documentation' },

            -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
            --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        appearance = {
            -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = 'mono',
        },
        completion = {
            -- By default, you may press `<c-space>` to show the documentation.
            -- Optionally, set `auto_show = true` to show the documentation after a delay.
            list = {
                selection = {
                    auto_insert = false,
                },
            },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 150,
                treesitter_highlighting = true,
                window = {
                    border = 'rounded',
                },
            },
            ghost_text = { enabled = true },
            menu = {
                border = 'rounded',
                min_width = 10,
                draw = {
                    -- We don't need label_description now because label and label_description are already
                    -- combined together in label by colorful-menu.nvim.
                    columns = { { 'kind_icon' }, { 'label', gap = 1 }, { 'source_name' } },
                    components = {
                        source_name = {
                            width = { max = 10 },
                            text = function(ctx)
                                return '[' .. ctx.source_name .. ']'
                            end,
                            highlight = 'BlinkCmpSource',
                        },
                        label = {
                            width = { fill = true, max = 60 },
                            text = function(ctx)
                                local highlights_info = require('colorful-menu').blink_highlights(ctx)
                                if highlights_info ~= nil then
                                    -- Or you want to add more item to label
                                    return highlights_info.label
                                else
                                    return ctx.label
                                end
                            end,
                            highlight = function(ctx)
                                local highlights = {}
                                local highlights_info = require('colorful-menu').blink_highlights(ctx)
                                if highlights_info ~= nil then
                                    highlights = highlights_info.highlights
                                end
                                for _, idx in ipairs(ctx.label_matched_indices) do
                                    table.insert(highlights, { idx, idx + 1, group = 'BlinkCmpLabelMatch' })
                                end
                                -- Do something else
                                return highlights
                            end,
                        },
                    },
                },
            },
        },

        sources = {
            default = { 'lsp', 'path', 'snippets', 'lazydev', 'buffer', 'ripgrep', 'copilot', 'choice' },
            providers = {
                lsp = { score_offset = 90 },
                lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
                ripgrep = {
                    module = 'blink-ripgrep',
                    name = 'Ripgrep',
                    ---@module "blink-ripgrep"
                    ---@type blink-ripgrep.Options
                    opts = {},
                },
                copilot = {
                    name = 'copilot',
                    module = 'blink-copilot',
                    score_offset = 100,
                    async = true,
                },
                choice = {
                    name = 'LuaSnip Choice Nodes',
                    module = 'blink-cmp-luasnip-choice',
                    opts = {},
                },
            },
        },

        snippets = { preset = 'luasnip' },

        -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
        -- which automatically downloads a prebuilt binary when enabled.
        --
        -- By default, we use the Lua implementation instead, but you may enable
        -- the rust implementation via `'prefer_rust_with_warning'`
        --
        -- See :h blink-cmp-config-fuzzy for more information
        fuzzy = { implementation = 'prefer_rust_with_warning', sorts = {
            'exact',
            'score',
            'sort_text',
        } },

        -- Shows a signature help window while you type arguments for a function
        signature = { enabled = true },
    },
}

return { blink }
