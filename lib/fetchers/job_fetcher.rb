module Fetchers
  class JobFetcher
    def self.search(params)
      jobs = Job.filter_it(params[:filters]).order("RANDOM()")
      if params[:jobs_ids] 
        jobs = jobs.no_repeat(params[:jobs_ids]) 
      end
      if params[:location_type] 
        jobs = jobs.send("from_#{params[:location_type]}", params[:location_id])
      end
      jobs.limit(8)
    end
  end
end
