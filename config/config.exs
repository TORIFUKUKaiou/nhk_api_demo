use Mix.Config

config :nhk,
  nhk_api_key: System.get_env("NHK_API_KEY"),
  area: System.get_env("NHK_AREA"),
  acts: System.get_env("NHK_ACTS"),
  titles: System.get_env("NHK_TITLES"),
  slack_incoming_webbook_url: System.get_env("NHK_SLACK_INCOMING_WEBHOOK_URL"),
  slack_channel: System.get_env("NHK_SLACK_CHANNEL")

config :nhk, Nhk.Scheduler,
  jobs: [
    {"10 22 * * *", {Nhk, :run, []}}
  ]
