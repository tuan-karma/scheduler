# Scheduler

## The public APIs and how to use this code:
APIs in `lib/scheduler.ex`

  * `Scheduler.add_job(%{name: :string, at_time: :time, time_zone: :string})`: persist to DB and starting a worker (GenServer) for the job.
  * `Scheduler.remove_job(%{name: :string})`: stop the worker/GenServer and remove the job from DB.
  * `Scheduler.update_job(update_job(%{name: name, at_time: _, time_zone: _})`: update DB and restart worker with a params/state.
  * `Scheduler.activate_job(%{name: binary})`: update the job status in DB, `activated: true` and start the worker (GenServer) for the job.
  * `Scheduler.deactivate_job(%{name: binary}`): set the job sst in DB `activated: false` and stop the worker (GenServer) of the job.

## Notes:

  - This code use a database repo to store the jobs list in "jobs" table. This can be a bit trade-off in term of performance, but using a separated database storage can help decouple and isolate concern of this `scheduler domain` from other contexts in your main application.

## Future works:
  - You can add a calendar database to this domain, and modify the Calendar context in `calendar.ex` to help your user can add a custom working calendar to the system.
