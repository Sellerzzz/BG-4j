#check latest dataset against current if == then !
wget -q -O Stats.txt https://wiki.thebiogrid.org/doku.php/statistics
grep -i "Current Build Statistics (" Stats.txt | head -1 > tbuild
rm Stats.txt
grep -o -P '(?<=\().*(?=\))' tbuild > vbuild

CHECK=$(<vbuild)
if grep -q $CHECK 'build'; then
    echo No update available
	rm vbuild tbuild
	exit
else
    echo Updating...
	mv vbuild build

#download latest dataset
	echo Downloading latest build...
BUILD=$(<build)

mkdir BioGRID-build-"$BUILD"
cd BioGRID-build-"$BUILD"
wget -q "https://thebiogrid.org/downloads/archives/Release%20Archive/BIOGRID-$BUILD/BIOGRID-ORGANISM-$BUILD.tab2.zip"
	echo Unzipping build...
#potentially need to clean before unzipping maybe save in specific builds then add option to remove all old builds?
unzip -u -qq "BIOGRID-ORGANISM-$BUILD.tab2.zip"
	printf "Updated build unzipped.\nPreparing files for import\n"

#prep files for import
CURR=BIOGRID-ORGANISM-Homo_sapiens-"$BUILD".tab2.txt
cp $CURR BioGRID-relations-"$BUILD".tab2.txt

#create nodes and relations
n=$(hexdump -n 16 -e '4/4 "%08X"' /dev/random)
m=$(hexdump -n 16 -e '4/4 "%08X"' /dev/random)
rfile1="$n".txt
rfile2="$m".txt

cut -f 2,4,6,8,10,16 $CURR > $rfile1
cut -f 3,5,7,9,11,17 $CURR | tail +2 > $rfile2

cat $rfile1 $rfile2 > BioGRID-nodes-"$BUILD".tab2.txt
NODES=BioGRID-nodes-"$BUILD".tab2.txt
rm $rfile1 $rfile2
(head -n 1 $NODES && tail -n +2 $NODES | sort -u ) > temp
mv temp $NODES

#prep headers, labels & types
sed -i 's/$/\tProtein/' $NODES
tail -n +2 $NODES > temp
sed -i '1i nodeid:ID\tBioGRID ID Interactor A\tSystematic Name Interactor A\tOfficial Symbol Interactor A\tSynonyms Interactor A\tOrganism Interactor A\t:Label' temp
mv temp $NODES

RELAS=BioGRID-relations-"$BUILD".tab2.txt
sed -i 's/$/\tpp/' $RELAS
tail -n +2 $RELAS > temp
sed -i '1i BioGRID Interaction ID\t:START_ID\t:END_ID\tBioGRID ID Interactor A\tBioGRID ID Interactor B\tSystematic Name Interactor A\tSystematic Name Interactor B\tOfficial Symbol Interactor A\tOfficial Symbol Interactor B\tSynonyms Interactor A\tSynonyms Interactor B\tExperimental System\tExperimental System Type\tAuthor\tPubmed ID\tOrganism Interactor A\tOrganism Interactor \tThroughput\tScore\tModification\tPhenotypes\tQualifications\tTags\tSource Database\t:TYPE' temp
mv temp $RELAS

#pass nodes and relaations to cypher-shell or neo4j-import NEXT TO DO

neo4j stop
#neo4j-admin dump --database=BioGRID.db --to=/root/Research/Neo4j/Backup #Dump current db
#neo4j-admin import --database="BioGRID-$BUILD.db" --mode=csv --delimiter="TAB" --nodes:ID="$NODES" --relationships:TYPE="$RELAS"

echo 'Importing data to /var/lib/neo4j/data/databases/BioGRID-$BUILD.db'

mkdir /var/lib/neo4j/data/databases/BioGRID-$BUILD.db
cp "$NODES" /var/lib/neo4j/data/databases/BioGRID-$BUILD.db
cp "$RELAS" /var/lib/neo4j/data/databases/BioGRID-$BUILD.db
sudo neo4j-import --into /var/lib/neo4j/data/databases/BioGRID-$BUILD.db/ --delimiter 'TAB' --nodes "$NODES" --relationships "$RELAS"

echo 'NOTE: you will now need to change your active database within the neo4j.conf file to load from the updated database (default path: "/etc/neo4j/neo4j.conf") i.e. redefine "dbms.active_database=graph.db" to dbms.active_database=BioGRID-$BUILD before starting neo4j'

	exit
fi
