class SleepJob < Mosquito::QueuedJob
  params delay : Int32

  def perform
    sleep delay
  end
end
