FROM ray-ml:2.3.0-py38

COPY ../ray-cluster/mnist-tf.py mmist-tf.py
COPY ../ray-cluster/sample_code.py sample_code.py

#ENTRYPOINT ["python3", "mnist-tf.py", "--num-workers", "1", "--use-gpu", "False", "--epochs", "1"]