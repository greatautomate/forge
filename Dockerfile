FROM codeberg.org/forgejo/forgejo:11

USER root
RUN mkdir -p /data/forgejo
RUN chown -R git:git /data/forgejo

USER git
COPY --chown=git:git app.ini.template /data/forgejo/conf/app.ini.template
COPY --chown=git:git scripts/setup.sh /usr/local/bin/setup.sh

USER root
RUN chmod +x /usr/local/bin/setup.sh
USER git

EXPOSE 3000
WORKDIR /data/forgejo

CMD ["/usr/local/bin/setup.sh"]
