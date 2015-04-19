FROM sjackman/linuxbrew
MAINTAINER Peter Belmann, pbelmann@cebitec.uni-bielefeld.de

RUN sudo apt-get install wget

# install minia
RUN brew tap homebrew/science
RUN brew install minia

# Locations for biobox validator
ENV BASE_URL  https://s3-us-west-1.amazonaws.com/bioboxes-tools/validate-biobox-file
ENV VERSION   0.x.y
ENV VALIDATOR /bbx/validator/
RUN sudo mkdir -p  ${VALIDATOR} && sudo chmod -R a+wx  /bbx

# install yaml2json and jq tools
ENV CONVERT https://github.com/bronze1man/yaml2json/raw/master/builds/linux_386/yaml2json
RUN cd /usr/local/bin && sudo wget --quiet ${CONVERT} && sudo chmod a+x /usr/local/bin/yaml2json
RUN sudo apt-get install jq

# Install the biobox file validator
RUN sudo wget \
      --quiet \
      --output-document -\
      ${BASE_URL}/${VERSION}/validate-biobox-file.tar.xz \
    | sudo tar xJf - \
      --directory ${VALIDATOR} \
      --strip-components=1
ENV PATH ${PATH}:${VALIDATOR}

# add schema, tasks, run scripts
ADD run.sh /usr/local/bin/run
ADD schema.yaml ${VALIDATOR}
ADD tasks /

ENTRYPOINT ["sudo", "-E", "/bin/bash", "/usr/local/bin/run"]
