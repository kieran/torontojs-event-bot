base_event =
  kind: "calendar#event"
  etag: "\"3350678618282000\""
  id: "_clr6arjkbti66t3qc9q7ipj3cph7goi0dlimat3le0n66rrd"
  status: "confirmed"
  htmlLink: "https://www.google.com/calendar/event?eid=X2NscjZhcmprYnRpNjZ0M3FjOXE3aXBqM2NwaDdnb2kwZGxpbWF0M2xlMG42NnJyZCBrNmw4b2l1NDE2ZnRjanBqZXRuMHI3YTc5bWU4cHE0ckBp"
  created: "2023-02-02T12:01:48.000Z"
  updated: "2023-02-02T12:01:49.141Z"
  summary: "JS Code Club: Online - Group Programming"
  description: "Toronto JavaScript\nSaturday, March 18 at 4:00 PM\n\nWelcome to the TorontoJS Group Programming! TorontoJS Group Programming is a friendly coding environment where we can bounce ideas & ask questions fre...\n\nhttps://www.meetup.com/torontojs/events/291350726/"

event_with_url = {
  base_event...
  location: "https://google.com"
}

event_with_address = {
  base_event...
  location: "1 Blue Jays Way"
}

event_with_unclear_location = {
  base_event...
  location: "Online Event"
}

module.exports = {
  event_with_url
  event_with_address
  event_with_unclear_location
}
