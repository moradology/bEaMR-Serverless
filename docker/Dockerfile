FROM public.ecr.aws/emr-serverless/spark/emr-6.9.0:latest as builder

USER root

# GDAL build steps are modified from https://github.com/lambgeo/docker-lambda/tree/master
RUN yum update -y && \
    yum install -y git autoconf automake libtool flex bison \
      cmake make tar gzip gcc gcc-c++ automake16 libpng-devel \
      nasm libxml2-devel readline-devel openssl11-devel curl-devel \
      cmake3 git golang swig libffi-devel bzip2-devel && \
    yum clean all && \
    rm -rf /var/cache/yum /var/lib/yum/history

ENV PREFIX /opt

WORKDIR /opt

ENV LD_LIBRARY_PATH $PREFIX/lib:$LD_LIBRARY_PATH

# pkg-config
ENV PKGCONFIG_VERSION=0.29.2
RUN mkdir /tmp/pkg-config \
  && curl -sfL https://pkg-config.freedesktop.org/releases/pkg-config-${PKGCONFIG_VERSION}.tar.gz | tar zxf - -C /tmp/pkg-config --strip-components=1 \
  && cd /tmp/pkg-config \
  && CFLAGS="-O2 -Wl,-S" ./configure --prefix=$PREFIX --with-internal-glib \
  && make -j $(nproc) --silent && make install && make clean \
  && rm -rf /tmp/pkg-config

ENV PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/

# sqlite
RUN mkdir /tmp/sqlite \
  && curl -sfL https://www.sqlite.org/2020/sqlite-autoconf-3330000.tar.gz | tar zxf - -C /tmp/sqlite --strip-components=1 \
  && cd /tmp/sqlite \
  && CFLAGS="-O2 -Wl,-S" CXXFLAGS="-O2 -Wl,-S" ./configure --prefix=$PREFIX --disable-static \
  && make -j $(nproc) --silent && make install && make clean \
  && rm -rf /tmp/sqlite

# libexpat
RUN mkdir /tmp/libexpat \
  && curl -sfL https://github.com/libexpat/libexpat/releases/download/R_2_2_10/expat-2.2.10.tar.gz | tar zxf - -C /tmp/libexpat --strip-components=1 \
  && cd /tmp/libexpat \
  && CFLAGS="-O2 -Wl,-S" CXXFLAGS="-O2 -Wl,-S" ./configure --prefix=$PREFIX --disable-static \
  && make -j $(nproc) --silent && make install && make clean \
  && rm -rf /tmp/libexpat

ENV \
  SQLITE3_LIBS="-L${PREFIX}/lib -lsqlite3" \
  SQLITE3_INCLUDE_DIR="${PREFIX}/include" \
  SQLITE3_CFLAGS="$CFLAGS -I${PREFIX}/include" \
  PATH=${PREFIX}/bin/:$PATH

# nghttp2
ENV NGHTTP2_VERSION=1.42.0
RUN mkdir /tmp/nghttp2 \
  && curl -sfL https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_VERSION}/nghttp2-${NGHTTP2_VERSION}.tar.gz | tar zxf - -C /tmp/nghttp2 --strip-components=1 \
  && cd /tmp/nghttp2 \
  && ./configure --enable-lib-only --prefix=$PREFIX \
  && make -j $(nproc) --silent && make install \
  && rm -rf /tmp/nghttp2

# libcurl
ENV CURL_VERSION=7.73.0
RUN mkdir /tmp/libcurl \
  && curl -sfL https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz | tar zxf - -C /tmp/libcurl --strip-components=1 \
  && cd /tmp/libcurl \
  && ./configure --disable-manual --disable-cookies --with-nghttp2=$PREFIX --prefix=$PREFIX \
  && make -j $(nproc) --silent && make install \
  && rm -rf /tmp/libcurl

# libdeflate
RUN mkdir /tmp/libdeflate \
  && curl -sfL https://github.com/ebiggers/libdeflate/archive/v1.10.tar.gz | tar zxf - -C /tmp/libdeflate --strip-components=1 \
  && cd /tmp/libdeflate \
  && make -j $(nproc) --silent PREFIX=$PREFIX && make install \
  && rm -rf /tmp/libdeflate

