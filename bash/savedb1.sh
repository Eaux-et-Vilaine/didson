# save didson

d:
pg_dump --dbname=postgresql://${env:usermercure}:${env:passmercure}@${env:hostmercure}:5432/didson -Fc -f "sauv_base\didson_2024.backup" 


# run 04/03/2025 before changing time

pg_dump --dbname=postgresql://${env:usermercure}:${env:passmercure}@${env:hostmercure}:5432/didson2 --table did.t_env_env | psql --dbname=postgresql://${env:usermercure}:${env:passmercure}@${env:hostmercure}:5432/didson 