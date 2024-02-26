import pandas as pd
from sqlalchemy import create_engine
import matplotlib.pyplot as plt
import numpy as np


# Crear el motor de la base de datos (si se quiere usar el script, cambiar contraeña, usuario y lo que sea pertinente)
engine = create_engine('postgresql://postgres:admin@localhost/soccer')

# Query con todos los datos necesarios para el analisis
query = """
select t."name" as "Equipo",g."season" as "Temporada", l."name" as "Liga",
((sum(case when t."teamID" = g."homeTeamID" then g."homeGoals" else 0 end) +
sum(case when t."teamID" = g."awayTeamID" then g."awayGoals" else 0 end))) as "GF",
sum(case when t."teamID" = g."homeTeamID" then g."awayGoals" else 0 end ) +
sum(case when t."teamID" = g."awayTeamID" then g."homeGoals" else 0 end) as "GC",
((sum(case when t."teamID" = g."homeTeamID" then g."homeGoals" else 0 end) +
sum(case when t."teamID" = g."awayTeamID" then g."awayGoals" else 0 end))) - 
(sum(case when t."teamID" = g."homeTeamID" then g."awayGoals" else 0 end ) +
sum(case when t."teamID" = g."awayTeamID" then g."homeGoals" else 0 end)) as "GD",
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end) as "Puntos",
rank() over (partition by l."name", g."season" order by 
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end)
desc ) as "Posicion", count(*) as "Partidos jugados",
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 1 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 1 else 0 end) as "W",
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" < g."awayGoals" then 1 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" < g."homeGoals" then 1 else 0 end) as "L",
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" = g."awayGoals" then 1 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end) as "D"
from games g join teams t on t."teamID" = g."homeTeamID" or t."teamID" = g."awayTeamID" join leagues l on g."leagueID" = l."leagueID"
group by t."name", g."season", l."name"
order by l."name", g."season", "Posicion"
"""


# Hacer el query y guardarlo en un df
df = pd.read_sql_query(query, engine)


# CCerrar la conexion
engine.dispose()




df.to_excel('ProyectoBasesDeDatos.xlsx', index=False)

