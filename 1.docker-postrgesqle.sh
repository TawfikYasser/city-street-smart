# ABOUT
# PostgreSQL as a Docker Container
# Access PostgreSQL using pgcli
# Download and move the data using Jupyter notebook



mkdir docker_postgresql

code .
## in vscode

Dockerfile
FROM python:latest

RUN pip install pandas

# WORKDIR /app
# COPY pipeline.py pipeline.py

ENTRYPOINT [ "bash" ]

##

docker build -t test:pandas .
docker run -it test:pandas


##################################################

# postgressql, put data in it

docker run -it \
-e POSTGRES_USER="root" \
-e POSTGRES_PASSWORD="root" \
-e POSTGRES_DB="css" \
-v /home/tawfik/Softy/cityStreetSmart/docker_postgresql/css_postgres_data:/var/lib/postgresql/data \
-p 5432:5432 \
--network=pg-network \
--name pg-database \
postgres:13


pip install pgcli

pgcli -h localhost -p 5432 -u root -d css

pip install jupyter

jupyter notebook # http://localhost:8888/notebooks/Untitled.ipynb?kernel_name=python3
# code in jupyter
pip install pandas

wget https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2021-01.csv
less yellow_tripdata_2021-01.csv

#count lines
wc -l yellow_tripdata_2021-01.csv 
1369766 yellow_tripdata_2021-01.csv

pip install sqlalchemy


# All related code in jupyter notebook (found in /home/tawfik/Softy/cityStreetSmart/docker_postgresql/Untitled.ipynb)
# Link: http://localhost:8888/notebooks/Untitled.ipynb?kernel_name=python3



###########
# PGAdmin

# Create network for both postgres and pgadmin
docker network create pg-network

docker run -it \
    -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
    -e PGADMIN_DEFAULT_PASSWORD="root" \
    -p 8080:80 \
    --network=pg-network \
    --name pgadmin \
    dpage/pgadmin4 
    
# http://localhost:8080
# then create a server with the localhost: pg-database as the container name


####
Containerizing the ingestion

#1. Conver the notebook to python script

#### To Run the file #### https://github.com/TawfikYasser/city-street-smart/blob/main/data_ingestion.py
URL="https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2021-01.csv "
python3 data_ingestion.py \
    --user=root \
    --password=root \
    --host=localhost \
    --port=5432 \
    --db_name=css \
    --table_name=yellow_taxi_trips \
    --url=${URL}
    
    
# Now send to docker
# to build the docker for ingestion
# Dockerfile: https://github.com/TawfikYasser/city-street-smart/blob/main/Dockerfile
# go to the build context
docker build -t taxi_trips_data:v001 .

# To run the ingestion using docker
URL="https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2021-01.csv "
docker run -it \
    --network=pg-network 
    taxi_trips_data \
    --user=root \
    --password=root \
    --host=localhost \
    --port=5432 \
    --db_name=css \
    --table_name=yellow_taxi_trips \
    --url=${URL}
    

# To prevent downloading the file if found
python3 -m http.server
# open http://localhost:8000, get the file link
# ip address 172.17.0.1

# To run the ingestion using docker
URL="http://172.17.0.1:8000/yellow_tripdata_2021-01.csv"
docker run -it \
    --network=pg-network \
    taxi_trips_data:v001 \
    --user=root \
    --password=root \
    --host=pg-database \
    --port=5432 \
    --db_name=css \
    --table_name=yellow_taxi_trips \
    --url=${URL}

# Docker compose (postgresql and pgadmin in docker)
# yml
services:
  pgdatabase:
    image: postgres:13
    environment:
      - POSTGRES_USER=root
      - POSTGRES_PASSWORD=root
      - POSTGRES_DB=css
    volumes:
      - "./css_postgres_data:/var/lib/postgresql/data:rw"
    ports:
      - "5432:5432"
  pgadmin:
    image: dpage/pgadmin4
    environment:
      - PGADMIN_DEFAULT_EMAIL=admin@admin.com
      - PGADMIN_DEFAULT_PASSWORD=root
    ports:
      - "8088:80"
docker-compose up

