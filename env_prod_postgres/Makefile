create_user:
			##创建kong用户
			docker exec -t postgres psql "host=127.0.0.1 user=postgres password=c99ee26a6727380311dae5431e348b76" -c "CREATE USER kong WITH PASSWORD 'f334ed0e3';"
			docker exec -t postgres psql "host=127.0.0.1 user=postgres password=c99ee26a6727380311dae5431e348b76" -c "create database kong owner kong; "
			docker exec -t postgres psql "host=127.0.0.1 user=postgres password=c99ee26a6727380311dae5431e348b76" -c "GRANT ALL PRIVILEGES ON DATABASE kong TO kong;"
			##创建konga用户
			docker exec -t postgres psql "host=127.0.0.1 user=postgres password=c99ee26a6727380311dae5431e348b76" -c "CREATE USER konga WITH PASSWORD 'konga123';"
			docker exec -t postgres psql "host=127.0.0.1 user=postgres password=c99ee26a6727380311dae5431e348b76" -c "create database konga owner konga; "
			docker exec -t postgres psql "host=127.0.0.1 user=postgres password=c99ee26a6727380311dae5431e348b76" -c "GRANT ALL PRIVILEGES ON DATABASE konga TO konga;"

