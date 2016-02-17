class DynamicsExportJob < ActiveJob::Base
  queue_as :default
  require 'export'

  def success(job)
    ap 'success'
  end

  def error(job, e)
    ap e
  end


  def perform(cpny)
    e = Export.new(cpny, '2016-02-17', '2016-02-17')
    e.export
  end
end
