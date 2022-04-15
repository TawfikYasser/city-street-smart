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
