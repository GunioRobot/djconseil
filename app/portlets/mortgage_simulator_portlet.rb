class MortgageSimulatorPortlet < Portlet
  render_inline false

  def render
    @capital         = params[:capital].to_f.round(2)
    @years           = params[:years].to_i
    @months          = @years * 12
    @yearly_rate     = params[:interest_rate].to_f / 100
    @monthy_rate     = @yearly_rate / 12
    @monthly_payment = params[:monthly_payment].to_f.round(2)

    if request.post?
      begin
        @schedule = send("simulate_#{params[:simulate]}")
      rescue => e
        # raise @last_schedule.inspect
        raise e.backtrace.join("<br/>")
      end
    end
  end

  def simulate_repayment_schedule
    depreciation_schedule = []

    capital = @capital
    deprecated = 0.0

    @monthly_payment = @capital * @monthy_rate / (1 - (1 + @monthy_rate) ** (@months * -1))
    @mortgage_cost = 0.0

    @months.times do |month|
      interest     = (capital * @monthy_rate)
      depreciation = @monthly_payment - interest
      capital      = capital - depreciation
      deprecated  += depreciation

      @mortgage_cost += interest

      depreciation_schedule << {
        :year         => month / 12,
        :month        => month,
        :payment      => @monthly_payment,
        :interest     => interest,
        :depreciation => depreciation,
        :capital      => capital,
        :deprecated   => deprecated
      }
    end

    depreciation_schedule_per_year(depreciation_schedule)
  end

  def simulate_borrowable_capital
    depreciation_schedule = []

    @capital = @monthly_payment * (1 - (1 + @monthy_rate) ** (@months * -1)) / @monthy_rate

    capital = @capital
    deprecated = 0.0

    @mortgage_cost = 0.0

    @months.times do |month|
      interest     = (capital * @monthy_rate)
      depreciation = @monthly_payment - interest
      capital      = capital - depreciation
      deprecated  += depreciation

      @mortgage_cost += interest

      depreciation_schedule << {
        :year         => month / 12,
        :month        => month,
        :payment      => @monthly_payment,
        :interest     => interest,
        :depreciation => depreciation,
        :capital      => capital,
        :deprecated   => deprecated
      }
    end

    depreciation_schedule_per_year(depreciation_schedule)
  end

  def simulate_mortgage_duration
    depreciation_schedule = []

    capital = @capital
    deprecated = 0.0
    month = 0

    @mortgage_cost = 0.0

    while capital.round(2) > 0 do
      payment      = [capital, @monthly_payment].min
      interest     = (capital * @monthy_rate)
      depreciation = payment - interest
      capital      = capital - depreciation
      deprecated  += depreciation

      @mortgage_cost += interest

      depreciation_schedule << {
        :year         => month / 12,
        :month        => month,
        :payment      => payment,
        :interest     => interest,
        :depreciation => depreciation,
        :capital      => capital,
        :deprecated   => deprecated
      }

      month += 1
    end

    depreciation_schedule_per_year(depreciation_schedule)
    # depreciation_schedule
  end

  def depreciation_schedule_per_year(schedule_per_month)
    schedule_per_month.inject([]) do |schedule, depreciation|
      year = depreciation[:year]

      schedule[year] ||= { :payment => 0.0, :interest => 0.0, :depreciation => 0.0, :capital => 0.0, :deprecated => 0.0 }

      @last_depreciation = depreciation
      @last_schedule = schedule

      schedule[year] = {
        :year         => year,
        :payment      => depreciation[:payment] + schedule[year][:payment],
        :interest     => depreciation[:interest] + schedule[year][:interest],
        :depreciation => depreciation[:depreciation] + schedule[year][:depreciation],
        :deprecated   => depreciation[:deprecated],
        :capital      => depreciation[:capital]
      }

      schedule
    end
  end
end