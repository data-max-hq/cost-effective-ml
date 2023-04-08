import kfp
from kfp import dsl
import kfp.components as components

ray_job_manifest = {
  "apiVersion": "ray.io/v1alpha1",
  "kind": "RayJob",
  "metadata": {
    "name": "rayjob-sample",
  },
  "spec": {
    "entrypoint": "python3 sample_code.py",
    "rayClusterSpec": {
      "headGroupSpec": {
        "rayStartParams": {
          "dashboard-host": "0.0.0.0"
        },
        "template": {
          "metadata": {},
          "spec": {
            "containers": [
              {
                "image": "us-central1-docker.pkg.dev/sustained-drake-368613/cost-efficient-ml/ray-server:2.3.0-py38-2",
                "name": "ray-head",
                "ports": [
                  {
                    "containerPort": 6379,
                    "name": "gcs-server",
                    "protocol": "TCP"
                  },
                  {
                    "containerPort": 8265,
                    "name": "dashboard",
                    "protocol": "TCP"
                  },
                  {
                    "containerPort": 10001,
                    "name": "client",
                    "protocol": "TCP"
                  },
                  {
                    "containerPort": 8000,
                    "name": "serve",
                    "protocol": "TCP"
                  }
                ],
                "resources": {}
              }
            ]
          }
        }
      },
      "rayVersion": "2.3.0",
      "workerGroupSpecs": [
        {
          "groupName": "small-group",
          "maxReplicas": 2,
          "minReplicas": 1,
          "rayStartParams": {},
          "replicas": 1,
          "scaleStrategy": {},
          "template": {
            "metadata": {},
            "spec": {
              "containers": [
                {
                  "image": "us-central1-docker.pkg.dev/sustained-drake-368613/cost-efficient-ml/ray-server:2.3.0-py38-2",
                  "lifecycle": {
                    "preStop": {
                      "exec": {
                        "command": [
                          "/bin/sh",
                          "-c",
                          "ray stop"
                        ]
                      }
                    }
                  },
                  "name": "ray-worker",
                  "resources": {}
                }
              ],
              "nodeSelector": {
                "gpu": "true"
              }
            }
          }
        }
      ]
    },
    "runtimeEnv": "ewogICAgInBpcCI6IFsKICAgICAgICAicmVxdWVzdHM9PTIuMjYuMCIsCiAgICAgICAgInBlbmR1bHVtPT0yLjEuMiIKICAgIF0sCiAgICAiZW52X3ZhcnMiOiB7ImNvdW50ZXJfbmFtZSI6ICJ0ZXN0X2NvdW50ZXIifQp9Cg=="
  },
  # "status": {
  #   "dashboardURL": "rayjob-sample-raycluster-r92h2-head-svc.default.svc.cluster.local:8265",
  #   "endTime": "2023-04-08T16:49:19Z",
  #   "jobDeploymentStatus": "Running",
  #   "jobId": "rayjob-sample-mw4zg",
  #   "jobStatus": "SUCCEEDED",
  #   "message": "Job finished successfully.",
  #   "observedGeneration": 2,
  #   "rayClusterName": "rayjob-sample-raycluster-r92h2",
  #   "rayClusterStatus": {
  #     "availableWorkerReplicas": 1,
  #     "desiredWorkerReplicas": 1,
  #     "endpoints": {
  #       "client": "10001",
  #       "dashboard": "8265",
  #       "gcs-server": "6379",
  #       "metrics": "8080",
  #       "serve": "8000"
  #     },
  #     "head": {
  #       "podIP": "10.42.2.9",
  #       "serviceIP": "10.43.42.228"
  #     },
  #     "lastUpdateTime": "2023-04-08T16:49:04Z",
  #     "maxWorkerReplicas": 2,
  #     "minWorkerReplicas": 1,
  #     "observedGeneration": 1,
  #     "state": "ready"
  #   },
  #   "startTime": "2023-04-08T16:49:07Z"
  # }
}


@components.create_component_from_func
def echo_op():
    print("Hello world")


@components.create_component_from_func
def echo_msg(msg: str):
    """Echo a message by parameter."""
    print(msg)


@dsl.pipeline(
    name="rayjob-pipeline",
    description='A hello world RayJob pipeline.'
)
def ray_job_pipeline():
    exit_task = echo_msg("Exit!")

    with dsl.ExitHandler(exit_task):
        # download_task = gcs_download_op(url)
        echo_task = echo_op()
        rop = kfp.dsl.ResourceOp(
            name="start-kfp-task",
            k8s_resource=ray_job_manifest,
            action="create",
            success_condition="status.jobStatus == SUCCEEDED"
        ).after(echo_task)

        rop.set_caching_options(enable_caching=False)
        # afterwards delete using kubernetes_resource_delete_op


if __name__ == '__main__':
    kfp.compiler.Compiler().compile(ray_job_pipeline, __file__ + '.yaml')