# libpng
ENV LIBPNG_VERSION=1.6.37
RUN mkdir /tmp/png \
  && curl -sfL https://github.com/glennrp/libpng/archive/v${LIBPNG_VERSION}.tar.gz | tar zxf - -C /tmp/png --strip-components=1 \
  && cd /tmp/png \
  && CFLAGS="-O2 -Wl,-S" CXXFLAGS="-O2 -Wl,-S" ./configure --prefix=$PREFIX \
  && make -j $(nproc) --silent && make install \
  && rm -rf /tmp/png

# zstd
ENV ZSTD_VERSION=1.4.5
RUN mkdir /tmp/zstd \
  && curl -sfL https://github.com/facebook/zstd/archive/v${ZSTD_VERSION}.tar.gz | tar zxf - -C /tmp/zstd --strip-components=1 \
  && cd /tmp/zstd \
  && make -j $(nproc) PREFIX=$PREFIX ZSTD_LEGACY_SUPPORT=0 CFLAGS=-O1 --silent && make install PREFIX=$PREFIX ZSTD_LEGACY_SUPPORT=0 CFLAGS=-O1 \
  && rm -rf /tmp/zstd

# libjpeg_turbo
ENV LIBJPEG_TURBO_VERSION=2.1.3
RUN mkdir /tmp/jpeg \
  && curl -sfL https://github.com/libjpeg-turbo/libjpeg-turbo/archive/${LIBJPEG_TURBO_VERSION}.tar.gz | tar zxf - -C /tmp/jpeg --strip-components=1 \
  && cd /tmp/jpeg \
  && mkdir build && cd build \
  && cmake3 .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR:PATH=lib \
    -DCMAKE_C_FLAGS="-O2 -Wl,-S" \
    -DCMAKE_CXX_FLAGS="-O2 -Wl,-S" \
  && make -j $(nproc) --silent && make install \
  && rm -rf /tmp/jpeg

# webp
ENV WEBP_VERSION=1.1.0
RUN mkdir /tmp/webp \
  && curl -sfL https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${WEBP_VERSION}.tar.gz | tar zxf - -C /tmp/webp --strip-components=1 \
  && cd /tmp/webp \
  && CFLAGS="-O2 -Wl,-S" ./configure --prefix=$PREFIX \
  && make -j $(nproc) --silent && make install \
  && rm -rf /tmp/webp


# lerc
ENV LERC_VERSION=2.2.1
RUN mkdir /tmp/lerc \
  && curl -sfL https://github.com/Esri/lerc/archive/v${LERC_VERSION}.tar.gz | tar zxf - -C /tmp/lerc --strip-components=1 \
  && cd /tmp/lerc \
  && cmake3 . \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR:PATH=lib \
    -DCMAKE_C_FLAGS="-O2 -Wl,-S" \
    -DCMAKE_CXX_FLAGS="-O2 -Wl,-S" \
  && make -j $(nproc) --silent && make install \
  && rm -rf /tmp/lerc

# libtiff
ENV LIBTIFF_VERSION=4.5.0
RUN mkdir /tmp/libtiff \
  && curl -sfL https://download.osgeo.org/libtiff/tiff-${LIBTIFF_VERSION}.tar.gz | tar zxf - -C /tmp/libtiff --strip-components=1 \
  && cd /tmp/libtiff \
  && LDFLAGS="-Wl,-rpath,'\$\$ORIGIN'" CFLAGS="-O2 -Wl,-S" CXXFLAGS="-O2 -Wl,-S" ./configure \
    --prefix=$PREFIX \
    --disable-static \
    --enable-rpath \
    --with-lerc-lib-dir=$PREFIX/lib \
    --with-lerc-include-dir=$PREFIX/include \
    --with-libdeflate-lib-dir=$PREFIX/lib \
    --with-libdeflate-include-dir=$PREFIX/include \
    --with-jpeg-lib-dir=$PREFIX/lib \
    --with-jpeg-include-dir=$PREFIX/include \
  && make -j $(nproc) --silent && make install \
  && rm -rf /tmp/libtiff

# postgres
ENV PG_VERSION=15.2
RUN mkdir /tmp/postgres \
  && curl -sfL https://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.gz | tar zxf - -C /tmp/postgres --strip-components=1 \
  && cd /tmp/postgres \
  && CFLAGS="-O2 -Wl,-S" CXXFLAGS="-O2 -Wl,-S" ./configure --prefix=$PREFIX --with-openssl \
  && make -j $(nproc) --silent && make install \
  && rm -rf /tmp/postgres

