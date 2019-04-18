module Issuecloser

  def self.install
    puts 'Issue closer is setting up, please wait...'

    #system 'bundle check || bundle install'

    puts 'Setting up schedule..'
    system 'wheneverize .' until File.exist?('config/schedule.rb')
    unless File.foreach('config/schedule.rb').grep(/issuecloser:close_tasks/).any?
      print 'Writing schedule config..'
      plugin_config = File.read('plugins/issuecloser/config/schedule.rb')
      File.open('config/schedule.rb', 'a') do |config_file|
        config_file.puts plugin_config
      end
      puts 'ok'
    end
    system 'whenever --update-crontab'
    puts 'Done.'
  end

  def self.iclose
    Setting.plugin_issuecloser['projects'].each do |setting|
      if plugin_settings_available?(setting)
        change_status(setting)
      end
    end
  end

  def self.change_status(setting)
    issues_to_change = Issue.where(status_id: setting['issues_status_from'])
                            .where(project_id: setting['project_id'])
                            .where('updated_on < ?', setting['auto_close_after_days'].to_i.days.ago)

    issues_to_change.each do |issue|
      Issue.update(issue.id, status_id: setting['issues_status_to'])
      p "Issue##{issue.id} closed"
    end
  end

  def self.plugin_settings_available?(setting)
    setting['project_id'] && setting['issues_status_from'] &&
      setting['issues_status_to'] && setting['auto_close_after_days'] && setting['auto_close'] == 'true'
  end

end
