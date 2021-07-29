import Config

config :scheduler, Scheduler.Repo,
  database: "scheduler_repo",
  username: "postgres",
  password: "",
  hostname: "localhost"

config :scheduler, ecto_repos: [Scheduler.Repo]
