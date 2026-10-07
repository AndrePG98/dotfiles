local snacks = {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    init = function()
        vim.notify = require 'snacks.notifier'
    end,
    ---@type snacks.Config
    opts = {
        dashboard = {
            preset = {
                keys = {
                    { icon = '󰒲', key = 'L', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
                    { icon = '󰏗', key = 'M', desc = 'Mason', action = ':Mason', enabled = package.loaded.lazy ~= nil },
                    { icon = '', key = 'q', desc = 'Quit', action = ':qa' },
                },
            },
            sections = {
                { section = 'header' },
                { section = 'keys', gap = 1, padding = 2 },
                -- { icon = ' ', title = 'Projects', section = 'projects', indent = 3, padding = 2 },
                { section = 'startup' },
            },
        },
        lazygit = {},
        notifier = {
            style = 'compact',
            top_down = false,
        },
        dim = {},
        indent = {
            enabled = true,
            only_scope = true,
            animate = {
                enabled = false,
            },
        },
        scratch = {},
        input = {},
        bufdelete = {},
        picker = {
            win = {
                input = {
                    keys = {
                        ['<S-Tab>'] = { 'list_up', mode = { 'i', 'n', 'x' } },
                        ['<Tab>'] = { 'list_down', mode = { 'i', 'n', 'x' } },
                        ['<c-j>'] = 'select_and_next',
                        ['<c-k>'] = 'select_and_prev',
                    },
                },
            },
            sources = {
                lsp_symbols = {
                    filter = {
                        default = true,
                    },
                },
                explorer = {
                    exclude = { '*.uid' },
                    layout = {
                        layout = {
                            position = 'right',
                        },
                    },
                },
            },
        },
        ---@class snacks.explorer.Config
        explorer = {
            replace_netrw = true,
            trash = true,
        },
        image = {},
    },
    keys = {
        {
            '<leader><leader>',
            function()
                Snacks.picker.lines()
            end,
            desc = '[/] Fuzzily search in current buffer',
        },
        {
            '<leader>sw',
            function()
                Snacks.picker.grep_word()
            end,
            desc = '[S]earch [W]ord',
        },
        {
            '<leader>sK',
            function()
                Snacks.picker.keymaps()
            end,
            desc = '[S]earch [K]eymaps',
        },
        {
            '<leader>sH',
            function()
                Snacks.picker.help()
            end,
            desc = '[S]earch [H]elp',
        },
        {
            '<leader>sr',
            function()
                Snacks.picker.resume()
            end,
            desc = '[S]earch [R]esume',
        },
        {
            '<Leader>sC',
            function()
                local original = vim.g.colors_name
                Snacks.picker.colorschemes {
                    layout = { preset = 'vscode' },
                    on_change = function(_, item)
                        if item then
                            vim.cmd('colorscheme ' .. item.text)
                        end
                    end,
                    confirm = function(picker, item)
                        picker:close()
                        if item then
                            vim.cmd('colorscheme ' .. item.text)
                        else
                            vim.cmd('colorscheme ' .. original)
                        end
                    end,
                    on_close = function(picker)
                        if not picker.closed then
                            vim.cmd('colorscheme ' .. original)
                        end
                    end,
                }
            end,
            desc = '[S]earch [C]olorschemes',
        },
        {
            '<Leader>sp',
            function()
                Snacks.picker.grep {
                    layout = {
                        layout = {
                            box = 'horizontal',
                            width = 0.75,
                            height = 0.45,
                            {
                                box = 'vertical',
                                border = 'rounded',
                                title = '{title} {live} {flags}',
                                { win = 'input', height = 1, border = 'bottom' },
                                { win = 'list', border = 'none' },
                            },
                            -- { win = 'preview', title = '{preview}', width = 0.55, border = 'rounded' },
                        },
                    },
                }
            end,
            desc = '[S]earch [P]roject',
        },
        {
            '<Leader>sd',
            function()
                local grep_opts = {
                    layout = {
                        layout = {
                            box = 'horizontal',
                            width = 0.85,
                            height = 0.75,
                            {
                                box = 'vertical',
                                border = 'rounded',
                                title = '{title} {live} {flags}',
                                { win = 'input', height = 1, border = 'bottom' },
                                { win = 'list', border = 'none' },
                            },
                            { win = 'preview', title = '{preview}', width = 0.55, border = 'rounded' },
                        },
                    },
                }
                if vim.bo.filetype == 'neo-tree' then
                    local state = require('neo-tree.sources.manager').get_state 'filesystem'
                    local node = state.tree:get_node()
                    local path = node.path

                    if node.type == 'file' then
                        path = vim.fn.fnamemodify(path, ':h')
                    end

                    grep_opts.dirs = { path }
                    Snacks.picker.grep(grep_opts)
                else
                    vim.ui.input({ prompt = 'Grep in directory: ', default = './', completion = 'dir' }, function(dir)
                        if dir then
                            grep_opts.dirs = { dir }
                            Snacks.picker.grep(grep_opts)
                        end
                    end)
                end
            end,
            desc = '[S]earch [D]irectory',
        },
        {
            '<leader>sf',
            function()
                Snacks.picker.files {
                    layout = {
                        preset = 'select',
                    },
                }
            end,
            desc = '[S]earch [F]iles',
        },
        {
            '<leader>sR',
            function()
                Snacks.picker.registers()
            end,
            desc = '[S]earch [R]egisters',
        },
        {
            '<leader>tg',
            function()
                Snacks.lazygit {}
            end,
            desc = '[T]oggle Lazy[G]it',
        },
        {
            '<leader>tz',
            function()
                if vim.g.snacks_dim then
                    Snacks.dim.disable()
                    vim.g.snacks_dim = false
                else
                    Snacks.dim.enable()
                    vim.g.snacks_dim = true
                end
            end,
            desc = '[T]oggle [Z]one out',
        },
        {
            '<leader>nn',
            function()
                Snacks.input({ prompt = 'Note name: ' }, function(name)
                    if name and name ~= '' then
                        Snacks.scratch.open { name = name }
                    else
                        Snacks.scratch.open { name = 'Scratch' }
                    end
                end)
            end,
            desc = '[N]ote open/create',
        },
        {
            '<leader>nd',
            function()
                local files = Snacks.scratch.list()

                if #files == 0 then
                    vim.notify('No scratch files found', vim.log.levels.INFO)
                    return
                end

                local display = vim.tbl_map(function(f)
                    return f.name .. ' [' .. f.ft .. ']'
                end, files)

                vim.ui.select(display, { prompt = 'Delete note file:' }, function(_, idx)
                    if not idx then
                        return
                    end
                    local file = files[idx]
                    vim.fn.delete(file.file)
                    vim.notify('Deleted: ' .. file.name, vim.log.levels.INFO)
                end)
            end,
            desc = '[N]ote [D]elete',
        },
        {
            '<leader>ns',
            function()
                Snacks.scratch.select()
            end,
            desc = '[N]ote [S]elect',
        },
        {
            '<leader>q',
            function()
                local winAmount = #vim.api.nvim_tabpage_list_wins(0)
                if winAmount > 1 and vim.fn.winnr() ~= 1 then
                    vim.cmd 'q'
                    return
                end

                if pcall(Snacks.bufdelete) then
                    return
                else
                    vim.cmd 'q'
                end
            end,
            desc = '[Q]uit Current Buffer',
        },
        {
            '<leader>gD',
            function()
                Snacks.picker.git_diff()
            end,
            desc = '[G]it project [D]iff',
        },
        {
            '\\',
            function()
                Snacks.explorer.open()
            end,
            desc = 'File explorer',
        },
    },
}

return { snacks }
