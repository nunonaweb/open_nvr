



#Tnunel ssh para o Lens:
#ssh -L 45543:localhost:45543 bruno@192.168.1.140

# acessar http://192.168.1.140:8080/
kubectl port-forward -n nvr service/nvr-viewer-service 8080:80 --address 0.0.0.0
