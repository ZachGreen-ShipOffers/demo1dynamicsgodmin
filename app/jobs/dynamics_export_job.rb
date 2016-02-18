class DynamicsExportJob < ActiveJob::Base
  queue_as :default
  require 'export'

  def success(job)
    ap 'success'
  end

  def error(job, e)
    ap e.message
  end

  def failure(job)
    ap job
  end


  def perform(cpny,date)
    e = Export.new(cpny, date)
    e.export
  end
end
