class Mailer < ActionMailer::Base
  default from: "mchittenden@dosomething.org"
  def stats_email(signups, reportbacks, votes, shares)
    @stats = {
      sign_ups: signups,
      report_backs: reportbacks,
      votes: votes,
      shares: shares
    }

    mail(to: 'mchittenden@dosomething.org,fsheikh@dosomething.org,jcusano@dosomething.org', subject: 'Fed Up Stats ' + Time.now.to_date.strftime('%b %d, %Y'))
  end
end
