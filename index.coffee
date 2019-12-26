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
router.get '/', (ctx)->
  ctx.body = """
  Usage:
    GET   /
      this message (🍁 free health check 🇨🇦)

    GET   /week
      display slack payload for the week

    POST  /week
      post this week's events to slack

    GET   /today
      display slack payload for today

    POST  /today
      post today's events to slack
  """

router.get  '/week', week = (ctx)->
  events = await Event.this_week()
  ctx.assert events.length, 204, 'No events this week'
  ctx.body = slack_payload events, "Events this week"

router.post '/week', (ctx)->
  await post_to_slack await week ctx

router.get  '/today', today = (ctx)->
  events = await Event.today()
  ctx.assert events.length, 204, 'No events today'
  ctx.body = slack_payload events, "Events today"

router.post '/today', (ctx)->
  await post_to_slack await today ctx

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
  username: "TorontoJS EventBot™"
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
