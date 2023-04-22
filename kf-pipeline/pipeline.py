import kfp
from kfp import dsl
import kfp.components as components


def read_rayjob(file_name):
    import json
    with open(file_name, "r") as input_file:
        data = json.load(input_file)
    return data


@components.create_component_from_func
def echo_op():
    print("Hello world")


@components.create_component_from_func
def echo_msg(msg: str):
    """Echo a message by parameter."""
    print(msg)


@dsl.pipeline(
    name="rayjob-pipeline",
    description="A hello world RayJob pipeline."
)
def ray_job_pipeline():
    exit_task = echo_msg("Exit!")
    exit_task.execution_options.caching_strategy.max_cache_staleness = "P0D"

    with dsl.ExitHandler(exit_task):
        # download_task = gcs_download_op(url)
        echo_task = echo_op()
        echo_task.execution_options.caching_strategy.max_cache_staleness = "P0D"

        ray_job_manifest_cpu = read_rayjob("cpurayjob.json")
        rop_cpu = kfp.dsl.ResourceOp(
            name="ray-job-cpu",
            k8s_resource=ray_job_manifest_cpu,
            action="apply",
            success_condition="status.jobStatus == SUCCEEDED",
        ).add_node_selector_constraint(label_name="cpu", value="true").set_caching_options(False).after(echo_task)
        rop_cpu.enable_caching = False

        ray_job_manifest_gpu = read_rayjob("gpurayjob.json")
        rop_gpu = kfp.dsl.ResourceOp(
            name="ray-job-gpu",
            k8s_resource=ray_job_manifest_gpu,
            action="apply",
            success_condition="status.jobStatus == SUCCEEDED",
            failure_condition="status.jobStatus == FAILED",
        ).add_node_selector_constraint(label_name="gpu", value="true").set_caching_options(False).after(rop_cpu)
        rop_gpu.enable_caching = False
        # rop.execution_options.caching_strategy.max_cache_staleness = "P0D"


if __name__ == "__main__":
    kfp.compiler.Compiler().compile(ray_job_pipeline, __file__ + ".yaml")
