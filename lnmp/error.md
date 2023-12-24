-  WARNING: Image for service nginx was built because it did not already exist. To rebuild this image you must use `docker-compose build` or `docker-compose up --build`.
- Installing header files:          /usr/local/include/php/
  find . -name \*.gcno -o -name \*.gcda | xargs rm -f
  find . -name \*.lo -o -name \*.o | xargs rm -f
  find . -name \*.la -o -name \*.a | xargs rm -f
  find . -name \*.so | xargs rm -f
  find . -name .libs -a -type d|xargs rm -rf
  rm -f libphp.la       modules/* libs/*
  WARNING: Ignoring APKINDEX.b3d2069c.tar.gz: No such file or directory
  WARNING: Ignoring APKINDEX.8d865ef8.tar.gz: No such file or directory
 
  
- ./configure: line 1: /usr/bin/file: not found  

- checking for gawk... configure: WARNING: You will need re2c 0.13.4 or later if you want to regenerate PHP parsers.