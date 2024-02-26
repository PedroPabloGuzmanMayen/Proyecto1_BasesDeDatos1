

--Juegos disputados por cada equipo en cada temporada
select t."name", string_agg( distinct l."name"::text, ' ') as "Liga",
coalesce(sum(case when g."season" = 2014 then 1 else 0 end), 0) as "Juegos en 2014",
coalesce(sum(case when g."season" = 2015 then 1 else 0 end), 0) as "Juegos en 2015",
coalesce(sum(case when g."season" = 2016 then 1 else 0 end), 0) as "Juegos en 2016",
coalesce(sum(case when g."season" = 2017 then 1 else 0 end), 0) as "Juegos en 2017",
coalesce(sum(case when g."season" = 2018 then 1 else 0 end), 0) as "Juegos en 2018",
coalesce(sum(case when g."season" = 2019 then 1 else 0 end), 0) as "Juegos en 2019",
coalesce(sum(case when g."season" = 2020 then 1 else 0 end), 0) as "Juegos en 2020"
from teams t 
left join 
games g on t."teamID" = g."homeTeamID" or t."teamID" = g."awayTeamID"
join 
leagues l on g."leagueID" = l."leagueID" 
group by t."name" order by "Liga";

--Diferencia de goles ordenada por liga

select "HomeGoals"."homeTeamID", t."name", l."name" as "Liga",
("HomeGoals"."homeFGoals" + "AwayGoals"."awayFGoals") as "Goles a favor",
("HomeGoals"."awayCGoals" + "AwayGoals"."homeCGoals") as "Goles en contra",
(("HomeGoals"."homeFGoals" + "AwayGoals"."awayFGoals") - ("HomeGoals"."awayCGoals" + "AwayGoals"."homeCGoals")) as "Diferencia de Gol",
rank() over (partition by l."name" order by 
(("HomeGoals"."homeFGoals" + "AwayGoals"."awayFGoals") - ("HomeGoals"."awayCGoals" + "AwayGoals"."homeCGoals"))
desc) as ranking
from
(select "homeTeamID", sum("homeGoals") as "homeFGoals", sum("awayGoals") as "awayCGoals", string_agg(distinct "leagueID"::text, ' ') as "Liga"
from games group by "homeTeamID" order by "homeTeamID" desc)
as "HomeGoals"
join 
(select "awayTeamID", sum("awayGoals") as "awayFGoals", sum("homeGoals") as "homeCGoals" from games group by "awayTeamID" order by "awayTeamID" desc)
as "AwayGoals"
on "HomeGoals"."homeTeamID" = "AwayGoals"."awayTeamID"
join teams t on "HomeGoals"."homeTeamID" = t."teamID"
join leagues l on "HomeGoals"."Liga"::int = l."leagueID" 
order by "Liga", "ranking" asc;

select "HomeGoals"."homeTeamID", t."name", l."name" as "Liga",
("HomeGoals"."homeFGoals" + "AwayGoals"."awayFGoals") as "Goles a favor",
("HomeGoals"."awayCGoals" + "AwayGoals"."homeCGoals") as "Goles en contra",
(("HomeGoals"."homeFGoals" + "AwayGoals"."awayFGoals") - ("HomeGoals"."awayCGoals" + "AwayGoals"."homeCGoals")) as "Diferencia de Gol"
from
(select "homeTeamID", sum("homeGoals") as "homeFGoals", sum("awayGoals") as "awayCGoals", string_agg(distinct "leagueID"::text, ' ') as "Liga"
from games group by "homeTeamID" order by "homeTeamID" desc)
as "HomeGoals"
join 
(select "awayTeamID", sum("awayGoals") as "awayFGoals", sum("homeGoals") as "homeCGoals" from games group by "awayTeamID" order by "awayTeamID" desc)
as "AwayGoals"
on "HomeGoals"."homeTeamID" = "AwayGoals"."awayTeamID"
join teams t on "HomeGoals"."homeTeamID" = t."teamID"
join leagues l on "HomeGoals"."Liga"::int = l."leagueID" 
order by "Diferencia de Gol" desc;


