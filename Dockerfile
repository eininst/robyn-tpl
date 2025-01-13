FROM python:3.13.1

WORKDIR /app

#COPY requirements.txt /app/
#
#RUN pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/
#
#COPY . /app
#
#STOPSIGNAL SIGTERM
#
#ENTRYPOINT /usr/local/bin/uwsgi /app/config/uwsgi.yaml
