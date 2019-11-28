{
  PORT
  SLACK_WEBHOOK
  SLACK_CHANNEL
  SENTRY_DSN_API
  NODE_ENV
} = process.env
environment = NODE_ENV ?= 'development'

axios   = require 'axios'
Koa     = require 'koa'
router  = require('koa-router')()
json    = require 'koa-json'
cors    = require '@koa/cors'
Sentry  = require '@sentry/node'
Event   = require './event'


#
# Routes
#
router.get '/ping', (ctx)->
  ctx.body = 'pong'

router.get '/week', (ctx)->
  events = await Event.this_week()
  ctx.assert events?.length, 404, 'No events this week'
  await post_to_slack ctx.body = slack_payload events, "Events this week"

router.get '/today', (ctx)->
  events = await Event.today()
  ctx.assert events?.length, 404, 'No events today'
  await post_to_slack ctx.body = slack_payload events, "Events today"


#
# Server init
#
app = new Koa
app.use cors()
app.use json()
app.use router.routes()

if dsn = SENTRY_DSN_API
  Sentry.init { dsn, environment }
  app.on 'error', (err, ctx)->
    Sentry.withScope (scope)->
      scope.addEventProcessor (event)-> Sentry.Handlers.parseRequest event, ctx.request
      Sentry.captureException err

app.listen PORT or 3000


#
# Helpers
#
slack_payload = (events, title)->
  channel:  SLACK_CHANNEL or "#events"
  username: "EventBot™"
  blocks:   slack_blocks events, title

slack_blocks = (events, title)->
  blocks = [
    type: "section"
    text:
      type: "mrkdwn"
      text: "*#{title}*"
  ]

  for evt, idx in events
    blocks.push type: "divider" if idx
    blocks.push evt.slack_section
  blocks

post_to_slack = (payload)->
  axios.post \
    SLACK_WEBHOOK or 'https://slack.com/api/api.test', \
    payload
