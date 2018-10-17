all: install.html install_slides.html

install.html: install.md
	pandoc -s -o install.html install.md

install_slides.html: install.md
	pandoc -s --webtex -t slidy -o install_slides.html install.md

clean:
	rm -rf install.html
