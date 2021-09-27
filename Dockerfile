FROM python:3.7.12-alpine3.14
##################################################################
# For:                                                           #
# 言語処理100本ノック ・ http://www.cl.ecei.tohoku.ac.jp/nlp100/    #
# Usage:                                                         #
# $ docker build -t jupyter .                                    #
# $ docker run -v $PWD:/local_home -p 10000:8888 jupyter         #
# $ xdg-open http://localhost:10000                              #
# Modified:                                                      #
# https://qiita.com/tikogr/items/6b1e48e0143195a426d1#dockerfile #
##################################################################

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV LANG C.UTF-8
ENV TZ Asia/Tokyo
ENV PYTHONUNBUFFERED 1

RUN apk add --no-cache \
    bash build-base curl gfortran \
    git libffi-dev linux-headers swig

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

# CRF++ (Cabochaで必要)
WORKDIR /tmp
RUN curl -o CRF++-0.58.tar.gz \
    'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7QVR6VXJ5dWExSTQ' \
    && tar zxf CRF++-0.58.tar.gz

WORKDIR /tmp/CRF++-0.58 
RUN ./configure \
    && make \
    && make install

# Cabocha
WORKDIR /tmp
RUN curl -L -b cookies.txt -o /tmp/cabocha-0.69.tar.bz2 \
    "https://drive.google.com$( \
    curl -c cookies.txt \
    'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7SDd1Q1dUQkZQaUU' \
    | sed -r 's/"/\n/g' | grep id=0B4y35FiV1wh7SDd1Q1dUQkZQaUU \
    | grep confirm | sed 's/&amp;/\&/g' \
    )" \
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
    scikit-learn gensim pandas
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]
