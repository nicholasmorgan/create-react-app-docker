# Build and Deploy a Create React App with Tekton

## How to clone from a private Github Enterprise repo with an ssh key

1. Create the key on your local machine:

```
ssh-keygen -t rsa -b 4096 -C "your@email.com"
```

n.b. leave the password field blank.

2. Copy your public key to the clipboard.

```
pbcopy < name-of-your-key.pub
```

3. Add the Deploy key to the Github Repo and check `Allow write access` (Setting > Deploy keys)

4. Copy the private key to your clipboard.

```
pbcopy < name-of-your-key
```

5. Add the private key to OpenShift as a Secret.

   > - On the Openshift Console go to Workloads > Secrets.
   > - Click Create > Source Secret.
   > - Choose Authentication Type - SSH Key.
   > - Paste the Private key into the SSH Private Key textarea.
   > - Click Create.

6. Annotate the Secret.

   > - On the Secret in the console click Actions > Edit Annotations.
   > - set KEY to: tekton.dev/git-0
   > - set VALUE to: github.ibm.com

7. Add known_hosts to your secret

Copy the Known Host value to your clipboard.

```
ssh-keyscan <Your Repo Host> | base64 | pbcopy
```

```
e.g.
ssh-keyscan github.ibm.com | base64 | pbcopy
```

Add the known hosts to your Secret by editing the Secret yaml directly and pasting in the `known_hosts` field. Once done it should look similar to the following:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ssh-key
  annotations:
    tekton.dev/git-0: github.ibm.com
data:
  ssh-privatekey: <private-key>
  known_hosts: <known-hosts>
type: kubernetes.io/ssh-auth
```

8. Add the secret to your Pipeline Service Account

```
oc secrets link <Service Account Name> <Secret name>
```

```
e.g.
 oc secrets link pipeline spring-was-lib-github-pull-secret
```

## Building and running the pipeline manually.

Apply the PVC yaml to create a Persistent Volume Claim that is needed to persist the cloned code between tasks.

```
oc apply - tekton/PVC
```

Apply the Pipeline and Task yamls

```
oc apply - tekton/Pipeline
```
```
oc apply - tekton/Tasks
```

To start the Pipeline with a PipelineRun, save a copy of the PipelineRun yaml in the `PipelineRun` folder to your local machine, update the `docker-image` param with what you want for your project and run the following.
```
oc create -f <path to pipelne run>
```

## Triggering the pipeline with a webhook.

Edit the `image-namespace` default variable in tekton/TriggerTamplate.yaml to be the namespace in the internal image registry the image will be saved.

Apply the Trigger yamls
```
oc apply - tekton/Triggers
```

Creating an EventListener will create a pod and a service automatically. Expose that service so that you have an endpoint for Github to send POST requests to.
```
oc service <name-of-event-listener-service>
```
### Configure Github Enterprise

1. In Github Enterprise go to Settings > Hooks.
2. Click `Add Webhook`.
3. Under payload URL, paste the the newly created URL of the Route you just exposed.
4. Set Content type to be application/json.
5. Click `Add Webhook`

Push some code to your repo to trigger the pipeline.