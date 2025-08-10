# Migração de bancos entre instâncias Cloud SQL (PostgreSQL)

## 1. Criar primeira instância

```sh
gcloud sql instances create instancia1 \
  --database-version=POSTGRES_15 \
  --cpu=1 \
  --memory=3840MB \
  --region=us-central1 \
  --storage-size=10GB
```

## 2. Definir senha do usuário admin

```sh
gcloud sql users set-password postgres \
  --instance=instancia1 \
  --password=senhaForte123
```

## 3. Criar banco de teste

```sh
gcloud sql databases create bancoteste --instance=instancia1
```

## 4. Conectar e popular banco de teste

```sh
gcloud sql connect instancia1 --user=postgres
```

```sql
CREATE TABLE clientes (
  id SERIAL PRIMARY KEY,
  nome TEXT NOT NULL,
  email TEXT NOT NULL
);

INSERT INTO clientes (nome, email) VALUES
  ('João', 'joao@example.com'),
  ('Maria', 'maria@example.com');
```

---

## 5. Criar segunda instância

```sh
gcloud sql instances create instancia2 \
  --database-version=POSTGRES_15 \
  --cpu=1 \
  --memory=3840MB \
  --region=us-central1 \
  --storage-size=10GB
```

## 6. Definir senha do usuário admin na segunda instância

```sh
gcloud sql users set-password postgres \
  --instance=instancia2 \
  --password=senhaForte123
```

---

## 7. Criar bucket para migração

```sh
export BUCKET=gs://bucket-migracao-$RANDOM
gcloud storage buckets create $BUCKET --location=us-central1
```

## 8. Permitir acesso do service account ao bucket

```sh
export SERVICE_ACCOUNT_EMAIL=$(gcloud sql instances describe instancia2 --format="value(serviceAccountEmailAddress)")
gsutil iam ch serviceAccount:$SERVICE_ACCOUNT_EMAIL:objectAdmin $BUCKET
```

---

## 9. Exportar todos os bancos da instância origem

> Após criar o bucket, execute o script de exportação para salvar todos os bancos no bucket:

```sh
./exportar_todos_bancos.sh
```

## 10. Importar todos os bancos na instância destino

> Após exportar todos os bancos, execute o script de importação na nova instância para restaurar os bancos exportados:

```sh
./importar_todos_banco.sh
```

---

## 11. Testar conexão na segunda instância

```sh
gcloud sql connect instancia2 --user=postgres
```

## 12. Consultar dados migrados

```sql
SELECT * FROM clientes;
```
