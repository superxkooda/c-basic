FROM debian:buster-slim as base
# Build a container that will have all the build tools we need to build and run our application.
RUN apt-get update && apt-get install -y gcc make
ARG project_dir=projects
ARG project=hello_world
COPY Makefile.base /app/
RUN ln -s /app/Makefile.base /app/Makefile
COPY ./${project_dir}/${project}/ /app/

FROM base as builder
# Here is where we will build our application
WORKDIR /app
RUN make
ENTRYPOINT ["/app/build/bin/the-basics"]

#FROM base as debugger

#WORKDIR /app
#RUN make debug
#ENTRYPOINT ["gdb" "/app/build/bin/the-basics"]

FROM debian:buster-slim as docs
# This installs Natural Docs and builds the documentation
# First we need mono. Following https://www.mono-project.com/download/stable/#download-lin-debian
RUN apt-get update && apt-get install -y apt-transport-https dirmngr gnupg ca-certificates unzip wget curl
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN echo "deb https://download.mono-project.com/repo/debian stable-buster main" > /etc/apt/sources.list.d/mono-official-stable.list
RUN apt-get update && apt-get install -y mono-runtime
#RUN apt-get update && apt-get install -y mono-devel
RUN wget https://www.naturaldocs.org/download/natural_docs/2.0.2/Natural_Docs_2.0.2.zip && \
    unzip Natural_Docs_2.0.2.zip && \
    rm Natural_Docs_2.0.2.zip
RUN mkdir /docs
COPY . /app
RUN mono /Natural\ Docs/NaturalDocs.exe /app/ndocs && \
    tar -cvf docs.tar docs && \
    rm -r docs

ENTRYPOINT ["cat", "/docs.tar"]
