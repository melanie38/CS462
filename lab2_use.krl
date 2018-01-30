ruleset lab2_use {
  meta {
    use module lab2_keys
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
}
