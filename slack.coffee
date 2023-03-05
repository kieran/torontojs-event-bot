{
  SLACK_WEBHOOK = 'https://slack.com/api/api.test'
  SLACK_CHANNEL = '#events'
} = process.env

#
# Helpers
#
slack_payload = (events, title)->
  channel:  SLACK_CHANNEL
  username: 'TorontoJS EventBot™'
  blocks:   slack_blocks events, title

# https://api.slack.com/tools/block-kit-builder
slack_section = (evt)->
  ret =
    type: 'section'
    text:
      type: 'mrkdwn'
      text: evt.description
  if evt.url
    ret.accessory =
      type: 'button'
      text:
        type: 'plain_text'
        text: 'Learn More'
        emoji: true
      url: evt.url
  ret

slack_blocks = (events, title)->
  blocks = [
    type: 'section'
    text:
      type: 'mrkdwn'
      text: "*#{title}*"
  ]

  for evt, idx in events
    blocks.push type: 'divider' if idx
    blocks.push slack_section evt
  blocks

post_to_slack = (payload)->
  axios.post SLACK_WEBHOOK, payload

module.exports = {
  slack_payload
  post_to_slack
}