# openjpeg
ENV OPENJPEG_VERSION=2.5.0
RUN mkdir /tmp/openjpeg \
  && curl -sfL https://github.com/uclouvain/openjpeg/archive/v${OPENJPEG_VERSION}.tar.gz | tar zxf - -C /tmp/openjpeg --strip-components=1 \
  && cd /tmp/openjpeg \
  && mkdir build && cd build \
  && cmake3 .. \
    -DBUILD_THIRDPARTY:BOOL=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR:PATH=lib \
    -DCMAKE_C_FLAGS="-O2 -Wl,-S" \
    -DCMAKE_CXX_FLAGS="-O2 -Wl,-S" \
  && make -j $(nproc) --silent && make install \
  && rm -rf /tmp/openjpeg

# geos
ENV GEOS_VERSION=3.11.2
RUN mkdir /tmp/geos \
  && curl -sfL https://github.com/libgeos/geos/archive/refs/tags/${GEOS_VERSION}.tar.gz | tar zxf - -C /tmp/geos --strip-components=1 \
  && cd /tmp/geos \
  && mkdir build && cd build \
  && cmake3 .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR:PATH=lib \
    -DCMAKE_C_FLAGS="-O2 -Wl,-S" \
    -DCMAKE_CXX_FLAGS="-O2 -Wl,-S" \
  && make -j $(nproc) --silent && make install \
  && rm -rf /tmp/geos

# proj
ENV PROJ_VERSION=9.2.0
RUN mkdir /tmp/proj && mkdir /tmp/proj/data \
  && curl -sfL https://github.com/OSGeo/proj/archive/${PROJ_VERSION}.tar.gz | tar zxf - -C /tmp/proj --strip-components=1 \
  && cd /tmp/proj \
  && mkdir build && cd build \
  && cmake3 .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR:PATH=lib \
    -DCMAKE_INSTALL_INCLUDEDIR:PATH=include \
    -DBUILD_TESTING=OFF \
    -DCMAKE_C_FLAGS="-O2 -Wl,-S" \
    -DCMAKE_CXX_FLAGS="-O2 -Wl,-S" \
  && make -j $(nproc) --silent && make install \
  && rm -rf /tmp/proj

# GeoTIFF
ENV LIBGEOTIFF_VERSION=1.7.1
RUN mkdir /tmp/libgeotiff \
  && curl -sfL https://github.com/OSGeo/libgeotiff/releases/download/${LIBGEOTIFF_VERSION}/libgeotiff-${LIBGEOTIFF_VERSION}.tar.gz | tar zxf - -C /tmp/libgeotiff --strip-components=1 \
  && cd /tmp/libgeotiff \
  && LDFLAGS="-Wl,-rpath,'\$\$ORIGIN'" CFLAGS="-O2 -Wl,-S" CXXFLAGS="-O2 -Wl,-S" ./configure \
    --prefix=$PREFIX \
    --with-proj=$PREFIX \
    --with-jpeg=$PREFIX \
    --with-zip=yes \
    --with-zlib \
    --with-libtiff=$PREFIX \
  && make -j $(nproc) --silent && make install \
  && rm -rf /tmp/libgeotiff

# Build blosc (needed for ZARR)
ENV BLOSC_VERSION=1.21.0
RUN mkdir /tmp/blosc \
  && curl -sfL https://github.com/Blosc/c-blosc/archive/refs/tags/v${BLOSC_VERSION}.tar.gz | tar zxf - -C /tmp/blosc --strip-components=1 \
  && cd /tmp/blosc \
  && cmake3 -G"Unix Makefiles" \
    -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR:PATH=lib \
    -DCMAKE_INSTALL_RPATH="$ORIGIN" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="-O2 -Wl,-S" \
    -DCMAKE_CXX_FLAGS="-O2 -Wl,-S" \
    -DBUILD_SHARED=ON \
    -DBUILD_STATIC=OFF \
    -DBUILD_BENCHMARKS=OFF \
    -DBUILD_FUZZERS=OFF \
    -DBUILD_TESTS=OFF \
    -DPREFER_EXTERNAL_LZ4=ON \
    -DPREFER_EXTERNAL_ZLIB=ON \
    -DPREFER_EXTERNAL_ZSTD=ON \
    -DDEACTIVATE_SNAPPY=OFF . \
  && make -j $(nproc) --silent && make install && make clean \
  && rm -rf /tmp/blosc

