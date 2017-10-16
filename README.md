# BG-4j
<p>This repository contains a shell script that will download the latest build of the BioGRID database, format the human interactome and upload this to your personal Neo4j database.</p>

<p>An updater script is also packaged which will update your BioGRID daataset to the latest build and updload this to a new database, it is advisable to dump your current version of the BioGRID database before updating so that no data is unintentionally lost.</p>

<p>Dependencies: neo4j</p>

<p>NOTE: you may have to grant read+write permissions to the script before installation and update, i.e. chmod 777 -R * [within the BG-4j directory].</p>
