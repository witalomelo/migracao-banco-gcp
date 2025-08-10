#!/bin/bash

INSTANCE="instancia1"
BUCKET="gs://bucket-migracao-10746"

# Pega a lista de bancos na instância, exceto template e padrão (postgres)
DATABASES=$(gcloud sql databases list --instance=$INSTANCE --format="json" | jq -r '.[] | select(.name != "postgres" and .name != "template0" and .name != "template1") | .name')

for DB in $DATABASES; do
  echo "Exportando banco: $DB"
  FILE="$BUCKET/dump_${DB}.sql"

  gcloud sql export sql $INSTANCE $FILE --database=$DB

  if [ $? -eq 0 ]; then
    echo "Exportação do banco $DB concluída com sucesso."
  else
    echo "Erro na exportação do banco $DB."
  fi
done