# libcrypto (for GPC access)
RUN mkdir /tmp/cryptopp \
  && curl -sfL https://github.com/weidai11/cryptopp/archive/refs/tags/CRYPTOPP_8_6_0.tar.gz | tar zxf - -C /tmp/cryptopp --strip-components=1 \
  && cd /tmp/cryptopp \
  && make -j $(nproc) --silent && make install PREFIX=$PREFIX \
  && rm -rf /tmp/cryptopp

# szip (for hdf)
ENV SZIP_VERSION=2.1.1
RUN mkdir /tmp/szip \
  && curl -sfL https://support.hdfgroup.org/ftp/lib-external/szip/${SZIP_VERSION}/src/szip-${SZIP_VERSION}.tar.gz | tar zxf - -C /tmp/szip --strip-components=1 \
  && cd /tmp/szip \
  && CFLAGS="-O2 -Wl,-S" CXXFLAGS="-O2 -Wl,-S" ./configure --prefix=$PREFIX --disable-static \
  && make -j $(nproc) --silent && make install && make clean \
  && rm -rf /tmp/szip

# libhdf4
ENV HDF4_VERSION=4.2.15
RUN mkdir /tmp/hdf4 \
  && curl -sfL https://support.hdfgroup.org/ftp/HDF/releases/HDF${HDF4_VERSION}/src/hdf-${HDF4_VERSION}.tar | tar xvf - -C /tmp/hdf4 --strip-components=1 \
  && cd /tmp/hdf4 \
  && CFLAGS="-O2 -Wl,-S" CXXFLAGS="-O2 -Wl,-S" ./configure \
  --prefix=$PREFIX \
  --with-szlib=$PREFIX \
  --with-jpeg=$PREFIX \
  --enable-shared \
  --disable-static \
  --disable-netcdf \
  --disable-fortran \
  && make -j $(nproc) --silent && make install && make clean \
  && rm -rf /tmp/hdf4

# libhdf5
ENV HDF5_VERSION=1.12.0
RUN mkdir /tmp/hdf5 \
  && curl -sfL https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${HDF5_VERSION%.*}/hdf5-${HDF5_VERSION}/src/hdf5-$HDF5_VERSION.tar.gz | tar zxf - -C /tmp/hdf5 --strip-components=1 \
  && cd /tmp/hdf5 \
  && CFLAGS="-O2 -Wl,-S" CXXFLAGS="-O2 -Wl,-S" ./configure \
  --prefix=$PREFIX \
  --with-szlib=$PREFIX \
  --enable-cxx \
  --enable-thread-safe \
  --disable-static \
  && make -j $(nproc) --silent && make install && make clean \
  && rm -rf /tmp/hdf5

# NetCDF
ENV NETCDF_VERSION=4.7.4
RUN mkdir /tmp/netcdf \
  && curl -sfL https://github.com/Unidata/netcdf-c/archive/v${NETCDF_VERSION}.tar.gz | tar zxf - -C /tmp/netcdf --strip-components=1 \
  && cd /tmp/netcdf \
  && CFLAGS="-O2 -Wl,-S" CXXFLAGS="-O2 -Wl,-S" CPPFLAGS="-I${PREFIX}/include" LDFLAGS="-L${PREFIX}/lib" ./configure \
  --with-default-chunk-size=67108864 \
  --with-chunk-cache-size=67108864 \
  --prefix=$PREFIX \
  --disable-static \
  --enable-netcdf4 \
  --enable-dap \
  --with-pic \
  && make -j $(nproc) --silent && make install && make clean \
  && rm -rf /tmp/netcdf

# brotli
ENV BROTLI_VERSION=1.0.9
RUN mkdir /tmp/brotli \
  && curl -sfL https://github.com/google/brotli/archive/refs/tags/v${BROTLI_VERSION}.tar.gz | tar zxf - -C /tmp/brotli --strip-components=1 \
  && cd /tmp/brotli \
  && mkdir build && cd build \
  && CFLAGS="-O2 -Wl,-S" CXXFLAGS="-O2 -Wl,-S" ../configure-cmake --prefix=$PREFIX \
  # && make -j $(nproc) --silent && make install && make clean \
  && rm -rf /tmp/brotli

