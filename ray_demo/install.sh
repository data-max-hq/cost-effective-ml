jupyter lab --ip 0.0.0.0

jupyter notebook --ip 0.0.0.0

# Start ray cluster
ray start --head --port=6379 --dashboard-host=0.0.0.0
ray start --address=192.168.11.161:6379

git clone https://github.com/data-max-hq/cost-effective-ml.git

RAY_ADDRESS='http://192.168.11.161:8265' ray job submit --working-dir . -- python3.9 mnist.py 2