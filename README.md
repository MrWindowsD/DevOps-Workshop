# DevOps-SkillBox
## Как запустить ВМ на Windows
1. Для начала стоит создать ВМ. Для этого можем воспользоваться Yandex.Cloud или любой другой платформой для создания ВМ.  
Также для ВМ нам понадобиться SSH ключ, его можно создать при помощи PuTTYgen, после его создание необходимо сохранить приватную версию ключа, в ВМ будем использовать публичную версию. 
2. После создания ВМ и его успешного запуска (это происходит автоматически, если правильно создать ВМ) нам нужно к нему подключиться, для этого мы запускаем программу PuTTY и в разделе "Session" заполняем публичный IP-adderss (который был выдан вашей ВМ), порт: 22 (классика), название (Saved Sessions) и для входа выбираем "Only on clean exit", после чего сохраняем данную сессию.  
3. После чего нам нужно запустить PuTTY Pageant и добавить туда свой приватный SSH ключ, после чего выходим.  

Теперь мы можем подключаться к нашей ВМ. Для этого в PuTTY загружаем нашу ранее подготовленную сессию и нажимаем на "Open" и у нас запускается консоль, где мы для входа используем свой логин и пароль. После успешного входа мы увидим в консоли имя_пользователя@название_вм:~$  
## Установка необходимых пакетов
Для выполнения поставленных нами задач мы установим на ВМ следующие пакеты: 
- GIt — это бесплатная распределенная система управления версиями с открытым исходным кодом, предназначенная для быстрой и эффективной обработки любых проектов, от небольших до очень крупных.  
- Docker — программное обеспечение для автоматизации развёртывания и управления приложениями в средах с поддержкой контейнеризации. Позволяет «упаковать» приложение со всем его окружением и зависимостями в контейнер, который может быть перенесён на любую Linux-систему с поддержкой cgroups в ядре, а также предоставляет среду по управлению контейнерами.
- Любой текстовый редактор. К примеру **Nano**  

Начнём по порядку. Дня начала по традиции обновляем все репозитории. Для этого вводим команду:  
`sudo apt-get update`. Напоминаю, что в нашем случае у нас стоит _Ubuntu_.  
Теперь устанавливаем необходимые пакеты:  
`sudo apt-get install git docker.io nano`  
Отлично. Установка пакетов закончена. Теперь можем приступать к работе с ВМ !  

## Непрерывная интеграция (CI)
https://www.red-gate.com/simple-talk/sysadmin/devops/introduction-to-devops-the-application-delivery-pipeline/  
  
CI (Continuous Integration) — в дословном переводе «непрерывная интеграция». Имеется в виду интеграция отдельных кусочков кода приложения между собой. CI позволяет делать такие проверки автоматически. Он используется в продвинутых командах разработки, которые пишут не только код, но и автотесты. 
В данном разделе мы узнаем о том, как произвести деплой нашего проекта.  

1. Для начала нам нужен сервис, который поможет в CI, к примеру _GitLab_. После регистрации нам нужно создать пустой репозиторий, а также подключить ранее созданный SSH ключ.
2. Нам нужно перенести наш ранее созданный репозиторий на _GitLab_, так как мы использовали _GitHub_ нам понадобиться следующие команды. **Прежде чем переносить репозиторий убедитесь в том, что ваши изменения перенесены с локального на виртуальный репозиторий (на сервер, где храниться </>)**  
Для начала нам стоит узнать название нашего репозитория командой:  
`git remote`. Обычно это "origin".  
После чего мы можем убедиться в том, что это действительно тот репозиторий который нам нужен, а не какой-то другой командой:  
`git remote show -n origin`  
После того как мы в этом убедились, нам нужно переименовать наш репозиторий:  
`git remote rename origin [new_name]`  
Дальше нам нужно просто через ссылку добавить наш репозиторий:  
`git remote add origin https://gitlab.com/userName/repoName.git`. Проверяем командой `git remote` и убеждаемся в том, что у нас теперь два репозитория, один _origin_, другой тот что мы задавали ранее.  
Теперь нам остаётся только запушать наши изменения на сервер:  
`git push -u origin master`   
3. После клонирования репозитория на _GitLab_ нам нужно построить DevOps-пайплайн для запуска CI  
Для этого создаём новый файл: _.gitlab-ci.yml_ в директории репозитория.  
После чего прописываем следующие:  

