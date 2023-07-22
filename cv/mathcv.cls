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

% styling
% -------

% fonts
\RequirePackage{palatino}

% biblatex
% --------
\RequirePackage[
  backend=biber,
  backref=false,
  clearlang=true,
  giveninits=true,
  natbib=true,
  style=numeric,
  sorting=none,
  doi=false,
  isbn=false,
  maxbibnames=99,
  minalphanames=3,
  url=false,
  date=year
]{biblatex}

\AtBeginBibliography{\raggedright}

% bold volume number; plain pages
\DeclareFieldFormat[article]{volume}{\mkbibbold{#1}}
\DeclareFieldFormat{pages}{#1}
\DeclareFieldFormat{journaltitle}{#1}
\DeclareFieldFormat{booktitle}{\mkbibquote{#1}}

% italicsed title
\DeclareFieldFormat
  [article,preprint,inbook,incollection,inproceedings,thesis]
  {title}{\mkbibemph{#1\isdot}}

% custom formatting for preprints (with and without journal)
\newbibmacro*{preprint:journal}{\iffieldundef{journaltitle}{\printtext{Preprint}}{\printtext{To appear in:}\addspace\printfield{journaltitle}}}

% short journal name and volume (suppress number)
\newbibmacro*{journalshort}{%
  \usebibmacro{journal}%
  \setunit*{\addspace}%
  \printfield{volume}
  \setunit{\addspace}%
  \usebibmacro{issue+date}%
  \newunit}

\DeclareFieldFormat[preprint]{labelalpha}{#1+} % change formatting for manuscript

% eprint / archive
% define new eprinttype using e.g. `eprint:jstor` (see below for pattern)
\newbibmacro{archive}{\iffieldundef{eprinttype}
  {\printfield{eprint}}
  {\printfield[eprint:\strfield{eprinttype}]{eprint}}
}
\DeclareFieldFormat{eprint:arxiv}{\href{https://arxiv.org/abs/#1}{\nolinkurl{arxiv:#1}}}
\DeclareFieldFormat{eprint:zbl}{\href{https://zbmath.org/#1}{\nolinkurl{zbl:#1}}}
\DeclareFieldFormat{eprint:zbmath}{\href{https://zbmath.org/#1}{\nolinkurl{zbmath:#1}}}
\DeclareFieldFormat{eprint:doi}{\href{https://doi.org/#1}{\nolinkurl{doi:#1}}}
\DeclareFieldFormat{eprint:mr}{\href{https://mathscinet.ams.org/mathscinet-getitem?mr=#1}{\nolinkurl{MR#1}}}

% main drivers
\DeclareBibliographyDriver{preprint}{%
  \usebibmacro{bibindex}%
  \usebibmacro{begentry}%
  \usebibmacro{author/translator+others}%
  \setunit{\printdelim{nametitledelim}}\newblock
  \usebibmacro{title}%
  \newunit\newblock
  \usebibmacro{preprint:journal}%
  \newunit\newblock
  \usebibmacro{archive}%
  \usebibmacro{finentry}}

\DeclareBibliographyDriver{article}{%
  \usebibmacro{bibindex}%
  \usebibmacro{begentry}%
  \usebibmacro{author/translator+others}%
  \setunit{\printdelim{nametitledelim}}\newblock
  \usebibmacro{title}%
  \newunit\newblock
  \usebibmacro{byauthor}%
  \newunit\newblock
  \usebibmacro{journalshort}
  \newunit
  \usebibmacro{note+pages}%
  \usebibmacro{archive}%
  \usebibmacro{finentry}}

\DeclareBibliographyDriver{book}{%
  \usebibmacro{bibindex}%
  \usebibmacro{begentry}%
  \usebibmacro{author/editor+others/translator+others}%
  \setunit{\printdelim{nametitledelim}}\newblock
  \usebibmacro{maintitle+title}%
  \newunit\newblock
  \usebibmacro{byauthor}%
  \newunit\newblock
  \usebibmacro{byeditor+others}%
  \newunit\newblock
  \printfield{edition}%
  \newunit
  \iffieldundef{maintitle}
    {\printfield{volume}%
     \printfield{part}}
    {}%
  \newunit
  \printfield{volumes}%
  \newunit\newblock
  \usebibmacro{series+number}%
  \newunit\newblock
  \printfield{note}%
  \newunit\newblock
  \usebibmacro{publisher+location+date}%
  \newunit\newblock
  \usebibmacro{chapter+pages}%
  \newunit
  \printfield{pagetotal}%
  \newunit\newblock
  \usebibmacro{archive}%
  \usebibmacro{finentry}}

\DeclareBibliographyDriver{incollection}{%
  \usebibmacro{bibindex}%
  \usebibmacro{begentry}%
  \usebibmacro{author/translator+others}%
  \setunit{\printdelim{nametitledelim}}\newblock
  \usebibmacro{title}%
  \newunit\newblock
  \usebibmacro{byauthor}%
  \newunit\newblock
  \usebibmacro{in:}
  \usebibmacro{maintitle+booktitle}%
  \newunit\newblock
  \usebibmacro{byeditor+others}%
  \newunit\newblock
  \printfield{edition}%
  \newunit
  \iffieldundef{maintitle}
    {\printfield{volume}%
     \printfield{part}}
    {}%
  \newunit
  \printfield{volumes}%
  \newunit\newblock
  \usebibmacro{series+number}%
  \newunit\newblock
  \printfield{note}%
  \newunit\newblock
  \usebibmacro{publisher+location+date}%
  \newunit\newblock
  \usebibmacro{chapter+pages}%
  \usebibmacro{archive}%
  \usebibmacro{finentry}}

\DeclareBibliographyDriver{inproceedings}{%
  \usebibmacro{bibindex}%
  \usebibmacro{begentry}%
  \usebibmacro{author/translator+others}%
  \setunit{\printdelim{nametitledelim}}\newblock
  \usebibmacro{title}%
  \newunit\newblock
  \usebibmacro{byauthor}%
  \newunit\newblock
  \usebibmacro{in:}
  \usebibmacro{maintitle+booktitle}%
  \newunit\newblock
  \usebibmacro{byeditor+others}%
  \newunit\newblock
  \printfield{edition}%
  \newunit
  \iffieldundef{maintitle}
    {\printfield{volume}%
     \printfield{part}}
    {}%
  \newunit
  \printfield{volumes}%
  \newunit\newblock
  \usebibmacro{series+number}%
  \newunit\newblock
  \printfield{note}%
  \newunit\newblock
  \usebibmacro{publisher+location+date}%
  \newunit\newblock
  \usebibmacro{chapter+pages}%
  \usebibmacro{archive}%
  \usebibmacro{finentry}}

\def\blx@warn@bibempty{}


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
