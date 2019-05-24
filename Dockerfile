FROM gobuffalo/buffalo:v0.14.3 as builder

ARG GITHUB_TOKEN=local
ENV GITHUB_TOKEN ${GITHUB_TOKEN}

RUN mkdir -p /tmp/gobuffalo
WORKDIR /tmp/gobuffalo

# this will cache the npm install step, unless package.json changes
ADD package.json .
ADD yarn.lock .
RUN yarn install --no-progress
ADD . .
RUN GO111MODULE=on buffalo build --static -o /bin/app -v --environment=production --skip-template-validation

FROM alpine
RUN apk add --no-cache curl
RUN apk add --no-cache bash
RUN apk add --no-cache ca-certificates

WORKDIR /bin/

COPY --from=builder /bin/app .

# Comment out to run the binary in "production" mode:
ENV GO_ENV=production

# Bind the app to 0.0.0.0 so it can be seen from outside the container
ENV ADDR=0.0.0.0

EXPOSE 3000

CMD /bin/app migrate; /bin/app
