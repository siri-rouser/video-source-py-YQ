FROM python:3.10-slim as build

RUN apt update && apt install --no-install-recommends -y \
    curl \
    git \
    build-essential

ARG POETRY_VERSION
ENV POETRY_HOME=/opt/poetry
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="${POETRY_HOME}/bin:${PATH}"

# Copy only files that are necessary to install dependencies
COPY poetry.lock poetry.toml pyproject.toml /code/

WORKDIR /code
RUN --mount=type=secret,id=GIT_CREDENTIALS,target=/root/.git-credentials \
    git config --global credential.helper store && \
    poetry install
    
# Copy the rest of the project
COPY . /code/


### Main artifact / deliverable image

FROM python:3.10-slim
RUN apt update && apt install --no-install-recommends -y \
    libglib2.0-0 \
    libgl1
COPY --from=build /code /code
WORKDIR /code
ENV PATH="/code/.venv/bin:$PATH"
CMD [ "python", "run_stage.py" ]