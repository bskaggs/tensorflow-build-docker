FROM centos:7
ARG BASE
RUN [ ! -z "$BASE" ] || (>&2 echo You must specify a URL at build time with --build-arg BASE=http://... && exit 1)

ENV CUDA cuda_7.0.28_linux.run
ENV CUDNN cudnn-6.5-linux-x64-v2

RUN yum -y install epel-release && yum -y update && yum -y install numpy swig wget gcc perl java-1.8.0-openjdk-devel gcc-c++ unzip zlib-devel tar which python-devel python-pip file git && yum clean all
RUN curl -L $BASE/$CUDA > /tmp/cuda.run && sh /tmp/cuda.run --silent --toolkit --override && rm -f /tmp/cuda.run
RUN curl -L $BASE/${CUDNN}.tgz > /tmp/${CUDNN}.tgz && tar -C /tmp -x --no-same-owner -f /tmp/${CUDNN}.tgz && cp /tmp/$CUDNN/cudnn.h /usr/local/cuda/include && cp /tmp/$CUDNN/libcudnn* /usr/local/cuda/lib64 && rm -rf /tmp/${CUDNN}*

RUN echo 'export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64"' >> /etc/profile.d/cuda.sh
RUN echo 'export CUDA_HOME=/usr/local/cuda' >> /etc/profile.d/cuda.sh
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0

RUN curl -L https://github.com/bazelbuild/bazel/releases/download/0.1.1/bazel-0.1.1-installer-linux-x86_64.sh > /opt/bazel-installer.sh && chmod +x /opt/bazel-installer.sh && /opt/bazel-installer.sh && rm /opt/bazel-installer.sh
RUN pip install wheel

RUN adduser -m user
USER user
WORKDIR /home/user
RUN git clone --recurse-submodules -b 0.6.0 https://github.com/tensorflow/tensorflow.git
WORKDIR /home/user/tensorflow

RUN (echo; echo Y; echo; echo) | ./configure 
RUN bazel --batch fetch --config=cuda //tensorflow/tools/pip_package:build_pip_package
RUN bazel --batch build --fetch=false -c opt --config=cuda --spawn_strategy=standalone --genrule_strategy=standalone //tensorflow/tools/pip_package:build_pip_package
RUN bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
