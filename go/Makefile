isuports: test go.mod go.sum *.go cmd/isuports/*
	go build -o isuports ./cmd/isuports

test:
	go test -v ./...

# from kumashun8/isucon-toolbox
#
SERVICE_NAME = isuports # systemctl status $(SERVICE_NAME)
BUILD_TARGET = isuports
ALP_REGEXP = '/api/sample/[0-9a-z\-]+'

restart: $(BUILD_TARGET) log.rotate restart-mysql restart-app restart-nginx # set build target on top
init: init.config init.asdf init.tools log.init
survey: survey.mysql survey.sqlite survey.nginx

restart-app:
	rm -f /tmp/webapp.sock
	sudo systemctl restart $(SERVICE_NAME)
	sudo systemctl status $(SERVICE_NAME) | tail -n 5

restart-nginx:
	sudo rsync -av ../conf/nginx/ /etc/nginx/
	sudo nginx -s reload
	sudo systemctl status nginx | tail -n 5

restart-mysql:
	sudo rsync -av ../conf/mysql/ /etc/mysql/
	sudo systemctl restart mysql.service
	sudo systemctl status mysql.service | tail -n 5
	../sql/alter.sh

init.config:
	mkdir -p ../conf
	mkdir -p ../conf/nginx
	mkdir -p ../conf/mysql
	mkdir -p ../conf/nginx/sites-enabled
	mkdir -p ../conf/mysql/conf.d
	cp /etc/nginx/nginx.conf ../conf/nginx/nginx.conf
	cp /etc/nginx/sites-enabled/* ../conf/nginx/sites-enabled/
	cp /etc/mysql/conf.d/*.cnf ../conf/mysql/conf.d/

init.asdf:
	git clone https://github.com/asdf-vm/asdf.git ~/.asdf
	echo '. "/home/isucon/.asdf/asdf.sh"' > ~/.bashrc
	. ~/.bashrc

init.tools:
	sudo apt update
	sudo apt-get install -y percona-toolkit unzip
	asdf plugin add alp
	asdf install alp `asdf list-all alp | tail -1`
	asdf global alp `asdf list-all alp | tail -1`

survey.mysql:
	sudo pt-query-digest /var/log/mysql/mysql-slow.log | \
	tee ../survey/mysql/digest_`date +%Y%m%d%H%M%S`.txt

survey.sqlite:
	sed -e '1i\[' -e '$$a\]' -e 's/$$/,/g' ../sql/slowlog_sqlite/log.json | sed -z 's/,\n\]/\n\]/g' | \
	jq 'group_by(.statement) | map({"statement": .[0].statement, "count": [.[]]|length, "avg": ([.[].query_time]|add/length)}) | sort_by(.count) | reverse' | \
	tee ../survey/sqlite/digest_`date +%Y%m%d%H%M%S`.json 

# need to customize regexp
survey.nginx:
	sudo cat /var/log/nginx/access.log | \
	alp json --sort=sum -r -m $(ALP_REGEXP)| \
	tee ../survey/nginx/alp_`date +%Y%m%d%H%M%S`.txt

log.init:
	sudo touch /var/log/mysql/mysql-slow.log
	sudo chmod 666 /var/log/mysql/mysql-slow.log
	sudo chown mysql:mysql /var/log/mysql/mysql-slow.log
	sudo touch /var/log/nginx/access.log
	mkdir -p ../survey
	mkdir -p ../survey/mysql
	mkdir -p ../survey/nginx
	mkdir -p ../survey/sqlite


log.rotate:
	sudo mv /var/log/mysql/mysql-slow.log /var/log/mysql/mysql-slow.log.`date +%Y%m%d%H%M%S`
	sudo touch /var/log/mysql/mysql-slow.log
	mv ../sql/slowlog_sqlite/log.json ../sql/slowlog_sqlite/log_`date +%Y%m%d%H%M%S`.json
	touch ../sql/slowlog_sqlite/log.json
	sudo chmod 666 /var/log/mysql/mysql-slow.log
	sudo chown mysql:mysql /var/log/mysql/mysql-slow.log
	sudo mv /var/log/nginx/access.log /var/log/nginx/access.log.`date +%Y%m%d%H%M%S`
	sudo touch /var/log/nginx/access.log

clean.all: clean.log
	rm -rf ../conf
	sudo rm -rf /home/isucon/.asdf

clean.log:
	rm -rf ../survey

# e.g. GIT_HUB_USER_EMAIL=test@test.com GIT_HUB_USER_NAME=test make config.git
config.git:
	git config --global user.email $$GIT_HUB_USER_EMAIL
	git config --global user.name $$GIT_HUB_USER_NAME
	git config --global core.editor vim
	git config -l

tail.mysql:
	sudo tail -f /var/log/mysql/mysql-slow.log

tail.sqlite:
	tail -f ../sql/slowlog_sqlite/log.json

tail.nginx:
	sudo tail -f /var/log/nginx/access.log

tail.app:
	sudo journalctl -u $(SERVICE_NAME) -f

# mysql slow-log
#
# slow_query_log = 1
# slow_query_log_file = /var/log/mysql/mysql-slow.log
# long_query_time = 0
#
#
# nginx log
# # copy in http directive
# log_format json escape=json '{"time":"$time_iso8601",'
#                             '"host":"$remote_addr",'
#                             '"port":$remote_port,'
#                             '"method":"$request_method",'
#                             '"uri":"$request_uri",'
#                             '"status":"$status",'
#                             '"body_bytes":$body_bytes_sent,'
#                             '"referer":"$http_referer",'
#                             '"ua":"$http_user_agent",'
#                             '"request_time":"$request_time",'
#                             '"response_time":"$upstream_response_time"}';
# access_log /var/log/nginx/access.log json;
