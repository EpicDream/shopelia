module Push

  def self.send_message message
    return unless message.device.push_token.present?
    if Rails.env.test?
      $push_delivery_count += 1
    elsif Rails.env.production?
      GCM.send_notification message.device.push_token, {
        type:'Georges',
        message:message.content,
        products:message.build_push_data,
        notification:message.autoreply.present? ? 0 : 1
      }
    end
  end
end
