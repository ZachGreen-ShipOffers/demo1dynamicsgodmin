class ExportController < ApplicationController
  require 'export'
  def index
    @cpny = ClientCompany.all.sort_by {|c| c.dyna_code }

  end

  def run
    job = DynamicsExportJob.delay.perform_now(params['code'], params['date'])
    ap job
    # jid = job.provider_job_id
    render json: {job: job}
  end

  def dyinfo
    date = Date.parse(params['date'])
    cpny = ClientCompany.where(dyna_code: params['code']).first
    info = DynamicsInfo.where(date: date, client_company_id: cpny.id).first
    render json: {info: info}

  end

  def checkjob
    job = Delayed::Job.find_by(id: params['id'])
    if job.nil?
      render json: {job: 'done'}
    else
      render json: {job: job}
    end
  end

end
