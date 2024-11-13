<h4><b>Папка users-app:</b></h4>
Содержит пройстейшее приложение для api.

<h4><b>Папка k8s-manifests:</b></h4>
Сборка манифестов k8s лежит в директории k8s-manifests.<br />
Чтобы собрать ее нужно в директории выполнить:<br />
kubectl apply -f .

Удаление в директории k8s-manifests:<br />
kubectl delete -f .

<h4><b>Папка users-charts:</b></h4>
Содержит манифесты helm чарта. 

<h4><b>Файл users-chart-0.1.5.tgz:</b></h4>
Содержит уже собранный helm чарт.
Чтобы собрать его нужно выполнить:<br />
helm install users-chart ./users-chart-0.1.5.tgz

Чтобы удалить его нужно выполнить:<br />
helm uninstall users-chart

Проверка:<br />
Добавить в hosts строку(ip можно взять из Address в команде - kubectl get ingress)<br />
192.168.49.2	arch.homework

В постмане сделать импорт файла users_app.postman_collection.json.
Протестировать CRUD методы. В методах update и delete использовать существующие id.

<i>В файле newman_screenshot.jpg приложен скриншот от newman тестa.</i>