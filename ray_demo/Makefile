requirements:
	pip install -r requirements.txt

start-jupyter:
	jupyter lab --ip 0.0.0.0

start-ray:
	ray start --head --port=6379 --dashboard-host=0.0.0.0 --disable-usage-stats

clone:
	git clone https://github.com/data-max-hq/cost-effective-ml.git

j:
	jupyter lab --ip 0.0.0.0

r:
	ray start --head --port=6379 --dashboard-host=0.0.0.0 --disable-usage-stats

terminal:
	RAY_ADDRESS='http://192.168.10.65:8265' ray job submit --working-dir . -- python3.10 mnist.py 2