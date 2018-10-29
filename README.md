# Brat with Docker + Kubernetes on Google Cloud with data stored in Google Cloud Storage.

NOTE: Data is served from Google Cloud Storage (which costs money)!


1. Create a Google Service Account with Google Cloud Storage Object Editor privileges.
2. Download the json credentials from above, and create a kubernetes secret from file.
3. Create a bucket in Google Cloud storage with paths data and cfg under it. Inside cfg upload a json that lists
users and passwords as below:


```javascript
{
    "user1": "password",
    "user2": "password",
    ...
}
```

Note that several variables are strewn about the Makefile and paths are hardcoded into the kubernetes resource files. In case you wanted to reuse this for yourself, you'll have to modify according to your setup. Also note the kubectl context related targets in the Makefile.
