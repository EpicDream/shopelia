class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body , :flinker , :created_at

  def flinker
    FlinkerSerializer.new(object.flinker).as_json[:flinker]
  end

  def created_at
    object.created_at.to_i
  end

end