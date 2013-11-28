class MerkavTransactionSerializer < ActiveModel::Serializer

  attributes :id, :status, :amount, :vad_id, :executed_at, :created_at, :merkav_transaction_id, :cvv_number

  def cvv_number
    if object.virtual_card.present?
      number = object.virtual_card.number
      "#{number[0]}XXXXXXXXXXX#{number[12..15]}"
    else
      nil
    end
  end

  def created_at
    object.created_at.to_i
  end

  def executed_at
    object.executed_at ? object.executed_at.to_i : nil
  end
end