---

> image: docker

> services:  
ㅤㅤ- docker:dind

> build:  
ㅤㅤscript:  
ㅤㅤㅤㅤ- docker build . --tag flatris  

---

_Так как это YAML соблюдайте пробелы и разметку. НЕ нужно копировать этот текст_  
После чего сохраняем изменения:  
`git add .`  
`git commit -m "Added gitlab ci pipeline"`  
`git push` или `git push -u origin main` — в моём случае.  
После чего начинается скачивания образа системы на _GitLab_ и запускается файл _.gitlab-ci.yml_, после чего запуститься прописанный скрипт.  
Но пока что pipeline лишь собрал наш docker образ. И мы его никак не можем получить.  
4. Для того чтобы другие люди его смогли скачать мы будем использовать Container Registry. Такую функцию предоставляет нам _GitLab_, но есть и другие способы. Для этого воспользуемся возможностями `docker login --help`, а именно передавать логин и пароль с ключами через командную строку. Этим мы и воспользуемся, чтобы залогиниться в pipeline и там же отправлять наш контейнер на публикацию в Container Registry.  
Для начала нам нужно отредактировать файл _.gitlab-ci.yml_:  

---

> image: docker  

> services:  
ㅤㅤ- docker:dind  

> before_script:  
ㅤㅤ- docker login registry.gitlab.com -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD  
  
> build:  
ㅤㅤscript:  
ㅤㅤㅤㅤ- docker pull registry.gitlab.com/userName/repoName || true  
ㅤㅤㅤㅤ- docker build -t registry.gitlab.com/userName/repoName:latest -t registry.gitlab.com/userName/repoName:$CI_COMMIT_SHORT_SHA . --cache-from registry.gitlab.com/userName/repoName  
ㅤㅤㅤㅤ- docker push registry.gitlab.com/userName/repoName:latest  
ㅤㅤㅤㅤ- docker push registry.gitlab.com/userName/repoName:$CI_COMMIT_SHORT_SHA  

---

_CI_REGISTRY_USER и $CI_REGISTRY_PASSWORD вбивают вашего USER и PASSWORD для входа, при том эти данные будут скрыты. userName/repoName — используем свой адрес репозитория_.  
После чего снова сохраняем изменения, комментируем и отправляем на виртуальный репозиторий в _GitLab_. Отлично, наш образ готов !  

Конструкция `|| true` и `--cache-from` поможет ускорить процесс сборки. `:latest -t registry.gitlab.com/userName/repoName:latest:$CI_COMMIT_SHORT_SHA` что это за монстр такой ? Данная конструкция меняет название нашей сборки на _GitLab_ с "latest" на CI_COMMIT_SHORT_SHA. `CI_COMMIT_SHORT_SHA` в свою очередь просто короткий набор символов, который скорее всего не будет повторяться. Это сделано для того, чтобы другим пользователям можно было узнать: менялся ли наш билд вообще.  
Отлично ! На этом с пайплайном можно закончить. Основу под конвейер мы какую-то заложили. Что дальше ?  

