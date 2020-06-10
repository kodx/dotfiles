" Vim color file
" Maintainer:	Petrov Vladislav <petrov.vy@gmail.com>
" Last Change:	2004 Dec 12
" Last Change:	080424

" This color scheme uses a dark grey background.
" Based on "desert" && "evening"

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif

let colors_name = "vjp"


""""""""" GUI """""""""""""
hi Normal		guifg=White guibg=grey20

" Groups used in the 'highlight' and 'guicursor' options default value.
hi Cursor		guibg=Green guifg=Black
hi DiffAdd		guibg=DarkGreen
hi DiffChange	guibg=DarkMagenta
hi DiffDelete	gui=bold guifg=Green guibg=DarkCyan
hi DiffText		gui=bold guibg=Red
hi Directory	guifg=Cyan
hi Error		guibg=Red guifg=White
hi ErrorMsg		guibg=Red guifg=White
hi FoldColumn	guibg=Grey20 guifg=DarkGreen
hi Folded		guibg=Grey20 guifg=Yellow
hi Ignore		gui=reverse
hi IncSearch	gui=reverse
hi lCursor		guibg=Cyan guifg=Black
hi LineNr		guifg=DarkYellow
hi ModeMsg		gui=bold
hi MoreMsg		gui=bold guifg=SeaGreen
hi NonText		gui=bold guifg=LightGreen guibg=grey30
hi Question		gui=bold guifg=Green
hi Search		guibg=Yellow guifg=Black
hi StatusLineNC	gui=reverse
hi StatusLine	gui=reverse,bold,italic
hi Title		gui=bold guifg=Magenta
hi VertSplit	gui=reverse
hi VisualNOS	gui=underline,bold
hi Visual		gui=reverse guifg=Grey guibg=fg
hi WarningMsg	guifg=Red
hi WildMenu		guibg=Yellow guifg=Black


""""""""" Terminal """""""""""""
hi Normal		cterm=none ctermfg=grey ctermbg=none

" Groups used in the 'highlight' and 'guicursor' options default value.
hi Cursor		cterm=none
hi DiffAdd		cterm=bold ctermbg=Darkblue
hi DiffChange	cterm=bold ctermbg=DarkMagenta
hi DiffDelete	cterm=bold ctermfg=Green ctermbg=cyan
hi DiffText		cterm=reverse ctermbg=red
hi Directory	cterm=bold ctermfg=LightCyan
hi Error		cterm=bold ctermfg=7 ctermbg=1
hi ErrorMsg		cterm=none ctermbg=DarkRed ctermfg=White
hi FoldColumn	cterm=none ctermfg=DarkGreen
hi Folded		cterm=none ctermfg=darkyellow
hi Ignore		cterm=bold ctermfg=7
hi IncSearch	cterm=reverse
hi lCursor		cterm=none
hi LineNr		cterm=none ctermfg=darkyellow
hi ModeMsg		cterm=bold
hi MoreMsg		cterm=bold ctermfg=LightGreen
hi NonText		cterm=bold ctermfg=LightGreen
hi Question		cterm=none ctermfg=LightGreen
hi Search		cterm=none ctermfg=white ctermbg=blue
hi StatusLineNC	cterm=reverse
hi StatusLine	cterm=reverse,bold
hi Title		cterm=bold ctermfg=LightMagenta
hi VertSplit	cterm=reverse
hi VisualNOS	cterm=underline,bold
hi Visual		cterm=reverse
hi WarningMsg	cterm=none ctermfg=LightRed
hi WildMenu		cterm=none ctermbg=Yellow ctermfg=Black


" Groups for syntax highlighting
" ******************************

hi comment		cterm=none ctermfg=darkcyan	guifg=SkyBlue

hi constant		cterm=none ctermfg=magenta	guifg=#ffa0a0
"hi string		cterm=none ctermfg=grey		guifg=#ffa0a0
"hi character	cterm=none ctermfg=grey		guifg=#ffa0a0
"hi number		cterm=none ctermfg=grey		guifg=#ffa0a0
"hi boolean		cterm=none ctermfg=grey		guifg=#ffa0a0
"hi float		cterm=none ctermfg=grey		guifg=#ffa0a0

hi identifier	cterm=none ctermfg=yellow	guifg=palegreen
"hi function		cterm=none ctermfg=yellow	guifg=palegreen

hi statement	cterm=none ctermfg=cyan	gui=bold guifg=khaki
hi conditional	cterm=bold ctermfg=blue	gui=bold guifg=khaki
hi repeat		cterm=bold ctermfg=blue	gui=bold guifg=khaki
hi shFor		cterm=none ctermfg=red	gui=bold guifg=khaki
"hi label		cterm=none ctermfg=red	gui=bold guifg=khaki
hi operator		cterm=none ctermfg=green	gui=bold guifg=khaki
"hi keyword		cterm=none ctermfg=red	gui=bold guifg=khaki
"hi exception	cterm=none ctermfg=red	gui=bold guifg=khaki

" sh: ${VAR}
hi preproc		cterm=none ctermfg=darkyellow	gui=italic guifg=navajowhite
hi include		cterm=none ctermfg=darkcyan		gui=italic guifg=LightGreen
hi define		cterm=none ctermfg=darkcyan
hi precondit	cterm=none ctermfg=darkcyan

hi type			cterm=none ctermfg=green	guifg=khaki
"hi storageclass	cterm=none ctermfg=brown 	guifg=khaki
"hi structure	cterm=none ctermfg=brown 	guifg=khaki
"hi typedef		cterm=none ctermfg=brown 	guifg=khaki

" sh: `execute`
hi special		cterm=none ctermfg=lightred guifg=indianred
hi tag			cterm=bold ctermfg=green	guifg=indianred

hi todo			cterm=none ctermfg=white	gui=bold,italic guifg=orangered guibg=yellow2

"hi Label		term=underline ctermfg=green guifg=lightgreen
"hi CppString	term=underline ctermfg=Magenta guifg=#ffa0a0
"hi Format		term=underline ctermfg=Magenta guifg=#ffa0a0
"hi Character	term=underline ctermfg=Magenta guifg=#ffa0a0
"hi SpecialError	term=underline ctermfg=Magenta guifg=#ffa0a0
"hi SpecialCharacter	term=underline ctermfg=Magenta guifg=#ffa0a0
"hi SpaceError	term=underline ctermfg=Magenta guifg=#ffa0a0
"hi Block		term=underline ctermfg=Magenta guifg=#ffa0a0
"hi Underlined
hi SpecialKey		guifg=Cyan
hi Ignore			ctermfg=DarkGrey guifg=grey20

" sh: "$VAR"
hi shDerefSimple	cterm=none ctermfg=darkyellow guifg=navajowhite

hi SignColumn		ctermbg=none

hi ShowMarksHLl		ctermfg=lightgreen guifg=lightgreen
hi ShowMarksHLu		ctermfg=green guifg=green
hi ShowMarksHLo		ctermfg=darkgrey guifg=darkgrey
hi ShowMarksHLm		ctermfg=red guifg=blue

" vim: sw=2
