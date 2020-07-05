class SleepJob < Mosquito::QueuedJob
  params delay : Int32

  def perform
    puts "sleeping #{delay}"
    sleep delay
  end
end
