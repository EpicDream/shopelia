class Viking::ProductSerializer < ActiveModel::Serializer
  attributes :id, :url, :merchant_id, :batch_mode

  def batch_mode
    object.events.order(:created_at).last.try(:action) == Event::REQUEST
  end
end