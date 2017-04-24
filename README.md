# zero-to-jupyterhub

Currently our focus is Google Cloud where a managed Kubernetes
environment itself needs only configuration, whereas setting up your
own Kubernetes enviroment on bare metal or another cloud provider is
more involved.

See step-by-step manual instructions at: [Zero to JupyterHub in 15 minutes](https://paper.dropbox.com/doc/Zero-to-JupyterHub-in-15-minutes-mbwBn4mjyIuM5siYsFtay)

Execute the following from GCS (Google Cloud Shell): [https://cloud.google.com/shell/](https://cloud.google.com/shell/)

```
REPO=https://github.com/user/repo bash <(curl -s https://raw.githubusercontent.com/aculich/zero-to-jupyterhub/master/gcloud-bootstrap.sh)
```

To completely destroy everything run this from GCS:
```
bash <(curl -s https://raw.githubusercontent.com/aculich/zero-to-jupyterhub/master/gcloud-destroy.sh)
```
