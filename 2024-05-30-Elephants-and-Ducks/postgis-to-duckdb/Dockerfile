# Specify the exact base image version for consistency
FROM postgis/postgis:16-3.4

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
    pip3 install --no-deps -r requirements.txt \

# Install additional extensions
RUN set -xe; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		"postgresql-${PG_MAJOR}-pgaudit" \
		"postgresql-${PG_MAJOR}-pg-failover-slots" \
		"postgresql-${PG_MAJOR}-pgrouting" \
        "pgxn install h3" \
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


# pgRouting install


# Final Cleanup
RUN apt-get purge -y --auto-remove wget lsb-release && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Change the uid of postgres to 26
RUN usermod -u 26 postgres

# Set user to postgres
USER 26


docker run --name e_and_d_db -e POSTGRES_PASSWORD=password elephants-and-ducks 

docker run --name e_and_d_db -e POSTGRES_PASSWORD=password elephants-and-ducks 
