FROM openjdk:8-jdk-alpine

MAINTAINER stpork from Mordor team

ENV JIRA_VERSION=7.7.1 \
JIRA_INSTALL=/opt/atlassian/jira \
JIRA_HOME=/var/atlassian/application-data/jira \
JIRA_SHARED_HOME=/var/atlassian/application-data/jira/shared \
RUN_USER=daemon \
RUN_GROUP=daemon \
JIRA_CLUSTER_CONFIG="/var/atlassian/application-data/jira/cluster.properties"

ENV HOME=${JIRA_HOME}

LABEL io.k8s.description="Atlassian JIRA"
LABEL io.k8s.display-name="JIRA ${JIRA_VERSION}"
LABEL io.openshift.expose-services="8080:http"

RUN set -x \
&& apk update -qq \
&& update-ca-certificates \
&& apk add --no-cache ca-certificates curl git openssh bash procps openssl perl ttf-dejavu tini nano \
&& rm -rf /var/cache/apk/* /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/* \
&& mkdir -p ${JIRA_INSTALL} \
&& mkdir -p ${JIRA_SHARED_HOME} \
&& curl -fsSL \
"https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${JIRA_VERSION}.tar.gz" \
| tar -xz --strip-components=1 -C "${JIRA_INSTALL}" \
&& echo -e "\njira.home=${JIRA_HOME}" >> "${JIRA_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties" \
&& chown -R ${RUN_USER}:${RUN_GROUP} ${JIRA_INSTALL} \
&& chmod -R 777 ${JIRA_INSTALL} \
&& chown -R ${RUN_USER}:${RUN_GROUP} ${JIRA_HOME} \
&& chmod -R 777 ${JIRA_HOME}

USER ${RUN_USER}:${RUN_GROUP}

EXPOSE 8080

VOLUME ["${JIRA_SHARED_HOME}"]

WORKDIR ${JIRA_HOME}

COPY entrypoint.sh /entrypoint.sh
COPY check-java.sh "${JIRA_INSTALL}/bin/check-java.sh"

CMD ["/entrypoint.sh", "-fg"]
ENTRYPOINT ["/sbin/tini", "--"]
