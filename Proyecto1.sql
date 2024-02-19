--Este query suma el total de juegos jugados por cada equipo en todas las temporadas
select t."name" as "Equipo", l."name" as "Liga",
home.cuentaH as "Juegos como local", away.cuentaV as "Juegos como Visitante",
(home.cuentaH + away.cuentaV) as "Juegos totales"
from 
(select "homeTeamID", count(*) as cuentaH, string_agg(distinct "leagueID"::text, ' ') as liga
 from games g group by "homeTeamID" order by cuentaH desc) as home
join (select "awayTeamID", count(*) as cuentaV from games g group by "awayTeamID" order by cuentaV desc) as away
on home."homeTeamID" = "awayTeamID"
join leagues l on home.liga::int = l."leagueID" 
join teams t on home."homeTeamID" = t."teamID"
order by "Juegos como local" desc;


--Este query muestra los juegos jugados por cada equipo en cada temporada
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

--Diferencia de goles

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