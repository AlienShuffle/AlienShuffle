# Github / Google Cloud Interactions.
Authenticate the login to the Github account
```
gh auth login
```
For now we are logging into the Github w/ the AlienShuffle account and using github.com as the authentication method.

Clone a GitHub Repo call CashAnalyzer under Account AlienShuffle, logged in above.
```
gh repo clone AlienShuffle/CashAnalyzer
````
Use git commands like commit, push, etc. to maintain the repo on the local computer and Github.
```
git add file1 file2
git commmit -m 'message'
git push
git pull
```
Using gcloud command submit a Google Cloud Function from this repository into the Google Cloud account.
Used to configure login to the GCF account, this also sets the project
```
gcloud init
```
Login to readngtndude@gmail.com account and use the CashAnalyzer project

# Deploy a Google Cloud Function called helloWorld into the curent project
``` 
gcloud functions deploy 'testfunc' --runtime nodejs12 --trigger-http --entry-point=helloWorld
```
See the file deploy-gcloud.bash in each GCF folder for details on each deployment scheme.

Add a test harness for GCF on a local node instance
```
npm install @google-cloud/functions-framework
```
See the package.json file for configuration details. The CashAnalyzer/Ally function repo folder is the prototype/template for a puppeteer based Node.js Cloud Function.
