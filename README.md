# Flowmap demo Relocations
This repository lets you test [flowmap.blue](www.flowmap.blue) with relocation data from Statistics Netherlands.
Read this manual for all the steps that are needed to achieve [this result by @rug_geo](https://flowmap.blue/1ve7b0rqusOi1l67niVbVpMKwcYg7GrwJMHm_UkL9thU).
You can also find the necessary sql in ```flowmap.sql```

## Step 1: get the data 
1. Go to [Statistics Netherlands](https://opendata.cbs.nl/statline/portal.html?_la=nl&_catalog=CBS&tableId=81734NED&_theme=278) and choose Downloads -> Onbewerkte dataset (raw dataset). 
2. Choose "Regio van Vestigingen" (destinations) -> "Alle Gemeenten" (all municipalities). 
3. Choose "Regio van Vertrek" (departures) -> "Alle Gemeenten" (all municipalities). 
4. Choose "Periodes" -> 2017
5. Download csv

## Step 2: prepare google sheet

Follow the steps from the [flowmap.blue manual](https://flowmap.blue).

## Step 3: prepare database
In this case we used PostgreSQL with Postgis. This migt work with sqlite or mysql too, apart from the coordinates transformation.

1. Create relocation data table:

```sql
create table relocations(
	id text,
	from text,
	to text,
	period text,
	count text
	)
;
```

2. Import the downloaded csv
Use your preferred way of imporing data, in my case psql:
```
\copy relocations from Downloads/relocations.csv csv header delimiter ';';
```

3. If you don't have the Dutch municipalities in your database, download them from [Statistics Netherlands](https://www.cbs.nl/nl-nl/dossier/nederland-regionaal/geografische%20data/wijk-en-buurtkaart-2017) and import into your database. E.g. via [Qgis DB Manager](https://docs.qgis.org/2.8/en/docs/training_manual/databases/db_manager.html) or [ogr2ogr](http://www.bostongis.com/PrinterFriendly.aspx?content_name=ogr_cheatsheet)

## Step 4: export data
1. Export a list of municipalities and their centroids in lat/long (for labeling).

```sql
select 
	substring(gm_code,3) as id,
	gm_naam as municipality_name, 
	st_y(st_transform(st_centroid(geom),4326)) y,
	st_x(st_transform(st_centroid(geom),4326)) x 
from 
	cbs_gemeente_2017
;
```

Copy the result into the locations tab in your google sheet

2. Export the flows between municipalities

The municipal code is trimmed to end up with a numerical identifier.
The count is trimmed to get rid of any spaces.
```sql
select 
	substring(from,3)::text from, 
	substring(to,3)::text to, 
	count::text
from 
	relocations 
where 
	from is not null 
	and 
	to is not null 
	and 
	count is not null 
	and 
	trim(count) != '0'
;
```

Copy the result into the flows tab in your google sheet and check out your map!