--Goles de cada jugador

select p."name" as "Jugador", sum(a.goals) as "Goles totales" from appeareances a join players p on a."playerID" = p."playerID" group by p."name" order by
"Goles totales" desc; 

--Jugadores con más goles y pases derechos

select p."name" as "Jugador", count(*) as "Pases a la derecha", sum(case when "shotResult" = 'Goal' then 1 else 0 end) as "Goles"
from shots s join players p on p."playerID" = s."shooterID"
where s."lastAction" = 'Pass' and "shotType" = 'RightFoot'
group by p."name" order by count(*) desc ;

--Jugadores con más pases izquierdos que meten goles

select p."name" as "Jugador", count(*) as "Pases a la derecha", sum(case when "shotResult" = 'Goal' then 1 else 0 end) as "Goles"
from shots s join players p on p."playerID" = s."shooterID"
where s."lastAction" = 'Pass' and "shotType" = 'LeftFoot'
group by p."name" order by count(*) desc ;

--Jugadores con más pases izquierdos y derechos que meten goles
select p."name" as "Jugador", count(*) as "Pases", sum(case when "shotResult" = 'Goal' then 1 else 0 end) as "Goles"
from shots s join players p on p."playerID" = s."shooterID"
where s."lastAction" = 'Pass'
group by p."name" order by count(*) desc ;

--Comparativo de las probabilidades

select t."name" as "Equipo", 
greatest(max(1/"B365H"), max (1/"BWH"), max(1/"IWH"), max(1/"PSH"), max(1/"WHH"), max(1/"VCH"), max(1/"PSCH")) as "Max Home probabilty",
greatest(max(1/"B365A"), max (1/"BWA"), max(1/"IWA"), max(1/"PSA"), max(1/"WHA"), max(1/"VCA"), max(1/"PSCA")) as "Max away probability",
greatest(max(1/"B365D"), max (1/"BWD"), max(1/"IWD"), max(1/"PSD"), max(1/"WHD"), max(1/"VCD"), max(1/"PSCD")) as "Max draw proability"

from games g join teams t on g."homeTeamID" = t."teamID" or g."awayTeamID" = t."teamID" 
where g."B365H" != 0 and g."B365D" !=0 and g."B365A" !=0 and g."BWH" !=0 and g."BWD" != 0 and g."BWA" !=0 
and g."IWH" != 0 and g."IWD" !=0 and g."IWA" !=0 and g."PSH" !=0 and g."PSD" !=0 and g."PSA" !=0 and g."WHH" !=0 and g."WHD" !=0
and g."WHA" !=0 and g."VCH" !=0 and g."VCD" !=0 and g."VCA" != 0 and g."PSCH" != 0 and g."PSCD" != 0 and g."PSCA" !=0
group by t."name";


--Expected goals vs goles por cada temporada de cada equipo


select "Home"."name" as "Team", "Home"."Home expected goals" as "Home xGoals"
, "Home"."Home goals" as "Home Goals", 
"Away"."Away expected goals" as "Away xGoals", 
"Away"."Away goals" as "Away Goals",
("Home"."Home expected goals" + "Away"."Away expected goals") as "Total xGoals",
("Home"."Home goals" + "Away"."Away goals") as "Total Goals"
from
(select t."name", sum("xGoals") as "Home expected goals", sum("goals") as "Home goals" from teamstats ts join teams t on t."teamID" =
ts."teamID" where "location" = 'h'
group by t."name" order by 
sum("goals") desc) as "Home" join 
(select t."name", sum("xGoals") as "Away expected goals", sum("goals") as "Away goals" from teamstats ts join teams t on t."teamID" =
ts."teamID" where "location" = 'a' group by t."name" order by 
sum("goals") desc) as "Away" on "Home"."name" = "Away"."name" order by "Total xGoals"  desc;


--Equipo con mayores expected goals

