module Push

  def self.send_message message
    return unless message.device.push_token.present?
    if Rails.env.test?
      $push_delivery_count += 1
    else
      GCM.send_notification message.device.push_token, message.as_push
    end
  end
end
