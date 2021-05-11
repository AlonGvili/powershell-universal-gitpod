# Docker image file that describes an Ubuntu18.04 image with PowerShell installed from Microsoft APT Repo

FROM mcr.microsoft.com/powershell AS installer-env

ARG VERSION=1.3.1
ARG PACKAGE_URL=https://imsreleases.blob.core.windows.net/universal/production/1.6.0/Universal.linux-x64.1.6.0.zip
ARG DEBIAN_FRONTEND=noninteractive 

# Install dependencies and clean up
RUN apt-get update \
    && apt-get install -y apt-utils 2>&1 | grep -v "debconf: delaying package configuration, since apt-utils is not installed" \
    && apt-get install --no-install-recommends -y \
    # curl is required to grab the Linux package
        curl \
    # less is required for help in powershell
        less \
    # requied to setup the locale
        locales \
    # required for SSL
        ca-certificates \
        gss-ntlmssp \
    # PowerShell remoting over SSH dependencies
        openssh-client \
        unzip \
    # Download the Linux package and save it
    && echo ${PACKAGE_URL} \
    && curl -sSL ${PACKAGE_URL} -o /tmp/universal.zip \
    && unzip /tmp/universal.zip -d ./home/Universal || : \
    # remove powershell package
    && rm /tmp/universal.zip \
    && chmod +x ./home/Universal/Universal.Server

# Use PowerShell as the default shell
# Use array to avoid Docker prepending /bin/sh -c
EXPOSE 5000
ENTRYPOINT ["./home/Universal/Universal.Server"]
