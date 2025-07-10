FROM forgejo/forgejo:1.21

# Create necessary directories
USER root
RUN mkdir -p /data/forgejo
RUN chown -R git:git /data/forgejo

# Switch back to git user
USER git

# Copy configuration template
COPY --chown=git:git app.ini.template /data/forgejo/conf/app.ini.template
COPY --chown=git:git scripts/setup.sh /usr/local/bin/setup.sh

# Make setup script executable
USER root
RUN chmod +x /usr/local/bin/setup.sh
USER git

# Expose port
EXPOSE 3000

# Set working directory
WORKDIR /data/forgejo

# Entry point
CMD ["/usr/local/bin/setup.sh"]
