import ray
from ray.rllib.agents.trainer import Trainer
from ray.train.examples.tf.tensorflow_quick_start import train_func_distributed

ray.init("ray://raycluster-kuberay-head-svc:10001")

trainer = Trainer(backend="tensorflow", num_workers=2)
trainer.start()
results = trainer.run(train_func_distributed)
trainer.shutdown()

# serve.start(detached=True, http_options={"host": "0.0.0.0"})
# TFMnistModel.deploy(TRAINED_MODEL_PATH)

# resp = requests.get(
#       "http://example-cluster-head-svc:8000/mnist",
#       json={"array": np.random.randn(28 * 28).tolist()})
