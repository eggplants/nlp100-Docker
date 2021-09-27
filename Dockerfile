FROM python:3.7.12-alpine3.14

# Modified:                                                      #
# https://qiita.com/tikogr/items/6b1e48e0143195a426d1#dockerfile #

ENV LANG C.UTF-8
ENV TZ Asia/Tokyo
ENV PYTHONUNBUFFERED 1

RUN apk add --no-cache \
    bash==5.1.4-r0 \
    build-base==0.5-r2 \
    curl==7.79.1-r0 \
    gfortran==10.3.1_git20210424-r2 \
    git==2.32.0-r0 \
    libffi-dev==3.3-r2 \
    linux-headers==5.10.41-r0 \
    swig==4.0.2-r2

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Mecab
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/taku910/mecab.git

WORKDIR /tmp/mecab/mecab
RUN ./configure --enable-utf8-only --with-charset=utf8 \
    && make \
    && make install

WORKDIR /tmp/mecab/mecab-ipadic
RUN ./configure --with-charset=utf8 \
    && make \
    && make install

# CRF++ (Cabocha dependency)
WORKDIR /tmp
RUN curl -Lo CRF++-0.58.tar.gz \
    'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7QVR6VXJ5dWExSTQ' \
    && tar zxf CRF++-0.58.tar.gz

WORKDIR /tmp/CRF++-0.58 
RUN ./configure \
    && make \
    && make install

# Cabocha
WORKDIR /tmp
RUN DL="https://drive.google.com$( \
    curl -c cookies.txt \
    'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7SDd1Q1dUQkZQaUU' \
    | sed -r 's/"/\n/g' | grep id=0B4y35FiV1wh7SDd1Q1dUQkZQaUU \
    | grep confirm | sed 's/&amp;/\&/g' \
    )" \
    && curl -L -b cookies.txt -o /tmp/cabocha-0.69.tar.bz2 "$DL"\
    && tar jxf cabocha-0.69.tar.bz2

WORKDIR /tmp/cabocha-0.69
RUN ./configure \
    --with-mecab-config="$(which mecab-config)" \
    --with-charset=utf8 \
    && make \
    && make install

WORKDIR /tmp/cabocha-0.69/python
RUN python setup.py build \
    && python setup.py install

# LAPACK/BLAS (scikit-learnで必要)
WORKDIR /tmp
RUN curl -o lapack-3.8.0.tar.gz \
    'http://www.netlib.org/lapack/lapack-3.8.0.tar.gz' \
    && tar zxf lapack-3.8.0.tar.gz

WORKDIR /tmp/lapack-3.8.0
RUN cp make.inc.example make.inc \
    && make blaslib \
    && make lapacklib \
    && cp librefblas.a /usr/lib/libblas.a \
    && cp liblapack.a /usr/lib/liblapack.a

WORKDIR /
RUN rm -rf /tmp/*

# pip
WORKDIR /home
RUN pip install --no-cache-dir pip==21.2.4 \
    && pip install --no-cache-dir \
    jupyterlab mecab-python3 numpy scipy \
    scikit-learn gensim pandas \
    && pip list
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]
