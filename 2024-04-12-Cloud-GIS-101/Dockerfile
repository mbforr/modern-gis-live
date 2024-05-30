##############################################################################
# Base stage                                                                 #
##############################################################################
ARG DISTRO=debian
ARG IMAGE_VERSION=bookworm
ARG IMAGE_VARIANT=slim
FROM $DISTRO:$IMAGE_VERSION-$IMAGE_VARIANT AS postgis-base
LABEL maintainer="Tim Sutton<tim@kartoza.com>"
# Cache invalidation number is used to invalidate a cache.
# Simply increment the number by 1 to reset the cache in local and GitHub Action
# This is added because we can't purge GitHub Action cache manually
LABEL cache.invalidation.number="1"
ARG CACHE_INVALIDATION_NUMBER=1


# Reset ARG for version
ARG IMAGE_VERSION

RUN apt-get -qq update --fix-missing && apt-get -qq --yes upgrade

RUN set -eux \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
        locales gnupg2 wget ca-certificates rpl pwgen software-properties-common  iputils-ping \
        apt-transport-https curl gettext pgxnclient cmake && \
    apt-get -y install build-essential autoconf  libxml2-dev zlib1g-dev netcat-openbsd gdal-bin \
    figlet toilet gosu; \
    # verify that the binary works
	gosu nobody true && \
    dpkg-divert --local --rename --add /sbin/initctl


# Generating locales takes a long time. Utilize caching by runnig it by itself
# early in the build process.

# Generate all locale only on deployment mode build
# Set to empty string to generate only default locale
ARG GENERATE_ALL_LOCALE=0
ARG LANGS="en_US.UTF-8,id_ID.UTF-8"
ARG LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

COPY ./base_build/scripts/locale.gen /etc/all.locale.gen
COPY ./base_build/scripts/locale-filter.sh /etc/locale-filter.sh
RUN if [ -z "${GENERATE_ALL_LOCALE}" ] || [ $GENERATE_ALL_LOCALE -eq 0 ]; \
	then \
		cat /etc/all.locale.gen | grep "${LANG}" > /etc/locale.gen; \
		/bin/bash /etc/locale-filter.sh; \
	else \
		cp -f /etc/all.locale.gen /etc/locale.gen; \
	fi; \
	set -eux \
	&& /usr/sbin/locale-gen

RUN update-locale ${LANG}


# Cleanup resources
RUN apt-get -y --purge autoremove  \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


##############################################################################
# Production Stage                                                           #
##############################################################################
FROM postgis-base AS postgis-prod


# Reset ARG for version
ARG IMAGE_VERSION
ARG POSTGRES_MAJOR_VERSION=16
ARG POSTGIS_MAJOR_VERSION=3
ARG POSTGIS_MINOR_RELEASE=4
# https://packagecloud.io/timescale/timescaledb
ARG TIMESCALE_VERSION=2-2.11.2
ARG BUILD_TIMESCALE=false



RUN set -eux \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && wget -O- https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor |  sh -c 'cat > /usr/share/keyrings/postgresql.gpg' > /dev/null \
    && echo deb [signed-by=/usr/share/keyrings/postgresql.gpg] https://apt.postgresql.org/pub/repos/apt/ ${IMAGE_VERSION}-pgdg main | tee /etc/apt/sources.list.d/pgdg.list 2>/dev/null \
    && apt-get -y --purge autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && dpkg-divert --local --rename --add /sbin/initctl


#-------------Application Specific Stuff ----------------------------------------------------

# We add postgis as well to prevent build errors (that we dont see on local builds)
# on docker hub e.g.
# The following packages have unmet dependencies:

RUN set -eux \
    && export DEBIAN_FRONTEND=noninteractive \
    &&  apt-get update \
    && apt-get -y --no-install-recommends install postgresql-client-${POSTGRES_MAJOR_VERSION} \
        postgresql-common postgresql-${POSTGRES_MAJOR_VERSION} \
        postgresql-${POSTGRES_MAJOR_VERSION}-postgis-${POSTGIS_MAJOR_VERSION} \
        postgresql-${POSTGRES_MAJOR_VERSION}-ogr-fdw \
        postgresql-${POSTGRES_MAJOR_VERSION}-postgis-${POSTGIS_MAJOR_VERSION}-scripts \
        postgresql-plpython3-${POSTGRES_MAJOR_VERSION} postgresql-${POSTGRES_MAJOR_VERSION}-pgrouting \
        postgresql-server-dev-${POSTGRES_MAJOR_VERSION}  postgresql-${POSTGRES_MAJOR_VERSION}-cron \
        postgresql-${POSTGRES_MAJOR_VERSION}-mysql-fdw && \
        pgxn install h3

