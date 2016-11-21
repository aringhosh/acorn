library("mailR")

send.mail(from = "report@acorninfluence.com",
          to = c("aghosh@acorninfluence.com"),
          subject = "test email",
          body = "Body of the email",
          smtp = list(host.name = "aspmx.l.google.com", port = 25),
          authenticate = TRUE,
          send = TRUE,
          debug = TRUE)