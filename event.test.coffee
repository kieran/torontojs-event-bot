{
  event_with_url
  event_with_address
  event_with_unclear_location
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

try
  test_online_event()
  test_in_person_event()
  test_unclear_event()
catch e
  console.error e
  process.exit 1
