FROM python:alpine

WORKDIR /usr/src/app
COPY . .

RUN apk update && \
    apk upgrade && \
    apk add bash && \
    apk add --no-cache --virtual build-deps build-base gcc && \
    pip install aws-sam-cli==0.14.0 && \
    apk del build-deps

ENTRYPOINT [ "/usr/src/app/entrypoint.sh" ]
