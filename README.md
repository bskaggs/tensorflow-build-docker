Docker builder for TensorFlow
=============================

A CentOS-based Docker capable of building Tensorflow from source.

Build Instructions:`
* Upload cuda_7.0.28_linux.run and cudnn-6.5-linux-x64-v2.tgz to a common base URL
* docker build -t tensorflow --build-arg BASE=https://... .

