# Scheduler

## The public APIs and how to use this code:

  * `Scheduler.add_job(%{name: binary, at_time: utc_datetime})`: persist to DB and starting a worker (GenServer) for the job.
  * `Scheduler.remove_job(%{name: binary})`: stop the worker/GenServer and remove the job from DB.
  * `Scheduler.update_job(%{name: binary, at_time: utc_datetime})`: update DB and restart worker with a newly_calculated `interval`.
  * `Scheduler.activate_job(%{name: binary})`: update the job status in DB, `activated: true` and start the worker (GenServer) for the job.
  * `Scheduler.deactivate_job(%{name: binary}`): set the job sst in DB `activated: false` and stop the worker (GenServer) of the job.

## Notes:

  - This code use a database repo to store the jobs list in "jobs" table. This can be a bit trade-off in term of performance, but using a separated database storage can help decouple and isolate concern of this `scheduler domain` from other contexts in your main application.

## Future works:
  - You can add a calendar database to this domain, and modify the Calendar context in `calendar.ex` to help your user can add a custom working calendar to the system.