## Создаём deployments через Kubernetes
Deployment — это такая сущность Kubernetes-а. С помощью Deploymen-та мы сможем указывать какой кол-во кластеров нужно поднять или прибить. Нужно это для балансировщика — единая входная точка для пользователей, которая распределяет их по приложениям (кластерам) для снижения нагрузки на сервер.  
Kubernetes — открытое программное обеспечение для автоматизации развёртывания, масштабирования конвейеризированных приложений и управления ими. Поддерживает основные технологии контейнеризации, включая Docker, rkt.  
Также возможна поддержка технологий аппаратной виртуализации. Что это значит ? Это значит, что мы можем зайти на тот же Yandex.Cloud и запустить там новый кластер в разделе "Managed Service for Kubernetes". С этого и начнём.  
1. Создаём на любой платформе новый кластер Kubernetes.
2. Всё там же создаём группу узлов. Если не вникать в подробности, то группа узлов — это ВМ, грубо говоря мощность нашего Kubernetes-а. При создание группы узлов нужно будет использовать тот же логи и публичный SSH ключ, что и при создание ВМ.  
3. Дальше нам понадобиться установить приложение Yandex Cloud, о том как это сделать написано тут: https://cloud.yandex.ru/docs/cli/quickstart 
4. Теперь нам нужно установить консольный менеджер, чтобы как-то взаимодействовать с нашим Kubernetes, о том как это сделать написано тут: https://kubernetes.io/ru/docs/tasks/tools/install-kubectl/  
5. После успешной установки давай узнаем какие у нас есть доступные кластера в облаке:  
`yc k8s cluster list`  
После того как мы убедились в том, что у нас всё работает, давайте попробуем подключиться к нашему кластеру, для этого вводим:  
`yc k8s cluster get-credentials --external [ID]`. Вместо [ID] пишем ID своего кластера.  
`kubectl create deployment [name] --image=registry.gitlab.com/userName/repoName:CI_COMMIT_SHORT_SHA`. Такой командой мы создаём наш deployment, где должны дать ему [name] и _image_. Я взял image с CI_COMMIT_SHORT_SHA, который сохранился при создание образа на _GitLab_ в нашем контейнере.  
Командой `kubectl get deployments` смотрим список наших deployments. После того как наш deployment будет готов мы продолжим.  
Командой `kubectl expose deployments [name_deployment] --port=[number] --target-port=[number] --type=LoadBalancer` мы создаём сервер и сообщаем всему миру о нашем deployment-е. **LoadBalancer** — это как раз тот самый балансеровщик, который будет распределять нагрузку между нашими сервисами и будет доступен в интернете.  
А командой `kubectl get services` мы можем посмотреть список наших серверов. Хочу заметить, что на локальной машине Kubernetes никак не сможет создать внешний ip.  
Для того чтобы увеличить кол-во инстансов для нашего deployment-а, воспользуемся командой `kubectl scale deployment [name_deployment] --replicas=[number]` где [number] кол-во инстансов которое мы хотим.  
Командой `kubectl get po` мы можем увидеть, что у нас создались ещё новые контейнеры.  
7. Также есть возможность создать все эти сущность через файл _.gitlab-ci.yml_. Для этого можем воспользоваться Сервисом **NodePort** — самый примитивный способ направить внешний трафик в сервис. NodePort, как следует из названия, открывает указанный порт для всех Nodes (виртуальных машин), и трафик на этот порт перенаправляется сервису.  
YAML (мы создаём отдельный файл, к примеру _deploy.yml_) для службы NodePort выглядит так:  

---

> apiVersion: v1  
kind: Service  
metadata:  
ㅤname: my-nodeport-service  
selector:  
ㅤapp: my-app  
spec:  
ㅤtype: NodePort  
ㅤports:  
ㅤ- name: http  
ㅤㅤport: [number]  
ㅤㅤtargetPort: [number]  
ㅤㅤnodePort: 30036  
ㅤㅤprotocol: TCP  

---

Метод имеет множество недостатков:  
На порт садится только один сервис  
Доступны только порты 30000–32767  
Если IP-адрес узла/виртуальной машины изменяется, придется разбираться  
  
По этим причинам я не рекомендую использовать этот метод в продакшн, чтобы напрямую предоставлять доступ к сервису. Но если постоянная доступность сервиса вам безразлична, а уровень затрат — нет, этот метод для вас. Хороший пример такого приложения — демка или временная затычка.  
8. Для LoadBalancer YAML файл (мы создаём отдельный файл, к примеру _deploy.yml_) будет выглядит примерно так:  

---


> apiVersion: apps/v1  
kind: Deployment  
metadata:  
ㅤname: [name_deployment]  
ㅤlabels:  
ㅤㅤapp: [name_deployment]  
spec:  
ㅤreplicas: [number]  
ㅤselector:  
ㅤㅤmatchLabels:  
ㅤㅤㅤapp: [name_deployment]  
ㅤtemplate:  
ㅤㅤmetadata:  
ㅤㅤㅤlabels:  
ㅤㅤㅤㅤapp: [name_deployment]  
ㅤㅤspec:  
ㅤㅤㅤcontainers:  
ㅤㅤㅤㅤ- name: [name_deployment]  
ㅤㅤㅤㅤㅤimage: registry.gitlab.com/userName/repoName:latest  
  
  
> apiVersion: v1  
kind: Service  
metadata:  
ㅤname: [name_deployment]  
spec:  
ㅤselector:  
ㅤㅤapp: [name_deployment]  
ㅤports:  
ㅤㅤ- port: [number]  
ㅤㅤㅤtargetPort: [number]  
ㅤㅤtype: LoadBalancer  