##########################
#   Install duckdb_fdw   #
##########################

# Copy requirements file
COPY requirements.txt /

# Install packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3-pip python3-psycopg2 python3-setuptools wget make cmake gcc \
        libtool unzip pgxnclient libpq-dev postgresql-server-dev-${PG_MAJOR} \
        lsb-release \
        ca-certificates build-essential autoconf automake zlib1g-dev \
        libxml2-dev postgresql-server-dev-all git \
        libboost-atomic1.74.0 libboost-chrono1.74.0 libboost-graph1.74.0 \
        libboost-date-time1.74.0 libboost-program-options1.74.0 libboost-system1.74.0 \
        libboost-thread1.74.0 libboost-dev && \
    apt-get install -y python3 postgresql-plpython3-${PG_MAJOR} && \
    pip3 install --upgrade pip && \
    pip3 install --no-deps -r requirements.txt

# Install additional extensions
RUN set -xe; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		"postgresql-${PG_MAJOR}-pgaudit" \
		"postgresql-${PG_MAJOR}-pg-failover-slots" \
		"postgresql-${PG_MAJOR}-pgrouting" \
	; \
	rm -fr /tmp/* ; \
	rm -rf /var/lib/apt/lists/*;

# Clone duckdb_fdw repository
RUN git clone https://github.com/alitrack/duckdb_fdw

# Adjust the path to pg_config as necessary
ENV PG_CONFIG=/usr/lib/postgresql/${PG_MAJOR}/bin/pg_config

# duckdb foreign data wrapper installation
RUN cd duckdb_fdw && \
    wget -c https://github.com/duckdb/duckdb/releases/download/v0.10.1/libduckdb-linux-amd64.zip && \
    unzip -o libduckdb-linux-amd64.zip && \
    cp libduckdb.so $($PG_CONFIG --libdir) && \
    make USE_PGXS=1 PG_CONFIG=$PG_CONFIG && \
    make install USE_PGXS=1 PG_CONFIG=$PG_CONFIG

# Final Cleanup
RUN apt-get purge -y --auto-remove wget lsb-release && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Change the uid of postgres to 26
RUN usermod -u 26 postgres

# Set user to postgres
USER 26
# TODO a case insensitive match would be more robust
RUN if [ "${BUILD_TIMESCALE}" = "true" ]; then \
        export DEBIAN_FRONTEND=noninteractive && \
        sh -c "echo \"deb [signed-by=/usr/share/keyrings/timescale.keyring] https://packagecloud.io/timescale/timescaledb/debian/ ${IMAGE_VERSION} main\" > /etc/apt/sources.list.d/timescaledb.list" && \
        wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey |  gpg --dearmor -o /usr/share/keyrings/timescale.keyring && \
        apt-get update && \
        apt-get -y --no-install-recommends install timescaledb-${TIMESCALE_VERSION}-postgresql-${POSTGRES_MAJOR_VERSION} timescaledb-tools;\
    fi;

RUN  echo $POSTGRES_MAJOR_VERSION >/tmp/pg_version.txt && echo $POSTGIS_MAJOR_VERSION >/tmp/pg_major_version.txt && \
     echo $POSTGIS_MINOR_RELEASE >/tmp/pg_minor_version.txt
ENV \
    PATH="$PATH:/usr/lib/postgresql/${POSTGRES_MAJOR_VERSION}/bin"
# Compile pointcloud extension

RUN wget -O- https://github.com/pgpointcloud/pointcloud/archive/master.tar.gz | tar xz && \
cd pointcloud-master && \
./autogen.sh && ./configure && make -j 4 && make install && \
cd .. && rm -Rf pointcloud-master

# Cleanup resources
RUN apt-get -y --purge autoremove  \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Open port 5432 so linked containers can see them
EXPOSE 5432

# Copy scripts
ADD ./scripts /scripts
WORKDIR /scripts
RUN chmod +x *.sh

# Run any additional tasks here that are too tedious to put in
# this dockerfile directly.
RUN set -eux \
    && /scripts/setup.sh;rm /scripts/.pass_*
RUN echo 'figlet -t "Kartoza Docker PostGIS"' >> ~/.bashrc


ENTRYPOINT ["/bin/bash", "/scripts/docker-entrypoint.sh"]


##############################################################################
# Testing Stage                                                           #
##############################################################################
FROM postgis-prod AS postgis-test

COPY ./scenario_tests/utils/requirements.txt /lib/utils/requirements.txt

RUN set -eux \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y --no-install-recommends install python3-pip procps \
    && apt-get -y --purge autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install -r /lib/utils/requirements.txt --break-system-packages