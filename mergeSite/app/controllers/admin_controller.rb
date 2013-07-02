class AdminController < ActionController::Base
  http_basic_authenticate_with :name => "admin", :password => "secret4shane"
  protect_from_forgery
  layout 'application'

  def home
    @new_attr = MbkAttribute.new
    @logs = Log.first(100)
    if params[:attr_name]
      @new_attr = MbkAttribute.new :name => params[:attr_name].downcase.gsub(/\s/,'_')
      if @new_attr.save
        flash.alert = "New Attribute #{@new_attr.name} Created"
        @new_attr = MbkAttribute.new
      else
        flash.alert = @new_attr.errors.full_messages.join(', ')
      end
    elsif params[:delete]
      MbkAttribute.find_by_name(params[:delete]).delete
      flash.alert = "Removed #{params[:delete]}..."
    end
  end

  def run_script
    script = ScriptRunner.find(params[:id])
    if system("cd /home/jason/MBK; ./" + script.name + " &")
      flash.alert = "Started #{script.name}."
    else
      flash.alert = "#{script.name} did not run."
    end
    redirect_to "/admin"
  end
end
