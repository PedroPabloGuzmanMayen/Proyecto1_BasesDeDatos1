import psycopg2
import pandas as pd
from sqlalchemy import create_engine, text

params = {
    'host': 'localhost',
    'database': 'postgres',
    'user': 'postgres',
    'password': '040603xD'
}


files = {
    'players': 'players.csv',
    'teams': 'teams.csv',
    'games': 'games.csv',
    'teamstats': 'teamstats.csv',
    'shots': 'shots.csv',
    'appeareances': 'appearances.csv',
    'leagues': 'leagues.csv'

}
conn = psycopg2.connect(
    host=params['host'],
    database=params['database'],
    user=params['user'],
    password=params['password']
)

cursor = conn.cursor()

conn.set_session(autocommit=True)
cursor.execute("CREATE DATABASE soccer")

conn.commit()
cursor.close()
conn.close()

params['database'] = 'soccer'



engine = create_engine(f'postgresql://{params["user"]}:{params["password"]}@{params["host"]}/{params["database"]}')

for table_name, file_path in files.items():
    df = pd.read_csv(file_path)
    df.to_sql(table_name, engine, if_exists='replace', index=False)