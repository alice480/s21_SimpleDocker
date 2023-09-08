# DO5_SimpleDocker-1 Report


## Part 1. Готовый докер


**== Выполнение ==**

- Выкачаем официальный докер образ с **nginx** при помощи `docker pull`

![image](./images/docker_pull_ngix.png)

- Проверим наличие докер образа через `docker images`

![image](./images/docker_images.png)


- Запустим докер образ через `docker run -d [image_id|repository]`: `docker run -d ngix`
- Проверим, что образ запустился: `docker ps`

![image](./images/docker_run_docker_ps.png)

- Посмотрим информацию о контейнере через `docker inspect [container_id]` или `docker inspect [container_name]`

![image](./images/docker_inspect_id.png)
![image](./images/docker_inspect_name.png)

- По выводу команды с помощью `grep` определим _размер контейнера_, _список замапленных портов_ и _ip контейнера_

![image](./images/container_info.png)

- Остановим докер образ через `docker stop [container_id|container_name]`

![image](./images/docker_stop.png)

- Проверим, что образ остановился: `docker ps`. Вывод команды должен быть пустым

![image](./images/docker_ps_empty.png)

- Запустим докер с портами 80 и 443 в контейнере. Для этого выполним *run* с опцией `--publish` для сопоставления портов

![image](./images/docker_run_publish.png)

- Команда `docker ps` в колонке _PORTS_ теперь отображает замапленные порты

![image](./images/mapped_ports.png)

- Проверим, что в браузере по адресу *localhost:80* доступна стартовая страница **nginx**

![image](./images/ngix_start_page.png)

- Перезапустим докер контейнер через `docker restart [container_id|container_name]`. Проверим, что контейнер запустился, с помощью `docker ps`. Колонка _STATUS_ была обновлена: контейнер работает 2 секунды (после перезапуска)

![image](./images/docker_restart.png)


## Part 2. Операции с контейнером


- Прочитаем конфигурационный файл *nginx.conf* внутри докер контейнера _boring_engelbart_ через команду *exec*: `docker exec [container_name] cat [file_path]`

![image](./images/ngix_conf.png)

- Создим на локальной машине файл *nginx.conf*: `touch ngix.conf`

- Настроим в *nginx.conf* по пути */status* отдачу страницы статуса сервера **nginx**: добавим блок _server_, а также закомментируем `#include /etc/nginx/conf.d/*.conf;`

![image](./images/nginx_conf.png)

- Скопируем созданный файл *nginx.conf* внутрь докер образа через команду _docker cp_: `docker cp [source_path] [container_name]:[dest_path]`

![image](./images/docker_cp_nginx_conf.png)

- Перезапустим **nginx** внутри докер образа через команду *exec*: `docker exec [container_name] nginx -s reload`

![image](./images/exec_nginx_reload.png)

- Проверим, что по адресу *localhost:80/status* отдается страничка со статусом сервера **nginx**

![image](./images/localhost_status.png)

- Экспортируем контейнер в файл *container.tar* через команду *export*: `docker export [container_name] > [file_name]`

![image](./images/container_tar.png)

- Остановим контейнер: `docker stop [container_name]`

![image](./images/docker_stop_container.png)

- Удалим образ через `docker rmi [image_id|repository]`, не удаляя перед этим контейнеры

![image](./images/docker_rmi_f.png)

> При простом запуске rmi команда выдает ошибку, сообщающую о том, что удаление образа _ngix_ невозможно из-за использования его контейнером. Запустим удаление с опцией --force (-f), принудительно удаляющей образы

- Удалим остановленный контейнер: `docker rm [container_name]`

![image](./images/docker_rm_container.png)

> До удаления контейнера команда `docker ps -a` отображает информацию о нем, после удаления вывод этой команды пуст. Значит контейнер был успешно удален


- Импортируем контейнер обратно через команду *import*

![image](./images/docker_import_with_cmd.png)

> Так как `docker export` не экспортирует всю информацию о контейнере, при импорте дампа обратно в новый образ докера необходимо указать дополнительные флаги для воссоздания контекста. Поскольку для запуска контейнера необходима одна из инструкций _ENTRYPOINT_ или _CMD_, нужно определить одну из них

- Запустим импортированный контейнер

![image](./images/docker_run_new_image.png)

- Проверим, что по адресу *localhost:80/status* отдается страничка со статусом сервера **nginx**

![image](./images/new_container_status.png)


## Part 3. Мини веб-сервер


- Выкачаем официальный докер образ `docker pull nginx` и запустим контейнер с портом 81

![image](./images/docker_run_nginx_81.png)

- Напишем мини сервер на **C** и **FastCgi**, который будет возвращать простейшую страничку с надписью `Hello World!`

![image](./images/fcgi_app.png)

- Напшем *nginx.conf*, который будет проксировать все запросы с 81 порта на *127.0.0.1:8080*

![image](./images/nginx_cong_fcgi.png)

> `fastcgi_pass адрес;` задает адрес FastCGI-сервера

- Скопируем созданные файлы в контейнер с помощью _docker cp_

![image](./images/docker_cp_files.png)

- Зайдем в контейнер с использованием оболочки _bash_ и обновим _apt-get_ 

![image](./images/apt_get_update_in_container.png)

