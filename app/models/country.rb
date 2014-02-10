class Country < ActiveRecord::Base
  has_many :addresses
  has_many :states
  has_many :users
  has_many :flinkers
  
  attr_accessible :id, :name, :iso
  
  def i18n_locale #TODO : add column i18n_locale and set it in database
    case iso
    when 'US' then  :'en'
    when 'GB' then :'en'
    else iso.downcase.to_sym
    end
  end
  
end
