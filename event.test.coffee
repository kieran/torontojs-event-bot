{
  event_with_url
  event_with_address
  event_with_unclear_location
  event_with_a_tag_description
  event_with_url_in_description
} = require "./fixtures"
Event = require "./event"
assert = require "assert"

test_online_event = ->
  test_event = new Event event_with_url
  actual = test_event.slack_where
  expected = "<https://google.com>"
  assert.strictEqual actual, expected

test_in_person_event = ->
  test_event = new Event event_with_address
  actual = test_event.slack_where
  expected = "<https://www.google.com/maps/search/?api=1&query=1+Blue+Jays+Way|1 Blue Jays Way>"
  assert.strictEqual actual, expected

test_unclear_event = ->
  test_event = new Event event_with_unclear_location
  actual = test_event.slack_where
  expected = "Online Event"
  assert.strictEqual actual, expected

test_event_atag = ->
  test_event = new Event event_with_a_tag_description
  actual = test_event.url
  expected = "https://www.meetup.com/meetup-group-iqklclbh/events/296278058/"
  assert.strictEqual actual, expected

test_event_url = ->
  test_event = new Event event_with_url_in_description
  actual = test_event.url
  expected = "http://www.meetup.com/ruby-lightning-to/events/226535947/"
  assert.strictEqual actual, expected

try
  test_online_event()
  test_in_person_event()
  test_unclear_event()
  test_event_url()
  test_event_atag()
catch e
  console.error e
  process.exit 1
