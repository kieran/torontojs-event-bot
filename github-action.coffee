{
  SLACK_WEBHOOK = 'https://slack.com/api/api.test'
  SLACK_CHANNEL = '#events'
} = process.env

{
  this_week
  today
  all
} = require './event'

{
  slack_payload
  post_to_slack
} = require './slack'

# example: coffee github-action.coffee [week | today]
do ->
  switch process.argv[2]
    when 'week'
      events = await this_week()
      return unless events.length
      # testing:
      console.log SLACK_WEBHOOK, SLACK_CHANNEL, slack_payload events, 'Events this week'
      #await post_to_slack slack_payload events, 'Events this week'
    when 'today'
      events = await today()
      return unless events.length
      # testing:
      console.log SLACK_WEBHOOK, SLACK_CHANNEL, slack_payload events, 'Events today'
      # await post_to_slack slack_payload events, 'Events today'
    when 'all' # TODO: remove
      events = await all()
      return unless events.length
      # testing:
      console.log SLACK_WEBHOOK, SLACK_CHANNEL, slack_payload events, 'All Events'
      # await post_to_slack slack_payload events, 'Events today'
