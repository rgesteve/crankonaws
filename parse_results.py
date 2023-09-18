#!/usr/bin/env python3

import os, sys, json
import itertools

metrics_of_interest = {
    "load" : ["http/rps/mean", "http/latency/mean", "http/firstrequest", "benchmarks/start-time"],
    "application" : ["benchmarks/working-set"]
}

path_to_files = os.path.join('aug28', 'aws_m7g.12xlarge')

#instance_sizes = [2,4,8,12]
instance_sizes = [12]
workloads = ["plaintext", "platformplaintext", "json", "platformjson"]
archs = ["i", "g"]

def results_fname(wl, sz):
    return f"{wl}_m7%s.{sz}xlarge_%s.json"

def read_results_spec(fname_template, archs):
    suffix = "7of10"
    #return {a: fname_template % (a,suffix) for a in archs}
    return {a: trace_to_dict(fname_template % (a,suffix), path_to_files) for a in archs}

def trace_to_dict(fname : str, rootpath : str):
    # if not os.path.exists(rootpath):
    #     print("The path dos not exist!")
    #     sys.exit(1)
    fpath = os.path.join(rootpath, fname)
    with open(fpath) as f:
        return json.load(f)

# jobs = data["jobResults"]["jobs"]
# app = jobs["application"]
# load = jobs["load"]

# load_md = load["metadata"]
# app_md = app["metadata"]

# print("properties in load:")
# for prop in load_md:
#     pp = prop["name"]
#     print(f"Key: {pp}")
# #print(f"the type is: {type(load_md)}")

# print("properties in app:")
# for prop in app_md:
#     pp = prop["name"]
#     print(f"Key: {pp}")

# cpu_in_app = app["results"]["benchmarks/cpu"]
# print(f"The CPU utilization in app is [{cpu_in_app}]")


#for (i, (wl, sz)) in enumerate(itertools.product(workloads, instance_sizes)):
for (i, it) in enumerate(itertools.product(workloads, instance_sizes)):
    fname_template = results_fname(*it)
    fs = read_results_spec(fname_template, archs)
    for k,it in fs.items():
        print(f"The files are {it}.")

print("Done!")

# ~/crank_on_aws/aug30/aws_/
# json_m7g.12xlarge_7of10.json  json_m7i.4xlarge_7of10.json        plaintext_m7i.12xlarge_7of10.json     platformjson_m7g.4xlarge_7of10.json   platformplaintext_m7g.12xlarge_7of10.json  platformplaintext_m7i.4xlarge_7of10.json
# json_m7g.2xlarge_7of10.json   json_m7i.8xlarge_7of10.json        plaintext_m7i.2xlarge_7of10.json      platformjson_m7g.8xlarge_7of10.json   platformplaintext_m7g.2xlarge_7of10.json   platformplaintext_m7i.8xlarge_7of10.json
# json_m7g.4xlarge_7of10.json   plaintext_m7g.12xlarge_7of10.json  plaintext_m7i.4xlarge_7of10.json      platformjson_m7i.12xlarge_7of10.json  platformplaintext_m7g.4xlarge_7of10.json
# json_m7g.8xlarge_7of10.json   plaintext_m7g.2xlarge_7of10.json   plaintext_m7i.8xlarge_7of10.json      platformjson_m7i.2xlarge_7of10.json   platformplaintext_m7g.8xlarge_7of10.json
# json_m7i.12xlarge_7of10.json  plaintext_m7g.4xlarge_7of10.json   platformjson_m7g.12xlarge_7of10.json  platformjson_m7i.4xlarge_7of10.json   platformplaintext_m7i.12xlarge_7of10.json
# json_m7i.2xlarge_7of10.json   plaintext_m7g.8xlarge_7of10.json   platformjson_m7g.2xlarge_7of10.json   platformjson_m7i.8xlarge_7of10.json   platformplaintext_m7i.2xlarge_7of10.json

# properties in load:
# Key: benchmarks/cpu
# Key: benchmarks/cpu/raw
# Key: benchmarks/working-set
# Key: benchmarks/private-memory
# Key: benchmarks/build-time
# Key: benchmarks/start-time
# Key: benchmarks/published-size
# Key: benchmarks/published-nativeaot-size/raw
# Key: benchmarks/symbols-size
# Key: benchmarks/memory/swap
# Key: benchmarks/cpu/periods/total
# Key: benchmarks/cpu/periods/throttled
# Key: benchmarks/cpu/throttled
# Key: netSdkVersion
# Key: AspNetCoreVersion
# Key: NetCoreAppVersion
# Key: http/firstrequest
# Key: http/rps/mean
# Key: http/requests
# Key: http/latency/mean
# Key: http/latency/max
# Key: http/requests/badresponses
# Key: http/requests/errors
# Key: http/throughput
# Key: http/latency/50
# Key: http/latency/75
# Key: http/latency/90
# Key: http/latency/99
# properties in app:
# Key: benchmarks/cpu
# Key: benchmarks/cpu/raw
# Key: benchmarks/working-set
# Key: benchmarks/private-memory
# Key: benchmarks/build-time
# Key: benchmarks/start-time
# Key: benchmarks/published-size
# Key: benchmarks/published-nativeaot-size/raw
# Key: benchmarks/symbols-size
# Key: benchmarks/memory/swap
# Key: benchmarks/cpu/periods/total
# Key: benchmarks/cpu/periods/throttled
# Key: benchmarks/cpu/throttled
# Key: netSdkVersion
# Key: AspNetCoreVersion
# Key: NetCoreAppVersion
