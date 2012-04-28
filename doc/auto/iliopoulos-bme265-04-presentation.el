(TeX-add-style-hook "iliopoulos-bme265-04-presentation"
 (lambda ()
    (LaTeX-add-bibliographies
     "refs-presentation.bib")
    (TeX-add-symbols
     '("mbs" 1)
     "newblock")
    (TeX-run-style-hooks
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
     "graphicx"
     "subcaption"
     "caption"
     "placeins"
     "section"
     "cancel"
     "array"
     "mathrsfs"
     "amsthm"
     "amsfonts"
     "amsmath"
     "setspace"
     "latex2e"
     "beamer12"
     "beamer"
     "12pt"
     "x11names")))

