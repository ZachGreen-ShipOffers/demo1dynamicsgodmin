class ExportController < ApplicationController
  require 'export'
  def index
    @cpny = ClientCompany.all.sort_by {|c| c.dyna_code }

  end

  def run
    job = DynamicsExportJob.delay.perform_now(params['code'])
    ap job
    # jid = job.provider_job_id
    render json: {done: 'true'}
  end

end
