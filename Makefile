# build package documentation
doc:
	R -e 'devtools::document()'

check:
	R -e 'devtools::check()'

install:
	R -e 'remotes::install_github("super-lou/NCf")'

documentation:
	python3 generate_documentation.py