select "Home"."name" as "Team", "Home"."Home expected goals" as "Home xGoals"
, "Home"."Home goals" as "Home goals", 
"Away"."Away expected goals" as "Away xGoals", 
"Away"."Away goals" as "Away Goals",
("Home"."Home expected goals" + "Away"."Away expected goals") as "Total xGoals",
("Home"."Home goals" + "Away"."Away goals") as "Total Goals"
from
(select t."name", sum("xGoals") as "Home expected goals", sum("goals") as "Home goals" from teamstats ts join teams t on t."teamID" =
ts."teamID" where "location" = 'h'
group by t."name" order by 
sum("goals") desc) as "Home" join 
(select t."name", sum("xGoals") as "Away expected goals", sum("goals") as "Away goals" from teamstats ts join teams t on t."teamID" =
ts."teamID" where "location" = 'a' group by t."name" order by 
sum("goals") desc) as "Away" on "Home"."name" = "Away"."name" order by "Total Goals"  desc;



--Equipos que ganan cuando sus probabilidades de ganar son bajas

select "Less home probability"."name" as "Equipo",
("Less home probability"."sumHome" + "Less away probability"."sumAway") as "Partidos en donde el contexto no era favorable"
from
(select t."name", count(*) as "sumHome" from games g join teams t on t."teamID" = g."homeTeamID"  
where "homeProbability" < "awayProbability" and "homeGoals" > "awayGoals"
group by t."name"  order by count(*) desc) as "Less home probability"
join 
(select t."name", count(*) as "sumAway" from games g join teams t on t."teamID" = g."awayTeamID"  
where "awayProbability" < "homeProbability" and "awayGoals" > "homeGoals"
group by t."name"  order by count(*) desc) as "Less away probability"
on "Less home probability"."name" = "Less away probability"."name"
order by "Partidos en donde el contexto no era favorable" desc ;

--Equipos que ganan cuando no tienen un contexto favorable según las apuestas (bet 365)
select "Less home probability"."name" as "Equipo",
("Less home probability"."sumHome" + "Less away probability"."sumAway") as "Partidos en donde el contexto no era favorable según Bet365"
from
(select t."name", count(*) as "sumHome" from games g join teams t on t."teamID" = g."homeTeamID"  
where 1/"B365H" < 1/"B365A" and "homeGoals" > "awayGoals" and "B365H" >0 and "B365A" >0
group by t."name"  order by count(*) desc) as "Less home probability"
join 
(select t."name", count(*) as "sumAway" from games g join teams t on t."teamID" = g."awayTeamID"  
where 1/"B365A" < 1/"B365H" and "awayGoals" > "homeGoals" and "B365H" >0 and "B365A" >0
group by t."name"  order by count(*) desc) as "Less away probability"
on "Less home probability"."name" = "Less away probability"."name"
order by "Partidos en donde el contexto no era favorable según Bet365" desc ;



--Equipos que pierden cuando tienen un contexto favorable según las apuestas


select "Most home probability"."name" as "Equipo",
("Most home probability"."sumHome" + "Most away probability"."sumAway") as "Partidos en donde el contexto era favorable"
from
(select t."name", count(*) as "sumHome" from games g join teams t on t."teamID" = g."homeTeamID"  
where 1/"B365H" > 1/"B365A" and "homeGoals" < "awayGoals" and "B365H" >0 and "B365A" >0
group by t."name"  order by count(*) desc) as "Most home probability"
join 
(select t."name", count(*) as "sumAway" from games g join teams t on t."teamID" = g."awayTeamID"  
where 1/"B365A" > 1/"B365H" and "awayGoals" < "homeGoals" and "B365H" >0 and "B365A" >0
group by t."name"  order by count(*) desc) as "Most away probability"
on "Most home probability"."name" = "Most away probability"."name"
order by "Partidos en donde el contexto era favorable" desc ;

--Equipos que pierden cuando sus probabilidades de ganar son altas

