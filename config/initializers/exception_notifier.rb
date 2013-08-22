CreateAndShare::Application.config.middleware.use ExceptionNotification::Rack,
  :email => {
    :email_prefix => "[CAS ERROR] ",
    :sender_address => %{"notifier" <notifier@example.com>},
    :exception_recipients => %w{mchittenden@dosomething.org}
  }