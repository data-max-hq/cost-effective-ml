git clone https://github.com/data-max-hq/cost-effective-ml.git

jupyter lab --ip 0.0.0.0

jupyter notebook --ip 0.0.0.0

# Start ray cluster
ray start --head --port=6379 --dashboard-host=0.0.0.0 --disable-usage-stats
ray start --address=192.168.10.160:6379

RAY_ADDRESS='http://192.168.10.160:8265' ray job submit --working-dir . -- python3.9 mnist.py 2