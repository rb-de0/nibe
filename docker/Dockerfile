FROM swift:5.4.1

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NOWARNINGS yes

RUN apt update
RUN apt install -y mecab libmecab-dev mecab-ipadic-utf8
RUN apt install -y sqlite3 libsqlite3-dev