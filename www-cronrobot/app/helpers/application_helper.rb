module ApplicationHelper
  def friendly_schedules
    [
      {
        name: "Custom",
        id: "custom"
      },
      {
        name: "Every minute",
        cron: "* * * * *",
        id: "every_minute"
      },
      {
        name: "Every hour",
        cron: "0 * * * *",
        id: "every_hour"
      },
    ]
  end

  def friendly_schedule_lister
    friendly_schedules.map { |s| [s[:name], s[:id]] }
  end

end