---

На этом создание deployment-а подошёл к концу.  

## Красивый pipeline
На последок хочется сделать наш pipeline более грамотным и красивым. Для это сделаем следующие изменения:  

---

> image: docker  
services:  
ㅤㅤ- docker:dind  

> stages:  
ㅤ- build  
ㅤ- test  
ㅤ- release  

---

Такой добавкой мы разделим наш pipeline на этапы, а именно на build, test и release.

---

> variables:  
ㅤCONTAINER_TEST_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA  
ㅤCONTAINER_RELEASE_IMAGE: $CI_REGISTRY_IMAGE:latest  

---

Тут мы выносим переменные в отдельный блок, чтобы было проще к ним обращаться. Также изменения не будут дублироваться.

---

> before_script:  
ㅤ- docker login registry.gitlab.com -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD  

---

Тут мы ничего не меняем.

---

> build:  
ㅤstage: build  
ㅤscript:  
ㅤㅤ- docker build --pull -t $CONTAINER_TEST_IMAGE .  
ㅤㅤ- docker push $CONTAINER_TEST_IMAGE  

---

Это этап сборки, который был упрощён для удобства. Как можно заметить тут теперь используется конструкция `$CONTAINER_TEST_IMAGE` которая была вынесена в отдельный блок выше, что сильно сокращает наш код и делает его более читабельным.

---

> test:  
ㅤstage: test  
ㅤscript:  
ㅤㅤ- docker pull $CONTAINER_TEST_IMAGE  
ㅤㅤ- docker run $CONTAINER_TEST_IMAGE yarn test  

---

Это новый блок. Блок теста. Мы кэшируем наш билд и запускаем знакомый `yarn test`. Однако хочу заметить, что в таком случае нужно в файле _Dockerfile_ убрать или закомментировать строку `RUN yarn test`, думаю понятно зачем.

---

> release-image:  
ㅤstage: release  
ㅤscript:  
ㅤㅤ- docker pull $CONTAINER_TEST_IMAGE  
ㅤㅤ- docker tag $CONTAINER_TEST_IMAGE $CONTAINER_RELEASE_IMAGE  
ㅤㅤ- docker push $CONTAINER_RELEASE_IMAGE  
ㅤonly:  
ㅤㅤ- master  

---

Это релиз нашего билда. Он немного потолстел, зато стал стройнее, особенно за счёт конструкции `only: - master` которая делает релиз нового билда в ветку master, что упрощает жизнь не трогая ветку main.


Вот и всё. Процесс долгий, сложный, зато интереный ! Good Luck 
  
https://gitlab.com/MrWindowsD/devops-skillbox.git

---

# Flatris
[![Flatris](flatris.png)](https://flatris.space/)

[![Build Status](https://travis-ci.org/skidding/flatris.svg?branch=master)](https://travis-ci.org/skidding/flatris)

> **Work in progress:** Flatris has been recently redesigned from the ground up and turned into a multiplayer game with both UI and server components. This has been an interesting journey and I plan to document the architecture in depth. **[Stay tuned](https://twitter.com/skidding)**.

[![Flatris](flatris.gif)](https://flatris.space/)

> **Contribution disclaimer:** Flatris is a web game with an opinionated feature set and architectural design. It doesn't have a roadmap. While I'm generally open to ideas, I would advise against submitting unannounced PRs with new or modified functionality. That said, **bug reports and fixes are most appreciated.**

Thanks [@paulgergely](https://twitter.com/paulgergely) for the initial flat design!

Also see [elm-flatris](https://github.com/w0rm/elm-flatris).


## Setup and running

```
yarn install
yarn test
yarn build
yarn start
```

Go to http://localhost:3000