- Скачаем _gcc_ (компиляции FastCgi-приложения на C), _spawn-fcgi_ (порождает процессы FastCGI), _libfcgi-dev_ (содержит заголовочные файлы FastCGI)

![image](./images/apt_install_in_container.png)

- Скомпилируем FastCGI-приложение, отдающее страничку c `Hello World!`

![image](./images/gcc_fcgi_server.png)

> `-l` указывает, с какой библиотекой скомпилировать файл

- Запустим написанный мини сервер через *spawn-fcgi* на порту 8080

![image](./images/spawn_fcgi.png)

> `spawn−fcgi [опции] [ −− <приложение−fcgi> [аргументы приложения fcgi]]`. В качестве опции указываем -p для указания прослушиваемого порта TCP

- Проверим, что в браузере по *localhost:81* отдается написанная вами страничка

![image](./images/hello_world.png)

- Положим файл *nginx.conf* по пути *./nginx/nginx.conf*


## Part 4. Свой докер

- Напишем скрипт run.sh для запуска процессов _fcgi_ и _nginx_

![image](./images/run_sh.png)

- Напишем свой докер образ

    1. собирает исходники мини сервера на FastCgi из [Части 3]
    2. запускает его на 8080 порту
    3. копирует внутрь образа написанный *./nginx/nginx.conf*
    4. запускает **nginx**

![image](./images/dockerfile_part4.png)

> `FROM nginx`: образ собирается на основе готового **nginx**

- Соберем написанный докер образ через `docker build` при этом указав имя и тег

![image](./images/docker_build_part4.png)

> Синтаксис команды _build_: `docker build [OPTIONS] PATH`. `-t` позволяет задать имя и тег (опционально)

- Проверим через `docker images`, что все собралось корректно

![image](./images/docker_images_my_docker_part4.png)

- Запустим собранный докер образ с маппингом 81 порта на 80 на локальной машине и маппингом папки *./nginx* внутрь контейнера по адресу, где лежат конфигурационные файлы **nginx**'а

![image](./images/docker_run_with_mount.png)

> `--mount type=bind,source=[host-src],target=[container-dest]` позволяет смонтировать папки на хосте и в контейнере

- Проверим, что по localhost:80 доступна страничка написанного мини сервера

![image](./images/hello_world2.png)

- Допишем в *./nginx/nginx.conf* проксирование странички */status*, по которой надо отдавать статус сервера **nginx**

![image](./images/vim_nginx_config.png)

- Перезапустим контейнер

![image](./images/docker_restart_my_docker.png)

> После сохранения файла и перезапуска контейнера конфигурационный файл внутри докер образа обновляется самостоятельно

- Проверим, что теперь по *localhost:80/status* отдается страничка со статусом **nginx**

![image](./images/localhost_status2.png)


## Part 5. **Dockle**


- Устанавливаем _dockle_ (Ubuntu):

> VERSION=$(
 curl --silent "https://api.github.com/repos/goodwithtech/dockle/releases/latest" | \
 grep '"tag_name":' | \
 sed -E 's/.*"v([^"]+)".*/\1/' \
) && curl -L -o dockle.deb https://github.com/goodwithtech/dockle/releases/download/v${VERSION}/dockle_${VERSION}_Linux-64bit.deb
$ sudo dpkg -i dockle.deb && rm dockle.deb

> sudo dpkg -i dockle.deb && rm dockle.deb

- Просканируем образ из предыдущего задания через `dockle [image_id|repository]`

![image](./images/dockle_scan.png)

- Исправим образ так, чтобы при проверке через **dockle** не было ошибок и предупреждений

![image](./images/dockerfile_corrected_part5.png)

> `rm -rf /var/lib/apt/lists`: очистка apt-get кэша

> `USER my_docker_user`: создать пользователя контейнера

- Соберем новый образ

![image](./images/docker_build_part5.png)

- Просканируем исправленную версию образа: `dockle -ak NGINX_GPGKEY -ak NGINX_GPGKEY_PATH [image_name]:[image_tag]`

![image](./images/dockle_part5.png)

> Так как образ создается на основе _официальной последней версии nginx_, в Dockerfile которой используются NGINX_GPGKEY и NGINX_GPGKEY_PATH, а _Dockle_ в _CIS-DI-0010_ ищет ключевые слова (key, password), то это приводит к ложным срабатываниям. Поэтому запустим dockle с флагом `-ak`



## Part 6. Базовый **Docker Compose**


- Напишем файл *docker-compose.yml*, с помощью которого:
    1. Поднимем докер контейнер из [Части 5]
    2. Поднимем докер контейнер с **nginx**, который будет проксировать все запросы с 8080 порта на 81 порт первого контейнера
    3. Замапим 8080 порт второго контейнера на 80 порт локальной машины

![image](./images/docker_compose_yaml.png)

- Остановим запущенные контейнеры

![image](./images/docker_stop6.png)

- Соберем и запустим проект с помощью команд `docker-compose build` и `docker-compose up`

![image](./images/docker_compose_part6.png)

![image](./images/docker_compose_up.png)

- Проверить, что в браузере по *localhost:80* отдается написанная вами страничка, как и ранее

![image](./images/hello_world3.png)