select "Most home probability"."name" as "Equipo",
("Most home probability"."sumHome" + "Most away probability"."sumAway") as "Partidos en donde el contexto era favorable seegún Bet365"
from
(select t."name", count(*) as "sumHome" from games g join teams t on t."teamID" = g."homeTeamID"  
where "homeProbability" > "awayProbability" and "homeGoals" < "awayGoals"
group by t."name"  order by count(*) desc) as "Most home probability"
join 
(select t."name", count(*) as "sumAway" from games g join teams t on t."teamID" = g."awayTeamID"  
where "awayProbability" > "homeProbability" and "awayGoals" < "homeGoals"
group by t."name"  order by count(*) desc) as "Most away probability"
on "Most home probability"."name" = "Most away probability"."name"
order by "Partidos en donde el contexto era favorable seegún Bet365" desc ;

--Jugadores con mejor promedio goleador
select p."name", sum("goals")/count(*) as "PromGoelador" from appeareances a join players p
on a."playerID" = p."playerID"
group by p."name" having count(*) > 35 order by sum("goals")/count(*) desc ;






--La cantidad de goles anotados define tu posición en cada temporada


select t."name" as "Equipo",g."season" as "Temporada", l."name" as "Liga",
((sum(case when t."teamID" = g."homeTeamID" then g."homeGoals" else 0 end) +
sum(case when t."teamID" = g."awayTeamID" then g."awayGoals" else 0 end))) as "Goles",
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end) as "Puntos",
rank() over (partition by l."name", g."season" order by 
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end)
desc ) as "Posicion", count(*)
from games g join teams t on t."teamID" = g."homeTeamID" or t."teamID" = g."awayTeamID" join leagues l on g."leagueID" = l."leagueID"
group by t."name", g."season", l."name"
order by l."name", g."season", "Posicion";

--La cantidad de goles por partido define la posición de un equipo
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
order by l."name", g."season", "Posicion";


--características de los equipos campeones

select * from
(select t."name" as "Equipo",g."season" as "Temporada", l."name" as "Liga",
((sum(case when t."teamID" = g."homeTeamID" then g."homeGoals" else 0 end) +
sum(case when t."teamID" = g."awayTeamID" then g."awayGoals" else 0 end))) as "Goles",
sum(case when t."teamID" = g."homeTeamID" then g."awayGoals" else 0 end ) +
sum(case when t."teamID" = g."awayTeamID" then g."homeGoals" else 0 end) as "Goles en contra",
((sum(case when t."teamID" = g."homeTeamID" then g."homeGoals" else 0 end) +
sum(case when t."teamID" = g."awayTeamID" then g."awayGoals" else 0 end))) - 
(sum(case when t."teamID" = g."homeTeamID" then g."awayGoals" else 0 end ) +
sum(case when t."teamID" = g."awayTeamID" then g."homeGoals" else 0 end)) as "Diferencia de gol",
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end) as "Puntos",
rank() over (partition by l."name", g."season" order by 
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end)
desc ) as "Posicion", count(*)
from games g join teams t on t."teamID" = g."homeTeamID" or t."teamID" = g."awayTeamID" join leagues l on g."leagueID" = l."leagueID"
group by t."name", g."season", l."name"
order by l."name", g."season", "Posicion")
where "Posicion" = 1;



--Mejores equipos según las apuestas
select subquery."name" as "Equipo", AVG("Prob") as "Probabilidad" from
(select t."name",
AVG(1.0 / "B365H" + 1.0 / "BWH" + 1.0 / "IWH" + 1.0 / "PSH" + 1.0 / "WHH" + 1.0 / "VCH" + 
1.0 / "PSCH") as "Prob"
from games g join teams t on t."teamID" = g."homeTeamID" where g."B365H" != 0 and g."B365D" !=0 and g."B365A" !=0 and g."BWH" !=0 and g."BWD" != 0 and g."BWA" !=0 
and g."IWH" != 0 and g."IWD" !=0 and g."IWA" !=0 and g."PSH" !=0 and g."PSD" !=0 and g."PSA" !=0 and g."WHH" !=0 and g."WHD" !=0
and g."WHA" !=0 and g."VCH" !=0 and g."VCD" !=0 and g."VCA" != 0 and g."PSCH" != 0 and g."PSCD" != 0 and g."PSCA" !=0 group by t."name") as subquery
group by subquery."name"
order by "Probabilidad" desc;


--Mejores jugadores

