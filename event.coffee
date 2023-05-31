axios = require 'axios'

{
  parseISO
  addDays
  isBefore
} = require 'date-fns'

{
  sortBy
  compact
} = require 'underscore'

URL_REGEX = /\b(https?:\/\/\S+)\b/
GCAL_KEY = 'AIzaSyA-xW0xIfYvro-zD0JCLRfJwqs6s2MmKmU'
GCAL_IDS = [
  'tgh4uc5t6uhr4icjrcgqfhe18r2uu3fg@import.calendar.google.com'         # angular
  '11j5qfhbb916srru7kuae99i4rn3p8r5@import.calendar.google.com'         # ember
  '89aheia1si29mqt1kvuprggnid983m87@import.calendar.google.com'         # htmlTO
  '3drnie5h5b5mr73acgcqpvvc2k@group.calendar.google.com'                # nodeschool
  'torontojs.com_o83mhhuck726m114hgkk3hl79g@group.calendar.google.com'  # one-off events
  'torontojs.com_60bdi1crj6so3s0a5angstepso@group.calendar.google.com'  # Toronto Affiliates - Managed by Simon Stern
  'r9dg86fs6utf6gv2dage634dts30ha14@import.calendar.google.com'         # polyhack
  '59s1qmiqr7bo98uqkek5ba7er2eduk3t@import.calendar.google.com'         # react
  'k6l8oiu416ftcjpjetn0r7a79me8pq4r@import.calendar.google.com'         # torontojs
  'h1tmhrt7ruckpk3ad20jaq55amvaiubu@import.calendar.google.com'         # webperf
  '32clmdbdnjukvbigjs6k174m44hhc7lu@import.calendar.google.com'         # vue
  '7i14k13k6h3a9opbokgmj63k1074gd78@import.calendar.google.com'         # DevTO
  'cmm8uhv8s34d21711h5faa4e3a34napd@import.calendar.google.com'         # Toronto Elixir
  'ftabe5ssvic0sdmqv048i6294k@group.calendar.google.com'                # north gta
  'pqn3frde4ici6rc4ati3qopg78@group.calendar.google.com'                # Andrew's virtual coffee chats
  'c_55f8635eda110a7fbe428aa5f1f10ce10aec4c2095f9a7f32b8a97a4723c9d84@group.calendar.google.com' # Crafting and Code Coffee Chats
]

class Model
  @getter: (prop, get) ->
    Object.defineProperty @prototype, prop, {get, configurable: yes}

module.exports =
class Event extends Model
  constructor: (obj={})->
    super arguments...
    @[key] = val for key, val of obj
    @

  @getter 'url', ->
    @description?.match(URL_REGEX)?[1]

  @getter 'venue', ->
    @location?.match(/(.*)\s\(/)?[1] or @location

  @getter 'address', ->
    @location?.match(/\((.*)\)/)?[1] or @location

  @getter 'map_url', ->
    "https://www.google.com/maps/search/?api=1&query=#{@address.replace /\s+/g, '+'}" if @address

  @getter 'host', ->
    @organizer.displayName.replace 'Events - ', ''

  @getter 'starts_at', ->
    parseISO @start?.dateTime

  @getter 'starts_at_stamp', ->
    Math.round @starts_at / 1000

  @getter 'ends_at', ->
    parseISO @end?.dateTime

  @getter 'is_confirmed', ->
    @status is 'confirmed'

  @getter 'is_future', ->
    isBefore Date.now(), @starts_at

  @getter 'is_this_week', ->
    @is_future and isBefore @starts_at, addDays Date.now(), 7

  @getter 'is_today', ->
    @is_future and isBefore @starts_at, addDays Date.now(), 1

  @getter 'slack_what', ->
    """
      *#{@summary}*
      by #{@host}
    """

  @getter 'slack_when', ->
    "<!date^#{@starts_at_stamp}^{date_pretty} at {time}|#{@starts_at}>"

  @getter 'slack_where', ->
    # does it look like a URL?
    return "<#{@location}>" if URL_REGEX.test @location

    # does it look like an address? (is there a number?)
    return "<#{@map_url}|#{@venue}>" if /\d/.test @location

    # I'm out of ideas, just print the text
    @location

  @getter 'slack_description', ->
    compact([@slack_what, @slack_when, @slack_where]).join "\n\n"

  @load_feeds: ->
    Promise.all GCAL_IDS.map (id)->
      try
        await axios.get "https://www.googleapis.com/calendar/v3/calendars/#{id}/events?singleEvents=true&key=#{GCAL_KEY}"
      catch
        Promise.resolve()

  @all: ->
    events = (await Event.load_feeds())
    .map (feed)-> feed?.data?.items or []
    .reduce (arr=[], items)->
      arr.push new Event item for item in items
      arr

    sortBy events, 'starts_at'

  @this_week: ->
    (evt for evt in (await Event.all()) when evt.is_confirmed and evt.is_this_week)

  @today: ->
    (evt for evt in (await Event.all()) when evt.is_confirmed and evt.is_today)
