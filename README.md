# Run Crank on AWS

## Prerequisite
>Note: This doc assumes the user is on a Linux system.

Here are a list of tools you need to install on your local machine/system to continue the following tasks. Please refer to the links provided to install them.

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
3. [Terraform](https://developer.hashicorp.com/terraform/downloads) [a easier way than what is shown on the offical website.]
4. Setting `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` with your AWS credential to the env vars, either a temp one through the command line or a permanent one through .bashrc
5. If under the intel's network, set the proxy: copy the following to `~/.ssh/config`
```
host * !*.intel.com
        ProxyCommand nc -x proxy-us.intel.com:1080 %h %p
```

## Step 1: On your local machine (Linux/VM/WSL)

### 1.
Clone the repo to your local and checkout to `clx_vs_gvt2`
```
git clone https://github.com/rgesteve/crankonaws.git
git checkout clx_vs_gvt2
```

### 2. 
Then generate `MyIdentity.pem`
```
ssh-keygen  -f MyIdentity.pem -m PEM -C "Running crank on AWS"
```
you will have `MyIdentity.pem` and `MyIdentity.pem.pub` in your folder.

Copy the public key in `MyIdentity.pem.pub` to `main.tf`: replace line 38 with the whole line in `MyIdentity.pem.pub` 


### 3. 

Now you should be ready to get started with setting the `terraform`:
```Bash
terraform init
terraform validate #Optional, ensure their is no error before this.
./run_crank_aws.sh <# of vCPU / 4>
```

Then in the middle of the log info, you can find some logs like:
```
app_ips = "The application public IP is: 18.118.218.244, and its private ip is: <controller-ip>."
login = "ssh -i ./MyIdentity.pem ubuntu@<controller-ip>"
private_ips = "The worker private IPs are: app: 10.0.1.186, loadgen: 10.0.1.226, and db: 10.0.1.134."
``` 

Now open another terminal window, and log into the AWS cluster by copying the command after login: 
```Bash
ssh -i ./MyIdentity.pem ubuntu@<controller-ip>
```

### 4. Debug tips:
There might be some error messages when running `run_crank_aws.sh`, should be fine if you only see one `timeout` error, other than that, go back and check with the logs to see what is wrong.

The shell script will help you copy the private key: `MyIdentity.pem` to the controller machine, this is conducted by a `scp` command, and it might fail due to the connectivity issue. If so, do the copy manually:
```Bash
scp -o "ProxyCommand=nc -x proxy-us.intel.com:1080 %h %p" -i <private_key_file> <private_key_file> ubuntu@<controller_ip>:/home/ubuntu
```
## Step 2: On AWS cluster:
>Note: By this step, you should have successfully logged into the AWS cluster.


### 1.
Open a tmux session:
```Bash
$ tmux
```

### 2.
```Bash
$ /tmp/crank_connect-workers.sh
```
Then you will see multiple tmux tabs generated, e.g.
```
0. bash
1. db
2. app_clx
3. loadgen_clx
4. app_gvt
5. loadgen_gvt
6. for_gvt
```

One thing need to notice here is that tab 0 and tab 6 are actually on the same machine: controller. But to differenciate and parallelize the crank iteration on CLX and GVT, they are split into 2. 

Then run 
```Bash
$ /tmp/crank_setup-crank.sh
```
in tab0~5. (Basically run the script on every machine we have, since tab 0 and 6 are the same machine, we don't need to run it twice.)

The script will set up the crank ready to run on app/loadgen, if you see some logs like:
```
Agent listening to ...
```
Then that means the machine is ready.

### 3.

In the following part, I will refer tab 0 as `x86 controller` and tab 6 as `arm controller`.

In `x86 controller`, run 
```
$ ./crank_run-crank.sh
```
and in `arm controller`, run 
```
$ ./crank_run-crank.sh gvt2
```

Then we started the the crank iteration on both CLX and GVT. The iteration will normally complete within 1 hour.

## 3. Back on your local machine:

After the iterations completed on both machine, download the results from the cluster to your local:

```
collect_data_from_aws.sh
```
The results will be put into a folder named with the date. (Currently hard coded.)

If you want a summary of the results, run the data processing script:
```python
python3 parse_results.py >results.csv
```

If you complete this step, then you have successfully run TechEmpower with Crank on AWS and got the results locally.