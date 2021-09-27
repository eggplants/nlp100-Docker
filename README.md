# nlp100-Docker

A Docker image for [nlp100](http://www.cl.ecei.tohoku.ac.jp/nlp100/)

## Usage

### build

```bash
git clone --depth 1 https://github.com/eggplants/nlp100_docker
cd nlp100_docker
docker build -t eggplanter/nlp100 .
# or ...
docker pull eggplanter/nlp100
```

### Run

```bash
docker run -v $(pwd):/home/local_home/ -p 10000:8888 eggplanter/nlp100
xdg-open http://localhost:10000
```

## License

- CRF++, Cabocha
  - [LGPL](http://www.gnu.org/copyleft/lesser.html) or [new BSD License](http://www.opensource.org/licenses/bsd-license.php)

## References

<https://qiita.com/tikogr/items/6b1e48e0143195a426d1#dockerfile>
