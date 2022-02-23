class MetricsController < ApplicationController

  def show
    ok, result = ApiConsumerService::get_metrics
    pp result
    if ok
      render json:{
        fail_percentage: result[:failed_percentage],
        lead_time: result[:lead_time],
        downtime_average: result[:downtime_average]
      }, status: 200
    else
      render json: {errors: result}, status: 400
    end
  end
end