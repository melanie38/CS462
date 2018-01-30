ruleset lab2 {
  meta {
    configure using account_sid = ""
                    auth_token = ""
    provides
        messages,
        send_sms
  }

  global {

    base_url = <<https://#{account_sid}:#{auth_token}@api.twilio.com//2010-04-01/Accounts/#{account_sid}/>>

    messages = function(from, to) {
      response = http:get(base_url + "Messages.json", form = {
                          "From":from,
                          "To":to});

      response_content = response{"content"}.decode();
      response_content
    }

    send_sms = defaction(to, from, message) {
       http:post(base_url + "Messages.json", form = {
                "From":from,
                "To":to,
                "Body":message
            })
    }

  }
}
