{
  describe
  it
  before
} = require 'node:test'
assert  = require "node:assert"
Event   = require "./event"

event = (overrides={})->
  base =
    kind:         "calendar#event"
    etag:         '"3350678618282000"'
    id:           "_clr6arjkbti66t3qc9q7ipj3cph7goi0dlimat3le0n66rrd"
    status:       "confirmed"
    htmlLink:     "https://www.google.com/calendar/event?eid=X2NscjZhcmprYnRpNjZ0M3FjOXE3aXBqM2NwaDdnb2kwZGxpbWF0M2xlMG42NnJyZCBrNmw4b2l1NDE2ZnRjanBqZXRuMHI3YTc5bWU4cHE0ckBp"
    created:      "2023-02-02T12:01:48.000Z"
    updated:      "2023-02-02T12:01:49.141Z"
    summary:      "JS Code Club: Online - Group Programming"
    description:  "Toronto JavaScript\nSaturday, March 18 at 4:00 PM\n\nWelcome to the TorontoJS Group Programming! TorontoJS Group Programming is a friendly coding environment where we can bounce ideas & ask questions fre...\n\nhttps://www.meetup.com/torontojs/events/291350726/"

  new Event { base..., overrides... }

describe 'Event', ->

  before console.clear

  describe '#slack_where', ->
    it 'should link a bare URL', ->
      assert.strictEqual \
        event(location: "https://google.com").slack_where,
        "<https://zombo.com>"

    it 'should add a google search for an address', ->
      assert.strictEqual \
        event(location: "1 Blue Jays Way").slack_where,
        "<https://www.google.com/maps/search/?api=1&query=1+Blue+Jays+Way|1 Blue Jays Way>"

    it 'should pass through ambiguous text as plain text', ->
      assert.strictEqual \
        event(location: "Online Event").slack_where,
        "Online Event"

  describe '#url', ->
    it 'should find the URL in an anchor tag', ->
      assert.strictEqual \
        event(description: '<a href="https://www.meetup.com/meetup-group-iqklclbh/events/296278058/">https://www.meetup.com/meetup-group-iqklclbh/events/296278058/</a>').url,
        "https://www.meetup.com/meetup-group-iqklclbh/events/296278058/"

    it 'should find a bare URL in some text / MD', ->
      assert.strictEqual \
        event(description: 'For full details, including the address, and to RSVP see:\nhttp://www.meetup.com/ruby-lightning-to/events/226535947/\nRuby Lightning Talks T.O.\nCome join us for four lightning-style talks covering intermediate Ruby and Web topics, all in one night!\nFormat:\n6:30-7:00 - Pizza, pop, an...').url,
        "http://www.meetup.com/ruby-lightning-to/events/226535947/"
