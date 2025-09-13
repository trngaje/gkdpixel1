FROM i386/ubuntu:16.04

ENV TZ="Asia/Seoul" 
    
RUN apt -y update && apt -y install build-essential git unzip  wget nano zip && \
    apt -y install tzdata && ln -snf /usr/share/zoneinfo/Asia/Seoul /etc/localtime && \
    apt -y install --no-install-recommends locales wget && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/workspace

WORKDIR /root

RUN cd /opt/ && wget https://github.com/shauninman/union-gkdpixel-toolchain/releases/download/v001/gcw0-toolchain.zip && unzip gcw0-toolchain.zip && rm gcw0-toolchain.zip
RUN echo "export CROSS_COMPILE=/opt/gcw0-toolchain/usr/bin/mipsel-gcw0-linux-uclibc-" >> ~/.bashrc
RUN echo "export SYSROOT=/opt/gcw0-toolchain/usr/mipsel-gcw0-linux-uclibc/sysroot" >> ~/.bashrc
RUN echo "export CC=/opt/gcw0-toolchain/usr/bin/mipsel-gcw0-linux-uclibc-gcc" >> ~/.bashrc
RUN echo "export CXX=/opt/gcw0-toolchain/usr/bin/mipsel-gcw0-linux-uclibc-g++" >> ~/.bashrc
RUN echo "export AR=/opt/gcw0-toolchain/usr/bin/mipsel-gcw0-linux-uclibc-ar" >> ~/.bashrc
RUN echo "export LD=/opt/gcw0-toolchain/usr/bin/mipsel-gcw0-linux-uclibc-ld" >> ~/.bashrc

VOLUME /root/workspace
WORKDIR /root/workspace

ENV PATH="/opt/gcw0-toolchain/usr/bin:${PATH}:/opt/gcw0-toolchain/usr/mipsel-gcw0-linux-uclibc/sysroot/bin"
ENV CROSS_COMPILE=/opt/gcw0-toolchain/usr/bin/mipsel-gcw0-linux-uclibc-
ENV PREFIX=/opt/gcw0-toolchain/usr/mipsel-gcw0-linux-uclibc/sysroot/usr
ENV UNION_PLATFORM=gkdpixel

WORKDIR /root
RUN wget https://web.archive.org/web/20221208023418/https://mpg123.org/download/mpg123-1.25.10.tar.bz2
RUN tar -xvjf mpg123-1.25.10.tar.bz2
WORKDIR /root/mpg123-1.25.10
RUN ./configure --host=mipsel-gcw0-linux-uclibc --prefix=/usr
RUN make -j4

RUN cp /root/mpg123-1.25.10/src/libmpg123/mpg123.h /opt/gcw0-toolchain/usr/mipsel-gcw0-linux-uclibc/sysroot/usr/include/
RUN cp /root/mpg123-1.25.10/src/libmpg123/fmt123.h /opt/gcw0-toolchain/usr/mipsel-gcw0-linux-uclibc/sysroot/usr/include/
RUN cp /root/mpg123-1.25.10/src/libmpg123/.libs/libmpg123.so* /opt/gcw0-toolchain/usr/mipsel-gcw0-linux-uclibc/sysroot/usr/lib/

WORKDIR /root

CMD ["/bin/bash"]
