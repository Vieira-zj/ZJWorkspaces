# build Pymysql + Flask env.
#
FROM rackspacedot/python37

WORKDIR /app
# ADD ./login_backend /app

RUN pip install flask
EXPOSE 12340

ENV MYSQL localhost
ENV FLASK_ENV test

CMD ["/bin/bash", "-c", "while true; do echo 'hello'; sleep 10; done"]
# CMD ["/bin/bash", "-c", "python app.py"]