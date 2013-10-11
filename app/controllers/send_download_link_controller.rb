class SendDownloadLinkController <  ApplicationController
  before_filter :prepare_message
  before_filter :prepare_data

  def create
    if @phone
      response = NexmoGateway.new.send_sms(@phone, @message)
      respond_to do |format|
        if Rails.env.test? || response.ok?
          format.js { render "sms_success" }
        else
          format.js { render "sms_error" }
        end
      end
    elsif @email
      Emailer.send_user_download_link(@email).deliver
      respond_to do |format|
        format.js { render "email" }
      end
    else
      respond_to do |format|
        format.js { render "error" }
      end
    end
  end

  private

  def prepare_message
    @message = I18n.t('app.public.download.sms_message', { url:download_url })
  end

  def prepare_data
    data = params[:data]
    if data =~ /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$/i
      @email = data
    elsif data =~ /^((\+\d{1,3}(-| )?\(?\d\)?(-| )?\d{1,5})|(\(?\d{2,6}\)?))(-| )?(\d{3,4})(-| )?(\d{4})(( x| ext)\d{1,5}){0,1}$/
      @phone = data
      if data[0] == "+" || data[0..1] == "00"
        @phone = data
      elsif ["06","07"].include?(data[0..1])
        @phone = "0033" + data[1..-1]
      end
    end
  end
end
