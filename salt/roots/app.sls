app-pkgs:
  pkg.installed:
    - pkgs:
      - git
      - firefox
      - xorg-x11-server-Xvfb

ImageMagick-deps:
  pkg.installed:
    - pkgs:
      - tcl-devel
      - libpng-devel
      - ghostscript-devel
      - bzip2-devel
      - freetype-devel
      - libtiff-devel
      - libjpeg-turbo-devel

ImageMagick:
  cmd.run:
    - name: wget http://www.imagemagick.org/download/ImageMagick.tar.gz && tar xvfz ImageMagick.tar.gz && cd ImageMagick-6.8.6-4 && ./configure --prefix=/usr/local --with-bzlib=yes --with-fontconfig=yes --with-freetype=yes --with-gslib=yes --with-gvc=yes --with-jpeg=yes --with-jp2=yes --with-png=yes --with-tiff=yes && make clean && make && sudo make install
    - unless: stat ~/ImageMagick.tar.gz
    - cwd: ~
    - user: vagrant
    - require:
      - pkg: ImageMagick-deps