ruleset lab2 {
  meta {
    configure using account_sid = ""
                    auth_token = ""
    provides
        send_sms
  }

  global {

    messages = defaction(from, to) {
      url = <<https://#{account_sid}:#{auth_token}@api.twilio.com//2010-04-01/Accounts/#{account_sid}/Messages>>
      http:get(url, {"From":from, "To":to})
//      send_directive("Response from Twilio", {"content": response.klog("content: ")})
    }

    send_sms = defaction(to, from, message) {
       base_url = <<https://#{account_sid}:#{auth_token}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/>>
       http:post(base_url + "Messages.json", form = {
                "From":from,
                "To":to,
                "Body":message
            })
    }

  }
}
