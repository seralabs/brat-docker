# start from a base ubuntu image
FROM ubuntu

# Install pre-reqs
RUN apt-get update
RUN apt-get install -y curl vim sudo wget rsync gnupg lsb-release
RUN apt-get install -y python

# Install gcsfuse that enables mounting a Google Cloud Storage bucket.
RUN export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s` \
    && echo "deb  http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list; \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && apt-get update \
    && apt-get install -y gcsfuse

# Clean up
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add the user UID:1000, GID:1000, home at /app
RUN groupadd -r app -g 1000 && useradd -u 1000 -r -g app -m -d /app -s /sbin/nologin -c "App user" app && chmod 755 /app

# Fetch  brat
RUN mkdir /app/brat
RUN curl http://weaver.nlplab.org/~brat/releases/brat-v1.3_Crunchy_Frog.tar.gz > /app/brat/brat-v1.3_Crunchy_Frog.tar.gz 
RUN cd /app/brat && tar -xvzf brat-v1.3_Crunchy_Frog.tar.gz

# Create the path where GCS bucket will be mounted and symlink
# to the data and cfg locations that brat needs

RUN mkdir -p  /app/seralabs-ml/brat-annotator/data \
  && mkdir -p /app/seralabs-ml/brat-annotator/cfg
RUN ln -s /app/seralabs-ml/brat-annotator/data /app/brat/brat-v1.3_Crunchy_Frog/data
RUN ln -s /app/seralabs-ml/brat-annotator/cfg /app/brat/brat-v1.3_Crunchy_Frog/cfg

# add the user patching script
ADD user_patch.py /app/brat/brat-v1.3_Crunchy_Frog/user_patch.py

# override with dispatch file that requires tougher authentication
ADD dispatch.py /app/brat/brat-v1.3_Crunchy_Frog/server/src/dispatch.py

# add start script
ADD patch_and_start.sh /app/brat/brat-v1.3_Crunchy_Frog/patch_and_start.sh

RUN chown -R app:app /app

USER app
WORKDIR /app/brat/brat-v1.3_Crunchy_Frog/

RUN chmod o-rwx /app/seralabs-ml
RUN chmod +x /app/brat/brat-v1.3_Crunchy_Frog/patch_and_start.sh
RUN chmod +x /app/brat/brat-v1.3_Crunchy_Frog/install.sh

EXPOSE 8001

CMD ./patch_and_start.sh