select p."name" as "Jugador", sum("goals") as "Goles", sum("shots") as "Tiros", sum("xGoalsChain") as "Goal Chain", sum("xGoalsBuildup") as "GoalBuildup", 
sum("assists") as "Asistencias", sum("keyPasses") as "Pases clave"
from appeareances a join players p on p."playerID" = a."playerID" group by p."name"
order by sum("goals") desc, sum("shots") desc, sum("xGoalsChain") desc,sum("xGoalsBuildup") desc, 
sum("assists") desc, sum("keyPasses") desc; 


--Equipos que han mejorado con respecto a la primera temporada registrada

select "Puntos 2014"."Equipo", "Puntos 2014"."Liga", "Puntos 2020"."Puntos" -"Puntos 2014"."Puntos" as "Diferencia de puntos"
from
(
(select "Equipo", "Liga", "Temporada", "Puntos" from 
(select t."name" as "Equipo",g."season" as "Temporada", l."name" as "Liga",
((sum(case when t."teamID" = g."homeTeamID" then g."homeGoals" else 0 end) +
sum(case when t."teamID" = g."awayTeamID" then g."awayGoals" else 0 end))) as "Goles",
sum(case when t."teamID" = g."homeTeamID" then g."awayGoals" else 0 end ) +
sum(case when t."teamID" = g."awayTeamID" then g."homeGoals" else 0 end) as "Goles en contra",
((sum(case when t."teamID" = g."homeTeamID" then g."homeGoals" else 0 end) +
sum(case when t."teamID" = g."awayTeamID" then g."awayGoals" else 0 end))) - 
(sum(case when t."teamID" = g."homeTeamID" then g."awayGoals" else 0 end ) +
sum(case when t."teamID" = g."awayTeamID" then g."homeGoals" else 0 end)) as "Diferencia de gol",
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end) as "Puntos",
rank() over (partition by l."name", g."season" order by 
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end)
desc ) as "Posicion", count(*)
from games g join teams t on t."teamID" = g."homeTeamID" or t."teamID" = g."awayTeamID" join leagues l on g."leagueID" = l."leagueID"
group by t."name", g."season", l."name"
order by l."name", g."season", "Posicion")
where "Temporada" = 2014) as "Puntos 2014"
join

(select "Equipo", "Liga", "Temporada", "Puntos" from 
(select t."name" as "Equipo",g."season" as "Temporada", l."name" as "Liga",
((sum(case when t."teamID" = g."homeTeamID" then g."homeGoals" else 0 end) +
sum(case when t."teamID" = g."awayTeamID" then g."awayGoals" else 0 end))) as "Goles",
sum(case when t."teamID" = g."homeTeamID" then g."awayGoals" else 0 end ) +
sum(case when t."teamID" = g."awayTeamID" then g."homeGoals" else 0 end) as "Goles en contra",
((sum(case when t."teamID" = g."homeTeamID" then g."homeGoals" else 0 end) +
sum(case when t."teamID" = g."awayTeamID" then g."awayGoals" else 0 end))) - 
(sum(case when t."teamID" = g."homeTeamID" then g."awayGoals" else 0 end ) +
sum(case when t."teamID" = g."awayTeamID" then g."homeGoals" else 0 end)) as "Diferencia de gol",
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end) as "Puntos",
rank() over (partition by l."name", g."season" order by 
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end)
desc ) as "Posicion", count(*)
from games g join teams t on t."teamID" = g."homeTeamID" or t."teamID" = g."awayTeamID" join leagues l on g."leagueID" = l."leagueID"
group by t."name", g."season", l."name"
order by l."name", g."season", "Posicion")
where "Temporada" = 2020) as "Puntos 2020"
on "Puntos 2014"."Equipo" = "Puntos 2020"."Equipo"
) order by "Diferencia de puntos" desc;

--Equipos que han empeorado


