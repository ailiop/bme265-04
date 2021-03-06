(TeX-add-style-hook "iliopoulos-bme265-04-project"
 (lambda ()
    (LaTeX-add-environments
     "theorem"
     "lemma"
     "corollary")
    (TeX-add-symbols
     '("mbs" 1)
     "resetcounters")
    (TeX-run-style-hooks
     "cleveref"
     "natbib"
     "numbers"
     "square"
     "cmap"
     "resetfonts"
     "nth"
     "super"
     "footmisc"
     "bottom"
     "fancyhdr"
     "paralist"
     "enumerate"
     "booktabs"
     "multirow"
     "xcolor"
     "pdftex"
     "hyperref"
     "x11names"
     "graphicx"
     "subcaption"
     "caption"
     "algpseudocode"
     "algorithm"
     "listings"
     "float"
     "placeins"
     "section"
     "cancel"
     "array"
     "mathrsfs"
     "amsthm"
     "amsfonts"
     "amsmath"
     "setspace"
     "geometry"
     "latex2e"
     "IEEEtran10"
     "IEEEtran"
     "twoside")))

