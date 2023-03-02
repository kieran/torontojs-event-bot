# TorontoJS event bot

It posts events to the TorontoJS slack `#events` channel

![example](https://user-images.githubusercontent.com/3444/222536319-8ae83bd0-5527-4337-bbd5-87f2fd8be641.png)

## Local dev
```
# setup
nvm use
npm i

# run a dev server on port 3000
npm run dev
```

## Endpoints
```
GET   /week
  display slack payload for the week
  
POST  /week
  post this week's events to slack
  
GET   /today
   display slack payload for today
   
POST  /today
  post today's events to slack
```

## Deploy

I deployed this to AWS Lambda using apex [up](https://github.com/apex/up) (which seems to be sunsetted now)

You could deploy it anywhere a node service can run, including your local machine / network.

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
You'd want to ensure the above ENV var is available if you actually want to post to slack

Right now it's scheduled using [cron-job.org](https://cron-job.org) - every morning at 8am for daily events and every week on Sunday at 8pm for the coming week
