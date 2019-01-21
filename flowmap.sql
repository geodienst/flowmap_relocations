create table _temp.cbs_verhuizingen(
	id text,
	naar text,
	van text,
	periode text,
	aantal text
	)
;

\copy cbs_verhuizingen from Downloads/cbs_verhuizingen.csv csv header delimiter ';';

select 
	substring(van,3)::text van, 
	substring(naar,3)::text naar, 
	trim(aantal)::text
from 
	_temp.cbs_verhuizingen_nieuw
where 
	van is not null 
	and 
	naar is not null 
	and 
	aantal is not null 
	and 
	trim(aantal) != '0'
;

select 
	substring(gm_code,3) as id,
	gm_naam, 
	st_y(st_transform(st_centroid(geom),4326)) y,
	st_x(st_transform(st_centroid(geom),4326)) x 
from 
	cbs_gemeente_2017
;
