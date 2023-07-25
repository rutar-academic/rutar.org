\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{mathcv}[2023/06/05 Mathematics CV Class]

\LoadClass[12pt, a4paper]{article}

\RequirePackage[bottom=3cm, right=2.3cm, top=2.5cm, left=2.3cm]{geometry}
\RequirePackage{bm}
\RequirePackage{enumitem}
\SetEnumitemKey{nl}{nolistsep}
\SetEnumitemKey{r}{label=(\roman*)}
\SetEnumitemKey{a}{label=(\alph*)}

\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage[protrusion=true,expansion=true]{microtype}
\RequirePackage[french,english]{babel}
\RequirePackage{etoolbox}
\RequirePackage{csquotes}

\RequirePackage{mathtools}

\RequirePackage{stmaryrd}
\SetSymbolFont{stmry}{bold}{U}{stmry}{m}{n} % fix missing bold font error

% fonts
% -----
\RequirePackage{palatino}

% hyperref
% --------
\RequirePackage[bookmarks=true,hidelinks]{hyperref}
\RequirePackage{bookmark}
\RequirePackage{xcolor}
\newcommand\myshade{85}
\colorlet{mylinkcolor}{violet}
\colorlet{mycitecolor}{orange!50!yellow}
\colorlet{myurlcolor}{green!50!blue}

\hypersetup{
    linkcolor  = mylinkcolor!\myshade!black,
    citecolor  = mycitecolor!\myshade!black,
    urlcolor   = myurlcolor!\myshade!black,
    colorlinks = true
}

% custom macros
% -------------
\RequirePackage{longtable}
\newcommand\filltoend{\leavevmode{\unskip
          \leaders\hrule height.6ex depth\dimexpr-.5ex+0.8pt\hfill\hbox{}%
            \parfillskip=0pt\endgraf}}

\newcommand{\rsec}[1]{\section*{{#1}\phantom{o}\filltoend}}

\newenvironment{twocolsec}[1]{
    \rsec{#1}
    \begin{longtable}{p{2.5cm}p{13cm}}
}{
    \end{longtable}
}
\newenvironment{threecolsec}[1]{
    \rsec{#1}
    \begin{longtable}{p{1cm}p{1.58cm}p{12.5cm}}
}{
    \end{longtable}
}
