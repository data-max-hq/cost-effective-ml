# Create organization tags

# Create firewall rule
#

# Create instances with tags
# 4 CPU 16 GB 100 GB
sudo apt-get update -y
sudo apt-get install apt-transport-https git -y

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

# Install k3s main
curl -sfL https://get.k3s.io | sh -

# Get node token
#sudo cat /var/lib/rancher/k3s/server/node-token
export K3S_NODE_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)

# Add agent nodes
SERVER_IP=10.128.0.32
K3S_NODE_TOKEN=K1003938202511d74c89bbfd0c851d055d042bfb824e75ae99423c1f4cff3bb307a::server:a7d766c5e4d286a205dcbe8a1fe8e9ac
curl -sfL https://get.k3s.io | K3S_URL=https://${SERVER_IP}:6443 K3S_TOKEN=${K3S_NODE_TOKEN} sh -

# Dashboard
# https://docs.k3s.io/installation/kube-dashboard
GITHUB_URL=https://github.com/kubernetes/dashboard/releases
VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
sudo k3s kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml

vi user.yaml
vi role.yaml

sudo k3s kubectl create -f user.yaml -f role.yaml

sudo k3s kubectl -n kubernetes-dashboard create token admin-user

# eyJhbGciOiJSUzI1NiIsImtpZCI6IjNBVlpjOUNNcXl1X1RMemZWYUk4S1Q3NF95b2J2Nkt1ZFpSWTUxQks4WlkifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiLCJrM3MiXSwiZXhwIjoxNjc5ODYxNTY0LCJpYXQiOjE2Nzk4NTc5NjQsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJhZG1pbi11c2VyIiwidWlkIjoiNjMwNjhlZjctZGFmNC00YzlkLWFiY2QtMTc0YWNhMjMxNTQ1In19LCJuYmYiOjE2Nzk4NTc5NjQsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlcm5ldGVzLWRhc2hib2FyZDphZG1pbi11c2VyIn0.wYg76TAcgpr7eE4mltY-Ib6-46rHnmwLeNBDD97JJ9V_KPw76E0YJ_PNbCj_onwijpDo0ZIyIYh563vNDKnIUisJ-3M_WktqTK9vRaNXO13JpySvlGsGeAdTe82yLrJHqKM92TKtZpr9TgfckYx-N0iGtay3bZ1Jl3qgupeJJfBua7l1oKHFAlwFU9Tjo1G6GFhgMGXjzAsj-1Lvo9MPviqJVorzneQU4BL7QSyjkHqh33Mhc3nDf9X7bTRyXBzPcyfgJwTR1VxVaDB7uBOaHu3B_rzXeyX-KAGEOD-ajeAPNbEF9tvBSLIzAucEE7z5AWMgF6Z0wdO30elX97jc8Q

sudo k3s kubectl port-forward svc/kubernetes-dashboard  -n kubernetes-dashboard 8443:443 --address='0.0.0.0'

# Kubeflow UI

sudo k3s kubectl port-forward svc/ml-pipeline-ui  -n kubeflow 8080:80 --address='0.0.0.0'
