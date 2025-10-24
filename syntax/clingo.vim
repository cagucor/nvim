" Vim syntax file
" Language: Clingo / ASP
" Maintainer: Your Name
" Last Change: 2025-06-11

if exists("b:current_syntax")
  finish
endif

" Comments
syntax match clingoComment "%.*$"
highlight link clingoComment Comment

" Directives
syntax keyword clingoDirective #const #show #hide #program #external #include
highlight link clingoDirective PreProc

" Built-in keywords
syntax keyword clingoKeyword not
highlight link clingoKeyword Keyword

" Variables (start with uppercase)
syntax match clingoVariable "\<[A-Z][A-Za-z0-9_]*\>"
highlight link clingoVariable Identifier

" Atoms / predicates (lowercase identifiers)
syntax match clingoAtom "\<[a-z][a-zA-Z0-9_]*\>"
highlight link clingoAtom Function

" Numbers
syntax match clingoNumber "\<[0-9]\+\>"
highlight link clingoNumber Number

" Operators
syntax match clingoOperator "[:.,;|+\-*=/<>!~&]"
highlight link clingoOperator Operator

let b:current_syntax = "clingo"

