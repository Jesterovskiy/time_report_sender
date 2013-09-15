namespace :time_report do
  desc "Send report to all emails in options"
  task :send_reports => :environment do
    raise "Project ID not exists in options" if !Setting.plugin_time_report_sender['project_id']

    Setting.plugin_time_report_sender['notification_addresses'].split(' ').each do |email|
      begin
        puts "Send report to #{email}"
        Mailer.send_time_report(email).deliver
      rescue Exception => ex
        puts "Issues with sending to #{email}: #{ex.message}"
      end
    end
  end
end
