FROM python:3.7-slim

# Modified:                                                      #
# https://qiita.com/tikogr/items/6b1e48e0143195a426d1#dockerfile #

ENV LANG C.UTF-8
ENV TZ Asia/Tokyo
ENV PYTHONUNBUFFERED 1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    libmecab-dev \
    mecab \
    mecab-ipadic-utf8 \
    tar \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# CRF++ (Cabocha dependency)
WORKDIR /tmp
RUN curl -Lo CRF++-0.58.tar.gz \
    'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7QVR6VXJ5dWExSTQ' \
    && tar zxf CRF++-0.58.tar.gz

WORKDIR /tmp/CRF++-0.58
RUN ./configure \
    && make \
    && make install \
    && ldconfig

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
    && python setup.py install \
    && ldconfig

WORKDIR /
RUN rm -rf /tmp/*

# pip
WORKDIR /home
RUN pip install --no-cache-dir \
    jupyterlab mecab-python3 numpy scipy \
    scikit-learn gensim pandas \
    && pip list
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root", "--NotebookApp.token=''"]
