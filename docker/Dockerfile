# Dockerfile
FROM public.ecr.aws/emr-serverless/spark/emr-6.9.0:latest

USER root

# Install development tools and dependencies
RUN yum update -y && \
    yum install git golang -y && \
    yum clean all

RUN pip3 install 'urllib3<1.27,>=1.25.4' boto3 apache-beam[aws]

# Build the binary to boot beam processes
RUN cd /mnt && git clone --branch v2.51.0 --single-branch https://github.com/apache/beam.git
RUN cd /mnt/beam && ./gradlew :sdks:python:container:build 
RUN cd /mnt/beam && cp sdks/python/container/build/target/launcher/linux_amd64/boot /home/hadoop/boot
RUN rm -rf /mnt/beam

USER hadoop:hadoop