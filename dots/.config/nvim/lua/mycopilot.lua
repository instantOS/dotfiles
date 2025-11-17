vim.cmd([[
    imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
    let g:copilot_no_tab_map = v:true

    let g:copilot_filetypes = {
        \ 'xml': v:false,
        \ 'txt': v:false,
        \ 'text': v:false,
        \ 'markdown': v:false,
        \ 'md': v:false,
        \ 'env': v:false,
        \ 'sh': v:false,
        \ 'gpg': v:false,
        \ }
]])