# Python 3.11.7
RUN mkdir /tmp/python \
  && curl -fsSL https://www.python.org/ftp/python/3.11.7/Python-3.11.7.tgz | tar -xzC /tmp/python --strip-components=1 \
  && cd /tmp/python \
  && ./configure --prefix=/opt/python/3.11.7/ --enable-optimizations --with-lto --with-computed-gotos --with-system-ffi --enable-shared \
  && make -j "$(nproc)" \
  && make altinstall \
  && rm -rf /tmp/python

ENV LD_LIBRARY_PATH=/opt/python/3.11.7/lib:$LD_LIBRARY_PATH

RUN /opt/python/3.11.7/bin/python3.11 -m pip install --upgrade pip setuptools wheel \
  && ln -s /opt/python/3.11.7/bin/python3.11 /opt/python/3.11.7/bin/python3 \
  && ln -s /opt/python/3.11.7/bin/python3.11 /opt/python/3.11.7/bin/python \
  && ln -s /opt/python/3.11.7/bin/pydoc3.11 /opt/python/3.11.7/bin/pydoc \
  && ln -s /opt/python/3.11.7/bin/idle3.11 /opt/python/3.11.7/bin/idle \
  && ln -s /opt/python/3.11.7/bin/python3.11-config /opt/python/3.11.7/bin/python-config

ENV PATH=/opt/python/3.11.7/bin:$PATH

# Python deps
COPY requirements.txt /tmp/requirements.txt
RUN pip install numpy
RUN pip install -r /tmp/requirements.txt

# GDAL
RUN mkdir /tmp/gdal \
  && curl -sfL https://github.com/OSGeo/gdal/archive/refs/tags/v3.8.3.tar.gz | tar zxf - -C /tmp/gdal --strip-components=1 \
  && cd /tmp/gdal \
  && mkdir build && cd build \
  && cmake3 .. \
    -DGDAL_USE_EXTERNAL_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR:PATH=lib \
    -DCMAKE_C_FLAGS="-O2 -Wl,-S" \
    -DCMAKE_CXX_FLAGS="-O2 -Wl,-S" \
    -DGDAL_SET_INSTALL_RELATIVE_RPATH=ON \
    -DGDAL_USE_TIFF_INTERNAL=OFF \
    -DGDAL_USE_GEOTIFF_INTERNAL=OFF \
    -DGDAL_USE_LERC_INTERNAL=OFF \
    -DLERC_INCLUDE_DIR=$PREFIX/include \
    -DLERC_LIBRARY=$PREFIX/lib/libLercLib.so \
    -DPNG_PNG_INCLUDE_DIR=$PREFIX/include \
    -DPNG_LIBRARY_RELEASE=$PREFIX/lib/libpng.so \
    -DBUILD_PYTHON_BINDINGS=ON \
  && make -j $(nproc) --silent && make install \
  && rm -rf /tmp/gdal

# libturbojpeg.so is not used by GDAL. Only libjpeg.so*
RUN rm -f $PREFIX/lib/libturbojpeg.so* \
  # Only libwebp.so is used by GDAL
  && rm -f  $PREFIX/lib/libwebpmux.so*  $PREFIX/lib/libwebpdemux.so* $PREFIX/lib/libwebpdecoder.so*

# Build the binary to boot beam processes
RUN cd /opt && git clone --branch v2.51.0 --single-branch https://github.com/apache/beam.git; \
    cd /opt/beam && ./gradlew :sdks:python:container:build && \
    cp sdks/python/container/build/target/launcher/linux_amd64/boot /home/hadoop/boot; \
    chmod +x /home/hadoop/boot; \
    rm -rf /opt/beam


FROM public.ecr.aws/emr-serverless/spark/emr-6.9.0:latest as runner

USER root
ENV PREFIX /opt

COPY --from=builder /opt /opt
COPY --from=builder /home/hadoop /home/hadoop

ENV \
  GDAL_DATA=$PREFIX/share/gdal \
  PROJ_LIB=$PREFIX/share/proj \
  GDAL_CONFIG=$PREFIX/bin/gdal-config \
  GEOS_CONFIG=$PREFIX/bin/geos-config \
  LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/lib:/opt/python/3.11.7/lib \
  PATH=/opt/python/3.11.7/bin:$PREFIX/bin:$PATH

# Linkage for gdal
RUN echo '/opt/lib' >> /etc/ld.so.conf && ldconfig

WORKDIR /home/hadoop
USER hadoop:hadoop