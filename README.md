# nlp100-Docker

[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/eggplanter/nlp100)](https://hub.docker.com/r/eggplanter/nlp100)

A Docker image for [nlp100](http://www.cl.ecei.tohoku.ac.jp/nlp100/)

## Usage

### Build

```bash
docker pull eggplanter/nlp100
```

or

```bash
git clone --depth 1 https://github.com/eggplants/nlp100_docker
cd nlp100_docker
docker build -t eggplanter/nlp100 .
```

### Run

```bash
docker run -v $(pwd):/home/local_home/ -p 10000:8888 eggplanter/nlp100
```

or

```bash
curl -sL https://git.io/Jz5ec | docker-compose -f- up -d
```

### Open Notebook

Go to <http://localhost:10000>

## License

- CRF++, Cabocha
  - [LGPL](http://www.gnu.org/copyleft/lesser.html) or [new BSD License](http://www.opensource.org/licenses/bsd-license.php)

## References

- [nlp100-image/Dockerfile at master · moisutsu/nlp100-image](https://github.com/moisutsu/nlp100-image/blob/master/Dockerfile)
- [Python/NLP/機械学習のためのDocker環境構築 - Qiita](https://qiita.com/tikogr/items/6b1e48e0143195a426d1#dockerfile)
- [myword-cloud/Dockerfile at main · Amakuchisan/myword-cloud](https://github.com/Amakuchisan/myword-cloud/blob/423bce27868bb421244d9c09919f07eb843327bf/Dockerfile)
