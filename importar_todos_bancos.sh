#!/bin/bash

INSTANCE="instancia2"
BUCKET="gs://bucket-migracao-10746"

# Lista todos os arquivos .sql no bucket
FILES=$(gsutil ls $BUCKET/*.sql)

for FILE in $FILES; do
  # Extrai o nome do banco do arquivo (removendo prefixo e extensão)
  BASENAME=$(basename $FILE)            
  DBNAME=${BASENAME#dump_}              
  DBNAME=${DBNAME%.sql}                  

  echo "Importando arquivo $FILE para banco $DBNAME"

  # Criar banco se não existir (ignora erro se já existir)
  gcloud sql databases create $DBNAME --instance=$INSTANCE || true

  # Importa o arquivo para o banco
  gcloud sql import sql $INSTANCE $FILE --database=$DBNAME --quiet

  if [ $? -eq 0 ]; then
    echo "Importação do banco $DBNAME concluída com sucesso."
  else
    echo "Erro na importação do banco $DBNAME."
  fi
done
