FROM nvidia/cuda:7.0-cudnn4-runtime

ARG DEBIAN_FRONTEND=noninteractive
RUN \
  apt-get update && \
  apt-get -y install python-numpy swig wget gcc perl unzip zlib1g-dev tar python-dev python-pip file git curl && \
  rm -rf /var/lib/apt/lists/*

RUN pip install wheel

RUN useradd -m user
COPY tensorflow-0.9.0rc0-cp27-none-linux_x86_64.whl /tmp/tensorflow_pkg/
RUN pip install /tmp/tensorflow_pkg/*
RUN pip install jupyter

RUN curl -L https://github.com/krallin/tini/releases/download/v0.6.0/tini > tini && \
    echo "d5ed732199c36a1189320e6c4859f0169e950692f451c03e7854243b95f4234b *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

USER user
RUN mkdir -p /home/user/notebooks
WORKDIR /home/user/notebooks
RUN mkdir -p -m 700 ~/.jupyter && echo "c.NotebookApp.ip = '*'" >> ~/.jupyter/jupyter_notebook_config.py
#ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu/
ENTRYPOINT ["tini", "--"]
CMD ["jupyter", "notebook", "--no-browser"]
