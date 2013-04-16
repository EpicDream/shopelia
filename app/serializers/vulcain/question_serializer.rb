class Vulcain::QuestionSerializer < ActiveModel::Serializer
  attributes :question_id, :answer
  
  def question_id
    object.id
  end
end
