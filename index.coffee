{
  PORT          = 3000
  NODE_ENV      = 'development'
  SENTRY_DSN_API
} = process.env

Koa     = require 'koa'
router  = do require 'koa-router'
json    = require 'koa-json'
cors    = require '@koa/cors'
Sentry  = require '@sentry/node'

Event = require './event'

{
  slack_payload
  post_to_slack
} = require './slack'

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
  ctx.assert events.length, 404, 'No events this week'
  ctx.body = slack_payload events, 'Events this week'

router.post '/week', (ctx)->
  await post_to_slack await week ctx

router.get  '/today', today = (ctx)->
  events = await Event.today()
  ctx.assert events.length, 404, 'No events today'
  ctx.body = slack_payload events, 'Events today'

router.post '/today', (ctx)->
  await post_to_slack await Event.today ctx

#
# Server init
#
app = new Koa
app.use cors()
app.use json()
app.use router.routes()

if dsn = SENTRY_DSN_API
  Sentry.init { dsn, environment: NODE_ENV }
  app.on 'error', (err, ctx)->
    Sentry.withScope (scope)->
      scope.addEventProcessor (event)-> Sentry.Handlers.parseRequest event, ctx.request
      Sentry.captureException err

app.listen PORT
