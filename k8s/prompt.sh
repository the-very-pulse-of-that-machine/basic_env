kubectl logs job/uva-eval-job
kubectl apply -f uva-job.yaml
kubectl delete job uva-eval-job
kubectl get jobs

kubectl delete pod uva-pod
kubectl exec uva-pod -it -- bash
kubectl get pods
kubectl delete pod uva-eval-job-44k94

kubectl cp default/uva-eval-job-k76lp:/data/qiaohansheng/uva/pusht_eval_output ./pusht_eval_output -c uva-eval-container