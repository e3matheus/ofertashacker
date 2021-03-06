require "twitter"

class Job < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  belongs_to :company
  has_and_belongs_to_many :required_skills

  accepts_nested_attributes_for :required_skills

  validates_presence_of :company_id, :title, :description, :city
  validates_presence_of :at_least_one_type
  validate :extra_skill, :length => {:maximum => 140}

  FILTERS = %w{full_time part_time flexible remote}
  after_create :post_twitter

  metropoli_for :city

  scope   :ordered, order('id DESC')

  def post_twitter
    if Rails.env == 'production'
      url = $bitly.shorten("http://www.ofertashacker.com/jobs/#{self.id}")
      tweet_message = truncate("#{self.company.title}: #{self.title}", :length => 115 )
      Twitter.update("#{tweet_message} #{url.short_url}")
    end
  end

  def self.filter_it(filters={}, company=nil)
    results = Job.includes(:company)
    unless filters.blank?
      results = results.where(FILTERS.collect do |filter|
        %|jobs.#{filter} = 't'| if eval(filters[filter.to_sym]) 
      end.compact.join(' OR '))
    end
    results
  end

  def to_param
    "#{self.id}-#{self.title.parameterize}"
  end

  def at_least_one_type
    full_time || part_time || remote || flexible
  end

  def format_extra_skills
    extra_skill.split(',')
  end

  def formated_description
    self.description.gsub(/^h2\./,'h3.').gsub(/^h1\./,'h2.')
  end

  def latest_required_skills
    required_skills.all(:limit => 4, :order => "id desc" )
  end
  
  def self.no_repeat(jobs=[])
    unless jobs.blank? 
      where(sanitize_sql("jobs.id NOT IN (#{jobs.join(',')})"))
    end
  end

  def to_s
    title
  end

end
