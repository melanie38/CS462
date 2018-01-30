ruleset lab2_use {
  meta {
    use module twilio_keys
    use module lab2 alias twilio
        with account_sid = keys:twilio("account_sid")
             auth_token = keys:twilio("auth_token")
  }

  rule test_send_sms {
    select when test new_message
    twilio:send_sms(event:attr("to"),
                    event:attr("from"),
                    event:attr("message")
                   )
  }

  rule test_get_records {
    select when test get_records
    pre {
      content = twilio:messages(event:attr("to"),
                      event:attr("from"))
    }
    send_directive("Response", {"Content": content})

  }

}
