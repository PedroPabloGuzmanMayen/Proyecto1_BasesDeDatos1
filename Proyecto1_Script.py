import psycopg2
import pandas as pd
from sqlalchemy import create_engine, text

#Definimos un diccionario con los parametros de la conexion
params = {
    'host': 'localhost',
    'database': 'postgres',
    'user': 'postgres',
    'password': 'admin'
}
#Definimos un diccionario con los nombres de los archivos

files = {
    'players': 'players.csv',
    'teams': 'teams.csv',
    'games': 'games.csv',
    'teamstats': 'teamstats.csv',
    'shots': 'shots.csv',
    'appeareances': 'appearances.csv',
    'leagues': 'leagues.csv'

}

#Conectamos a la base de datos
conn = psycopg2.connect(
    host=params['host'],
    database=params['database'],
    user=params['user'],
    password=params['password']
)
#Creamos un cursor para ejecutar comandos
cursor = conn.cursor()
#Creamos la base de datos
conn.set_session(autocommit=True)
cursor.execute("CREATE DATABASE soccer")
#Cerramos la conexion
conn.commit()
cursor.close()
conn.close()
#Cambiamos el nombre de la base de datos a la nueva base de datos que se ha creado
params['database'] = 'soccer'


#Creamos el motor de la base de datos (Nota: si desea levantar la base de datos en su dispositivo debe cmbiar usuario, contraseña y todo lo que se pertinente)
engine = create_engine(f'postgresql://{params["user"]}:{params["password"]}@{params["host"]}/{params["database"]}')
#Leemos los archivos y los guardamos en la base de datos
for table_name, file_path in files.items():
    df = pd.read_csv(file_path)
    df.to_sql(table_name, engine, if_exists='replace', index=False)