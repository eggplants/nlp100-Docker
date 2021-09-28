FROM python:3.7-slim

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV TZ Asia/Tokyo
ENV PYTHONUNBUFFERED 1
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    libmecab-dev \
    mecab \
    mecab-ipadic-utf8 \
    tar \
    locales \
    sudo \
    xz-utils file \
    fonts-noto-cjk \
    graphviz \
    && apt-get autoremove \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/*

ENV LANG C.UTF-8
RUN locale-gen ja_JP.UTF-8


# Neologd
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git \
    && mecab-ipadic-neologd/bin/install-mecab-ipadic-neologd -y -n \
    && echo "dicdir = /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd" \
    > /etc/mecabrc

WORKDIR /
RUN rm -rf /tmp/*

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

# pip
WORKDIR /home
RUN pip install --no-cache-dir \
    jupyterlab mecab-python3 numpy scipy \
    scikit-learn gensim pandas \
    requests matplotlib pydot graphviz nltk

RUN : \
    && echo "font.serif      :" \
            "Noto Serif CJK JP, DejaVu Serif, DejaVu Serif, Bitstream Vera Serif," \
            "Computer Modern Roman, New Century Schoolbook, Century Schoolbook L," \
            "Utopia, ITC Bookman, Bookman, Nimbus Roman No9 L, Times New Roman, Times, Palatino" \
       >> /usr/local/lib/python3.7/site-packages/matplotlib/mpl-data/matplotlibrc \
    && echo "font.sans-serif :" \
            "Noto Sans CJK JP, DejaVu Sans, Bitstream Vera Sans, Computer Modern Sans Serif," \
            "Lucida Grande, Verdana, Geneva, Lucid, Arial, Helvetica, Avant Garde, sans-serif" \
       >> /usr/local/lib/python3.7/site-packages/matplotlib/mpl-data/matplotlibrc \
    && rm -rf ~/.cache/matplotlib

CMD ["jupyter", "notebook", \
     "--port=8888", "--no-browser", \
     "--ip=0.0.0.0", "--allow-root", \
     "--NotebookApp.token=''"]