select p."name" as "Jugador", sum("goals") as "Goles", sum("shots") as "Tiros", sum("xGoalsChain") as "Goal Chain", sum("xGoalsBuildup") as "GoalBuildup", 
sum("assists") as "Asistencias", sum("keyPasses") as "Pases clave"
from appeareances a join players p on p."playerID" = a."playerID" group by p."name"
order by sum("goals") desc, sum("shots") desc, sum("xGoalsChain") desc,sum("xGoalsBuildup") desc, 
sum("assists") desc, sum("keyPasses") desc; 


--Equipos que han mejorado con respecto a la primera temporada registrada

select "Puntos 2014"."Equipo", "Puntos 2014"."Liga", "Puntos 2020"."Puntos" -"Puntos 2014"."Puntos" as "Diferencia de puntos"
from
(
(select "Equipo", "Liga", "Temporada", "Puntos" from 
(select t."name" as "Equipo",g."season" as "Temporada", l."name" as "Liga",
((sum(case when t."teamID" = g."homeTeamID" then g."homeGoals" else 0 end) +
sum(case when t."teamID" = g."awayTeamID" then g."awayGoals" else 0 end))) as "Goles",
sum(case when t."teamID" = g."homeTeamID" then g."awayGoals" else 0 end ) +
sum(case when t."teamID" = g."awayTeamID" then g."homeGoals" else 0 end) as "Goles en contra",
((sum(case when t."teamID" = g."homeTeamID" then g."homeGoals" else 0 end) +
sum(case when t."teamID" = g."awayTeamID" then g."awayGoals" else 0 end))) - 
(sum(case when t."teamID" = g."homeTeamID" then g."awayGoals" else 0 end ) +
sum(case when t."teamID" = g."awayTeamID" then g."homeGoals" else 0 end)) as "Diferencia de gol",
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end) as "Puntos",
rank() over (partition by l."name", g."season" order by 
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end)
desc ) as "Posicion", count(*)
from games g join teams t on t."teamID" = g."homeTeamID" or t."teamID" = g."awayTeamID" join leagues l on g."leagueID" = l."leagueID"
group by t."name", g."season", l."name"
order by l."name", g."season", "Posicion")
where "Temporada" = 2014) as "Puntos 2014"
join

(select "Equipo", "Liga", "Temporada", "Puntos" from 
(select t."name" as "Equipo",g."season" as "Temporada", l."name" as "Liga",
((sum(case when t."teamID" = g."homeTeamID" then g."homeGoals" else 0 end) +
sum(case when t."teamID" = g."awayTeamID" then g."awayGoals" else 0 end))) as "Goles",
sum(case when t."teamID" = g."homeTeamID" then g."awayGoals" else 0 end ) +
sum(case when t."teamID" = g."awayTeamID" then g."homeGoals" else 0 end) as "Goles en contra",
((sum(case when t."teamID" = g."homeTeamID" then g."homeGoals" else 0 end) +
sum(case when t."teamID" = g."awayTeamID" then g."awayGoals" else 0 end))) - 
(sum(case when t."teamID" = g."homeTeamID" then g."awayGoals" else 0 end ) +
sum(case when t."teamID" = g."awayTeamID" then g."homeGoals" else 0 end)) as "Diferencia de gol",
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end) as "Puntos",
rank() over (partition by l."name", g."season" order by 
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end)
desc ) as "Posicion", count(*)
from games g join teams t on t."teamID" = g."homeTeamID" or t."teamID" = g."awayTeamID" join leagues l on g."leagueID" = l."leagueID"
group by t."name", g."season", l."name"
order by l."name", g."season", "Posicion")
where "Temporada" = 2020) as "Puntos 2020"
on "Puntos 2014"."Equipo" = "Puntos 2020"."Equipo"
) order by "Diferencia de puntos" asc;



--Promedio de puntos por posición
select max("Puntos") as "Máximo", avg("Puntos") as "Promedio", min("Puntos") as "Minimo" from
(select t."name" as "Equipo",g."season" as "Temporada", l."name" as "Liga",
((sum(case when t."teamID" = g."homeTeamID" then g."homeGoals" else 0 end) +
sum(case when t."teamID" = g."awayTeamID" then g."awayGoals" else 0 end))/count(*)) as "Goles",
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end) as "Puntos",
rank() over (partition by l."name", g."season" order by 
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end)
desc ) as "Posicion", count(*)
from games g join teams t on t."teamID" = g."homeTeamID" or t."teamID" = g."awayTeamID" join leagues l on g."leagueID" = l."leagueID"
group by t."name", g."season", l."name"
order by l."name", g."season", "Posicion") as "Primeras posiciones"
where "Posicion" between 1 and 5;

