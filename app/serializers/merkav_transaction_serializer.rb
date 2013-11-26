class MerkavTransactionSerializer < ActiveModel::Serializer
  include ActiveModelSerializerExtension::JsonWithoutNilKeys

  attributes :id, :status, :amount, :vad_id, :executed_at, :created_at, :merkav_transaction_id

  def created_at
    object.created_at.to_i
  end

  def executed_at
    object.executed_at ? object.executed_at.to_i : nil
  end
end