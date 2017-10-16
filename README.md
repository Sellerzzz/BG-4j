# BG-4j
This repository contains a shell script that will download the latest build of the BioGRID database, format the human interactome and upload this to your personal Neo4j database.
An updater script is also packaged which when ran will update your database to the latest version, it is advisable to dump your current version of the BioGRID database before updating so that no data is unintentionally lost.
Dependencies: neo4j
NOTE: you may have to grant read+write permissions to the script before installation and update, i.e. chmod 777 -R * [within the BG-4j directory].
