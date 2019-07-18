FROM python:3

WORKDIR /usr/src/app

RUN python3 -m pip install --user --no-warn-script-location aws-sam-cli

ENTRYPOINT [ "/usr/src/app/entrypoint.sh" ]
