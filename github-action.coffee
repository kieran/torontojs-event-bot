{
  this_week
  today
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
      await post_to_slack slack_payload events, 'Events this week (via gh actions)'
    when 'today'
      events = await today()
      return unless events.length
      await post_to_slack slack_payload events, 'Events today (via gh actions)'
