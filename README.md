### This project was a background for a dissertation implementation purposes. It is not suitable for production environment, only for learning purposes!

The deployment was produced in the GCP cloud platform, in GKE.
The implementation consists of 2 sample web applications deployments in Kubernetes cluster.
In cloud_db folder deployment of WordPress application with MySQL database in GCP CloudSQL.
In stateful_db folder deployment of WordPress application with MySQL database in Kubernetes cluster.
Each deployment was provided with bash scripts for deployment in GCP.
In 2 folders, cloud_db and stateful_db are consists of bash scripts for deployment and .yaml configuration files for deployment. These files required for bash scripts to run!

Additionally, the projects consists of Docker container deployments of bombardier and sysbench performance tests of deployment clusters in GCP.
