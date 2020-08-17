FROM rackspacedot/python37

WORKDIR /app
ADD ./login_backend /app

RUN pip install flask
EXPOSE 12340

ENV MYSQL mysql
ENV FLASK_ENV prod

CMD ["/bin/bash", "-c", "sleep 3 && python app.py"]
