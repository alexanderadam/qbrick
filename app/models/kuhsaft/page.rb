class Kuhsaft::Page < ActiveRecord::Base
  include Kuhsaft::Orderable
  include Kuhsaft::Translatable
  include Kuhsaft::BrickList
  include Kuhsaft::Searchable

  has_ancestry
  acts_as_brick_list

  translate :title, :slug, :keywords, :description, :body, :redirect_url, :url, :fulltext
  attr_accessible :title, :slug, :redirect_url, :url, :page_type, :parent_id, :keywords, :description, :published

  default_scope order('position ASC')

  scope :published, where(:published => Kuhsaft::PublishState::PUBLISHED)
  scope :content_page, where(:page_type => Kuhsaft::PageType::CONTENT)
  scope :navigation, lambda{ |slug| where(locale_attr(:slug) => slug).where(locale_attr(:page_type) => Kuhsaft::PageType::NAVIGATION) }

  before_validation :create_slug, :create_url

  before_validation :collect_fulltext do
    self.fulltext = collect_fulltext
  end

  validates :title, :presence => true
  validates :slug, :presence => true
  validates :redirect_url, :presence => true, :if => :redirect?

  class << self
    def flat_tree(pages = nil)
      arrange_as_array
    end

    def arrange_as_array(options={}, hash=nil)
      hash ||= arrange(options)

      arr = []
      hash.each do |node, children|
        arr << node
        arr += arrange_as_array(options, children) unless children.empty?
      end

      arr
    end
  end

  def without_self
    Kuhsaft::Page.where('id != ?', self.id)
  end

  def published?
    published == Kuhsaft::PublishState::PUBLISHED
  end

  def state_class
    if published?
      'published'
    else
      'unpublished'
    end
  end

  def redirect?
    page_type == Kuhsaft::PageType::REDIRECT
  end

  def navigation?
    page_type == Kuhsaft::PageType::NAVIGATION
  end

  def parent_pages
    ancestors
  end

  def link
    if bricks.count == 0 && children.count > 0
      children.first.link
    else
      "/#{url}"
    end
  end

  def create_url
    complete_slug = ''
    if parent.present?
      complete_slug << parent.url.to_s
    else
      complete_slug = "#{I18n.locale}"
    end
    complete_slug << "/#{self.slug}" unless navigation?
    self.url = complete_slug
  end

  def create_slug
    has_slug = title.present? && slug.blank?
    self.slug = title.downcase.parameterize if has_slug
  end

  def nesting_name
    num_dashes = parent_pages.size
    num_dashes = 0 if num_dashes < 0
    "#{'-' * num_dashes} #{self.title}".strip
  end

  def brick_list_type
    'Kuhsaft::Page'
  end

  def to_style_class
    'kuhsaft-page'
  end

  def allowed_brick_types
    Kuhsaft::BrickType.enabled.pluck(:class_name) - ['Kuhsaft::AccordionItemBrick']
  end
end
