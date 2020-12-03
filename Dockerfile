FROM registry.access.redhat.com/ubi8/nodejs-12

WORKDIR /usr/src/app  
  
COPY . .

USER 0
RUN chown -R 1001:0 /usr/src/app
USER 1001
 
RUN npm install  && \
    npm run build && \
    npm -g install serve

EXPOSE 3000
 
CMD ["serve", "-s", "build", "-l", "3000"]