--Posiciones entre 6 y 10
select max("Puntos") as "Máximo", avg("Puntos") as "Promedio", min("Puntos") as "Minimo" from
(select t."name" as "Equipo",g."season" as "Temporada", l."name" as "Liga",
((sum(case when t."teamID" = g."homeTeamID" then g."homeGoals" else 0 end) +
sum(case when t."teamID" = g."awayTeamID" then g."awayGoals" else 0 end))/count(*)) as "Goles",
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end) as "Puntos",
rank() over (partition by l."name", g."season" order by 
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end)
desc ) as "Posicion", count(*)
from games g join teams t on t."teamID" = g."homeTeamID" or t."teamID" = g."awayTeamID" join leagues l on g."leagueID" = l."leagueID"
group by t."name", g."season", l."name"
order by l."name", g."season", "Posicion") as "Posiciones medias"
where "Posicion" between 6 and 10;


--Posiciones 11 y 15

select max("Puntos") as "Máximo", avg("Puntos") as "Promedio", min("Puntos") as "Minimo" from
(select t."name" as "Equipo",g."season" as "Temporada", l."name" as "Liga",
((sum(case when t."teamID" = g."homeTeamID" then g."homeGoals" else 0 end) +
sum(case when t."teamID" = g."awayTeamID" then g."awayGoals" else 0 end))/count(*)) as "Goles",
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end) as "Puntos",
rank() over (partition by l."name", g."season" order by 
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end)
desc ) as "Posicion", count(*)
from games g join teams t on t."teamID" = g."homeTeamID" or t."teamID" = g."awayTeamID" join leagues l on g."leagueID" = l."leagueID"
group by t."name", g."season", l."name"
order by l."name", g."season", "Posicion") as "Primeras posiciones"
where "Posicion" between 11 and 15;

--Posiciones entre más bajas

select max("Puntos") as "Máximo", avg("Puntos") as "Promedio", min("Puntos") as "Minimo" from
(select t."name" as "Equipo",g."season" as "Temporada", l."name" as "Liga",
((sum(case when t."teamID" = g."homeTeamID" then g."homeGoals" else 0 end) +
sum(case when t."teamID" = g."awayTeamID" then g."awayGoals" else 0 end))/count(*)) as "Goles",
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end) as "Puntos",
rank() over (partition by l."name", g."season" order by 
sum(case when t."teamID" = g."homeTeamID" and g."homeGoals" > g."awayGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" > g."homeGoals" then 3 else 0 end) +
sum(case when t."teamID" = g."awayTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end ) +
sum(case when t."teamID" = g."homeTeamID" and g."awayGoals" = g."homeGoals" then 1 else 0 end)
desc ) as "Posicion", count(*)
from games g join teams t on t."teamID" = g."homeTeamID" or t."teamID" = g."awayTeamID" join leagues l on g."leagueID" = l."leagueID"
group by t."name", g."season", l."name"
order by l."name", g."season", "Posicion") as "Primeras posiciones"
where "Posicion" > 15;



--Goles en contra y diferencia de gol
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


--Promedios de cada equipo


select  "Stats"."Equipo", avg("Stats"."W") as "WP",
avg("Stats"."D") as "DP",
avg("Stats"."GF") as "GFP ",
avg("Stats"."GC") as "GCP",
avg("Stats"."GD") as "GDP",
avg("Stats"."L") as "LP",
avg("Stats"."Puntos") as "Puntos promedio",
avg("Stats"."Posicion") as "Poscion promedio"
from
(select t."name" as "Equipo",g."season" as "Temporada", l."name" as "Liga",
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
order by l."name", g."season", "Posicion") as "Stats"
group by "Stats"."Equipo";
