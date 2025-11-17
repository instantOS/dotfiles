return {
	"lervag/vimtex",
	event = "BufRead *.tex",
	config = function()
		vim.cmd([[
        let g:vimtex_compiler_latexmk_engines = {
            \ '_'                : '-lualatex',
            \ 'pdflatex'         : '-pdf',
            \ 'dvipdfex'         : '-pdfdvi',
            \ 'lualatex'         : '-lualatex',
            \ 'xelatex'          : '-xelatex',
            \ 'context (pdftex)' : '-pdf -pdflatex=texexec',
            \ 'context (luatex)' : '-pdf -pdflatex=context',
            \ 'context (xetex)'  : '-pdf -pdflatex=''texexec --xtx''',
            \}

        let g:tex_flavor = 'latex'
        ]])
	end,
}
