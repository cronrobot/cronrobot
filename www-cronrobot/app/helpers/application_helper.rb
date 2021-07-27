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
    ]
  end

  def friendly_schedule_lister
    friendly_schedules.map { |s| [s[:name], s[:id]] }
  end
end
