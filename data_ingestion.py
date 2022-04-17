import pandas as pd
from sqlalchemy import create_engine
from time import time
import argparse
import os
def main(params): 
    user = params.user
    password = params.password
    host = params.host
    port = params.port
    db_name = params.db_name
    table_name = params.table_name
    url_data = params.url
    csv_name = 'output.csv'
    # Download the csv
    os.system(f"wget {url_data} -O {csv_name}")
    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db_name}')
    df = pd.read_csv('yellow_tripdata_2021-01.csv', nrows=100)
    df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
    df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)
    # connection to postgres
    engine.connect()
    df_iter = pd.read_csv(csv_name, iterator=True, chunksize=100000)
    df = next(df_iter)
    df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
    df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)
    df.head(n=0).to_sql(name=table_name, con=engine, if_exists='replace')
    df.to_sql(name=table_name, con=engine, if_exists='append')
    while True:
        t_start = time()
        df = next(df_iter)
        df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
        df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)
        df.to_sql(name=table_name, con=engine, if_exists='append')
        t_end = time()
        print(f'Inserted another chunk... and took %.3f second {t_end - t_start}')

if __name__=='__main__':
    parser = argparse.ArgumentParser(description='Ingest CSV data to PostgeSQL')
    # User, password, host, post , db name, table name, url of CSV
    parser.add_argument('--user', help='user name for postgresql')
    parser.add_argument('--password', help='password for postgresql')
    parser.add_argument('--host', help='host for postgresql')
    parser.add_argument('--port', help='port for postgresql')
    parser.add_argument('--db_name', help='db name for postgresql')
    parser.add_argument('--table_name', help='table name for postgresql')
    parser.add_argument('--url', help='url for data csv')
    args = parser.parse_args()
    main(args)
