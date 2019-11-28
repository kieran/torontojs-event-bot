# TorontoJS event bot

It posts events to the TorontoJS slack `#events` channel

## Local dev
```
# setup
nvm use
npm i

# run a dev server on port 3000
npm run dev
```

## Endpoints
get `/week` to post this weeks events

get `/today` to post todays events

## Deploy to lambda via [up](https://apex.sh/docs/up)
```
# staging deploy
up

# production deploy
up deploy production

# get staging URL:
up url

# get production URL:
up url -s production
```

Super-secret slack webhook URL is stored in Lambda's ENV store:
```
up env add SLACK_WEBHOOK="https://secret.url/here" -s production
```

