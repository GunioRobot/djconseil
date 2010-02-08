class MortgageSimulatorPortlet < Portlet
  render_inline false
  
  def render
    @capital         = params[:capital].to_f
    @years           = params[:years].to_i
    @months          = @years * 12
    @yearly_rate     = params[:interest_rate].to_f / 100
    @monthy_rate     = @yearly_rate / 12
    @monthly_payment = params[:monthly_payment].to_f
    
    if request.post?
      @schedule = send("simulate_#{params[:simulate]}")
    end
  end
  
  def simulate_repayment_schedule
    depreciation_schedule_per_month = []
    depreciation_schedule_per_year  = []
    
    capital = @capital
    
    @monthly_payment = ((@capital * @monthy_rate) / (1 - (1 + @monthy_rate) ** (@months * -1)))
    
    yearly_interest = 0.0
    yearly_depreciation = 0.0
    
    @months.times do |month|
      if month % 12 == 0 && month / 12 > 0
        depreciation_schedule_per_year << {
          :year         => month / 12,
          :payment      => @monthly_payment * 12,
          :interest     => yearly_interest,
          :depreciation => yearly_depreciation,
          :capital      => capital
        }
        
        yearly_interest = 0.0
        yearly_depreciation = 0.0
      end
      
      interest     = (capital * @monthy_rate)
      depreciation = @monthly_payment - interest
      capital      = capital - depreciation
      
      yearly_interest     += interest
      yearly_depreciation += depreciation
      
      depreciation_schedule_per_month << {
        :year         => month / 12,
        :month        => month,
        :payment      => @monthly_payment,
        :interest     => interest,
        :depreciation => depreciation,
        :capital      => capital
      }
    end
    
    depreciation_schedule_per_year << {
      :year         => @years,
      :payment      => @monthly_payment * 12,
      :interest     => yearly_interest,
      :depreciation => yearly_depreciation,
      :capital      => capital
    }
    
    depreciation_schedule_per_year
  end
  
  def simulate_borrowable_capital
    
  end
  
  def simulate_mortgage_duration
    
  end
end