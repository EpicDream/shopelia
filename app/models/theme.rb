class Theme < ActiveRecord::Base
  COVER_HEIGHT_HIGH = 200
  COVER_HEIGHT_LOW = 120
  FONTS = YAML.load_file("#{Rails.root}/db/ios-fonts.yml")
  SIZES = (10..30).step(2).to_a
  DEFAULT_FONT = 'HelveticaNeue'
  
  acts_as_list
  
  attr_accessible :rank, :published, :position, :cover_height, :dev_publication, :series
  attr_accessible :title, :en_title, :subtitle, :en_subtitle
  attr_accessible :theme_cover_attributes, :hashtags_attributes, :country_ids
  attr_accessor :theme_cover_attributes
  
  has_and_belongs_to_many :looks
  has_and_belongs_to_many :flinkers
  has_and_belongs_to_many :hashtags
  has_and_belongs_to_many :countries
  has_one :theme_cover, foreign_key: :resource_id, dependent: :destroy
  
  before_create :assign_default_cover, unless: -> { self.theme_cover }
  before_create :assign_series
  before_validation :find_or_create_hashtag
  after_update :update_cover_heights, if: -> { self.position_changed? || self.series_changed? }
  after_create :update_cover_heights
  
  accepts_nested_attributes_for :theme_cover
  accepts_nested_attributes_for :hashtags, allow_destroy: true, reject_if: ->(attributes) { attributes['name'].blank? }
  
  scope :published, ->(published) { 
    where(published:published, dev_publication:false)
  }
  scope :of_series, ->(series) {
    series ||= Theme.last_series
    where(series:series)
  }
  scope :pre_published, -> { where(dev_publication:true) }
  scope :pre_published_or_published, -> { where('dev_publication = ? or published = ?', true, true) }
  scope :for_country, -> (country) {
    return unless country
    joins('left outer join countries_themes on countries_themes.theme_id = themes.id').
    where("not exists(select id from countries_themes where theme_id = themes.id) or countries_themes.country_id = #{country.id}")
  }
  
  #NOTE:uniq => true seems not work on many to many with rails 3, so we use uniq index
  def append_look look
    self.looks << look rescue PG::UniqueViolation 
  end
  
  def remove_look look
    self.looks.destroy(look)
  end
  
  def looks_of_flinker flinker
    looks.where(flinker_id: flinker.id)
  end
  
  def medaillon
    looks.first && looks.last.look_images.first && looks.last.look_images.first.picture.url(:small)
  end
  
  def append_flinker flinker
    self.flinkers << flinker rescue PG::UniqueViolation
  end
  
  def remove_flinker flinker
    self.flinkers.destroy(flinker)
  end
  
  def title_for_display lang=nil
    attribute = lang ? "#{lang}_title" : :title
    title_string_for_display(attribute)
  end
  
  def subtitle_for_display lang=nil
    attribute = lang ? "#{lang}_subtitle" : :subtitle
    title_string_for_display(attribute)
  end
  
  def title_for_ios lang=nil, default_font=false
    title = (lang == :en && !title_for_display(:en).blank?) ? self.en_title : self.title
    default_font ? convert_font(title) : title
  end
  
  def subtitle_for_ios lang=nil, default_font=false
    title = (lang == :en && !subtitle_for_display(:en).blank?) ? self.en_subtitle : self.subtitle
    default_font ? convert_font(title) : title
  end
  
  def self.last_series
    theme = Theme.order('series desc').first
    theme ? theme.series : 0
  end
  
  private
  
  def convert_font title
    non_helvetica_fonts = title.scan(/font='(.*?)'/).flatten.select { |font| font !~ /HelveticaNeue/ }
    non_helvetica_fonts.inject(title) { |new_title, font| 
      new_title = new_title.gsub(/#{font}/, DEFAULT_FONT)
    }
  end
  
  def update_cover_heights
    themes = Theme.of_series(self.series).order('position asc')
    themes.update_all(cover_height:COVER_HEIGHT_LOW)
    themes.first.update_attributes(cover_height:COVER_HEIGHT_HIGH)
  end
  
  def assign_series
    self.series = Theme.last_series 
  end
  
  def title_string_for_display attribute
    title = send(attribute)
    title.scan(/<style\s.*?>(.*?)<\/style>/).flatten.join.gsub(/<!\[CDATA\[|\]\]>/, '') if title
  end
  
  def find_or_create_hashtag
    self.hashtags = self.hashtags.map { |hashtag|  
      if hashtag.new_record?
        Hashtag.find_by_name(hashtag.name) || hashtag
      else
        hashtag
      end
    }
  end
  
  def assign_default_cover
    self.theme_cover = ThemeCover.default.dup
    self.theme_cover.save!
  end
  
end