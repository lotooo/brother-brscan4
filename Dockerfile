FROM ubuntu:18.04


### Vars
ENV NAME="brother"
ENV MODEL="MFC-L2710DW"
ENV IPADDRESS="192.168.250.250"
ENV USERNAME="dock"
ENV TZ="America/Chicago"
ENV DEBIAN_FRONTEND=noninteractive

ENV NC_USER=""
ENV NC_PASS=""
ENV NC_URL=""

# Expose Ports
EXPOSE 54925
EXPOSE 54921

##### update to latest, install packages, cleanup ##### 
#RUN apt-get -y install apt-utils
RUN echo $TZ > /etc/timezone
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install wget git unzip dpkg procps iputils-ping nano tzdata curl

#### Install scanner dependancies
RUN apt-get -y install units sane sane-utils netpbm ghostscript poppler-utils imagemagick unpaper util-linux tesseract-ocr parallel bc
RUN apt-get -y clean

#### Persistant Volumes #######
VOLUME /scans

##### setup scanner crap ######
## Add this code to my repo for management ##
RUN git clone https://github.com/rocketraman/sane-scan-pdf.git /sane-scan-pdf/

#### Add drivers folder and install #######
ADD drivers/* /drivers/
ADD scripts/* /scripts/

### Install and configure
RUN dpkg -i --force-all /drivers/brscan4*.deb
RUN dpkg -i --force-all /drivers/brscan-skey-*.deb

RUN brsaneconfig4 -a name=$NAME model=$MODEL ip=$IPADDRESS
RUN brsaneconfig4 -q | grep $NAME

#### Copy files #####
RUN rm /opt/brother/scanner/brscan-skey/brscan-skey.config
RUN cp /scripts/brscan-skey.config /opt/brother/scanner/brscan-skey/
RUN rm /sane-scan-pdf/scan
RUN cp /scripts/scan /sane-scan-pdf/


#### Start the scanner listener ####
CMD /scripts/start.sh
