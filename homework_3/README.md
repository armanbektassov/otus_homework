Сборка в директории homework_3:<br />
kubectl apply -f .

Удаление в директории homework_3:<br />
kubectl delete -f .

Проверка:<br />
Нужно подождать, пока появится ADDRESS у ingress.
Добавить в hosts строку(ip можно взять из Address в команде - kubectl get ingress)<br />
192.168.49.2	arch.homework

Затем открыть в бразуере http://arch.homework/health/ или дернуть курлом<br />
curl http://arch.homework/health/