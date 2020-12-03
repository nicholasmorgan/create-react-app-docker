FROM registry.access.redhat.com/ubi8/nodejs-12
  
COPY . .
 
RUN yarn install --no-cache --production=true && \
    yarn run build && \
    yarn global add serve

EXPOSE 3000
 
CMD ["serve", "-s", "build", "-l", "3000"]
