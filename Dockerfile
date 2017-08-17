FROM ubuntu:14.04

# Install dependencies

RUN apt-get update && apt-get install -y \
    software-properties-common
RUN add-apt-repository universe
RUN apt-get update && apt-get install -y \
    curl \
    git \
    python \
    python-pip \
    python-netaddr \
    unzip \
    python-dev \
    sqlite \
    wget

RUN pip install --upgrade pip
RUN pip install pygeoip
RUN pip install django-pagination
RUN pip install django-tables2==1.0
RUN pip install django-compressor
RUN pip install django-htmlmin
RUN pip install django-filter==0.7
RUN pip install Django==1.8

# Install DionaeaDR

WORKDIR /opt/
RUN git config --global http.proxy $http_proxy
RUN git clone https://github.com/rubenespadas/DionaeaFR.git
WORKDIR /opt/DionaeaFR/DionaeaFR
RUN mv settings.py.dist settings.py

#Install django-tables2-simplefilter

WORKDIR /opt/DionaeaFR
RUN wget https://github.com/benjiec/django-tables2-simplefilter/archive/master.zip -O django-tables2-simplefilter.zip
RUN unzip django-tables2-simplefilter.zip
RUN mv django-tables2-simplefilter-master/ django-tables2-simplefilter/
WORKDIR  /opt/DionaeaFR/django-tables2-simplefilter
RUN python setup.py install

#Install PySubnetTree

WORKDIR /opt/DionaeaFR
RUN git clone https://github.com/bro/pysubnettree.git
WORKDIR /opt/DionaeaFR/pysubnettree
RUN python setup.py install

#Install nodejs

WORKDIR /opt/DionaeaFR
RUN wget http://nodejs.org/dist/v0.10.33/node-v0.10.33.tar.gz
RUN tar xzvf node-v0.10.33.tar.gz
WORKDIR /opt/DionaeaFR/node-v0.10.33
RUN ./configure
RUN make
RUN make install
RUN npm install -g less

# Install GeoIP and GeoLiteCity

WORKDIR /tmp
RUN wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
RUN wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz

RUN gunzip GeoLiteCity.dat.gz
RUN gunzip GeoIP.dat.gz

RUN mv GeoIP.dat /opt/DionaeaFR/DionaeaFR/static
RUN mv GeoLiteCity.dat /opt/DionaeaFR/DionaeaFR/static

# Set prerequisites

RUN mkdir /var/run/dionaeafr/
WORKDIR /opt/DionaeaFR
COPY settings.py /opt/DionaeaFR/DionaeaFR
RUN echo yes | python manage.py collectstatic

# Run DionaeaFR and expose the service port

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
